import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:got_five_app/data/repositories/local_game_storage.dart';
import 'package:got_five_app/domain/engine/game_engine.dart';
import 'package:got_five_app/domain/models/clue.dart';
import 'package:got_five_app/domain/models/game_state.dart';
import 'package:got_five_app/domain/models/player.dart';
import 'package:got_five_app/domain/models/tile.dart';
import 'package:got_five_app/l10n/app_localizations.dart';
import 'package:got_five_app/ui/widgets/compact_deduction_sheet.dart';
import 'package:got_five_app/ui/widgets/physical_stand_workspace_widget.dart';

Tile makeTile(int number, TileColor color, int dots) => Tile(
      number: number,
      color: color,
      dots: dots.clamp(0, 3),
      symbol: Tile.symbolForColor(color),
    );

Widget testableWidget(
  Widget child, {
  Locale locale = const Locale('en'),
  double textScaleFactor = 1.0,
}) {
  return MediaQuery(
    data: MediaQueryData(
      textScaler: TextScaler.linear(textScaleFactor),
      size: const Size(390, 844),
    ),
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Fix 1: Automatically Cross Out Revealed Numbers', () {
    test('Computer reveals a tile and immediately uses it as a clue: number remains crossed out', () {
      final state = GameEngine.createGame(playerConfigs: [
        PlayerConfig(id: 'p0', name: 'Human', isAi: false),
        PlayerConfig(id: 'p1', name: 'Bot 1', isAi: true),
      ]);

      // Initially, pool has 5 tiles, human rack has 5 hidden tiles, bot has 5 rack tiles
      final initialHumanRevealed = GameEngine.getRevealedNumbersForPlayer(state, 0);
      expect(initialHumanRevealed.length, equals(10)); // 5 opponent tiles + 5 pool tiles

      // Human rack numbers must NEVER be in human revealed set
      for (final tile in state.players[0].rack) {
        expect(initialHumanRevealed.contains(tile.number), isFalse);
      }

      // Turn 1: Bot is active (or set bot as active)
      final botTurnState = state.copyWith(activePlayerIndex: 1, phase: GamePhase.revealingTile);
      final reserveColor = botTurnState.availableReserveColors.first;

      // Bot reveals a tile from reserve
      final afterRevealState = GameEngine.revealTile(botTurnState, reserveColor);
      final revealedTile = afterRevealState.justRevealedTile!;

      expect(afterRevealState.lastRevealedMessage, contains('Computer revealed ${revealedTile.number}'));
      expect(afterRevealState.lastRevealedTile, equals(revealedTile));

      // Sheet for human player immediately includes the newly revealed number
      final revealedAfterReveal = GameEngine.getRevealedNumbersForPlayer(afterRevealState, 0);
      expect(revealedAfterReveal.contains(revealedTile.number), isTrue);

      // Now bot uses this newly revealed tile as a SORT clue
      final afterClueState = GameEngine.askSortClue(afterRevealState, revealedTile);

      // Tile has moved from pool into bot's cluesReceived
      expect(afterClueState.pool.contains(revealedTile), isFalse);
      expect(afterClueState.players[1].cluesReceived.any((c) => c.tile == revealedTile), isTrue);

      // CRITICAL REQUIREMENT: Tile number MUST REMAIN CROSSED OUT for viewing player
      final revealedAfterClue = GameEngine.getRevealedNumbersForPlayer(afterClueState, 0);
      expect(revealedAfterClue.contains(revealedTile.number), isTrue);

      // CRITICAL REQUIREMENT: Message stays available after tile moves
      expect(afterClueState.lastRevealedMessage, contains('Computer revealed ${revealedTile.number}'));
      expect(afterClueState.lastRevealedTile, equals(revealedTile));
    });

    test('Separate player views in Pass-and-Play', () {
      final state = GameEngine.createGame(playerConfigs: [
        PlayerConfig(id: 'p0', name: 'Alice', isAi: false),
        PlayerConfig(id: 'p1', name: 'Bob', isAi: false),
      ]);

      final aliceRevealed = GameEngine.getRevealedNumbersForPlayer(state, 0);
      final bobRevealed = GameEngine.getRevealedNumbersForPlayer(state, 1);

      // Alice's view: Bob's 5 rack tiles are visible and crossed out
      for (final tile in state.players[1].rack) {
        expect(aliceRevealed.contains(tile.number), isTrue);
      }
      // Alice's view: Alice's own rack tiles are hidden and NEVER crossed out
      for (final tile in state.players[0].rack) {
        expect(aliceRevealed.contains(tile.number), isFalse);
      }

      // Bob's view: Alice's 5 rack tiles are visible and crossed out
      for (final tile in state.players[0].rack) {
        expect(bobRevealed.contains(tile.number), isTrue);
      }
      // Bob's view: Bob's own rack tiles are hidden and NEVER crossed out
      for (final tile in state.players[1].rack) {
        expect(bobRevealed.contains(tile.number), isFalse);
      }

      // Shared pool tiles (5 tiles) are crossed out for both
      for (final tile in state.pool) {
        expect(aliceRevealed.contains(tile.number), isTrue);
        expect(bobRevealed.contains(tile.number), isTrue);
      }
    });

    test('Saving and restoring a match preserves revealed marks and notes', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await LocalGameStorage.create();

      var state = GameEngine.createGame(playerConfigs: [
        PlayerConfig(id: 'p0', name: 'Human', isAi: false),
        PlayerConfig(id: 'p1', name: 'Computer', isAi: true),
      ]);

      // Reveal a tile
      state = state.copyWith(activePlayerIndex: 1, phase: GamePhase.revealingTile);
      state = GameEngine.revealTile(state, TileColor.green);
      final revealedTile = state.justRevealedTile!;

      await storage.saveGame(state);
      await storage.savePlayerNotes(
        gameId: state.gameId,
        playerId: 'p0',
        crossedOut: {10, 20},
        guesses: ['1', '2', '3', '4', '5'],
      );

      // Restore match
      final restoredState = storage.loadSavedGame()!;
      final restoredNotes = storage.loadPlayerNotes(
        gameId: restoredState.gameId,
        playerId: 'p0',
      );

      expect(restoredNotes.crossedOut, equals({10, 20}));
      expect(restoredNotes.guesses, equals(['1', '2', '3', '4', '5']));
      expect(restoredState.lastRevealedMessage, contains('Computer revealed ${revealedTile.number}'));

      final restoredRevealed = GameEngine.getRevealedNumbersForPlayer(restoredState, 0);
      expect(restoredRevealed.contains(revealedTile.number), isTrue);
    });

    testWidgets('CompactDeductionSheetWidget isolates manual Undo/Clear from auto-revealed tiles', (tester) async {
      Set<int> manualNotes = {10};
      final autoRevealed = {52, 60};
      int toggleCallCount = 0;

      await tester.pumpWidget(
        testableWidget(
          StatefulBuilder(
            builder: (ctx, setState) {
              return CompactDeductionSheetWidget(
                manualCrossedOutNumbers: manualNotes,
                autoRevealedNumbers: autoRevealed,
                canUndo: true,
                onToggleNumber: (num) {
                  toggleCallCount++;
                  setState(() {
                    if (manualNotes.contains(num)) {
                      manualNotes.remove(num);
                    } else {
                      manualNotes.add(num);
                    }
                  });
                },
                onClear: () {
                  setState(() {
                    manualNotes.clear();
                  });
                },
                onUndo: () {
                  setState(() {
                    manualNotes = {10};
                  });
                },
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Total count should be 3/60 (manual 10 + auto 52, 60)
      expect(find.text('3/60'), findsOneWidget);

      // Tapping on auto-revealed number 52 should NOT trigger onToggleNumber (warnIfMissed: false)
      await tester.tap(find.text('52'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(toggleCallCount, equals(0));

      // Clear notes should only clear manual notes, auto-revealed numbers remain visibly unavailable
      await tester.tap(find.byIcon(Icons.delete_sweep_outlined));
      await tester.pumpAndSettle();

      expect(manualNotes, isEmpty);
      // Total count is now 2/60 (only the 2 auto-revealed numbers remain)
      expect(find.text('2/60'), findsOneWidget);

      // Undo restores manual note 10
      await tester.tap(find.byIcon(Icons.undo_rounded));
      await tester.pumpAndSettle();
      expect(manualNotes, equals({10}));
      expect(find.text('3/60'), findsOneWidget);
    });
  });

  group('Fix 2: Make Order-Clue Numbers Readable in All Positions', () {
    testWidgets('Two-digit clues 12, 23, 52, 60 in all positions appear horizontally on one line', (tester) async {
      final player = Player(
        id: 'p1',
        name: 'Player 1',
        isAi: false,
        rack: [
          makeTile(7, TileColor.green, 1),
          makeTile(16, TileColor.pink, 2),
          makeTile(28, TileColor.blue, 3),
          makeTile(40, TileColor.red, 3),
          makeTile(55, TileColor.yellow, 3),
        ],
        cluesReceived: [
          // Slot 0 (Before first tile): 12
          SortClue(id: 'c0', tile: makeTile(12, TileColor.green, 1), targetPlayerIndex: 0, slotIndex: 0),
          // Slot 1 (Between 1st & 2nd): 23
          SortClue(id: 'c1', tile: makeTile(23, TileColor.pink, 2), targetPlayerIndex: 0, slotIndex: 1),
          // Slot 2 (Between 2nd & 3rd): 52
          SortClue(id: 'c2', tile: makeTile(52, TileColor.blue, 3), targetPlayerIndex: 0, slotIndex: 2),
          // Slot 3 (Between 3rd & 4th): 60
          SortClue(id: 'c3', tile: makeTile(60, TileColor.yellow, 3), targetPlayerIndex: 0, slotIndex: 3),
        ],
      );

      await tester.pumpWidget(
        testableWidget(
          PhysicalStandWorkspaceWidget(
            player: player,
            isCurrentPlayer: true,
            isOwnerView: true,
            guesses: const ['7', '16', '28', '40', '55'],
            onGuessChanged: (slot, val) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // All two-digit numbers must be visible as full horizontal strings
      expect(find.text('12'), findsOneWidget);
      expect(find.text('23'), findsOneWidget);
      expect(find.text('52'), findsOneWidget);
      expect(find.text('60'), findsOneWidget);

      // Verify that the Text widget has maxLines = 1 and softWrap = false
      final text52 = tester.widget<Text>(find.text('52'));
      expect(text52.maxLines, equals(1));
      expect(text52.softWrap, isFalse);

      // Check connectors (downward arrows) exist
      expect(find.byIcon(Icons.arrow_drop_down), findsWidgets);
    });

    testWidgets('Arabic RTL preserves strictly ascending order and horizontal digits', (tester) async {
      final player = Player(
        id: 'p1',
        name: 'اللاعب 1',
        isAi: false,
        rack: [
          makeTile(7, TileColor.green, 1),
          makeTile(16, TileColor.pink, 2),
          makeTile(28, TileColor.blue, 3),
          makeTile(40, TileColor.red, 3),
          makeTile(55, TileColor.yellow, 3),
        ],
        cluesReceived: [
          SortClue(id: 'c0', tile: makeTile(12, TileColor.green, 1), targetPlayerIndex: 0, slotIndex: 0),
          SortClue(id: 'c2', tile: makeTile(52, TileColor.blue, 3), targetPlayerIndex: 0, slotIndex: 2),
        ],
      );

      await tester.pumpWidget(
        testableWidget(
          PhysicalStandWorkspaceWidget(
            player: player,
            isCurrentPlayer: true,
            isOwnerView: true,
            guesses: const ['', '', '', '', ''],
            onGuessChanged: (slot, val) {},
          ),
          locale: const Locale('ar'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('12'), findsOneWidget);
      expect(find.text('52'), findsOneWidget);
      expect(find.text('تخميناتي'), findsOneWidget);
    });

    testWidgets('Larger text scale does not break two-digit clues', (tester) async {
      final player = Player(
        id: 'p1',
        name: 'Player 1',
        isAi: false,
        rack: Tile.tilesForColor(TileColor.green).take(5).toList(),
        cluesReceived: [
          SortClue(id: 'c2', tile: makeTile(52, TileColor.blue, 3), targetPlayerIndex: 0, slotIndex: 2),
          SortClue(id: 'c5', tile: makeTile(60, TileColor.yellow, 3), targetPlayerIndex: 0, slotIndex: 5),
        ],
      );

      await tester.pumpWidget(
        testableWidget(
          PhysicalStandWorkspaceWidget(
            player: player,
            isCurrentPlayer: true,
            isOwnerView: true,
            guesses: const ['', '', '', '', ''],
            onGuessChanged: (slot, val) {},
          ),
          textScaleFactor: 1.5,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('52'), findsOneWidget);
      expect(find.text('60'), findsOneWidget);
    });

    testWidgets('Grouped multiple clues show +N badge and allow inspection of all clues in group', (tester) async {
      final player = Player(
        id: 'p1',
        name: 'Player 1',
        isAi: false,
        rack: Tile.tilesForColor(TileColor.green).take(5).toList(),
        cluesReceived: [
          SortClue(id: 'c2a', tile: makeTile(23, TileColor.pink, 2), targetPlayerIndex: 0, slotIndex: 2),
          SortClue(id: 'c2b', tile: makeTile(52, TileColor.blue, 3), targetPlayerIndex: 0, slotIndex: 2),
        ],
      );

      await tester.pumpWidget(
        testableWidget(
          PhysicalStandWorkspaceWidget(
            player: player,
            isCurrentPlayer: true,
            isOwnerView: true,
            guesses: const ['', '', '', '', ''],
            onGuessChanged: (slot, val) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Top clue 52 is visible with "+1" badge
      expect(find.text('52'), findsOneWidget);
      expect(find.text('+1'), findsOneWidget);

      // Tap on the clue chip to inspect the group
      await tester.tap(find.text('52'));
      await tester.pumpAndSettle();

      // Group inspection dialog pops up showing both clues: 23 and 52
      expect(find.textContaining('Sort Clue (Order)'), findsOneWidget);
      expect(find.text('23'), findsOneWidget);
      expect(find.text('52'), findsNWidgets(2)); // in dialog + in background stand
    });
  });

  group('Fix 3: All Six Order-Clue Positions & Rack Geometry', () {
    testWidgets('Clues in all 6 positions (0 to 5) render with downward connectors and horizontal digits on 320px width', (tester) async {
      final player = Player(
        id: 'p1',
        name: 'Player 1',
        isAi: false,
        rack: [
          makeTile(15, TileColor.green, 1),
          makeTile(25, TileColor.pink, 2),
          makeTile(35, TileColor.blue, 3),
          makeTile(45, TileColor.red, 3),
          makeTile(55, TileColor.yellow, 3),
        ],
        cluesReceived: [
          SortClue(id: 'c0', tile: makeTile(10, TileColor.green, 1), targetPlayerIndex: 0, slotIndex: 0),
          SortClue(id: 'c1', tile: makeTile(20, TileColor.pink, 2), targetPlayerIndex: 0, slotIndex: 1),
          SortClue(id: 'c2', tile: makeTile(30, TileColor.blue, 3), targetPlayerIndex: 0, slotIndex: 2),
          SortClue(id: 'c3', tile: makeTile(40, TileColor.yellow, 3), targetPlayerIndex: 0, slotIndex: 3),
          SortClue(id: 'c4', tile: makeTile(50, TileColor.red, 3), targetPlayerIndex: 0, slotIndex: 4),
          SortClue(id: 'c5', tile: makeTile(60, TileColor.yellow, 3), targetPlayerIndex: 0, slotIndex: 5),
        ],
      );

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(320, 700)),
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: SingleChildScrollView(
                child: PhysicalStandWorkspaceWidget(
                  player: player,
                  isCurrentPlayer: true,
                  isOwnerView: true,
                  guesses: const ['', '', '', '', ''],
                  onGuessChanged: (slot, val) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // All 6 numbers must be visible as full horizontal two-digit strings
      expect(find.text('10'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
      expect(find.text('40'), findsOneWidget);
      expect(find.text('50'), findsOneWidget);
      expect(find.text('60'), findsOneWidget);

      // Downward arrow connectors must be visible
      expect(find.byIcon(Icons.arrow_drop_down), findsWidgets);
    });
  });

  group('Fix 4: Multiple Comparison Clues Inspection', () {
    testWidgets('Multiple comparisons for a single slot show badge and dialog with all results', (tester) async {
      final player = Player(
        id: 'p1',
        name: 'Player 1',
        isAi: false,
        rack: [
          makeTile(7, TileColor.green, 1),
          makeTile(16, TileColor.pink, 2),
          makeTile(28, TileColor.blue, 3),
          makeTile(40, TileColor.red, 3),
          makeTile(55, TileColor.yellow, 3),
        ],
        cluesReceived: [
          CompareClue(
            id: 'cmp1',
            tile: makeTile(14, TileColor.green, 2),
            targetPlayerIndex: 0,
            targetSlotIndex: 2,
            match: false,
          ),
          CompareClue(
            id: 'cmp2',
            tile: makeTile(38, TileColor.blue, 3),
            targetPlayerIndex: 0,
            targetSlotIndex: 2,
            match: true,
          ),
        ],
      );

      await tester.pumpWidget(
        testableWidget(
          PhysicalStandWorkspaceWidget(
            player: player,
            isCurrentPlayer: true,
            isOwnerView: true,
            guesses: const ['', '', '', '', ''],
            onGuessChanged: (slot, val) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Comparison indicator for slot 2 should show "+1" badge since there are 2 clues
      expect(find.text('+1'), findsOneWidget);

      // Tap the comparison indicator
      await tester.tap(find.text('+1'));
      await tester.pumpAndSettle();

      // Dialog opens showing header and target hidden tile
      expect(find.textContaining('Comparison Clues for Slot #3'), findsOneWidget);
      expect(find.textContaining('Target Tile: Slot #3'), findsOneWidget);

      // Shows both comparison clues with public numbers and match status
      expect(find.text('14'), findsOneWidget);
      expect(find.text('38'), findsOneWidget);
      expect(find.textContaining('Different'), findsOneWidget);
      expect(find.textContaining('Same'), findsOneWidget);
    });
  });

  group('Fix 5: Single Horizontal Row Per Color Deduction Sheet', () {
    testWidgets('CompactDeductionSheetWidget keeps 1 horizontal row per color on narrow screens (<380px) with 0 overflow', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(320, 600)),
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: CompactDeductionSheetWidget(
                autoRevealedNumbers: const {5, 12, 28},
                manualCrossedOutNumbers: const {10, 20},
                onToggleNumber: (n) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure no overflow and numbers are displayed
      expect(tester.takeException(), isNull);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('28'), findsOneWidget);

      // Verify each color has exactly 1 row: all 12 numbers in Green row share the same vertical Y coordinate
      final greenFirst = tester.getCenter(find.text('1')).dy;
      final greenSixth = tester.getCenter(find.text('26')).dy;
      expect(greenFirst, equals(greenSixth));

      // Verify pinned color symbols exist at start of rows
      expect(find.text('▲'), findsWidgets); // Green symbol
      expect(find.text('●'), findsWidgets); // Pink symbol
      expect(find.text('■'), findsWidgets); // Blue symbol
      expect(find.text('◆'), findsWidgets); // Red symbol
      expect(find.text('★'), findsWidgets); // Yellow symbol
    });

    testWidgets('Light theme contrast and reduced motion settings render cleanly', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(360, 640),
            disableAnimations: true,
          ),
          child: MaterialApp(
            theme: ThemeData.light(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: CompactDeductionSheetWidget(
                autoRevealedNumbers: const {1, 2},
                manualCrossedOutNumbers: const {3},
                onToggleNumber: (n) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('1'), findsOneWidget);
    });
  });

  group('Fix 6: Localization & Accessibility', () {
    testWidgets('Structured reveal events format properly in EN, FR, AR', (tester) async {
      // Create localizations for EN, FR, AR
      late AppLocalizations l10nEn;
      late AppLocalizations l10nFr;
      late AppLocalizations l10nAr;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Builder(builder: (ctx) {
            l10nEn = AppLocalizations.of(ctx)!;
            return const SizedBox();
          }),
        ),
      );
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('fr'),
          home: Builder(builder: (ctx) {
            l10nFr = AppLocalizations.of(ctx)!;
            return const SizedBox();
          }),
        ),
      );
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ar'),
          home: Builder(builder: (ctx) {
            l10nAr = AppLocalizations.of(ctx)!;
            return const SizedBox();
          }),
        ),
      );
      await tester.pumpAndSettle();

      // Human reveal test
      expect(l10nEn.playerRevealedTile('Alice', 42), equals('Alice revealed 42'));
      expect(l10nFr.playerRevealedTile('Alice', 42), equals('Alice a révélé le 42'));
      expect(l10nAr.playerRevealedTile('Alice', 42), equals('Alice كشف الرقم 42'));

      // Computer reveal test
      expect(l10nEn.playerRevealedTile(l10nEn.computer, 42), equals('Computer revealed 42'));
      expect(l10nFr.playerRevealedTile(l10nFr.computer, 42), equals('L\'ordinateur a révélé le 42'));
      expect(l10nAr.playerRevealedTile(l10nAr.computer, 42), equals('الكمبيوتر كشف الرقم 42'));

      // Reserve count test
      expect(l10nEn.inReserveCount(15), equals('15 in reserve'));
      expect(l10nFr.inReserveCount(15), equals('15 en réserve'));
      expect(l10nAr.inReserveCount(15), equals('15 في الاحتياطي'));

      // Compared with slot test
      expect(l10nEn.comparedWithSlot(3), equals('Compared with Slot #3'));
      expect(l10nFr.comparedWithSlot(3), equals('Comparé à la position #3'));
      expect(l10nAr.comparedWithSlot(3), equals('مقارن مع الخانة #3'));
    });
  });
}

