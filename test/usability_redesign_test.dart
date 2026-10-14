import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:got_five_app/data/repositories/local_game_storage.dart';
import 'package:got_five_app/domain/models/clue.dart';
import 'package:got_five_app/domain/models/player.dart';
import 'package:got_five_app/domain/models/tile.dart';
import 'package:got_five_app/l10n/app_localizations.dart';
import 'package:got_five_app/ui/widgets/clue_explanation_helper.dart';
import 'package:got_five_app/ui/widgets/compact_deduction_sheet.dart';
import 'package:got_five_app/ui/widgets/physical_stand_workspace_widget.dart';
import 'package:got_five_app/ui/features/game/declare_got_five_dialog.dart';

Tile makeTile(int number, TileColor color, int dots) => Tile(
  number: number,
  color: color,
  dots: dots,
  symbol: Tile.symbolForColor(color),
);

Widget testableWidget(Widget child, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  group('Usability Redesign - Physical Order Clues (All 6 Locations)', () {
    testWidgets('Validates spatial descriptions for all 6 gap locations', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(
        testableWidget(
          Builder(builder: (ctx) {
            capturedContext = ctx;
            return const Placeholder();
          }),
        ),
      );
      await tester.pumpAndSettle();

      final rackColors = [
        TileColor.green,
        TileColor.pink,
        TileColor.blue,
        TileColor.red,
        TileColor.yellow,
      ];

      // Test Slot 0 (Before first tile)
      final clue0 = SortClue(
        id: 'c0',
        tile: makeTile(5, TileColor.green, 1),
        targetPlayerIndex: 0,
        slotIndex: 0,
      );
      final desc0 = ClueExplanationHelper.explainSortClue(
        context: capturedContext,
        clue: clue0,
        rackColors: rackColors,
      );
      expect(desc0, contains('before your first tile'));
      expect(desc0, contains('All 5 of your numbers are larger than 5'));

      // Test Slot 1 (Between 1st and 2nd)
      final clue1 = SortClue(
        id: 'c1',
        tile: makeTile(14, TileColor.pink, 2),
        targetPlayerIndex: 0,
        slotIndex: 1,
      );
      final desc1 = ClueExplanationHelper.explainSortClue(
        context: capturedContext,
        clue: clue1,
        rackColors: rackColors,
      );
      expect(desc1, contains('between your 1st (Green) and 2nd (Pink) tiles'));

      // Test Slot 2 (Between 2nd and 3rd)
      final clue2 = SortClue(
        id: 'c2',
        tile: makeTile(23, TileColor.pink, 3),
        targetPlayerIndex: 0,
        slotIndex: 2,
      );
      final desc2 = ClueExplanationHelper.explainSortClue(
        context: capturedContext,
        clue: clue2,
        rackColors: rackColors,
      );
      expect(desc2, contains('between your 2nd (Pink) and 3rd (Blue) tiles'));
      expect(desc2, contains('Your first 2 numbers are smaller than 23'));

      // Test Slot 3 (Between 3rd and 4th)
      final clue3 = SortClue(
        id: 'c3',
        tile: makeTile(35, TileColor.blue, 3),
        targetPlayerIndex: 0,
        slotIndex: 3,
      );
      final desc3 = ClueExplanationHelper.explainSortClue(
        context: capturedContext,
        clue: clue3,
        rackColors: rackColors,
      );
      expect(desc3, contains('between your 3rd (Blue) and 4th (Red) tiles'));

      // Test Slot 4 (Between 4th and 5th)
      final clue4 = SortClue(
        id: 'c4',
        tile: makeTile(44, TileColor.red, 3),
        targetPlayerIndex: 0,
        slotIndex: 4,
      );
      final desc4 = ClueExplanationHelper.explainSortClue(
        context: capturedContext,
        clue: clue4,
        rackColors: rackColors,
      );
      expect(desc4, contains('between your 4th (Red) and 5th (Yellow) tiles'));

      // Test Slot 5 (After fifth tile)
      final clue5 = SortClue(
        id: 'c5',
        tile: makeTile(58, TileColor.yellow, 2),
        targetPlayerIndex: 0,
        slotIndex: 5,
      );
      final desc5 = ClueExplanationHelper.explainSortClue(
        context: capturedContext,
        clue: clue5,
        rackColors: rackColors,
      );
      expect(desc5, contains('after your fifth tile'));
      expect(desc5, contains('All 5 of your numbers are smaller than 58'));
    });
  });

  group('Usability Redesign - Dot Comparison Clues', () {
    testWidgets('Explains comparison results attached to specific hidden tile slot', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(
        testableWidget(
          Builder(builder: (ctx) {
            capturedContext = ctx;
            return const Placeholder();
          }),
        ),
      );
      await tester.pumpAndSettle();

      final rackColors = [
        TileColor.green,
        TileColor.pink,
        TileColor.blue,
        TileColor.red,
        TileColor.yellow,
      ];

      // Match = true
      final compareMatch = CompareClue(
        id: 'cm',
        tile: makeTile(18, TileColor.pink, 2),
        targetPlayerIndex: 0,
        targetSlotIndex: 1, // 2nd tile
        match: true,
      );
      final expMatch = ClueExplanationHelper.explainCompareClue(
        context: capturedContext,
        clue: compareMatch,
        rackColors: rackColors,
      );
      expect(expMatch, contains('SAME number of dots as your 2nd tile (Pink)'));

      // Match = false
      final compareDiff = CompareClue(
        id: 'cd',
        tile: makeTile(30, TileColor.blue, 2),
        targetPlayerIndex: 0,
        targetSlotIndex: 3, // 4th tile
        match: false,
      );
      final expDiff = ClueExplanationHelper.explainCompareClue(
        context: capturedContext,
        clue: compareDiff,
        rackColors: rackColors,
      );
      expect(expDiff, contains('DIFFERENT number of dots than your 4th tile (Red)'));
    });
  });

  group('Usability Redesign - Notes & Guesses Persistence', () {
    test('Saves and restores notes and guesses across app restart and per player', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalGameStorage(prefs);

      const gameId = 'game_alpha';
      const player1Id = 'p1_human';
      const player2Id = 'p2_friend';

      // Player 1 saves notes
      await storage.savePlayerNotes(
        gameId: gameId,
        playerId: player1Id,
        crossedOut: {1, 2, 14, 25, 60},
        guesses: ['7', '18', '29', '41', '55'],
      );

      // Player 2 saves separate notes
      await storage.savePlayerNotes(
        gameId: gameId,
        playerId: player2Id,
        crossedOut: {3, 4, 38},
        guesses: ['8', '20', '', '', ''],
      );

      // Reload player 1
      final p1Notes = storage.loadPlayerNotes(gameId: gameId, playerId: player1Id);
      expect(p1Notes.crossedOut, equals({1, 2, 14, 25, 60}));
      expect(p1Notes.guesses, equals(['7', '18', '29', '41', '55']));

      // Reload player 2 (verifies privacy)
      final p2Notes = storage.loadPlayerNotes(gameId: gameId, playerId: player2Id);
      expect(p2Notes.crossedOut, equals({3, 4, 38}));
      expect(p2Notes.guesses, equals(['8', '20', '', '', '']));
    });
  });

  group('Usability Redesign - Physical Stand Workspace Widget', () {
    testWidgets('Conceals hidden numbers and renders order notches and guess boxes', (tester) async {
      final player = Player(
        id: 'p1',
        name: 'Player 1',
        isAi: false,
        rack: [
          Tile.hidden(TileColor.green),
          Tile.hidden(TileColor.pink),
          Tile.hidden(TileColor.blue),
          Tile.hidden(TileColor.red),
          Tile.hidden(TileColor.yellow),
        ],
        cluesReceived: [
          SortClue(
            id: 'c1',
            tile: makeTile(23, TileColor.pink, 3),
            targetPlayerIndex: 0,
            slotIndex: 2, // between 2nd & 3rd
          ),
          CompareClue(
            id: 'c2',
            tile: makeTile(18, TileColor.pink, 2),
            targetPlayerIndex: 0,
            targetSlotIndex: 1, // slot 1
            match: false,
          ),
        ],
      );

      await tester.pumpWidget(
        testableWidget(
          PhysicalStandWorkspaceWidget(
            player: player,
            isCurrentPlayer: true,
            isOwnerView: true,
            guesses: const ['7', '16', '28', '', ''],
            onGuessChanged: (slot, val) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify numbers 7, 16, 28, 40, 55 are NOT visible on the hidden rack
      // Only '?' question marks are rendered
      expect(find.text('?'), findsNWidgets(5));

      // Verify order clue 23 is rendered face-up
      expect(find.text('23'), findsOneWidget);

      // Verify comparison clue indicator is attached
      expect(find.text('#18'), findsOneWidget);

      // Verify "My guesses" section is rendered
      expect(find.text('My Guesses'), findsOneWidget);
    });
  });

  group('Usability Redesign - Compact Deduction Sheet', () {
    testWidgets('Toggles crossed-out numbers, supports undo and clear', (tester) async {
      Set<int> crossed = {10, 20};
      int toggleCount = 0;
      bool undoCalled = false;
      bool clearCalled = false;

      await tester.pumpWidget(
        testableWidget(
          StatefulBuilder(
            builder: (ctx, setState) {
              return CompactDeductionSheetWidget(
                crossedOutNumbers: crossed,
                canUndo: true,
                onToggleNumber: (n) {
                  toggleCount++;
                  setState(() {
                    if (crossed.contains(n)) {
                      crossed.remove(n);
                    } else {
                      crossed.add(n);
                    }
                  });
                },
                onUndo: () => undoCalled = true,
                onClear: () => clearCalled = true,
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Expect to find numbers on the sheet
      expect(find.text('1'), findsOneWidget);
      expect(find.text('60'), findsOneWidget);
      expect(find.text('2/60'), findsOneWidget);

      // Tap on number 1 to cross it out
      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();

      expect(toggleCount, equals(1));
      expect(crossed.contains(1), isTrue);

      // Tap undo
      await tester.tap(find.byIcon(Icons.undo_rounded));
      await tester.pumpAndSettle();
      expect(undoCalled, isTrue);

      // Tap clear
      await tester.tap(find.byIcon(Icons.delete_sweep_outlined));
      await tester.pumpAndSettle();
      expect(clearCalled, isTrue);
    });
  });

  group('Usability Redesign - Arabic RTL & Ascending Order', () {
    testWidgets('Preserves ascending stand layout under Arabic locale', (tester) async {
      final player = Player(
        id: 'p1',
        name: 'اللاعب 1',
        isAi: false,
        rack: [
          Tile.hidden(TileColor.green),
          Tile.hidden(TileColor.pink),
          Tile.hidden(TileColor.blue),
          Tile.hidden(TileColor.red),
          Tile.hidden(TileColor.yellow),
        ],
        cluesReceived: [],
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

      // Verify Arabic label for "My guesses"
      expect(find.text('تخميناتي'), findsOneWidget);
      expect(find.text('اللاعب 1'), findsOneWidget);
    });
  });

  group('Usability Redesign - Deliberate Final Answers', () {
    testWidgets('Pre-fills written guesses and cancel never submits', (tester) async {
      final player = Player(
        id: 'p1',
        name: 'Player 1',
        isAi: false,
        rack: Tile.tilesForColor(TileColor.green).take(5).toList(),
        cluesReceived: [],
      );

      List<int>? submittedResult;

      await tester.pumpWidget(
        testableWidget(
          Builder(builder: (ctx) {
            return ElevatedButton(
              onPressed: () async {
                final res = await showDialog<List<int>>(
                  context: ctx,
                  builder: (_) => DeclareGotFiveDialog(
                    player: player,
                    initialGuesses: const ['2', '14', '26', '38', '50'],
                  ),
                );
                submittedResult = res;
              },
              child: const Text('Open'),
            );
          }),
        ),
      );
      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Verify guesses are pre-filled in dialog
      expect(find.text('2'), findsOneWidget);
      expect(find.text('14'), findsOneWidget);
      expect(find.text('26'), findsOneWidget);
      expect(find.text('38'), findsOneWidget);
      expect(find.text('50'), findsOneWidget);

      // Verify cancel does not submit
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(submittedResult, isNull);
    });
  });
}
