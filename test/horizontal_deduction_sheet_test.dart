import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:got_five_app/domain/models/tile.dart';
import 'package:got_five_app/l10n/app_localizations.dart';
import 'package:got_five_app/ui/widgets/compact_deduction_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestSheet({
    Locale locale = const Locale('en'),
    Size size = const Size(360, 640),
    Set<int> autoRevealed = const {},
    Set<int> manualNotes = const {},
    int? highlightedNumber,
    ValueChanged<int>? onToggle,
    VoidCallback? onUndo,
    VoidCallback? onClear,
    bool canUndo = false,
  }) {
    return MediaQuery(
      data: MediaQueryData(size: size),
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: size.width,
              child: SingleChildScrollView(
                child: CompactDeductionSheetWidget(
                  autoRevealedNumbers: autoRevealed,
                  manualCrossedOutNumbers: manualNotes,
                  highlightedNumber: highlightedNumber,
                  onToggleNumber: onToggle ?? (_) {},
                  onUndo: onUndo,
                  onClear: onClear,
                  canUndo: canUndo,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  group('Horizontal 1-Row-Per-Color Deduction Sheet Tests', () {
    testWidgets('Each color occupies exactly 1 horizontal row containing all 12 numbers (never wraps)', (tester) async {
      await tester.pumpWidget(buildTestSheet());
      await tester.pumpAndSettle();

      // Check Green row (1, 6, 11, 16, 21, 26, 31, 36, 41, 46, 51, 56)
      final greenTiles = Tile.tilesForColor(TileColor.green);
      expect(greenTiles.length, equals(12));
      final greenY = tester.getCenter(find.text('${greenTiles[0].number}')).dy;
      for (final t in greenTiles) {
        final cellY = tester.getCenter(find.text('${t.number}')).dy;
        expect(cellY, moreOrLessEquals(greenY, epsilon: 0.5), reason: 'Tile ${t.number} must be on the same horizontal row');
      }

      // Check Pink row (2, 7, 12, ...)
      final pinkTiles = Tile.tilesForColor(TileColor.pink);
      final pinkY = tester.getCenter(find.text('${pinkTiles[0].number}')).dy;
      expect(pinkY, greaterThan(greenY));
      for (final t in pinkTiles) {
        final cellY = tester.getCenter(find.text('${t.number}')).dy;
        expect(cellY, moreOrLessEquals(pinkY, epsilon: 0.5), reason: 'Tile ${t.number} must be on the same horizontal row');
      }

      // Check Blue row (3, 8, 13, ...)
      final blueTiles = Tile.tilesForColor(TileColor.blue);
      final blueY = tester.getCenter(find.text('${blueTiles[0].number}')).dy;
      expect(blueY, greaterThan(pinkY));

      // Check Red row (4, 9, 14, ...)
      final redTiles = Tile.tilesForColor(TileColor.red);
      final redY = tester.getCenter(find.text('${redTiles[0].number}')).dy;
      expect(redY, greaterThan(blueY));

      // Check Yellow row (5, 10, 15, ...)
      final yellowTiles = Tile.tilesForColor(TileColor.yellow);
      final yellowY = tester.getCenter(find.text('${yellowTiles[0].number}')).dy;
      expect(yellowY, greaterThan(redY));
    });

    testWidgets('Columns stay strictly aligned across all 5 rows', (tester) async {
      await tester.pumpWidget(buildTestSheet());
      await tester.pumpAndSettle();

      // Column 0: Green 1, Pink 2, Blue 3, Red 4, Yellow 5
      final col0X1 = tester.getCenter(find.text('1')).dx;
      final col0X2 = tester.getCenter(find.text('2')).dx;
      final col0X3 = tester.getCenter(find.text('3')).dx;
      final col0X4 = tester.getCenter(find.text('4')).dx;
      final col0X5 = tester.getCenter(find.text('5')).dx;

      expect(col0X2, moreOrLessEquals(col0X1, epsilon: 0.1));
      expect(col0X3, moreOrLessEquals(col0X1, epsilon: 0.1));
      expect(col0X4, moreOrLessEquals(col0X1, epsilon: 0.1));
      expect(col0X5, moreOrLessEquals(col0X1, epsilon: 0.1));

      // Column 1: Green 6, Pink 7, Blue 8, Red 9, Yellow 10
      final col1X6 = tester.getCenter(find.text('6')).dx;
      final col1X7 = tester.getCenter(find.text('7')).dx;
      final col1X8 = tester.getCenter(find.text('8')).dx;
      final col1X9 = tester.getCenter(find.text('9')).dx;
      final col1X10 = tester.getCenter(find.text('10')).dx;

      expect(col1X7, moreOrLessEquals(col1X6, epsilon: 0.1));
      expect(col1X8, moreOrLessEquals(col1X6, epsilon: 0.1));
      expect(col1X9, moreOrLessEquals(col1X6, epsilon: 0.1));
      expect(col1X10, moreOrLessEquals(col1X6, epsilon: 0.1));

      expect(col1X6, greaterThan(col0X1));
    });

    testWidgets('All 60 numbers fit simultaneously at 320px and 360px widths without horizontal scrolling', (tester) async {
      for (final width in [320.0, 360.0]) {
        await tester.pumpWidget(buildTestSheet(size: Size(width, 600)));
        await tester.pumpAndSettle();

        // Ensure NO horizontal SingleChildScrollView exists inside the sheet
        final horizontalScrolls = find.byWidgetPredicate(
          (w) => w is SingleChildScrollView && w.scrollDirection == Axis.horizontal,
        );
        expect(horizontalScrolls, findsNothing, reason: 'Horizontal scrolling must be removed at width $width');

        // Verify all 60 tile numbers are visible on screen within horizontal bounds [0, width]
        for (int n = 1; n <= 60; n++) {
          final textFinder = find.text('$n');
          expect(textFinder, findsOneWidget, reason: 'Tile $n must be visible at width $width');
          final center = tester.getCenter(textFinder);
          expect(center.dx, greaterThan(0.0), reason: 'Tile $n must be within left screen boundary at width $width');
          expect(center.dx, lessThan(width), reason: 'Tile $n must be within right screen boundary at width $width');
        }
      }
    });

    testWidgets('Tapping adjacent cells triggers accurate tile callbacks at 320px width', (tester) async {
      final List<int> tapped = [];
      await tester.pumpWidget(
        buildTestSheet(
          size: const Size(320, 600),
          onToggle: (n) => tapped.add(n),
        ),
      );
      await tester.pumpAndSettle();

      // Horizontally adjacent: Tile 1 (Green col 0) and Tile 6 (Green col 1)
      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();
      expect(tapped.last, equals(1));

      await tester.tap(find.text('6'));
      await tester.pumpAndSettle();
      expect(tapped.last, equals(6));

      // Vertically adjacent: Tile 1 (Green row 0 col 0) and Tile 2 (Pink row 1 col 0)
      await tester.tap(find.text('2'));
      await tester.pumpAndSettle();
      expect(tapped.last, equals(2));

      // Another pair: Tile 56 (Green col 11) and Tile 57 (Pink col 11)
      await tester.tap(find.text('56'));
      await tester.pumpAndSettle();
      expect(tapped.last, equals(56));

      await tester.tap(find.text('57'));
      await tester.pumpAndSettle();
      expect(tapped.last, equals(57));

      expect(tapped, equals([1, 6, 2, 56, 57]));
    });

    testWidgets('Numbers are strictly left-to-right ascending in Arabic RTL locale', (tester) async {
      await tester.pumpWidget(buildTestSheet(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      // In Arabic locale, numbers must still ascend from left to right (LTR)
      // Tile 1 is to the left of Tile 6, which is to the left of Tile 11
      final tile1X = tester.getCenter(find.text('1')).dx;
      final tile6X = tester.getCenter(find.text('6')).dx;
      final tile11X = tester.getCenter(find.text('11')).dx;

      expect(tile1X, lessThan(tile6X));
      expect(tile6X, lessThan(tile11X));

      // Pinned color symbol is on the left (the start of the row)
      final greenSymbolX = tester.getCenter(find.text(Tile.symbolForColor(TileColor.green).symbolUnicode).first).dx;
      expect(greenSymbolX, lessThan(tile1X));
    });

    testWidgets('Preserves auto-revealed tiles, manual marks, undo, and clear', (tester) async {
      Set<int> manualNotes = {1};
      final autoRevealed = {6, 11};
      int toggled = 0;
      bool undoCalled = false;
      bool clearCalled = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (ctx, setState) {
            return buildTestSheet(
              autoRevealed: autoRevealed,
              manualNotes: manualNotes,
              canUndo: true,
              onToggle: (n) {
                toggled = n;
                setState(() {
                  if (manualNotes.contains(n)) {
                    manualNotes.remove(n);
                  } else {
                    manualNotes.add(n);
                  }
                });
              },
              onUndo: () => undoCalled = true,
              onClear: () => clearCalled = true,
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      // Total count badge is 3/60
      expect(find.text('3/60'), findsOneWidget);

      // Tap on auto-revealed tile (6) -> should NOT trigger onToggle
      await tester.tap(find.text('6'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(toggled, equals(0));

      // Tap on manual tile (1) -> should toggle
      await tester.tap(find.text('1'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(toggled, equals(1));
      expect(manualNotes.contains(1), isFalse);

      // Undo button
      await tester.tap(find.byIcon(Icons.undo_rounded));
      await tester.pumpAndSettle();
      expect(undoCalled, isTrue);

      // Re-add note to test clear
      manualNotes.add(1);
      await tester.pumpWidget(
        buildTestSheet(
          autoRevealed: autoRevealed,
          manualNotes: manualNotes,
          onClear: () => clearCalled = true,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_sweep_outlined));
      await tester.pumpAndSettle();
      expect(clearCalled, isTrue);
    });
  });
}
