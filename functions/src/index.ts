import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();
const db = admin.firestore();

export type TileColor = 'green' | 'pink' | 'blue' | 'red' | 'yellow';

export interface ServerTile {
  number: number;
  color: TileColor;
  dots: number;
}

export function calculateDots(number: number): number {
  return Math.floor((number - 1) / 5) % 3 + 1;
}

export function colorForNumber(number: number): TileColor {
  switch (number % 5) {
    case 1: return 'green';
    case 2: return 'pink';
    case 3: return 'blue';
    case 4: return 'red';
    case 0:
    default: return 'yellow';
  }
}

export function generateAll60Tiles(): ServerTile[] {
  const tiles: ServerTile[] = [];
  for (let n = 1; n <= 60; n++) {
    tiles.push({
      number: n,
      color: colorForNumber(n),
      dots: calculateDots(n),
    });
  }
  return tiles;
}

/**
 * Server-authoritative Match Starter
 * Shuffles 60 tiles, deals 5 ascending tiles to each player,
 * and writes sanitized views so clients cannot snoop on their secret numbers.
 */
export const startOnlineMatch = functions.https.onCall(async (data, context) => {
  const { roomId } = data;
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated as guest or user.');
  }

  const roomRef = db.collection('rooms').doc(roomId);
  const roomSnap = await roomRef.get();
  if (!roomSnap.exists) {
    throw new functions.https.HttpsError('not-found', 'Room not found.');
  }

  const room = roomSnap.data()!;
  if (room.hostId !== context.auth.uid) {
    throw new functions.https.HttpsError('permission-denied', 'Only the room host can start the match.');
  }

  const players: { id: string; name: string }[] = room.players;
  if (players.length < 2 || players.length > 4) {
    throw new functions.https.HttpsError('invalid-argument', 'Got Five requires between 2 and 4 players.');
  }

  // Group tiles by color and shuffle
  const allTiles = generateAll60Tiles();
  const reserveByColor: { [key in TileColor]: ServerTile[] } = {
    green: allTiles.filter(t => t.color === 'green').sort(() => Math.random() - 0.5),
    pink: allTiles.filter(t => t.color === 'pink').sort(() => Math.random() - 0.5),
    blue: allTiles.filter(t => t.color === 'blue').sort(() => Math.random() - 0.5),
    red: allTiles.filter(t => t.color === 'red').sort(() => Math.random() - 0.5),
    yellow: allTiles.filter(t => t.color === 'yellow').sort(() => Math.random() - 0.5),
  };

  // Deal 1 tile of each color to each player
  const playerRacks: { [playerId: string]: ServerTile[] } = {};
  for (const p of players) {
    const rack: ServerTile[] = [
      reserveByColor.green.pop()!,
      reserveByColor.pink.pop()!,
      reserveByColor.blue.pop()!,
      reserveByColor.red.pop()!,
      reserveByColor.yellow.pop()!,
    ];
    // Sort strictly ascending
    rack.sort((a, b) => a.number - b.number);
    playerRacks[p.id] = rack;
  }

  // Draw 5 starting pool tiles
  const pool: ServerTile[] = [
    reserveByColor.green.pop()!,
    reserveByColor.pink.pop()!,
    reserveByColor.blue.pop()!,
    reserveByColor.red.pop()!,
    reserveByColor.yellow.pop()!,
  ].sort((a, b) => a.number - b.number);

  const gameId = `game_${roomId}_${Date.now()}`;
  const batch = db.batch();

  // 1. Authoritative secret state (Only Cloud Functions can read this)
  const secretGameRef = db.collection('games').doc(gameId).collection('secret').doc('master');
  batch.set(secretGameRef, {
    gameId,
    roomId,
    players,
    playerRacks,
    pool,
    reserveByColor,
    activePlayerIndex: 0,
    phase: 'revealingTile',
    cluesByPlayer: {},
    isGameOver: false,
    winnerId: null,
  });

  // 2. Sanitized client views for each player
  for (let i = 0; i < players.length; i++) {
    const p = players[i];
    const playerViewRef = db.collection('games').doc(gameId).collection('playerViews').doc(p.id);

    const visibleRacks: { [pId: string]: ServerTile[] } = {};
    for (const other of players) {
      if (other.id === p.id) {
        // MASK recipient's own rack: numbers and dots = 0
        visibleRacks[p.id] = playerRacks[p.id].map(t => ({
          number: 0,
          color: t.color,
          dots: 0,
        }));
      } else {
        // Opponents rack is visible
        visibleRacks[other.id] = playerRacks[other.id];
      }
    }

    batch.set(playerViewRef, {
      gameId,
      myPlayerId: p.id,
      players,
      visibleRacks,
      pool,
      reserveCounts: {
        green: reserveByColor.green.length,
        pink: reserveByColor.pink.length,
        blue: reserveByColor.blue.length,
        red: reserveByColor.red.length,
        yellow: reserveByColor.yellow.length,
      },
      activePlayerIndex: 0,
      phase: 'revealingTile',
      cluesByPlayer: {},
      isGameOver: false,
    });
  }

  batch.update(roomRef, {
    status: 'inGame',
    activeGameId: gameId,
  });

  await batch.commit();
  return { success: true, gameId };
});
