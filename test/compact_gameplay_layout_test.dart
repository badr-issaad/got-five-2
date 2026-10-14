import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:got_five_app/data/repositories/local_game_storage.dart';
import 'package:got_five_app/domain/engine/game_engine.dart';
import 'package:got_five_app/domain/models/clue.dart';
import 'package:got_five_app/domain/models/player.dart';
import 'package:got_five_app/domain/models/tile.dart';
import 'package:got_five_app/l10n/app_localizations.dart';
import 'package:got_five_app/ui/controllers/game_controller.dart';
import 'package:got_five_app/ui/features/game/game_screen.dart';
import 'package:got_five_app/ui/widgets/compact_deduction_sheet.dart';
import 'package:got_five_app/ui/widgets/compact_opponents_widget.dart';
import 'package:got_five_app/ui/widgets/physical_stand_workspace_widget.dart';

Tile makeTile(int number, TileColor color, int dots) => Tile(
      number: number,
      color: color,
      dots: dots.clamp(0, 3),
      symbol: Tile.symbolForColor(color),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Compact Portrait Gameplay Screen Usability', () {
    late LocalGameStorage storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      storage = LocalGameStorage(prefs);
    });

    testWidgets('Empty comparison-clue area is HIDDEN until clues exist', (tester) async {
      final playerWithoutCompareClues = Player(
        id: 'p1',
        name: 'Player 1',
        isAi: false,
        rack: [
          makeTile(5, TileColor.red, 1),
          makeTile(17, TileColor.yellow, 2),
          makeTile(29, TileColor.green, 3),
          makeTile(41, TileColor.blue, 1),
          makeTile(53, TileColor.pink, 2),
        ],
        cluesReceived: [
          // Only sort clues, no compare clues
          SortClue(
            id: 'c1',
            tile: makeTile(10, TileColor.red, 2),
            targetPlayerIndex: 0,
            slotIndex: 1,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: PhysicalStandWorkspaceWidget(
                player: playerWithoutCompareClues,
                isCurrentPlayer: true,
                isOwnerView: true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // No comparison clues exist -> comparison clue row should NOT be rendered
      expect(find.text('='), findsNothing);
      expect(find.text('≠'), findsNothing);

      // Now add a comparison clue
      final playerWithCompareClue = Player(
        id: 'p1',
        name: 'Player 1',
        isAi: false,
        rack: playerWithoutCompareClues.rack,
        cluesReceived: [
          ...playerWithoutCompareClues.cluesReceived,
          CompareClue(
            id: 'c2',
            tile: makeTile(18, TileColor.yellow, 2),
            targetPlayerIndex: 0,
            targetSlotIndex: 1,
            match: true,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: PhysicalStandWorkspaceWidget(
                player: playerWithCompareClue,
                isCurrentPlayer: true,
                isOwnerView: true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Comparison clue row is now visible with match '='
      expect(find.text('='), findsOneWidget);
    });

    testWidgets('Small Android phone (360x640) shows rack AND at least 3 complete sheet rows', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = GameController(storage: storage);
      controller.startNewGame([
        PlayerConfig(id: 'p0', name: 'Me', isAi: false),
        PlayerConfig(id: 'p1', name: 'Bot 1', isAi: true),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: GameScreen(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      // Verify opponent area, stand, guess boxes, and deduction sheet are all present
      expect(find.byType(CompactOpponentsWidget), findsOneWidget);
      expect(find.byType(PhysicalStandWorkspaceWidget), findsOneWidget);
      expect(find.text('My Guesses'), findsOneWidget);
      expect(find.byType(CompactDeductionSheetWidget), findsOneWidget);

      // Verify rack and guesses are pinned and visible simultaneously
      final guessesCenter = tester.getCenter(find.text('My Guesses')).dy;
      expect(guessesCenter, lessThan(640));

      // Verify deduction sheet cells are rendered
      final sheetCells = find.descendant(
        of: find.byType(CompactDeductionSheetWidget),
        matching: find.byType(InkWell),
      );
      expect(sheetCells, findsWidgets);

      // Verify at least 3 complete rows of sheet numbers are visible (< 640)
      // Check the center of cells in row 1, row 2, and row 3 (each color row has 12 numbers)
      final firstCellCenter = tester.getCenter(sheetCells.at(0)).dy;
      final secondRowCellCenter = tester.getCenter(sheetCells.at(12)).dy;
      final thirdRowCellCenter = tester.getCenter(sheetCells.at(24)).dy;
      expect(firstCellCenter, lessThan(secondRowCellCenter));
      expect(secondRowCellCenter, lessThan(thirdRowCellCenter));
      expect(thirdRowCellCenter, lessThan(640));
    });

    testWidgets('Arabic RTL on small screen keeps rack ascending and sheet rows visible', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = GameController(storage: storage);
      controller.startNewGame([
        PlayerConfig(id: 'p0', name: 'أنا', isAi: false),
        PlayerConfig(id: 'p1', name: 'المنافس', isAi: true),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: GameScreen(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PhysicalStandWorkspaceWidget), findsOneWidget);
      expect(find.text('تخميناتي'), findsOneWidget);
      expect(find.byType(CompactDeductionSheetWidget), findsOneWidget);

      final guessesCenter = tester.getCenter(find.text('تخميناتي')).dy;
      expect(guessesCenter, lessThan(640));

      final sheetCells = find.descendant(
        of: find.byType(CompactDeductionSheetWidget),
        matching: find.byType(InkWell),
      );
      expect(sheetCells, findsWidgets);

      final firstCellCenter = tester.getCenter(sheetCells.at(0)).dy;
      final secondRowCellCenter = tester.getCenter(sheetCells.at(12)).dy;
      final thirdRowCellCenter = tester.getCenter(sheetCells.at(24)).dy;
      expect(firstCellCenter, lessThan(secondRowCellCenter));
      expect(secondRowCellCenter, lessThan(thirdRowCellCenter));
      expect(thirdRowCellCenter, lessThan(640));
    });

    testWidgets('Large text (1.3x scale) on 360x640 screen shows at least 3 complete sheet rows without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = GameController(storage: storage);
      controller.startNewGame([
        PlayerConfig(id: 'p0', name: 'Player One', isAi: false),
        PlayerConfig(id: 'p1', name: 'Bot Rival', isAi: true),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.3),
              ),
              child: child!,
            );
          },
          home: GameScreen(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PhysicalStandWorkspaceWidget), findsOneWidget);
      expect(find.text('My Guesses'), findsOneWidget);
      expect(find.byType(CompactDeductionSheetWidget), findsOneWidget);

      final sheetCells = find.descendant(
        of: find.byType(CompactDeductionSheetWidget),
        matching: find.byType(InkWell),
      );
      expect(sheetCells, findsWidgets);

      final r1 = tester.getCenter(sheetCells.at(0)).dy;
      final r2 = tester.getCenter(sheetCells.at(12)).dy;
      final r3 = tester.getCenter(sheetCells.at(24)).dy;
      expect(r1, lessThan(r2));
      expect(r2, lessThan(r3));
      expect(r3, lessThan(640));
    });
  });
}
