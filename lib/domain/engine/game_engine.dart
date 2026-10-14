import 'dart:math';
import 'package:uuid/uuid.dart';
import '../models/clue.dart';
import '../models/game_state.dart';
import '../models/player.dart';
import '../models/tile.dart';

class GameEngine {
  static const _uuid = Uuid();

  /// Creates a new game adhering to the official Got Five! setup:
  /// - 2 to 4 players
  /// - Each player gets 1 random tile of each of the 5 colors, sorted in ascending order.
  /// - 5 tiles (1 of each color) are placed face-up in the central pool.
  /// - The remaining tiles form the color-segregated reserve supply.
  static GameState createGame({
    required List<PlayerConfig> playerConfigs,
    Random? random,
  }) {
    if (playerConfigs.length < 2 || playerConfigs.length > 4) {
      throw ArgumentError('Got Five! requires between 2 and 4 players.');
    }

    final rng = random ?? Random();

    // Group all 60 tiles by color and shuffle each color independently
    final reserveByColor = <TileColor, List<Tile>>{};
    for (final color in TileColor.values) {
      final colorTiles = Tile.tilesForColor(color);
      colorTiles.shuffle(rng);
      reserveByColor[color] = colorTiles;
    }

    // Deal 1 tile of each color to each player
    final players = <Player>[];
    for (final config in playerConfigs) {
      final rack = <Tile>[];
      for (final color in TileColor.values) {
        final dealtTile = reserveByColor[color]!.removeLast();
        rack.add(dealtTile);
      }
      // Strictly sort the player's rack in ascending order of tile number
      rack.sort((a, b) => a.number.compareTo(b.number));

      players.add(Player(
        id: config.id,
        name: config.name,
        isAi: config.isAi,
        aiDifficulty: config.aiDifficulty,
        rack: rack,
        preferredLocale: config.preferredLocale,
      ));
    }

    // Create the starting common pool: 1 tile of each color drawn from reserve
    final pool = <Tile>[];
    for (final color in TileColor.values) {
      final poolTile = reserveByColor[color]!.removeLast();
      pool.add(poolTile);
    }
    // Sort pool by color or number for clean display
    pool.sort((a, b) => a.number.compareTo(b.number));

    return GameState(
      gameId: _uuid.v4(),
      players: players,
      activePlayerIndex: 0,
      pool: pool,
      reserveByColor: reserveByColor,
      phase: GamePhase.revealingTile,
      gameLog: ['Game started with ${players.length} players.'],
    );
  }

  /// Step 1 of Turn: REVEAL A TILE
  /// Draw 1 tile from the reserve of the chosen color and add it to the common pool.
  ///
  /// Digital Edge Case Documentation:
  /// If the chosen color has no tiles left in the reserve, the player must pick an
  /// available color. If all colors in reserve are exhausted, this step is automatically
  /// skipped and the player directly selects a clue from the existing 5 pool tiles.
  static GameState revealTile(
    GameState state,
    TileColor color, {
    Random? random,
  }) {
    if (state.isGameOver) {
      throw StateError('Cannot make a move in a finished game.');
    }
    if (state.phase != GamePhase.revealingTile) {
      throw StateError('Invalid phase: expected revealingTile but was ${state.phase}.');
    }

    final rng = random ?? Random();

    // Check if entire reserve is empty
    if (state.totalReserveCount == 0) {
      return state.copyWith(
        phase: GamePhase.askingClue,
        clearJustRevealedTile: true,
        gameLog: [
          ...state.gameLog,
          '${state.activePlayer.name}: Reserve is empty. Proceeding to ask for a clue with existing pool.',
        ],
      );
    }

    final colorReserve = state.reserveByColor[color];
    if (colorReserve == null || colorReserve.isEmpty) {
      throw ArgumentError(
        'The reserve for color ${color.englishName} is depleted. Please choose an available color.',
      );
    }

    // Draw random tile of this color
    final newReserve = Map<TileColor, List<Tile>>.from(state.reserveByColor);
    final updatedList = List<Tile>.from(colorReserve);
    final revealedIndex = rng.nextInt(updatedList.length);
    final revealedTile = updatedList.removeAt(revealedIndex);
    newReserve[color] = updatedList;

    // Add revealed tile to the common pool (now 6 tiles)
    final newPool = List<Tile>.from(state.pool)..add(revealedTile);
    newPool.sort((a, b) => a.number.compareTo(b.number));

    final actor = state.activePlayer;
    final actorLabel = actor.isAi ? 'Computer' : actor.name;
    final revealedMessage = '$actorLabel revealed ${revealedTile.number}';

    return state.copyWith(
      pool: newPool,
      reserveByColor: newReserve,
      phase: GamePhase.askingClue,
      justRevealedTile: revealedTile,
      lastRevealedTile: revealedTile,
      lastRevealedMessage: revealedMessage,
      lastRevealedPlayerName: actor.name,
      lastRevealedPlayerIsAi: actor.isAi,
      lastRevealedPlayerIndex: state.activePlayerIndex,
      gameLog: [
        ...state.gameLog,
        '${state.activePlayer.name} revealed tile #${revealedTile.number} (${revealedTile.color.englishName}).',
      ],
    );
  }

  /// Returns all tile numbers currently visible to [viewingPlayerIndex].
  /// Includes:
  /// - Opponents' visible rack tiles (never the viewing player's own hidden rack).
  /// - All face-up tiles currently in the shared pool.
  /// - All clue tiles across all players' public clue areas.
  /// - Any face-up tile that was just revealed or recorded as last revealed.
  /// Unrevealed reserve tiles and the viewing player's own hidden rack are NEVER marked.
  static Set<int> getRevealedNumbersForPlayer(
    GameState state,
    int viewingPlayerIndex,
  ) {
    final revealed = <int>{};

    // 1. All opponents' rack tiles
    for (int i = 0; i < state.players.length; i++) {
      if (i != viewingPlayerIndex) {
        for (final tile in state.players[i].rack) {
          if (!tile.isHidden) {
            revealed.add(tile.number);
          }
        }
      }
    }

    // 2. All shared pool tiles
    for (final tile in state.pool) {
      if (!tile.isHidden) {
        revealed.add(tile.number);
      }
    }

    // 3. Every player's public clue area
    for (final player in state.players) {
      for (final clue in player.cluesReceived) {
        if (!clue.tile.isHidden) {
          revealed.add(clue.tile.number);
        }
      }
    }

    // 4. Just-revealed tile or last-revealed tile if visible
    if (state.justRevealedTile != null && !state.justRevealedTile!.isHidden) {
      revealed.add(state.justRevealedTile!.number);
    }

    return revealed;
  }

  /// Step 2 of Turn: ASK FOR A CLUE (SORT)
  /// Places [poolTile] in relation to the active player's 5 hidden rack tiles.
  /// Slot 0: < rack[0]
  /// Slot 1: rack[0] < tile < rack[1]
  /// Slot 2: rack[1] < tile < rack[2]
  /// Slot 3: rack[2] < tile < rack[3]
  /// Slot 4: rack[3] < tile < rack[4]
  /// Slot 5: > rack[4]
  ///
  /// The tile is transferred from the pool to the player's clue area (visible to all).
  static GameState askSortClue(GameState state, Tile poolTile) {
    if (state.isGameOver) {
      throw StateError('Cannot make a move in a finished game.');
    }
    if (state.phase != GamePhase.askingClue) {
      throw StateError('Invalid phase: expected askingClue but was ${state.phase}.');
    }
    if (!state.pool.contains(poolTile)) {
      throw ArgumentError('Tile #${poolTile.number} is not in the pool.');
    }

    final player = state.activePlayer;
    final slotIndex = player.calculateSortSlot(poolTile);

    final clue = SortClue(
      id: _uuid.v4(),
      tile: poolTile,
      targetPlayerIndex: state.activePlayerIndex,
      slotIndex: slotIndex,
    );

    // Remove tile from pool
    final newPool = List<Tile>.from(state.pool)..remove(poolTile);

    // Update active player's clues
    final updatedPlayer = player.copyWith(
      cluesReceived: [...player.cluesReceived, clue],
    );

    final updatedPlayers = List<Player>.from(state.players);
    updatedPlayers[state.activePlayerIndex] = updatedPlayer;

    final logMsg =
        '${player.name} took tile #${poolTile.number} as SORT clue -> slot $slotIndex.';

    return _advanceToNextTurn(
      state.copyWith(
        players: updatedPlayers,
        pool: newPool,
        clearJustRevealedTile: true,
        gameLog: [...state.gameLog, logMsg],
      ),
    );
  }

  /// Step 2 of Turn: ASK FOR A CLUE (COMPARE)
  /// Compares [poolTile]'s dots with the dots on the active player's hidden rack tile at [targetSlotIndex] (0 to 4).
  /// Yields true (YES) or false (NO).
  ///
  /// The tile is transferred from the pool to the player's clue area (visible to all).
  static GameState askCompareClue(
    GameState state,
    Tile poolTile,
    int targetSlotIndex,
  ) {
    if (state.isGameOver) {
      throw StateError('Cannot make a move in a finished game.');
    }
    if (state.phase != GamePhase.askingClue) {
      throw StateError('Invalid phase: expected askingClue but was ${state.phase}.');
    }
    if (!state.pool.contains(poolTile)) {
      throw ArgumentError('Tile #${poolTile.number} is not in the pool.');
    }
    if (targetSlotIndex < 0 || targetSlotIndex > 4) {
      throw ArgumentError('targetSlotIndex must be between 0 and 4.');
    }

    final player = state.activePlayer;
    final match = player.calculateCompareDots(poolTile, targetSlotIndex);

    final clue = CompareClue(
      id: _uuid.v4(),
      tile: poolTile,
      targetPlayerIndex: state.activePlayerIndex,
      targetSlotIndex: targetSlotIndex,
      match: match,
    );

    // Remove tile from pool
    final newPool = List<Tile>.from(state.pool)..remove(poolTile);

    // Update player clues
    final updatedPlayer = player.copyWith(
      cluesReceived: [...player.cluesReceived, clue],
    );

    final updatedPlayers = List<Player>.from(state.players);
    updatedPlayers[state.activePlayerIndex] = updatedPlayer;

    final targetColor = player.rack[targetSlotIndex].color.englishName;
    final logMsg =
        '${player.name} compared tile #${poolTile.number} (${poolTile.dots} dots) with their $targetColor tile (slot $targetSlotIndex) -> ${match ? "YES" : "NO"}.';

    return _advanceToNextTurn(
      state.copyWith(
        players: updatedPlayers,
        pool: newPool,
        clearJustRevealedTile: true,
        gameLog: [...state.gameLog, logMsg],
      ),
    );
  }

  /// "GOT FIVE!" DECLARATION (Guess)
  /// A player guesses the 5 numbers on their rack in strictly ascending order.
  /// Exactly one attempt per game.
  /// Correct -> Player wins immediately!
  /// Incorrect -> Player is eliminated immediately.
  /// If all opponents are eliminated, the remaining player wins automatically.
  static GameState declareGotFive(
    GameState state,
    int playerIndex,
    List<int> guessedNumbers,
  ) {
    if (state.isGameOver) {
      throw StateError('Cannot declare Got Five in a finished game.');
    }
    if (playerIndex < 0 || playerIndex >= state.players.length) {
      throw ArgumentError('Invalid player index: $playerIndex.');
    }

    final player = state.players[playerIndex];
    if (player.isEliminated) {
      throw StateError('Eliminated player cannot declare Got Five.');
    }
    if (player.hasGuessed) {
      throw StateError('Player ${player.name} has already made their guess attempt.');
    }
    if (guessedNumbers.length != 5) {
      throw ArgumentError('A Got Five declaration must contain exactly 5 numbers.');
    }

    // Verify strictly ascending order
    for (int i = 0; i < 4; i++) {
      if (guessedNumbers[i] >= guessedNumbers[i + 1]) {
        throw ArgumentError('Guessed numbers must be in strictly ascending order.');
      }
    }

    final actualNumbers = player.rack.map((t) => t.number).toList();
    bool isCorrect = true;
    for (int i = 0; i < 5; i++) {
      if (actualNumbers[i] != guessedNumbers[i]) {
        isCorrect = false;
        break;
      }
    }

    final updatedPlayers = List<Player>.from(state.players);

    if (isCorrect) {
      // Victory!
      updatedPlayers[playerIndex] = player.copyWith(
        hasGuessed: true,
        isWinner: true,
        submittedGuess: guessedNumbers,
      );

      return state.copyWith(
        players: updatedPlayers,
        phase: GamePhase.gameOver,
        winnerIndex: playerIndex,
        winnerReason: '${player.name} correctly guessed their 5 numbers: $guessedNumbers!',
        gameLog: [
          ...state.gameLog,
          '🎉 ${player.name} announced "GOT FIVE!" with $guessedNumbers and WON the game!',
        ],
      );
    } else {
      // Elimination!
      updatedPlayers[playerIndex] = player.copyWith(
        hasGuessed: true,
        isEliminated: true,
        submittedGuess: guessedNumbers,
      );

      final nonEliminated = updatedPlayers.where((p) => !p.isEliminated).toList();
      final logMsg =
          '❌ ${player.name} announced "GOT FIVE!" with $guessedNumbers which was incorrect and is ELIMINATED!';

      if (nonEliminated.length == 1) {
        // Last player standing wins!
        final winner = nonEliminated.first;
        final winnerIdx = updatedPlayers.indexOf(winner);
        updatedPlayers[winnerIdx] = winner.copyWith(isWinner: true);

        return state.copyWith(
          players: updatedPlayers,
          phase: GamePhase.gameOver,
          winnerIndex: winnerIdx,
          winnerReason: '${winner.name} won as the last remaining player!',
          gameLog: [
            ...state.gameLog,
            logMsg,
            '🏆 ${winner.name} wins by elimination of all opponents!',
          ],
        );
      }

      // If active player was eliminated, advance turn
      final nextState = state.copyWith(
        players: updatedPlayers,
        gameLog: [...state.gameLog, logMsg],
      );

      if (state.activePlayerIndex == playerIndex) {
        return _advanceToNextTurn(nextState);
      }
      return nextState;
    }
  }

  /// Advances turn to the next non-eliminated player.
  static GameState _advanceToNextTurn(GameState state) {
    if (state.isGameOver) return state;

    int nextIndex = (state.activePlayerIndex + 1) % state.players.length;
    int searchCount = 0;
    while (state.players[nextIndex].isEliminated && searchCount < state.players.length) {
      nextIndex = (nextIndex + 1) % state.players.length;
      searchCount++;
    }

    // Determine initial phase for next player based on reserve availability
    final nextPhase = (state.totalReserveCount == 0)
        ? GamePhase.askingClue
        : GamePhase.revealingTile;

    return state.copyWith(
      activePlayerIndex: nextIndex,
      phase: nextPhase,
      turnNumber: state.turnNumber + 1,
    );
  }
}

class PlayerConfig {
  final String id;
  final String name;
  final bool isAi;
  final AiDifficulty? aiDifficulty;
  final String? preferredLocale;

  const PlayerConfig({
    required this.id,
    required this.name,
    this.isAi = false,
    this.aiDifficulty,
    this.preferredLocale,
  });
}
