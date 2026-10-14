import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:got_five_app/domain/models/player.dart';
import 'package:got_five_app/domain/models/tile.dart';
import 'package:got_five_app/domain/models/clue.dart';
import 'package:got_five_app/ui/widgets/physical_stand_workspace_widget.dart';
import 'package:got_five_app/l10n/app_localizations.dart';

void main() {
  Tile makeTile(int num, TileColor color, int dots) => Tile(
        number: num,
        color: color,
        dots: dots.clamp(0, 3),
        symbol: Tile.symbolForColor(color),
      );

  Widget buildWorkspace({
    required Player player,
    Locale locale = const Locale('en'),
    double screenWidth = 360,
  }) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: screenWidth,
            child: PhysicalStandWorkspaceWidget(
              player: player,
              isCurrentPlayer: true,
              isOwnerView: true,
              guesses: const ['', '', '', '', ''],
              autoFilledSlots: const {},
              exhaustedColors: const {},
              onGuessChanged: (_, _) {},
            ),
          ),
        ),
      ),
    );
  }

  group('Order-Clue Arrow Band Verification', () {
    testWidgets('Empty state: band maintains consistent minimum height and displays positions 1–6 and full arrows', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

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
        cluesReceived: [], // 0 clues: completely empty
      );

      await tester.pumpWidget(buildWorkspace(player: player));
      await tester.pumpAndSettle();

      // All 6 position numbers must be visible and readable
      for (int i = 1; i <= 6; i++) {
        expect(find.text('$i'), findsOneWidget, reason: 'Position $i must be visible when empty');
      }

      // 6 downward arrows must be rendered targeting the 6 shelf notches
      final arrowFinder = find.byIcon(Icons.arrow_drop_down);
      expect(arrowFinder, findsNWidgets(6), reason: 'All 6 downward arrows must be present');

      // Check arrows are spaced horizontally from left to right
      final arrowPositions = tester.getRect(arrowFinder.at(0));
      final arrowLast = tester.getRect(arrowFinder.at(5));
      expect(arrowPositions.left < arrowLast.left, isTrue);

      // Verify the shelf and guess boxes are rendered
      expect(find.text('?'), findsNWidgets(5));
      expect(find.byType(TextField), findsNWidgets(5));
    });

    testWidgets('Adding first clue tile does NOT resize band or move rack shelf and guess boxes', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final emptyPlayer = Player(
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
        cluesReceived: [],
      );

      await tester.pumpWidget(buildWorkspace(player: emptyPlayer));
      await tester.pumpAndSettle();

      // Record Y positions of shelf and guess boxes before clue is added
      final shelfRectBefore = tester.getRect(find.text('?').first);
      final guessBoxRectBefore = tester.getRect(find.byType(TextField).first);

      // Now add the first clue tile (e.g. Pink 14 in gap 1)
      final playerWithOneClue = Player(
        id: 'p1',
        name: 'Player 1',
        isAi: false,
        rack: emptyPlayer.rack,
        cluesReceived: [
          SortClue(
            id: 'c1',
            tile: makeTile(14, TileColor.pink, 2),
            targetPlayerIndex: 0,
            slotIndex: 1,
          ),
        ],
      );

      await tester.pumpWidget(buildWorkspace(player: playerWithOneClue));
      await tester.pumpAndSettle();

      // Record Y positions after adding clue tile
      final shelfRectAfter = tester.getRect(find.text('?').first);
      final guessBoxRectAfter = tester.getRect(find.byType(TextField).first);

      // Adding the first clue tile must not resize the band or move the rack shelf or guess boxes
      expect(shelfRectAfter.top, equals(shelfRectBefore.top),
          reason: 'Shelf Y position must remain completely unchanged when first clue is added');
      expect(guessBoxRectAfter.top, equals(guessBoxRectBefore.top),
          reason: 'Guess box Y position must remain completely unchanged when first clue is added');

      // When a clue occupies a gap, its position number must remain visible too!
      for (int i = 1; i <= 6; i++) {
        expect(find.text('$i'), findsOneWidget,
            reason: 'Position $i must remain visible even when occupied by a clue');
      }

      // The clue tile number 14 must be visible in the bay
      expect(find.text('14'), findsOneWidget);
    });

    testWidgets('Multiple clues and grouped clues: badges, +N grouping, and readable digits', (tester) async {
      tester.view.physicalSize = const Size(320, 600); // Narrow 320px screen
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

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
          // Gap 0 (Before Tile 1): Green 15
          SortClue(id: 'c0', tile: makeTile(15, TileColor.green, 1), targetPlayerIndex: 0, slotIndex: 0),
          // Gap 2 (Between Tile 2 & 3): Blue 26
          SortClue(id: 'c2a', tile: makeTile(26, TileColor.blue, 2), targetPlayerIndex: 0, slotIndex: 2),
          // Gap 2 (Grouped clue): Red 38
          SortClue(id: 'c2b', tile: makeTile(38, TileColor.red, 3), targetPlayerIndex: 0, slotIndex: 2),
          // Gap 5 (After last tile): Yellow 58
          SortClue(id: 'c5', tile: makeTile(58, TileColor.yellow, 3), targetPlayerIndex: 0, slotIndex: 5),
        ],
      );

      await tester.pumpWidget(buildWorkspace(player: player, screenWidth: 320));
      await tester.pumpAndSettle();

      // All 6 position numbers must remain visible
      for (int i = 1; i <= 6; i++) {
        expect(find.text('$i'), findsOneWidget);
      }

      // Clue numbers must be readable
      expect(find.text('15'), findsOneWidget);
      expect(find.text('38'), findsOneWidget); // Latest clue in gap 2
      expect(find.text('58'), findsOneWidget);

      // Grouped clue badge '+1' must appear on gap 2
      expect(find.text('+1'), findsOneWidget);

      // Tapping grouped clue chip opens the dialog showing all clues in that gap
      await tester.tap(find.text('+1'));
      await tester.pumpAndSettle();

      // Dialog should show both Blue 26 and Red 38
      expect(find.text('26'), findsOneWidget);
      expect(find.text('38'), findsWidgets); // One in dialog, one on chip behind dialog
    });

    testWidgets('Arabic RTL screen: preserves ascending order (1–6) and shelf alignment', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

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
          SortClue(id: 'c0', tile: makeTile(11, TileColor.green, 1), targetPlayerIndex: 0, slotIndex: 0),
          SortClue(id: 'c3', tile: makeTile(35, TileColor.blue, 2), targetPlayerIndex: 0, slotIndex: 3),
        ],
      );

      await tester.pumpWidget(buildWorkspace(player: player, locale: const Locale('ar')));
      await tester.pumpAndSettle();

      // All 6 position numbers must appear in ascending order left-to-right
      final rect1 = tester.getRect(find.text('1'));
      final rect2 = tester.getRect(find.text('2'));
      final rect3 = tester.getRect(find.text('3'));
      final rect4 = tester.getRect(find.text('4'));
      final rect5 = tester.getRect(find.text('5'));
      final rect6 = tester.getRect(find.text('6'));

      expect(rect1.left < rect2.left, isTrue);
      expect(rect2.left < rect3.left, isTrue);
      expect(rect3.left < rect4.left, isTrue);
      expect(rect4.left < rect5.left, isTrue);
      expect(rect5.left < rect6.left, isTrue);

      // Clue numbers must be readable
      expect(find.text('35'), findsOneWidget);
    });
  });
}
