import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Got Five!'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Deduce your 5 hidden numbers before anyone else!'**
  String get tagline;

  /// No description provided for @singlePlayer.
  ///
  /// In en, this message translates to:
  /// **'Single Player'**
  String get singlePlayer;

  /// No description provided for @multiplayer.
  ///
  /// In en, this message translates to:
  /// **'Online Multiplayer'**
  String get multiplayer;

  /// No description provided for @tableMode.
  ///
  /// In en, this message translates to:
  /// **'Tabletop & Paper Mode'**
  String get tableMode;

  /// No description provided for @tutorial.
  ///
  /// In en, this message translates to:
  /// **'Interactive Tutorial'**
  String get tutorial;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @printMaterials.
  ///
  /// In en, this message translates to:
  /// **'Printable Sheets (PDF)'**
  String get printMaterials;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkTheme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightTheme;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System Theme'**
  String get systemTheme;

  /// No description provided for @soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get soundEffects;

  /// No description provided for @hapticFeedback.
  ///
  /// In en, this message translates to:
  /// **'Haptic Feedback'**
  String get hapticFeedback;

  /// No description provided for @reducedMotion.
  ///
  /// In en, this message translates to:
  /// **'Reduced Motion'**
  String get reducedMotion;

  /// No description provided for @accessibilityShapes.
  ///
  /// In en, this message translates to:
  /// **'Shape Indicators'**
  String get accessibilityShapes;

  /// No description provided for @accessibilityDesc.
  ///
  /// In en, this message translates to:
  /// **'Displays geometric symbols (triangle, circle, square, diamond, star) alongside colors for color-blind friendliness.'**
  String get accessibilityDesc;

  /// No description provided for @newGame.
  ///
  /// In en, this message translates to:
  /// **'New Game'**
  String get newGame;

  /// No description provided for @resumeGame.
  ///
  /// In en, this message translates to:
  /// **'Resume Game'**
  String get resumeGame;

  /// No description provided for @abandonGame.
  ///
  /// In en, this message translates to:
  /// **'Abandon Game'**
  String get abandonGame;

  /// No description provided for @abandonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to abandon the current game?'**
  String get abandonConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @selectOpponents.
  ///
  /// In en, this message translates to:
  /// **'Configure Opponents'**
  String get selectOpponents;

  /// No description provided for @playerCount.
  ///
  /// In en, this message translates to:
  /// **'Number of Players'**
  String get playerCount;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get yourName;

  /// No description provided for @aiDifficulty.
  ///
  /// In en, this message translates to:
  /// **'AI Difficulty'**
  String get aiDifficulty;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// No description provided for @startGame.
  ///
  /// In en, this message translates to:
  /// **'Start Match'**
  String get startGame;

  /// No description provided for @yourTurn.
  ///
  /// In en, this message translates to:
  /// **'Your Turn'**
  String get yourTurn;

  /// No description provided for @waitingFor.
  ///
  /// In en, this message translates to:
  /// **'Turn: {name}'**
  String waitingFor(String name);

  /// No description provided for @step1Reveal.
  ///
  /// In en, this message translates to:
  /// **'Step 1: Reveal a Tile'**
  String get step1Reveal;

  /// No description provided for @step1RevealDesc.
  ///
  /// In en, this message translates to:
  /// **'Select a color to draw a random tile from the reserve into the common pool.'**
  String get step1RevealDesc;

  /// No description provided for @step2Clue.
  ///
  /// In en, this message translates to:
  /// **'Step 2: Choose a Clue'**
  String get step2Clue;

  /// No description provided for @step2ClueDesc.
  ///
  /// In en, this message translates to:
  /// **'Pick 1 of the 6 pool tiles and ask for either a SORT or COMPARE clue.'**
  String get step2ClueDesc;

  /// No description provided for @poolTiles.
  ///
  /// In en, this message translates to:
  /// **'Common Pool'**
  String get poolTiles;

  /// No description provided for @yourRack.
  ///
  /// In en, this message translates to:
  /// **'Your Stand (Ascending Order)'**
  String get yourRack;

  /// No description provided for @opponents.
  ///
  /// In en, this message translates to:
  /// **'Opponents'**
  String get opponents;

  /// No description provided for @cluesReceived.
  ///
  /// In en, this message translates to:
  /// **'Clues Collected'**
  String get cluesReceived;

  /// No description provided for @sortClue.
  ///
  /// In en, this message translates to:
  /// **'Sort Clue (Order)'**
  String get sortClue;

  /// No description provided for @compareClue.
  ///
  /// In en, this message translates to:
  /// **'Compare Clue (Dots)'**
  String get compareClue;

  /// No description provided for @sortClueDesc.
  ///
  /// In en, this message translates to:
  /// **'Places the tile in one of 6 positions relative to your 5 hidden numbers.'**
  String get sortClueDesc;

  /// No description provided for @compareClueDesc.
  ///
  /// In en, this message translates to:
  /// **'Ask if this tile has the same number of dots as one of your 5 stand tiles (Yes/No).'**
  String get compareClueDesc;

  /// No description provided for @selectRackSlotToCompare.
  ///
  /// In en, this message translates to:
  /// **'Select which of your 5 tiles to compare dots with:'**
  String get selectRackSlotToCompare;

  /// No description provided for @declareGotFive.
  ///
  /// In en, this message translates to:
  /// **'Announce \"GOT FIVE!\"'**
  String get declareGotFive;

  /// No description provided for @declareGotFiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Declare Got Five!'**
  String get declareGotFiveTitle;

  /// No description provided for @declareGotFiveDesc.
  ///
  /// In en, this message translates to:
  /// **'You have ONLY ONE ATTEMPT! If all 5 numbers are correct, you win immediately. If any number is wrong, you are eliminated.'**
  String get declareGotFiveDesc;

  /// No description provided for @enterYourFiveNumbers.
  ///
  /// In en, this message translates to:
  /// **'Enter your 5 numbers in strictly ascending order:'**
  String get enterYourFiveNumbers;

  /// No description provided for @submitGuess.
  ///
  /// In en, this message translates to:
  /// **'Submit Guess'**
  String get submitGuess;

  /// No description provided for @incorrectGuessFormat.
  ///
  /// In en, this message translates to:
  /// **'Numbers must be between 1 and 60 in strictly ascending order.'**
  String get incorrectGuessFormat;

  /// No description provided for @gameOver.
  ///
  /// In en, this message translates to:
  /// **'Game Over'**
  String get gameOver;

  /// No description provided for @victory.
  ///
  /// In en, this message translates to:
  /// **'Victory!'**
  String get victory;

  /// No description provided for @eliminated.
  ///
  /// In en, this message translates to:
  /// **'Eliminated!'**
  String get eliminated;

  /// No description provided for @congratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! You correctly deduced all 5 numbers!'**
  String get congratulations;

  /// No description provided for @eliminationNotice.
  ///
  /// In en, this message translates to:
  /// **'Unfortunately, your guess was incorrect. You have been eliminated.'**
  String get eliminationNotice;

  /// No description provided for @lastPlayerStanding.
  ///
  /// In en, this message translates to:
  /// **'All other players were eliminated. You win!'**
  String get lastPlayerStanding;

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get playAgain;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Return to Home'**
  String get backToHome;

  /// No description provided for @deductionSheet.
  ///
  /// In en, this message translates to:
  /// **'Deduction Sheet'**
  String get deductionSheet;

  /// No description provided for @crossOut.
  ///
  /// In en, this message translates to:
  /// **'Cross Out'**
  String get crossOut;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @candidateNumbers.
  ///
  /// In en, this message translates to:
  /// **'Candidate Numbers'**
  String get candidateNumbers;

  /// No description provided for @green.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get green;

  /// No description provided for @pink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get pink;

  /// No description provided for @blue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get blue;

  /// No description provided for @red.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get red;

  /// No description provided for @yellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get yellow;

  /// No description provided for @dots.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 dot} other{{count} dots}}'**
  String dots(int count);

  /// No description provided for @slotBefore.
  ///
  /// In en, this message translates to:
  /// **'Before all (< {color})'**
  String slotBefore(String color);

  /// No description provided for @slotBetween.
  ///
  /// In en, this message translates to:
  /// **'Between {color1} and {color2}'**
  String slotBetween(String color1, String color2);

  /// No description provided for @slotAfter.
  ///
  /// In en, this message translates to:
  /// **'After all (> {color})'**
  String slotAfter(String color);

  /// No description provided for @matchYes.
  ///
  /// In en, this message translates to:
  /// **'YES (Same dots)'**
  String get matchYes;

  /// No description provided for @matchNo.
  ///
  /// In en, this message translates to:
  /// **'NO (Different dots)'**
  String get matchNo;

  /// No description provided for @tutorialTitle.
  ///
  /// In en, this message translates to:
  /// **'How to Play Got Five!'**
  String get tutorialTitle;

  /// No description provided for @tutorialStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Goal of the Game'**
  String get tutorialStep1Title;

  /// No description provided for @tutorialStep1Desc.
  ///
  /// In en, this message translates to:
  /// **'Be the first to correctly deduce the 5 numbers on your stand. Your 5 tiles are always arranged in strictly ascending order (from smallest to largest). You can see their colors, but NOT their numbers!'**
  String get tutorialStep1Desc;

  /// No description provided for @tutorialStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Opponents & Pool'**
  String get tutorialStep2Title;

  /// No description provided for @tutorialStep2Desc.
  ///
  /// In en, this message translates to:
  /// **'You CAN see the numbers and dots of all your opponents\' tiles, plus the 5 tiles in the common pool! Cross them off on your deduction sheet immediately.'**
  String get tutorialStep2Desc;

  /// No description provided for @tutorialStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Step 1: Reveal a Tile'**
  String get tutorialStep3Title;

  /// No description provided for @tutorialStep3Desc.
  ///
  /// In en, this message translates to:
  /// **'On your turn, choose a color to draw a tile from the reserve and add it to the pool, expanding it to 6 tiles.'**
  String get tutorialStep3Desc;

  /// No description provided for @tutorialStep4Title.
  ///
  /// In en, this message translates to:
  /// **'Step 2: Ask for a Clue'**
  String get tutorialStep4Title;

  /// No description provided for @tutorialStep4Desc.
  ///
  /// In en, this message translates to:
  /// **'Choose 1 of the 6 pool tiles for either SORT (determines where it fits among your 5 numbers) or COMPARE (asks if it shares the same dot count with one of your tiles).'**
  String get tutorialStep4Desc;

  /// No description provided for @tutorialStep5Title.
  ///
  /// In en, this message translates to:
  /// **'The Got Five Guess'**
  String get tutorialStep5Title;

  /// No description provided for @tutorialStep5Desc.
  ///
  /// In en, this message translates to:
  /// **'When you have deduced your 5 numbers, shout \"GOT FIVE!\" and declare them. You have only 1 attempt. Correct = Instant Win! Wrong = Eliminated!'**
  String get tutorialStep5Desc;

  /// No description provided for @nextStep.
  ///
  /// In en, this message translates to:
  /// **'Next Step'**
  String get nextStep;

  /// No description provided for @previousStep.
  ///
  /// In en, this message translates to:
  /// **'Previous Step'**
  String get previousStep;

  /// No description provided for @finishTutorial.
  ///
  /// In en, this message translates to:
  /// **'Got It! Let\'s Play'**
  String get finishTutorial;

  /// No description provided for @pdfSheetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Printable Game Materials (PDF)'**
  String get pdfSheetsTitle;

  /// No description provided for @pdfA4ColorSheet.
  ///
  /// In en, this message translates to:
  /// **'Color A4 Deduction Sheet'**
  String get pdfA4ColorSheet;

  /// No description provided for @pdfBwEcoSheet.
  ///
  /// In en, this message translates to:
  /// **'Ink-Saver B&W Deduction Sheet'**
  String get pdfBwEcoSheet;

  /// No description provided for @pdfRulesSummary.
  ///
  /// In en, this message translates to:
  /// **'Official Rules Summary (A4)'**
  String get pdfRulesSummary;

  /// No description provided for @pdfCutoutTiles.
  ///
  /// In en, this message translates to:
  /// **'Cut-Out Tiles & Stands Sheet'**
  String get pdfCutoutTiles;

  /// No description provided for @downloadOrPrint.
  ///
  /// In en, this message translates to:
  /// **'Print / Export PDF'**
  String get downloadOrPrint;

  /// No description provided for @offlineReady.
  ///
  /// In en, this message translates to:
  /// **'Generated 100% offline inside the app'**
  String get offlineReady;

  /// No description provided for @onlineRooms.
  ///
  /// In en, this message translates to:
  /// **'Online Multiplayer Rooms'**
  String get onlineRooms;

  /// No description provided for @roomCode.
  ///
  /// In en, this message translates to:
  /// **'Room Code'**
  String get roomCode;

  /// No description provided for @createRoom.
  ///
  /// In en, this message translates to:
  /// **'Create Room'**
  String get createRoom;

  /// No description provided for @joinRoom.
  ///
  /// In en, this message translates to:
  /// **'Join Room'**
  String get joinRoom;

  /// No description provided for @waitingForPlayers.
  ///
  /// In en, this message translates to:
  /// **'Waiting for players to join...'**
  String get waitingForPlayers;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// No description provided for @startOnlineMatch.
  ///
  /// In en, this message translates to:
  /// **'Start Match'**
  String get startOnlineMatch;

  /// No description provided for @tabletopPaperModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Tabletop & Paper Modes'**
  String get tabletopPaperModeTitle;

  /// No description provided for @tabletopModeADesc.
  ///
  /// In en, this message translates to:
  /// **'Connected Phones + Paper Notes: Play digitally while tracking deductions on a printed paper sheet.'**
  String get tabletopModeADesc;

  /// No description provided for @tabletopModeBDesc.
  ///
  /// In en, this message translates to:
  /// **'Single Shared Phone: One phone manages the game. Pass it around with a privacy screen between turns.'**
  String get tabletopModeBDesc;

  /// No description provided for @tabletopModeCDesc.
  ///
  /// In en, this message translates to:
  /// **'Helper Phone + Physical Tiles: Use the phone to manage clues for real physical tiles without peeking.'**
  String get tabletopModeCDesc;

  /// No description provided for @passPhoneTo.
  ///
  /// In en, this message translates to:
  /// **'Pass the phone to {player}'**
  String passPhoneTo(String player);

  /// No description provided for @privacyScreenNotice.
  ///
  /// In en, this message translates to:
  /// **'Tap when you are ready to view your clues. Keep the screen hidden from opponents!'**
  String get privacyScreenNotice;

  /// No description provided for @revealMyTurn.
  ///
  /// In en, this message translates to:
  /// **'I am {player} - Start My Turn'**
  String revealMyTurn(String player);

  /// No description provided for @myGuesses.
  ///
  /// In en, this message translates to:
  /// **'My Guesses'**
  String get myGuesses;

  /// No description provided for @announceNumbers.
  ///
  /// In en, this message translates to:
  /// **'Announce My Numbers'**
  String get announceNumbers;

  /// No description provided for @showPosition.
  ///
  /// In en, this message translates to:
  /// **'Show Position'**
  String get showPosition;

  /// No description provided for @compareDots.
  ///
  /// In en, this message translates to:
  /// **'Compare Dots'**
  String get compareDots;

  /// No description provided for @confirmCompare.
  ///
  /// In en, this message translates to:
  /// **'Confirm Comparison'**
  String get confirmCompare;

  /// No description provided for @chooseColorToReveal.
  ///
  /// In en, this message translates to:
  /// **'Choose a color to reveal a tile.'**
  String get chooseColorToReveal;

  /// No description provided for @chooseSharedTile.
  ///
  /// In en, this message translates to:
  /// **'Choose a shared tile.'**
  String get chooseSharedTile;

  /// No description provided for @chooseClueAction.
  ///
  /// In en, this message translates to:
  /// **'Show its position, or compare its dots.'**
  String get chooseClueAction;

  /// No description provided for @tapTileToCompare.
  ///
  /// In en, this message translates to:
  /// **'Tap one of your 5 hidden tiles to compare dots.'**
  String get tapTileToCompare;

  /// No description provided for @clueSavedUpdateNotes.
  ///
  /// In en, this message translates to:
  /// **'Your clue is saved. Update your notes.'**
  String get clueSavedUpdateNotes;

  /// No description provided for @sameDots.
  ///
  /// In en, this message translates to:
  /// **'Same number of dots'**
  String get sameDots;

  /// No description provided for @differentDots.
  ///
  /// In en, this message translates to:
  /// **'Different number of dots'**
  String get differentDots;

  /// No description provided for @posFirst.
  ///
  /// In en, this message translates to:
  /// **'1st'**
  String get posFirst;

  /// No description provided for @posSecond.
  ///
  /// In en, this message translates to:
  /// **'2nd'**
  String get posSecond;

  /// No description provided for @posThird.
  ///
  /// In en, this message translates to:
  /// **'3rd'**
  String get posThird;

  /// No description provided for @posFourth.
  ///
  /// In en, this message translates to:
  /// **'4th'**
  String get posFourth;

  /// No description provided for @posFifth.
  ///
  /// In en, this message translates to:
  /// **'5th'**
  String get posFifth;

  /// No description provided for @gapBeforeFirst.
  ///
  /// In en, this message translates to:
  /// **'Before 1st'**
  String get gapBeforeFirst;

  /// No description provided for @gapBetween.
  ///
  /// In en, this message translates to:
  /// **'Between {pos1} & {pos2}'**
  String gapBetween(String pos1, String pos2);

  /// No description provided for @gapAfterLast.
  ///
  /// In en, this message translates to:
  /// **'After 5th'**
  String get gapAfterLast;

  /// No description provided for @orderClueBeforeFirstDesc.
  ///
  /// In en, this message translates to:
  /// **'{number} is before your first tile ({color}). All 5 of your numbers are larger than {number}.'**
  String orderClueBeforeFirstDesc(int number, String color);

  /// No description provided for @orderClueBetweenDesc.
  ///
  /// In en, this message translates to:
  /// **'{number} is between your {pos1} ({color1}) and {pos2} ({color2}) tiles. Your first {count1} {count1, plural, =1{number is} other{numbers are}} smaller than {number}; your remaining {count2} {count2, plural, =1{is} other{are}} larger.'**
  String orderClueBetweenDesc(
    int number,
    String pos1,
    String color1,
    String pos2,
    String color2,
    int count1,
    int count2,
  );

  /// No description provided for @orderClueAfterLastDesc.
  ///
  /// In en, this message translates to:
  /// **'{number} is after your fifth tile ({color}). All 5 of your numbers are smaller than {number}.'**
  String orderClueAfterLastDesc(int number, String color);

  /// No description provided for @compareClueSameDesc.
  ///
  /// In en, this message translates to:
  /// **'Tile #{number} ({dots, plural, =1{1 dot} other{{dots} dots}}) has the SAME number of dots as your {pos} tile ({color}).'**
  String compareClueSameDesc(int number, int dots, String pos, String color);

  /// No description provided for @compareClueDiffDesc.
  ///
  /// In en, this message translates to:
  /// **'Tile #{number} ({dots, plural, =1{1 dot} other{{dots} dots}}) has a DIFFERENT number of dots than your {pos} tile ({color}).'**
  String compareClueDiffDesc(int number, int dots, String pos, String color);

  /// No description provided for @confirmAnnouncementTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Your Five Numbers'**
  String get confirmAnnouncementTitle;

  /// No description provided for @oneAttemptWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning: You have only ONE attempt in the entire game. If all 5 numbers are correct, you win immediately. If any number is wrong, you are eliminated.'**
  String get oneAttemptWarning;

  /// No description provided for @confirmSubmission.
  ///
  /// In en, this message translates to:
  /// **'Submit Final Numbers'**
  String get confirmSubmission;

  /// No description provided for @allCluesInGap.
  ///
  /// In en, this message translates to:
  /// **'Clues in this position ({count})'**
  String allCluesInGap(Object count);

  /// No description provided for @playerRevealedTile.
  ///
  /// In en, this message translates to:
  /// **'{player} revealed {number}'**
  String playerRevealedTile(String player, int number);

  /// No description provided for @computer.
  ///
  /// In en, this message translates to:
  /// **'Computer'**
  String get computer;

  /// No description provided for @inReserveCount.
  ///
  /// In en, this message translates to:
  /// **'{count} in reserve'**
  String inReserveCount(int count);

  /// No description provided for @comparedWithSlot.
  ///
  /// In en, this message translates to:
  /// **'Compared with Slot #{slot}'**
  String comparedWithSlot(int slot);

  /// No description provided for @comparisonCluesForSlot.
  ///
  /// In en, this message translates to:
  /// **'Comparison Clues for Slot #{slot} ({count})'**
  String comparisonCluesForSlot(int slot, int count);

  /// No description provided for @targetHiddenTile.
  ///
  /// In en, this message translates to:
  /// **'Target Tile: Slot #{slot} ({color})'**
  String targetHiddenTile(Object color, Object slot);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
