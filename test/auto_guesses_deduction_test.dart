import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:got_five_app/domain/engine/auto_guess_manager.dart';
import 'package:got_five_app/domain/engine/game_engine.dart';
import 'package:got_five_app/domain/models/tile.dart';
import 'package:got_five_app/data/repositories/local_game_storage.dart';
import 'package:got_five_app/ui/controllers/game_controller.dart';
import 'package:got_five_app/ui/features/game/game_screen.dart';
import 'package:got_five_app/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AutoGuessManager Unit Tests', () {
    test('All 5 colors: auto-fills guess when exactly 1 uncrossed candidate remains', () {
      // Test each color: Green (1..12), Pink (13..24), Blue (25..36), Red (37..48), Yellow (49..60)
      for (final color in TileColor.values) {
        final tiles = Tile.tilesForColor(color);
        expect(tiles.length, 12);

        // Cross out 11 of 12 tiles for this color
        final lastTile = tiles.last; // e.g. 12, 24, 36, 48, 60
        final crossedOut = tiles.take(11).map((t) => t.number).toSet();

        final result = AutoGuessManager.computeAutoGuesses(
          rackColors: [color],
          manualCrossedOutNumbers: crossedOut,
          autoRevealedNumbers: {},
          currentGuesses: [''],
          currentAutoFilledSlots: {},
        );

        expect(result.guesses[0], lastTile.number.toString(),
            reason: 'Color $color should have auto-filled remaining tile ${lastTile.number}');
        expect(result.autoFilledSlots.contains(0), isTrue);
        expect(result.exhaustedColors.contains(color), isFalse);
      }
    });

    test('Considers both automatic public-tile marks and manual marks', () {
      final greenTiles = Tile.tilesForColor(TileColor.green);
      // 5 manual marks, 6 public revealed marks -> total 11 marks out of 12
      final manualMarks = greenTiles.sublist(0, 5).map((t) => t.number).toSet();
      final publicMarks = greenTiles.sublist(5, 11).map((t) => t.number).toSet();
      final remainingNumber = greenTiles[11].number;

      final result = AutoGuessManager.computeAutoGuesses(
        rackColors: [TileColor.green],
        manualCrossedOutNumbers: manualMarks,
        autoRevealedNumbers: publicMarks,
        currentGuesses: [''],
        currentAutoFilledSlots: {},
      );

      expect(result.guesses[0], remainingNumber.toString());
      expect(result.autoFilledSlots.contains(0), isTrue);
    });

    test('Matches by hidden tile color, not rack position (handles permutations & duplicates)', () {
      // Rack with duplicated green and different order: [Yellow, Green, Red, Green, Blue]
      final rackColors = [
        TileColor.yellow,
        TileColor.green,
        TileColor.red,
        TileColor.green,
        TileColor.blue,
      ];

      // Green has only #26 remaining uncrossed (green numbers: 1, 6, 11, 16, 21, 26, 31, 36, 41, 46, 51, 56)
      final allGreen = Tile.tilesForColor(TileColor.green).map((t) => t.number).toSet();
      allGreen.remove(26);

      final result = AutoGuessManager.computeAutoGuesses(
        rackColors: rackColors,
        manualCrossedOutNumbers: allGreen,
        autoRevealedNumbers: {},
        currentGuesses: ['', '', '', '', ''],
        currentAutoFilledSlots: {},
      );

      // Yellow (slot 0) has >1 candidate -> empty
      expect(result.guesses[0], '');
      // Green (slot 1) -> auto-filled '26'
      expect(result.guesses[1], '26');
      expect(result.autoFilledSlots.contains(1), isTrue);
      // Red (slot 2) -> empty
      expect(result.guesses[2], '');
      // Green (slot 3) -> also auto-filled '26'!
      expect(result.guesses[3], '26');
      expect(result.autoFilledSlots.contains(3), isTrue);
      // Blue (slot 4) -> empty
      expect(result.guesses[4], '');
    });

    test('Clears auto-filled guess if candidate count becomes > 1 again (uncrossing / Undo)', () {
      final rackColors = [TileColor.pink];
      final pinkTiles = Tile.tilesForColor(TileColor.pink).map((t) => t.number).toList();

      // Step 1: 11 crossed out -> 1 candidate remains -> auto-filled
      final crossed11 = pinkTiles.take(11).toSet();
      final res1 = AutoGuessManager.computeAutoGuesses(
        rackColors: rackColors,
        manualCrossedOutNumbers: crossed11,
        autoRevealedNumbers: {},
        currentGuesses: [''],
        currentAutoFilledSlots: {},
      );
      expect(res1.guesses[0], pinkTiles.last.toString());
      expect(res1.autoFilledSlots.contains(0), isTrue);

      // Step 2: Uncross one number (undo) -> 2 candidates remain
      final crossed10 = pinkTiles.take(10).toSet();
      final res2 = AutoGuessManager.computeAutoGuesses(
        rackColors: rackColors,
        manualCrossedOutNumbers: crossed10,
        autoRevealedNumbers: {},
        currentGuesses: res1.guesses,
        currentAutoFilledSlots: res1.autoFilledSlots,
      );
      expect(res2.guesses[0], '', reason: 'Auto-filled guess must be cleared when candidates > 1');
      expect(res2.autoFilledSlots.contains(0), isFalse);
    });

    test('Clears auto-filled guess and marks exhausted when 0 candidates remain', () {
      final rackColors = [TileColor.blue];
      final blueTiles = Tile.tilesForColor(TileColor.blue).map((t) => t.number).toList();

      // Step 1: 1 candidate remains
      final res1 = AutoGuessManager.computeAutoGuesses(
        rackColors: rackColors,
        manualCrossedOutNumbers: blueTiles.take(11).toSet(),
        autoRevealedNumbers: {},
        currentGuesses: [''],
        currentAutoFilledSlots: {},
      );
      expect(res1.guesses[0], blueTiles.last.toString());
      expect(res1.autoFilledSlots.contains(0), isTrue);
      expect(res1.exhaustedColors.contains(TileColor.blue), isFalse);

      // Step 2: All 12 crossed out -> 0 candidates remain
      final res2 = AutoGuessManager.computeAutoGuesses(
        rackColors: rackColors,
        manualCrossedOutNumbers: blueTiles.toSet(),
        autoRevealedNumbers: {},
        currentGuesses: res1.guesses,
        currentAutoFilledSlots: res1.autoFilledSlots,
      );
      expect(res2.guesses[0], '', reason: 'Auto-filled guess must be cleared when 0 candidates remain');
      expect(res2.autoFilledSlots.contains(0), isFalse);
      expect(res2.exhaustedColors.contains(TileColor.blue), isTrue);
    });

    test('Preserves manually entered guesses and respects user edits', () {
      final rackColors = [TileColor.red];
      final redTiles = Tile.tilesForColor(TileColor.red).map((t) => t.number).toList();
      final crossed11 = redTiles.take(11).toSet();

      // Case A: User has manually entered '40' before candidate count became 1
      final resManual = AutoGuessManager.computeAutoGuesses(
        rackColors: rackColors,
        manualCrossedOutNumbers: crossed11,
        autoRevealedNumbers: {},
        currentGuesses: ['40'],
        currentAutoFilledSlots: {}, // not auto-filled
      );
      expect(resManual.guesses[0], '40', reason: 'Manual guess must not be overwritten by auto-fill');
      expect(resManual.autoFilledSlots.contains(0), isFalse);

      // Case B: Slot was auto-filled, then user edited it (turning it into manual)
      final autoResult = AutoGuessManager.computeAutoGuesses(
        rackColors: rackColors,
        manualCrossedOutNumbers: crossed11,
        autoRevealedNumbers: {},
        currentGuesses: [''],
        currentAutoFilledSlots: {},
      );
      expect(autoResult.guesses[0], redTiles.last.toString());
      expect(autoResult.autoFilledSlots.contains(0), isTrue);

      // User edits the box to '41' (simulated by updating guesses and removing from autoFilledSlots)
      final userEditedGuesses = ['41'];
      final userAutoFilledSlots = <int>{}; // removed 0 because user edited it

      // When candidates change (e.g. uncross 1 tile so 2 candidates remain)
      final crossed10 = redTiles.take(10).toSet();
      final afterUncross = AutoGuessManager.computeAutoGuesses(
        rackColors: rackColors,
        manualCrossedOutNumbers: crossed10,
        autoRevealedNumbers: {},
        currentGuesses: userEditedGuesses,
        currentAutoFilledSlots: userAutoFilledSlots,
      );
      expect(afterUncross.guesses[0], '41', reason: 'User-edited guess must be preserved even if candidates change');
      expect(afterUncross.autoFilledSlots.contains(0), isFalse);
    });
  });

  group('Storage Persistence Tests', () {
    test('LocalGameStorage saves and loads autoFilledSlots properly', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalGameStorage(prefs);

      await storage.savePlayerNotes(
        gameId: 'game_123',
        playerId: 'p1',
        crossedOut: {1, 2, 3},
        guesses: ['10', '20', '', '', '50'],
        autoFilledSlots: {0, 4},
      );

      final loaded = storage.loadPlayerNotes(
        gameId: 'game_123',
        playerId: 'p1',
      );

      expect(loaded.crossedOut, {1, 2, 3});
      expect(loaded.guesses, ['10', '20', '', '', '50']);
      expect(loaded.autoFilledSlots, {0, 4});
    });
  });

  group('GameScreen Integration Tests', () {
    late LocalGameStorage storage;
    late GameController controller;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      storage = LocalGameStorage(prefs);
      controller = GameController(storage: storage);
    });

    Widget createTestWidget() {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: GameScreen(controller: controller),
        ),
      );
    }

    testWidgets('Tapping sheet marks updates auto-guesses immediately; Undo & Clear work', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Start a standard 2-player game
      controller.startNewGame([
        PlayerConfig(id: 'p0', name: 'Hero', isAi: false),
        PlayerConfig(id: 'p1', name: 'Bot', isAi: true),
      ]);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final humanPlayer = controller.state!.players[0];
      final firstColor = humanPlayer.rackColors[0];
      final tilesOfColor = Tile.tilesForColor(firstColor);

      // Find 11 tiles of that color and cross them out manually by tapping sheet cells
      // Leave one uncrossed candidate that is not already in the common pool
      final autoRevealed = GameEngine.getRevealedNumbersForPlayer(controller.state!, 0);
      final unrevealed = tilesOfColor.where((t) => !autoRevealed.contains(t.number)).toList();
      final remainingTile = unrevealed.last;
      final tilesToCross = tilesOfColor.where((t) => t.number != remainingTile.number).toList();

      for (final tile in tilesToCross) {
        final cellFinder = find.widgetWithText(GestureDetector, tile.number.toString());
        if (cellFinder.evaluate().isNotEmpty) {
          await tester.tap(cellFinder.first);
          await tester.pump();
        }
      }

      await tester.pumpAndSettle();

      // Check that guess box 0 now contains the remaining number!
      final guessBox0Finder = find.widgetWithText(TextField, remainingTile.number.toString());
      expect(guessBox0Finder, findsWidgets,
          reason: 'Guess box for color $firstColor should automatically contain ${remainingTile.number}');

      // Tap UNDO button on sheet
      final undoButtonFinder = find.byIcon(Icons.undo_rounded);
      expect(undoButtonFinder, findsWidgets);
      await tester.tap(undoButtonFinder.first);
      await tester.pumpAndSettle();

      // Now 2 candidates remain for that color -> auto-fill should be cleared!
      final clearedBoxFinder = find.widgetWithText(TextField, remainingTile.number.toString());
      expect(clearedBoxFinder, findsNothing,
          reason: 'Auto-fill should be cleared when Undo returns candidates to > 1');

      // Tap CLEAR button to reset all notes
      final clearButtonFinder = find.byIcon(Icons.delete_sweep_outlined);
      expect(clearButtonFinder, findsWidgets);
      await tester.tap(clearButtonFinder.first);
      await tester.pumpAndSettle();

      // Now cross out ALL 12 tiles of that color from clean sheet
      for (final tile in tilesOfColor) {
        final cellFinder = find.widgetWithText(GestureDetector, tile.number.toString());
        if (cellFinder.evaluate().isNotEmpty) {
          await tester.tap(cellFinder.first);
          await tester.pump();
        }
      }
      await tester.pumpAndSettle();

      // Should show exhausted warning text and icon
      expect(find.byIcon(Icons.warning_amber_rounded), findsWidgets,
          reason: 'Exhausted warning must appear when all 12 numbers of a color are crossed out');

      // Tap CLEAR button again to restore
      await tester.tap(clearButtonFinder.first);
      await tester.pumpAndSettle();

      // After Clear, all numbers are uncrossed, exhausted warning is gone
      expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
    });

    testWidgets('Saved game restoration restores auto-guesses and notes', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      controller.startNewGame([
        PlayerConfig(id: 'p0', name: 'Hero', isAi: false),
        PlayerConfig(id: 'p1', name: 'Bot', isAi: true),
      ]);

      final gameId = controller.state!.gameId;
      final human = controller.state!.players[0];
      final color0 = human.rackColors[0];
      final color0Tiles = Tile.tilesForColor(color0);
      final autoRevealed = GameEngine.getRevealedNumbersForPlayer(controller.state!, 0);
      final unrevealedTiles = color0Tiles.where((t) => !autoRevealed.contains(t.number)).toList();
      final remainingTile = unrevealedTiles.last;

      // Pre-save notes in storage with all other tiles of that color crossed out
      final crossed11 = color0Tiles.where((t) => t.number != remainingTile.number).map((t) => t.number).toSet();
      await storage.savePlayerNotes(
        gameId: gameId,
        playerId: human.id,
        crossedOut: crossed11,
        guesses: [remainingTile.number.toString(), '', '', '', ''],
        autoFilledSlots: {0},
      );

      // Re-mount widget (simulating resuming/restoring saved game)
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Guess box 0 should immediately display the restored auto-guess
      expect(find.widgetWithText(TextField, remainingTile.number.toString()), findsWidgets);
    });
  });
}
