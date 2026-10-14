import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:got_five_app/domain/ai/ai_player.dart';
import 'package:got_five_app/domain/ai/deduction_tracker.dart';
import 'package:got_five_app/domain/engine/game_engine.dart';
import 'package:got_five_app/domain/models/clue.dart';
import 'package:got_five_app/domain/models/game_state.dart';
import 'package:got_five_app/domain/models/player.dart';
import 'package:got_five_app/domain/models/tile.dart';

void main() {
  group('AI Deduction Tracker & Constraint Propagation', () {
    test('DeductionTracker eliminates numbers visible on opponents racks and pool', () {
      final game = GameEngine.createGame(
        playerConfigs: [
          const PlayerConfig(id: 'p1', name: 'Human'),
          const PlayerConfig(id: 'ai1', name: 'Bot', isAi: true, aiDifficulty: AiDifficulty.hard),
        ],
        random: Random(999),
      );

      final tracker = DeductionTracker.fromGameState(
        state: game,
        targetPlayerIndex: 1, // AI is player index 1
      );

      // Opponent's (Human's) rack tiles must NOT be present in AI's candidate sets
      for (final humanTile in game.players[0].rack) {
        for (final candidates in tracker.slotCandidates) {
          expect(candidates.contains(humanTile.number), isFalse);
        }
      }

      // Starting pool tiles must NOT be present in AI's candidate sets
      for (final poolTile in game.pool) {
        for (final candidates in tracker.slotCandidates) {
          expect(candidates.contains(poolTile.number), isFalse);
        }
      }
    });

    test('Applying SORT clue restricts slot bounds correctly', () {
      // Deterministic colors: [green, pink, blue, red, yellow]
      final tracker = DeductionTracker(
        rackColors: [
          TileColor.green,
          TileColor.pink,
          TileColor.blue,
          TileColor.red,
          TileColor.yellow,
        ],
        slotCandidates: [
          Tile.tilesForColor(TileColor.green).map((t) => t.number).toSet(),
          Tile.tilesForColor(TileColor.pink).map((t) => t.number).toSet(),
          Tile.tilesForColor(TileColor.blue).map((t) => t.number).toSet(),
          Tile.tilesForColor(TileColor.red).map((t) => t.number).toSet(),
          Tile.tilesForColor(TileColor.yellow).map((t) => t.number).toSet(),
        ],
      );

      // Clue: Tile 25 (yellow) placed in slot 2 (between pink slot 1 and blue slot 2)
      // Slot 0 (green) and Slot 1 (pink) must be < 25
      // Slot 2 (blue), Slot 3 (red), Slot 4 (yellow) must be > 25
      final clue = SortClue(
        id: 'c1',
        tile: Tile.fromNumber(25),
        targetPlayerIndex: 0,
        slotIndex: 2,
      );

      tracker.applyClue(clue);

      for (final num in tracker.slotCandidates[0]) {
        expect(num < 25, isTrue, reason: 'Slot 0 green num: $num');
      }
      for (final num in tracker.slotCandidates[1]) {
        expect(num < 25, isTrue, reason: 'Slot 1 pink num: $num');
      }
      for (final num in tracker.slotCandidates[2]) {
        expect(num > 25, isTrue, reason: 'Slot 2 blue num: $num');
      }
      for (final num in tracker.slotCandidates[3]) {
        expect(num > 25, isTrue, reason: 'Slot 3 red num: $num');
      }
      for (final num in tracker.slotCandidates[4]) {
        expect(num > 25, isTrue, reason: 'Slot 4 yellow num: $num');
      }
    });

    test('Applying COMPARE clue filters candidates based on dot counts', () {
      final tracker = DeductionTracker(
        rackColors: [TileColor.blue],
        slotCandidates: [
          Tile.tilesForColor(TileColor.blue).map((t) => t.number).toSet(),
        ],
      );

      // Blue tiles: 3(1), 8(2), 13(3), 18(1), 23(2), 28(3), 33(1), 38(2), 43(3), 48(1), 53(2), 58(3)
      // Tile 18 has 1 dot.
      // Compare clue: Tile 18 compared to slot 0 returns MATCH = true!
      final clueMatch = CompareClue(
        id: 'c2',
        tile: Tile.fromNumber(18),
        targetPlayerIndex: 0,
        targetSlotIndex: 0,
        match: true,
      );

      tracker.applyClue(clueMatch);

      // Only tiles with 1 dot should remain: {3, 18, 33, 48}
      expect(tracker.slotCandidates[0], equals({3, 18, 33, 48}));
    });
  });

  group('Fair AI Brain Decision Making', () {
    test('AI selects a valid available reserve color in revealingTile phase', () {
      final game = GameEngine.createGame(
        playerConfigs: [
          const PlayerConfig(id: 'p1', name: 'Human'),
          const PlayerConfig(id: 'ai1', name: 'Bot', isAi: true, aiDifficulty: AiDifficulty.hard),
        ],
      );

      // Fast-forward to AI's turn
      final revealed1 = GameEngine.revealTile(game, TileColor.green);
      final afterClue1 = GameEngine.askSortClue(revealed1, revealed1.pool.first);

      expect(afterClue1.activePlayerIndex, equals(1)); // Bot turn
      expect(afterClue1.phase, equals(GamePhase.revealingTile));

      final aiBrain = AiBrain(random: Random(42));
      final action = aiBrain.decideNextAction(afterClue1);

      expect(action, isA<AiRevealAction>());
      final revealAction = action as AiRevealAction;
      expect(afterClue1.availableReserveColors.contains(revealAction.color), isTrue);
    });

    test('AI selects a valid clue from pool in askingClue phase', () {
      final game = GameEngine.createGame(
        playerConfigs: [
          const PlayerConfig(id: 'p1', name: 'Human'),
          const PlayerConfig(id: 'ai1', name: 'Bot', isAi: true, aiDifficulty: AiDifficulty.hard),
        ],
      );

      final revealed1 = GameEngine.revealTile(game, TileColor.pink);
      final afterClue1 = GameEngine.askSortClue(revealed1, revealed1.pool.first);

      // AI turn step 1
      final aiRevealed = GameEngine.revealTile(afterClue1, TileColor.yellow);
      expect(aiRevealed.phase, equals(GamePhase.askingClue));

      final aiBrain = AiBrain(random: Random(42));
      final action = aiBrain.decideNextAction(aiRevealed);

      if (action is AiSortClueAction) {
        expect(aiRevealed.pool.contains(action.tile), isTrue);
      } else if (action is AiCompareClueAction) {
        expect(aiRevealed.pool.contains(action.tile), isTrue);
        expect(action.targetSlotIndex >= 0 && action.targetSlotIndex <= 4, isTrue);
      } else {
        fail('Expected clue action but got $action');
      }
    });

    test('Simulate complete AI vs AI game runs to completion without errors', () {
      var game = GameEngine.createGame(
        playerConfigs: [
          const PlayerConfig(id: 'ai1', name: 'Bot 1', isAi: true, aiDifficulty: AiDifficulty.hard),
          const PlayerConfig(id: 'ai2', name: 'Bot 2', isAi: true, aiDifficulty: AiDifficulty.medium),
        ],
        random: Random(777),
      );

      final brain = AiBrain(random: Random(777));
      int movesCount = 0;
      const maxMoves = 150;

      while (!game.isGameOver && movesCount < maxMoves) {
        movesCount++;
        final action = brain.decideNextAction(game);

        if (action is AiGuessAction) {
          game = GameEngine.declareGotFive(game, game.activePlayerIndex, action.guessedNumbers);
        } else if (action is AiRevealAction) {
          game = GameEngine.revealTile(game, action.color);
        } else if (action is AiSortClueAction) {
          game = GameEngine.askSortClue(game, action.tile);
        } else if (action is AiCompareClueAction) {
          game = GameEngine.askCompareClue(game, action.tile, action.targetSlotIndex);
        }
      }

      expect(movesCount > 0, isTrue);
      expect(movesCount < maxMoves, isTrue, reason: 'Game should conclude or eliminate within 150 moves');
      expect(game.isGameOver, isTrue);
      expect(game.winnerIndex, isNotNull);
    });
  });
}
