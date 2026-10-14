import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:got_five_app/domain/engine/game_engine.dart';
import 'package:got_five_app/domain/models/clue.dart';
import 'package:got_five_app/domain/models/game_state.dart';
import 'package:got_five_app/domain/models/player.dart';
import 'package:got_five_app/domain/models/tile.dart';

void main() {
  group('Tile Specification & Data Integrity', () {
    test('All 60 tiles are generated uniquely with numbers 1 to 60', () {
      final allTiles = Tile.all60Tiles;
      expect(allTiles.length, equals(60));

      final numbers = allTiles.map((t) => t.number).toSet();
      expect(numbers.length, equals(60));
      expect(numbers.first, equals(1));
      expect(numbers.last, equals(60));
    });

    test('Each of the 5 colors contains exactly 12 tiles matching official lists', () {
      final greenTiles = Tile.tilesForColor(TileColor.green).map((t) => t.number).toList();
      final pinkTiles = Tile.tilesForColor(TileColor.pink).map((t) => t.number).toList();
      final blueTiles = Tile.tilesForColor(TileColor.blue).map((t) => t.number).toList();
      final redTiles = Tile.tilesForColor(TileColor.red).map((t) => t.number).toList();
      final yellowTiles = Tile.tilesForColor(TileColor.yellow).map((t) => t.number).toList();

      expect(greenTiles, equals([1, 6, 11, 16, 21, 26, 31, 36, 41, 46, 51, 56]));
      expect(pinkTiles, equals([2, 7, 12, 17, 22, 27, 32, 37, 42, 47, 52, 57]));
      expect(blueTiles, equals([3, 8, 13, 18, 23, 28, 33, 38, 43, 48, 53, 58]));
      expect(redTiles, equals([4, 9, 14, 19, 24, 29, 34, 39, 44, 49, 54, 59]));
      expect(yellowTiles, equals([5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60]));
    });

    test('Tile dots formula works correctly and specifically Tile 38 has 2 dots', () {
      // 1-5: 1 dot
      for (int i = 1; i <= 5; i++) {
        expect(Tile.fromNumber(i).dots, equals(1), reason: 'Tile $i');
      }
      // 6-10: 2 dots
      for (int i = 6; i <= 10; i++) {
        expect(Tile.fromNumber(i).dots, equals(2), reason: 'Tile $i');
      }
      // 11-15: 3 dots
      for (int i = 11; i <= 15; i++) {
        expect(Tile.fromNumber(i).dots, equals(3), reason: 'Tile $i');
      }

      // USA Got Five Rule explicitly requires Tile 38 to have 2 dots
      final tile38 = Tile.fromNumber(38);
      expect(tile38.number, equals(38));
      expect(tile38.color, equals(TileColor.blue));
      expect(tile38.dots, equals(2));

      // Range 36-40 should all have 2 dots
      for (int i = 36; i <= 40; i++) {
        expect(Tile.fromNumber(i).dots, equals(2), reason: 'Tile $i');
      }
      // Range 56-60 should all have 3 dots
      for (int i = 56; i <= 60; i++) {
        expect(Tile.fromNumber(i).dots, equals(3), reason: 'Tile $i');
      }
    });

    test('Each color is paired with a distinctive accessibility shape symbol', () {
      expect(Tile.symbolForColor(TileColor.green), equals(TileShapeSymbol.triangle));
      expect(Tile.symbolForColor(TileColor.pink), equals(TileShapeSymbol.circle));
      expect(Tile.symbolForColor(TileColor.blue), equals(TileShapeSymbol.square));
      expect(Tile.symbolForColor(TileColor.red), equals(TileShapeSymbol.diamond));
      expect(Tile.symbolForColor(TileColor.yellow), equals(TileShapeSymbol.star));
    });
  });

  group('GameEngine Setup & Dealing', () {
    test('Game setup correctly deals 5 ascending tiles of distinct colors to each player', () {
      final configs = [
        const PlayerConfig(id: 'p1', name: 'Alice'),
        const PlayerConfig(id: 'p2', name: 'Bob'),
        const PlayerConfig(id: 'p3', name: 'Charlie'),
      ];

      final game = GameEngine.createGame(
        playerConfigs: configs,
        random: Random(42),
      );

      expect(game.players.length, equals(3));
      expect(game.pool.length, equals(5));

      // Verify each player rack
      for (final player in game.players) {
        expect(player.rack.length, equals(5));

        // Colors must all be distinct
        final colors = player.rack.map((t) => t.color).toSet();
        expect(colors.length, equals(5));

        // Must be in strictly ascending order
        for (int i = 0; i < 4; i++) {
          expect(player.rack[i].number < player.rack[i + 1].number, isTrue);
        }
      }

      // Starting pool has 1 of each color
      final poolColors = game.pool.map((t) => t.color).toSet();
      expect(poolColors.length, equals(5));

      // Total tiles distributed = 3 players * 5 + 5 pool + reserve = 60
      final allAssignedTiles = <Tile>[];
      for (final p in game.players) {
        allAssignedTiles.addAll(p.rack);
      }
      allAssignedTiles.addAll(game.pool);
      for (final reserveList in game.reserveByColor.values) {
        allAssignedTiles.addAll(reserveList);
      }

      expect(allAssignedTiles.length, equals(60));
      expect(allAssignedTiles.map((t) => t.number).toSet().length, equals(60));
    });

    test('Throws if less than 2 or more than 4 players', () {
      expect(
        () => GameEngine.createGame(playerConfigs: [
          const PlayerConfig(id: 'p1', name: 'One'),
        ]),
        throwsArgumentError,
      );

      expect(
        () => GameEngine.createGame(playerConfigs: List.generate(
          5,
          (i) => PlayerConfig(id: 'p$i', name: 'Player $i'),
        )),
        throwsArgumentError,
      );
    });
  });

  group('Turn Mechanics & Clue Calculations', () {
    test('Step 1: Revealing a tile draws 1 from reserve and expands pool to 6 tiles', () {
      final game = GameEngine.createGame(
        playerConfigs: [
          const PlayerConfig(id: 'p1', name: 'Alice'),
          const PlayerConfig(id: 'p2', name: 'Bob'),
        ],
        random: Random(100),
      );

      expect(game.phase, equals(GamePhase.revealingTile));
      expect(game.pool.length, equals(5));

      final reserveCountBefore = game.reserveByColor[TileColor.green]!.length;
      final stateAfterReveal = GameEngine.revealTile(game, TileColor.green);

      expect(stateAfterReveal.phase, equals(GamePhase.askingClue));
      expect(stateAfterReveal.pool.length, equals(6));
      expect(
        stateAfterReveal.reserveByColor[TileColor.green]!.length,
        equals(reserveCountBefore - 1),
      );
      expect(stateAfterReveal.justRevealedTile, isNotNull);
      expect(stateAfterReveal.justRevealedTile!.color, equals(TileColor.green));
    });

    test('Step 2: Asking for SORT clue calculates correct slot index (0..5) and shrinks pool to 5', () {
      // Create a deterministic rack for player: [10, 20, 30, 40, 50]
      final rack = [
        Tile.fromNumber(10), // yellow
        Tile.fromNumber(21), // green
        Tile.fromNumber(32), // pink
        Tile.fromNumber(43), // blue
        Tile.fromNumber(54), // red
      ];
      final player = Player(id: 'p1', name: 'TestPlayer', rack: rack);

      // Test slot 0: tile < 10
      expect(player.calculateSortSlot(Tile.fromNumber(5)), equals(0));
      // Test slot 1: 10 < tile < 21
      expect(player.calculateSortSlot(Tile.fromNumber(15)), equals(1));
      // Test slot 2: 21 < tile < 32
      expect(player.calculateSortSlot(Tile.fromNumber(25)), equals(2));
      // Test slot 3: 32 < tile < 43
      expect(player.calculateSortSlot(Tile.fromNumber(35)), equals(3));
      // Test slot 4: 43 < tile < 54
      expect(player.calculateSortSlot(Tile.fromNumber(45)), equals(4));
      // Test slot 5: tile > 54
      expect(player.calculateSortSlot(Tile.fromNumber(60)), equals(5));

      // Test full engine sort clue execution
      final initialGame = GameEngine.createGame(
        playerConfigs: [
          const PlayerConfig(id: 'p1', name: 'Alice'),
          const PlayerConfig(id: 'p2', name: 'Bob'),
        ],
        random: Random(123),
      );
      final revealedGame = GameEngine.revealTile(initialGame, TileColor.blue);
      final chosenPoolTile = revealedGame.pool.first;

      final afterClue = GameEngine.askSortClue(revealedGame, chosenPoolTile);

      expect(afterClue.pool.length, equals(5));
      expect(afterClue.pool.contains(chosenPoolTile), isFalse);
      expect(afterClue.players[0].cluesReceived.length, equals(1));

      final clue = afterClue.players[0].cluesReceived.first as SortClue;
      expect(clue.tile, equals(chosenPoolTile));
      expect(clue.slotIndex >= 0 && clue.slotIndex <= 5, isTrue);

      // Turn advances to Player 2
      expect(afterClue.activePlayerIndex, equals(1));
      expect(afterClue.phase, equals(GamePhase.revealingTile));
    });

    test('Step 2: Asking for COMPARE clue returns correct dot match (YES/NO)', () {
      final rack = [
        Tile.fromNumber(1),  // 1 dot
        Tile.fromNumber(7),  // 2 dots
        Tile.fromNumber(13), // 3 dots
        Tile.fromNumber(19), // 1 dot
        Tile.fromNumber(25), // 2 dots
      ];
      final player = Player(id: 'p1', name: 'DotTester', rack: rack);

      // Comparing against slot 0 (1 dot):
      expect(player.calculateCompareDots(Tile.fromNumber(2), 0), isTrue);  // Tile 2 has 1 dot -> MATCH
      expect(player.calculateCompareDots(Tile.fromNumber(8), 0), isFalse); // Tile 8 has 2 dots -> NO MATCH

      // Comparing against slot 1 (2 dots):
      expect(player.calculateCompareDots(Tile.fromNumber(8), 1), isTrue);  // MATCH
      expect(player.calculateCompareDots(Tile.fromNumber(14), 1), isFalse); // NO MATCH (3 dots vs 2 dots)

      // Test engine execution
      final game = GameEngine.createGame(
        playerConfigs: [
          const PlayerConfig(id: 'p1', name: 'Alice'),
          const PlayerConfig(id: 'p2', name: 'Bob'),
        ],
      );
      final revealed = GameEngine.revealTile(game, TileColor.red);
      final poolTile = revealed.pool.first;

      final afterCompare = GameEngine.askCompareClue(revealed, poolTile, 2);
      expect(afterCompare.pool.length, equals(5));
      expect(afterCompare.players[0].cluesReceived.length, equals(1));
      final clue = afterCompare.players[0].cluesReceived.first as CompareClue;
      expect(clue.tile, equals(poolTile));
      expect(clue.targetSlotIndex, equals(2));
      expect(clue.match, equals(game.players[0].rack[2].dots == poolTile.dots));
    });
  });

  group('Winning & Elimination Mechanics ("GOT FIVE!")', () {
    test('Correct guess wins the game immediately', () {
      final game = GameEngine.createGame(
        playerConfigs: [
          const PlayerConfig(id: 'p1', name: 'Alice'),
          const PlayerConfig(id: 'p2', name: 'Bob'),
        ],
      );

      final aliceRackNumbers = game.players[0].rack.map((t) => t.number).toList();
      final wonGame = GameEngine.declareGotFive(game, 0, aliceRackNumbers);

      expect(wonGame.isGameOver, isTrue);
      expect(wonGame.winnerIndex, equals(0));
      expect(wonGame.players[0].isWinner, isTrue);
      expect(wonGame.players[0].hasGuessed, isTrue);
    });

    test('Incorrect guess eliminates player and remaining player wins by elimination', () {
      final game = GameEngine.createGame(
        playerConfigs: [
          const PlayerConfig(id: 'p1', name: 'Alice'),
          const PlayerConfig(id: 'p2', name: 'Bob'),
        ],
      );

      // Guess wrong numbers
      final wrongGuess = [1, 2, 3, 4, 5];
      // Make sure it doesn't accidentally match alice's rack
      if (wrongGuess.join(',') == game.players[0].rack.map((t) => t.number).join(',')) {
        wrongGuess[4] = 6;
      }

      final afterGuess = GameEngine.declareGotFive(game, 0, wrongGuess);

      expect(afterGuess.players[0].isEliminated, isTrue);
      expect(afterGuess.players[0].hasGuessed, isTrue);
      // In a 2-player game, Alice elimination means Bob wins!
      expect(afterGuess.isGameOver, isTrue);
      expect(afterGuess.winnerIndex, equals(1));
      expect(afterGuess.players[1].isWinner, isTrue);
    });

    test('In a 3-player game, 1 wrong guess eliminates that player but game continues for other 2', () {
      final game = GameEngine.createGame(
        playerConfigs: [
          const PlayerConfig(id: 'p1', name: 'Alice'),
          const PlayerConfig(id: 'p2', name: 'Bob'),
          const PlayerConfig(id: 'p3', name: 'Charlie'),
        ],
      );

      final wrongGuess = [2, 4, 6, 8, 10];
      final afterGuess = GameEngine.declareGotFive(game, 0, wrongGuess);

      expect(afterGuess.players[0].isEliminated, isTrue);
      expect(afterGuess.isGameOver, isFalse);
      // Active player advances to Bob (index 1)
      expect(afterGuess.activePlayerIndex, equals(1));
    });

    test('Player cannot guess twice', () {
      final game = GameEngine.createGame(
        playerConfigs: [
          const PlayerConfig(id: 'p1', name: 'Alice'),
          const PlayerConfig(id: 'p2', name: 'Bob'),
          const PlayerConfig(id: 'p3', name: 'Charlie'),
        ],
      );

      final wrongGuess = [2, 4, 6, 8, 10];
      final afterGuess = GameEngine.declareGotFive(game, 0, wrongGuess);

      expect(
        () => GameEngine.declareGotFive(afterGuess, 0, [3, 5, 7, 9, 11]),
        throwsStateError,
      );
    });
  });

  group('Client Data Sanitization & Security', () {
    test('sanitizedForPlayer masks own rack numbers and dots but preserves colors, opponents unmasked', () {
      final game = GameEngine.createGame(
        playerConfigs: [
          const PlayerConfig(id: 'p1', name: 'Alice'),
          const PlayerConfig(id: 'p2', name: 'Bob'),
        ],
      );

      final aliceView = game.sanitizedForPlayer(0);

      // Alice's own rack numbers and dots must be 0 (masked)
      for (final tile in aliceView.players[0].rack) {
        expect(tile.number, equals(0));
        expect(tile.dots, equals(0));
        expect(tile.color, isNotNull); // Color is visible!
      }
      expect(aliceView.players[0].rackColors.length, equals(5));

      // Bob's rack numbers and dots must remain visible as per official rules
      for (final tile in aliceView.players[1].rack) {
        expect(tile.number, greaterThan(0));
        expect(tile.dots, greaterThan(0));
      }

      // Reserve tiles must be masked
      for (final entry in aliceView.reserveByColor.entries) {
        for (final t in entry.value) {
          expect(t.number, equals(0));
          expect(t.dots, equals(0));
        }
      }
    });

    test('JSON serialization and deserialization roundtrip maintains exact game state', () {
      final game = GameEngine.createGame(
        playerConfigs: [
          const PlayerConfig(id: 'p1', name: 'Alice'),
          const PlayerConfig(id: 'p2', name: 'Bob'),
        ],
      );
      final revealed = GameEngine.revealTile(game, TileColor.yellow);
      final json = revealed.toJson();
      final restored = GameState.fromJson(json);

      expect(restored.gameId, equals(revealed.gameId));
      expect(restored.pool.length, equals(revealed.pool.length));
      expect(restored.players.length, equals(revealed.players.length));
      expect(restored.phase, equals(revealed.phase));
      expect(restored.justRevealedTile?.number, equals(revealed.justRevealedTile?.number));
    });

    test('Digital edge case: empty reserve allows directly proceeding to asking clue', () {
      // Create a state where reserve is completely emptied
      final emptyReserveGame = GameState(
        gameId: 'empty_res',
        players: [
          Player(
            id: 'p1',
            name: 'P1',
            rack: [
              Tile.fromNumber(1),
              Tile.fromNumber(7),
              Tile.fromNumber(13),
              Tile.fromNumber(19),
              Tile.fromNumber(25),
            ],
          ),
          Player(
            id: 'p2',
            name: 'P2',
            rack: [
              Tile.fromNumber(6),
              Tile.fromNumber(12),
              Tile.fromNumber(18),
              Tile.fromNumber(24),
              Tile.fromNumber(30),
            ],
          ),
        ],
        activePlayerIndex: 0,
        pool: [
          Tile.fromNumber(31),
          Tile.fromNumber(32),
          Tile.fromNumber(33),
          Tile.fromNumber(34),
          Tile.fromNumber(35),
        ],
        reserveByColor: {for (final c in TileColor.values) c: <Tile>[]},
        phase: GamePhase.revealingTile,
      );

      expect(emptyReserveGame.totalReserveCount, equals(0));
      final nextState = GameEngine.revealTile(emptyReserveGame, TileColor.green);
      expect(nextState.phase, equals(GamePhase.askingClue));
      expect(nextState.pool.length, equals(5));
    });
  });
}
