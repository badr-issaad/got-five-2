// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Got Five! (Trouve Cinq)';

  @override
  String get tagline => 'Déduisez vos 5 numéros secrets avant tout le monde !';

  @override
  String get singlePlayer => 'Partie Solo (vs IA)';

  @override
  String get multiplayer => 'Multijoueur en ligne';

  @override
  String get tableMode => 'Mode Table & Papier';

  @override
  String get tutorial => 'Tutoriel interactif & Règles';

  @override
  String get settings => 'Paramètres';

  @override
  String get printMaterials => 'Fiches à imprimer (PDF)';

  @override
  String get language => 'Langue';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get french => 'Français';

  @override
  String get theme => 'Thème';

  @override
  String get darkTheme => 'Mode Sombre';

  @override
  String get lightTheme => 'Mode Clair';

  @override
  String get systemTheme => 'Thème Système';

  @override
  String get soundEffects => 'Effets sonores';

  @override
  String get hapticFeedback => 'Vibrations haptiques';

  @override
  String get reducedMotion => 'Mouvements réduits';

  @override
  String get accessibilityShapes => 'Symboles géométriques';

  @override
  String get accessibilityDesc =>
      'Affiche des formes (triangle, cercle, carré, losange, étoile) en plus des couleurs pour l\'accessibilité daltonienne.';

  @override
  String get newGame => 'Nouvelle Partie';

  @override
  String get resumeGame => 'Reprendre la partie';

  @override
  String get abandonGame => 'Abandonner la partie';

  @override
  String get abandonConfirm =>
      'Voulez-vous vraiment abandonner la partie en cours ?';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get close => 'Fermer';

  @override
  String get back => 'Retour';

  @override
  String get done => 'Terminé';

  @override
  String get selectOpponents => 'Configurer la partie';

  @override
  String get playerCount => 'Nombre total de joueurs';

  @override
  String get yourName => 'Votre Pseudo';

  @override
  String get aiDifficulty => 'Niveau de l\'IA';

  @override
  String get easy => 'Facile';

  @override
  String get medium => 'Moyen';

  @override
  String get hard => 'Difficile';

  @override
  String get startGame => 'Lancer la partie';

  @override
  String get yourTurn => 'C\'est votre tour !';

  @override
  String waitingFor(String name) {
    return 'Au tour de : $name';
  }

  @override
  String get step1Reveal => 'Étape 1 : Révéler une tuile';

  @override
  String get step1RevealDesc =>
      'Choisissez une couleur pour piocher une tuile de la réserve et la placer au centre.';

  @override
  String get step2Clue => 'Étape 2 : Demander un indice';

  @override
  String get step2ClueDesc =>
      'Choisissez 1 des 6 tuiles centrales pour un indice de TRI (Ordre) ou de COMPARAISON (Points).';

  @override
  String get poolTiles => 'Tuiles Communes au Centre';

  @override
  String get yourRack => 'Votre Chevalet (Ordre croissant)';

  @override
  String get opponents => 'Chevalets des adversaires';

  @override
  String get cluesReceived => 'Vos Indices collectés';

  @override
  String get sortClue => 'Indice de Tri (Ordre)';

  @override
  String get compareClue => 'Indice de Comparaison (Points)';

  @override
  String get sortClueDesc =>
      'Indique la position de la tuile parmi vos 5 numéros secrets dans 1 des 6 emplacements possibles.';

  @override
  String get compareClueDesc =>
      'Répond par Oui ou Non si la tuile a le même nombre de points qu\'une tuile de votre chevalet.';

  @override
  String get selectRackSlotToCompare =>
      'Choisissez la tuile de votre chevalet à comparer :';

  @override
  String get declareGotFive => 'Annoncer \"GOT FIVE !\"';

  @override
  String get declareGotFiveTitle => 'Déclaration Got Five !';

  @override
  String get declareGotFiveDesc =>
      'Attention : Vous n\'avez qu\'UNE SEULE TENTATIVE ! Réponse exacte = Victoire immédiate. Moindre erreur = Élimination.';

  @override
  String get enterYourFiveNumbers =>
      'Entrez vos 5 numéros dans l\'ordre strictement croissant :';

  @override
  String get submitGuess => 'Valider la déclaration';

  @override
  String get incorrectGuessFormat =>
      'Les numéros doivent être compris entre 1 et 60 et strictement croissants.';

  @override
  String get gameOver => 'Fin de Partie';

  @override
  String get victory => '🎉 Victoire !';

  @override
  String get eliminated => '❌ Éliminé !';

  @override
  String get congratulations =>
      'Félicitations ! Vous avez déduit vos 5 numéros secrets avec succès !';

  @override
  String get eliminationNotice =>
      'Malheureusement, votre déclaration était incorrecte. Vous êtes éliminé.';

  @override
  String get lastPlayerStanding =>
      'Tous les autres joueurs ont été éliminés. Vous remportez la partie !';

  @override
  String get playAgain => 'Rejouer';

  @override
  String get backToHome => 'Retour à l\'accueil';

  @override
  String get deductionSheet => 'Feuille de Déduction';

  @override
  String get crossOut => 'Barrer';

  @override
  String get undo => 'Annuler';

  @override
  String get clearAll => 'Effacer tout';

  @override
  String get notes => 'Notes';

  @override
  String get candidateNumbers => 'Numéros candidats';

  @override
  String get green => 'Vert';

  @override
  String get pink => 'Rose';

  @override
  String get blue => 'Bleu';

  @override
  String get red => 'Rouge';

  @override
  String get yellow => 'Jaune';

  @override
  String dots(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count points',
      one: '1 point',
    );
    return '$_temp0';
  }

  @override
  String slotBefore(String color) {
    return 'Avant tout (< $color)';
  }

  @override
  String slotBetween(String color1, String color2) {
    return 'Entre $color1 et $color2';
  }

  @override
  String slotAfter(String color) {
    return 'Après tout (> $color)';
  }

  @override
  String get matchYes => 'OUI (Même nombre de points)';

  @override
  String get matchNo => 'NON (Points différents)';

  @override
  String get tutorialTitle => 'Comment jouer à Got Five !';

  @override
  String get tutorialStep1Title => 'Objectif & Chevalets';

  @override
  String get tutorialStep1Desc =>
      'Soyez le premier à déduire les 5 numéros secrets de votre chevalet. Vos tuiles sont toujours classées dans l\'ordre strictement croissant. Vous voyez leurs couleurs, mais PAS leurs numéros !';

  @override
  String get tutorialStep2Title => 'Adversaires & Réserve centrale';

  @override
  String get tutorialStep2Desc =>
      'Vous voyez les numéros et points de TOUS vos adversaires, ainsi que les tuiles du centre. Barrez-les immédiatement sur votre feuille de déduction !';

  @override
  String get tutorialStep3Title => 'Étape 1 : Révéler une tuile';

  @override
  String get tutorialStep3Desc =>
      'À votre tour, choisissez une couleur pour révéler une tuile de la réserve et l\'ajouter au centre (6 tuiles au total).';

  @override
  String get tutorialStep4Title => 'Étape 2 : Demander un indice';

  @override
  String get tutorialStep4Desc =>
      'Choisissez 1 des 6 tuiles centrales pour un indice de Tri ou de Comparaison. La tuile rejoint ensuite votre espace d\'indices permanent.';

  @override
  String get tutorialStep5Title => 'La déclaration finale';

  @override
  String get tutorialStep5Desc =>
      'Quand vous êtes prêt, annoncez \"GOT FIVE !\" et énoncez vos 5 numéros secrets dans l\'ordre croissant. Une seule tentative par partie !';

  @override
  String get nextStep => 'Étape suivante';

  @override
  String get previousStep => 'Étape précédente';

  @override
  String get finishTutorial => 'Compris ! Jouons';

  @override
  String get pdfSheetsTitle => 'Matériel imprimable (PDF)';

  @override
  String get pdfA4ColorSheet => 'Feuille de déduction A4 Couleur';

  @override
  String get pdfBwEcoSheet => 'Feuille économique Noir & Blanc';

  @override
  String get pdfRulesSummary => 'Résumé officiel des règles (A4)';

  @override
  String get pdfCutoutTiles => 'Planche de tuiles et chevalets à découper';

  @override
  String get downloadOrPrint => 'Imprimer / Exporter PDF';

  @override
  String get offlineReady => 'Généré 100% hors-ligne dans l\'application';

  @override
  String get onlineRooms => 'Salons Multijoueur en Ligne';

  @override
  String get roomCode => 'Code du salon';

  @override
  String get createRoom => 'Créer un salon';

  @override
  String get joinRoom => 'Rejoindre avec un code';

  @override
  String get waitingForPlayers => 'En attente des amis...';

  @override
  String get ready => 'Prêt';

  @override
  String get startOnlineMatch => 'Démarrer la partie';

  @override
  String get tabletopPaperModeTitle => 'Modes Table & Papier';

  @override
  String get tabletopModeADesc =>
      'Téléphones connectés + Papier : Jouez numériquement tout en notant vos déductions sur votre feuille papier imprimée.';

  @override
  String get tabletopModeBDesc =>
      'Téléphone unique partagé : Un seul téléphone gère la partie et tourne entre les joueurs avec un écran de confidentialité.';

  @override
  String get tabletopModeCDesc =>
      'Assistant pour tuiles physiques : Le téléphone calcule les indices pour vos tuiles physiques réelles sans tricher.';

  @override
  String passPhoneTo(String player) {
    return 'Passez le téléphone à : $player';
  }

  @override
  String get privacyScreenNotice =>
      'Touchez quand vous avez le téléphone en main, à l\'abri des regards adverses.';

  @override
  String revealMyTurn(String player) {
    return 'C\'est $player - Commencer mon tour';
  }

  @override
  String get myGuesses => 'Mes hypothèses';

  @override
  String get announceNumbers => 'Annoncer mes numéros';

  @override
  String get showPosition => 'Montrer sa position';

  @override
  String get compareDots => 'Comparer les points';

  @override
  String get confirmCompare => 'Confirmer la comparaison';

  @override
  String get chooseColorToReveal =>
      'Choisissez une couleur pour révéler une tuile.';

  @override
  String get chooseSharedTile => 'Choisissez une tuile partagée.';

  @override
  String get chooseClueAction => 'Montrez sa position, ou comparez ses points.';

  @override
  String get tapTileToCompare =>
      'Touchez l\'une de vos 5 tuiles cachées pour comparer les points.';

  @override
  String get clueSavedUpdateNotes =>
      'Votre indice est enregistré. Mettez à jour vos notes.';

  @override
  String get sameDots => 'Même nombre de points';

  @override
  String get differentDots => 'Nombre de points différent';

  @override
  String get posFirst => '1re';

  @override
  String get posSecond => '2e';

  @override
  String get posThird => '3rd';

  @override
  String get posFourth => '4e';

  @override
  String get posFifth => '5e';

  @override
  String get gapBeforeFirst => 'Avant la 1re';

  @override
  String gapBetween(String pos1, String pos2) {
    return 'Entre $pos1 et $pos2';
  }

  @override
  String get gapAfterLast => 'Après la 5e';

  @override
  String orderClueBeforeFirstDesc(int number, String color) {
    return '$number est avant votre 1re tuile ($color). Vos 5 numéros sont plus grands que $number.';
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
    return '$number est entre votre $pos1 ($color1) et votre $pos2 ($color2). Vos $count1 premier(s) numéro(s) sont plus petits que $number ; vos $count2 restant(s) sont plus grands.';
  }

  @override
  String orderClueAfterLastDesc(int number, String color) {
    return '$number est après votre 5e tuile ($color). Vos 5 numéros sont plus petits que $number.';
  }

  @override
  String compareClueSameDesc(int number, int dots, String pos, String color) {
    String _temp0 = intl.Intl.pluralLogic(
      dots,
      locale: localeName,
      other: '$dots points',
      one: '1 point',
    );
    return 'La tuile #$number ($_temp0) a le MÊME nombre de points que votre $pos tuile ($color).';
  }

  @override
  String compareClueDiffDesc(int number, int dots, String pos, String color) {
    String _temp0 = intl.Intl.pluralLogic(
      dots,
      locale: localeName,
      other: '$dots points',
      one: '1 point',
    );
    return 'La tuile #$number ($_temp0) a un nombre de points DIFFÉRENT de votre $pos tuile ($color).';
  }

  @override
  String get confirmAnnouncementTitle => 'Confirmer vos cinq numéros';

  @override
  String get oneAttemptWarning =>
      'Attention : vous n\'avez qu\'UNE SEULE tentative. Si tout est correct, vous gagnez. Si une seule erreur, vous êtes éliminé.';

  @override
  String get confirmSubmission => 'Valider l\'annonce finale';

  @override
  String allCluesInGap(Object count) {
    return 'Indices dans cette position ($count)';
  }

  @override
  String playerRevealedTile(String player, int number) {
    return '$player a révélé le $number';
  }

  @override
  String get computer => 'L\'ordinateur';

  @override
  String inReserveCount(int count) {
    return '$count en réserve';
  }

  @override
  String comparedWithSlot(int slot) {
    return 'Comparé à la position #$slot';
  }

  @override
  String comparisonCluesForSlot(int slot, int count) {
    return 'Indices de comparaison pour la position #$slot ($count)';
  }

  @override
  String targetHiddenTile(Object color, Object slot) {
    return 'Tuile ciblée : Position #$slot ($color)';
  }
}
