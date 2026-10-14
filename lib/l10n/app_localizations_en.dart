// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Got Five!';

  @override
  String get tagline => 'Deduce your 5 hidden numbers before anyone else!';

  @override
  String get singlePlayer => 'Single Player';

  @override
  String get multiplayer => 'Online Multiplayer';

  @override
  String get tableMode => 'Tabletop & Paper Mode';

  @override
  String get tutorial => 'Interactive Tutorial';

  @override
  String get settings => 'Settings';

  @override
  String get printMaterials => 'Printable Sheets (PDF)';

  @override
  String get language => 'Language';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get french => 'Français';

  @override
  String get theme => 'Theme';

  @override
  String get darkTheme => 'Dark Mode';

  @override
  String get lightTheme => 'Light Mode';

  @override
  String get systemTheme => 'System Theme';

  @override
  String get soundEffects => 'Sound Effects';

  @override
  String get hapticFeedback => 'Haptic Feedback';

  @override
  String get reducedMotion => 'Reduced Motion';

  @override
  String get accessibilityShapes => 'Shape Indicators';

  @override
  String get accessibilityDesc =>
      'Displays geometric symbols (triangle, circle, square, diamond, star) alongside colors for color-blind friendliness.';

  @override
  String get newGame => 'New Game';

  @override
  String get resumeGame => 'Resume Game';

  @override
  String get abandonGame => 'Abandon Game';

  @override
  String get abandonConfirm =>
      'Are you sure you want to abandon the current game?';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get done => 'Done';

  @override
  String get selectOpponents => 'Configure Opponents';

  @override
  String get playerCount => 'Number of Players';

  @override
  String get yourName => 'Your Name';

  @override
  String get aiDifficulty => 'AI Difficulty';

  @override
  String get easy => 'Easy';

  @override
  String get medium => 'Medium';

  @override
  String get hard => 'Hard';

  @override
  String get startGame => 'Start Match';

  @override
  String get yourTurn => 'Your Turn';

  @override
  String waitingFor(String name) {
    return 'Turn: $name';
  }

  @override
  String get step1Reveal => 'Step 1: Reveal a Tile';

  @override
  String get step1RevealDesc =>
      'Select a color to draw a random tile from the reserve into the common pool.';

  @override
  String get step2Clue => 'Step 2: Choose a Clue';

  @override
  String get step2ClueDesc =>
      'Pick 1 of the 6 pool tiles and ask for either a SORT or COMPARE clue.';

  @override
  String get poolTiles => 'Common Pool';

  @override
  String get yourRack => 'Your Stand (Ascending Order)';

  @override
  String get opponents => 'Opponents';

  @override
  String get cluesReceived => 'Clues Collected';

  @override
  String get sortClue => 'Sort Clue (Order)';

  @override
  String get compareClue => 'Compare Clue (Dots)';

  @override
  String get sortClueDesc =>
      'Places the tile in one of 6 positions relative to your 5 hidden numbers.';

  @override
  String get compareClueDesc =>
      'Ask if this tile has the same number of dots as one of your 5 stand tiles (Yes/No).';

  @override
  String get selectRackSlotToCompare =>
      'Select which of your 5 tiles to compare dots with:';

  @override
  String get declareGotFive => 'Announce \"GOT FIVE!\"';

  @override
  String get declareGotFiveTitle => 'Declare Got Five!';

  @override
  String get declareGotFiveDesc =>
      'You have ONLY ONE ATTEMPT! If all 5 numbers are correct, you win immediately. If any number is wrong, you are eliminated.';

  @override
  String get enterYourFiveNumbers =>
      'Enter your 5 numbers in strictly ascending order:';

  @override
  String get submitGuess => 'Submit Guess';

  @override
  String get incorrectGuessFormat =>
      'Numbers must be between 1 and 60 in strictly ascending order.';

  @override
  String get gameOver => 'Game Over';

  @override
  String get victory => 'Victory!';

  @override
  String get eliminated => 'Eliminated!';

  @override
  String get congratulations =>
      'Congratulations! You correctly deduced all 5 numbers!';

  @override
  String get eliminationNotice =>
      'Unfortunately, your guess was incorrect. You have been eliminated.';

  @override
  String get lastPlayerStanding =>
      'All other players were eliminated. You win!';

  @override
  String get playAgain => 'Play Again';

  @override
  String get backToHome => 'Return to Home';

  @override
  String get deductionSheet => 'Deduction Sheet';

  @override
  String get crossOut => 'Cross Out';

  @override
  String get undo => 'Undo';

  @override
  String get clearAll => 'Clear All';

  @override
  String get notes => 'Notes';

  @override
  String get candidateNumbers => 'Candidate Numbers';

  @override
  String get green => 'Green';

  @override
  String get pink => 'Pink';

  @override
  String get blue => 'Blue';

  @override
  String get red => 'Red';

  @override
  String get yellow => 'Yellow';

  @override
  String dots(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dots',
      one: '1 dot',
    );
    return '$_temp0';
  }

  @override
  String slotBefore(String color) {
    return 'Before all (< $color)';
  }

  @override
  String slotBetween(String color1, String color2) {
    return 'Between $color1 and $color2';
  }

  @override
  String slotAfter(String color) {
    return 'After all (> $color)';
  }

  @override
  String get matchYes => 'YES (Same dots)';

  @override
  String get matchNo => 'NO (Different dots)';

  @override
  String get tutorialTitle => 'How to Play Got Five!';

  @override
  String get tutorialStep1Title => 'Goal of the Game';

  @override
  String get tutorialStep1Desc =>
      'Be the first to correctly deduce the 5 numbers on your stand. Your 5 tiles are always arranged in strictly ascending order (from smallest to largest). You can see their colors, but NOT their numbers!';

  @override
  String get tutorialStep2Title => 'Opponents & Pool';

  @override
  String get tutorialStep2Desc =>
      'You CAN see the numbers and dots of all your opponents\' tiles, plus the 5 tiles in the common pool! Cross them off on your deduction sheet immediately.';

  @override
  String get tutorialStep3Title => 'Step 1: Reveal a Tile';

  @override
  String get tutorialStep3Desc =>
      'On your turn, choose a color to draw a tile from the reserve and add it to the pool, expanding it to 6 tiles.';

  @override
  String get tutorialStep4Title => 'Step 2: Ask for a Clue';

  @override
  String get tutorialStep4Desc =>
      'Choose 1 of the 6 pool tiles for either SORT (determines where it fits among your 5 numbers) or COMPARE (asks if it shares the same dot count with one of your tiles).';

  @override
  String get tutorialStep5Title => 'The Got Five Guess';

  @override
  String get tutorialStep5Desc =>
      'When you have deduced your 5 numbers, shout \"GOT FIVE!\" and declare them. You have only 1 attempt. Correct = Instant Win! Wrong = Eliminated!';

  @override
  String get nextStep => 'Next Step';

  @override
  String get previousStep => 'Previous Step';

  @override
  String get finishTutorial => 'Got It! Let\'s Play';

  @override
  String get pdfSheetsTitle => 'Printable Game Materials (PDF)';

  @override
  String get pdfA4ColorSheet => 'Color A4 Deduction Sheet';

  @override
  String get pdfBwEcoSheet => 'Ink-Saver B&W Deduction Sheet';

  @override
  String get pdfRulesSummary => 'Official Rules Summary (A4)';

  @override
  String get pdfCutoutTiles => 'Cut-Out Tiles & Stands Sheet';

  @override
  String get downloadOrPrint => 'Print / Export PDF';

  @override
  String get offlineReady => 'Generated 100% offline inside the app';

  @override
  String get onlineRooms => 'Online Multiplayer Rooms';

  @override
  String get roomCode => 'Room Code';

  @override
  String get createRoom => 'Create Room';

  @override
  String get joinRoom => 'Join Room';

  @override
  String get waitingForPlayers => 'Waiting for players to join...';

  @override
  String get ready => 'Ready';

  @override
  String get startOnlineMatch => 'Start Match';

  @override
  String get tabletopPaperModeTitle => 'Tabletop & Paper Modes';

  @override
  String get tabletopModeADesc =>
      'Connected Phones + Paper Notes: Play digitally while tracking deductions on a printed paper sheet.';

  @override
  String get tabletopModeBDesc =>
      'Single Shared Phone: One phone manages the game. Pass it around with a privacy screen between turns.';

  @override
  String get tabletopModeCDesc =>
      'Helper Phone + Physical Tiles: Use the phone to manage clues for real physical tiles without peeking.';

  @override
  String passPhoneTo(String player) {
    return 'Pass the phone to $player';
  }

  @override
  String get privacyScreenNotice =>
      'Tap when you are ready to view your clues. Keep the screen hidden from opponents!';

  @override
  String revealMyTurn(String player) {
    return 'I am $player - Start My Turn';
  }

  @override
  String get myGuesses => 'My Guesses';

  @override
  String get announceNumbers => 'Announce My Numbers';

  @override
  String get showPosition => 'Show Position';

  @override
  String get compareDots => 'Compare Dots';

  @override
  String get confirmCompare => 'Confirm Comparison';

  @override
  String get chooseColorToReveal => 'Choose a color to reveal a tile.';

  @override
  String get chooseSharedTile => 'Choose a shared tile.';

  @override
  String get chooseClueAction => 'Show its position, or compare its dots.';

  @override
  String get tapTileToCompare =>
      'Tap one of your 5 hidden tiles to compare dots.';

  @override
  String get clueSavedUpdateNotes => 'Your clue is saved. Update your notes.';

  @override
  String get sameDots => 'Same number of dots';

  @override
  String get differentDots => 'Different number of dots';

  @override
  String get posFirst => '1st';

  @override
  String get posSecond => '2nd';

  @override
  String get posThird => '3rd';

  @override
  String get posFourth => '4th';

  @override
  String get posFifth => '5th';

  @override
  String get gapBeforeFirst => 'Before 1st';

  @override
  String gapBetween(String pos1, String pos2) {
    return 'Between $pos1 & $pos2';
  }

  @override
  String get gapAfterLast => 'After 5th';

  @override
  String orderClueBeforeFirstDesc(int number, String color) {
    return '$number is before your first tile ($color). All 5 of your numbers are larger than $number.';
  }

  @override
  String orderClueBetweenDesc(
    int number,
    String pos1,
    String color1,
    String pos2,
    String color2,
    int count1,
    int count2,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      count1,
      locale: localeName,
      other: 'numbers are',
      one: 'number is',
    );
    String _temp1 = intl.Intl.pluralLogic(
      count2,
      locale: localeName,
      other: 'are',
      one: 'is',
    );
    return '$number is between your $pos1 ($color1) and $pos2 ($color2) tiles. Your first $count1 $_temp0 smaller than $number; your remaining $count2 $_temp1 larger.';
  }

  @override
  String orderClueAfterLastDesc(int number, String color) {
    return '$number is after your fifth tile ($color). All 5 of your numbers are smaller than $number.';
  }

  @override
  String compareClueSameDesc(int number, int dots, String pos, String color) {
    String _temp0 = intl.Intl.pluralLogic(
      dots,
      locale: localeName,
      other: '$dots dots',
      one: '1 dot',
    );
    return 'Tile #$number ($_temp0) has the SAME number of dots as your $pos tile ($color).';
  }

  @override
  String compareClueDiffDesc(int number, int dots, String pos, String color) {
    String _temp0 = intl.Intl.pluralLogic(
      dots,
      locale: localeName,
      other: '$dots dots',
      one: '1 dot',
    );
    return 'Tile #$number ($_temp0) has a DIFFERENT number of dots than your $pos tile ($color).';
  }

  @override
  String get confirmAnnouncementTitle => 'Confirm Your Five Numbers';

  @override
  String get oneAttemptWarning =>
      'Warning: You have only ONE attempt in the entire game. If all 5 numbers are correct, you win immediately. If any number is wrong, you are eliminated.';

  @override
  String get confirmSubmission => 'Submit Final Numbers';

  @override
  String allCluesInGap(Object count) {
    return 'Clues in this position ($count)';
  }

  @override
  String playerRevealedTile(String player, int number) {
    return '$player revealed $number';
  }

  @override
  String get computer => 'Computer';

  @override
  String inReserveCount(int count) {
    return '$count in reserve';
  }

  @override
  String comparedWithSlot(int slot) {
    return 'Compared with Slot #$slot';
  }

  @override
  String comparisonCluesForSlot(int slot, int count) {
    return 'Comparison Clues for Slot #$slot ($count)';
  }

  @override
  String targetHiddenTile(Object color, Object slot) {
    return 'Target Tile: Slot #$slot ($color)';
  }
}
