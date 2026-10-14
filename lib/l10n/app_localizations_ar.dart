// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Got Five! (خمسة أدلة)';

  @override
  String get tagline => 'استنتج أرقامك الخمسة المخفية قبل الجميع!';

  @override
  String get singlePlayer => 'لعب فردي (ضد الكمبيوتر)';

  @override
  String get multiplayer => 'اللعب الجماعي عبر الإنترنت';

  @override
  String get tableMode => 'وضع الطاولة والورق المطبوع';

  @override
  String get tutorial => 'التدريب التفاعلي والقواعد';

  @override
  String get settings => 'الإعدادات';

  @override
  String get printMaterials => 'أوراق اللعب والطباعة (PDF)';

  @override
  String get language => 'اللغة';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get french => 'Français';

  @override
  String get theme => 'المظهر والسمة';

  @override
  String get darkTheme => 'الوضع الداكن';

  @override
  String get lightTheme => 'الوضع الفاتح';

  @override
  String get systemTheme => 'سمة النظام';

  @override
  String get soundEffects => 'المؤثرات الصوتية';

  @override
  String get hapticFeedback => 'الاهتزاز التفاعلي';

  @override
  String get reducedMotion => 'تقليل الحركة والانتقالات';

  @override
  String get accessibilityShapes => 'رموز الأشكال الهندسية';

  @override
  String get accessibilityDesc =>
      'عرض رموز هندسية واضحة (مثلث، دائرة، مربع، معين، نجمة) بجانب الألوان لمراعاة عمى الألوان.';

  @override
  String get newGame => 'مباراة جديدة';

  @override
  String get resumeGame => 'استئناف المباراة';

  @override
  String get abandonGame => 'مغادرة المباراة الحالية';

  @override
  String get abandonConfirm =>
      'هل أنت متأكد من رغبتك في إنهاء المباراة الحالية والخروج؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get close => 'إغلاق';

  @override
  String get back => 'رجوع';

  @override
  String get done => 'تم';

  @override
  String get selectOpponents => 'إعداد الخصوم والمباراة';

  @override
  String get playerCount => 'عدد اللاعبين الإجمالي';

  @override
  String get yourName => 'اسمك المستعار';

  @override
  String get aiDifficulty => 'مستوى ذكاء الكمبيوتر';

  @override
  String get easy => 'سهل';

  @override
  String get medium => 'متوسط';

  @override
  String get hard => 'صعب (تحدي استنتاجي)';

  @override
  String get startGame => 'بدء المباراة';

  @override
  String get yourTurn => 'دورك الآن!';

  @override
  String waitingFor(String name) {
    return 'الدور الحالي: $name';
  }

  @override
  String get step1Reveal => 'الخطوة 1: كشف بلاطة من الاحتياطي';

  @override
  String get step1RevealDesc =>
      'اختر لونًا لسحب بلاطة عشوائية من الاحتياطي وإضافتها إلى المنطقة المشتركة.';

  @override
  String get step2Clue => 'الخطوة 2: طلب دليل استنتاجي';

  @override
  String get step2ClueDesc =>
      'اختر واحدة من البلاطات الست في المنطقة المشتركة واطلب إما دليل ترتيب أو مقارنة نقاط.';

  @override
  String get poolTiles => 'البلاطات المشتركة في الوسط';

  @override
  String get yourRack => 'حاملك الخاص (مرتب تصاعديًا من الأصغر للأكبر)';

  @override
  String get opponents => 'حوامل الخصوم';

  @override
  String get cluesReceived => 'سلة الأدلة المجمّعة لديك';

  @override
  String get sortClue => 'دليل الترتيب (موقع البلاطة)';

  @override
  String get compareClue => 'دليل مقارنة النقاط';

  @override
  String get sortClueDesc =>
      'يحدد موقع البلاطة بدقة بين أرقامك الخمسة المخفية في واحد من 6 مواضع ممكنة.';

  @override
  String get compareClueDesc =>
      'يعطيك إجابة نعم أو لا لتطابق عدد نقاط هذه البلاطة مع إحدى بلاطات حاملك.';

  @override
  String get selectRackSlotToCompare =>
      'اختر البلاطة من حاملك لمقارنة عدد نقاطها:';

  @override
  String get declareGotFive => 'إعلان الحل: \"GOT FIVE!\"';

  @override
  String get declareGotFiveTitle => 'إعلان حل الأرقام الخمسة';

  @override
  String get declareGotFiveDesc =>
      'تنبيه مهم: لديك محاولة واحدة فقط في المباراة! الحل الصحيح يحقق الفوز الفوري، والخطأ يؤدي إلى الإقصاء المباشر.';

  @override
  String get enterYourFiveNumbers =>
      'أدخل أرقامك الخمسة بالترتيب التصاعدي الدقيق:';

  @override
  String get submitGuess => 'تأكيد وإعلان الحل';

  @override
  String get incorrectGuessFormat =>
      'يجب أن تكون الأرقام بين 1 و 60 ومرتبة تصاعديًا بدقة ودون تكرار.';

  @override
  String get gameOver => 'نهاية المباراة';

  @override
  String get victory => '🎉 مبروك! فوز مستحق!';

  @override
  String get eliminated => '❌ تم إقصاؤك!';

  @override
  String get congratulations =>
      'أحسنت صنعًا! لقد استنتجت أرقامك الخمسة المخفية بنجاح وفزت بالمباراة!';

  @override
  String get eliminationNotice =>
      'للأسف، إعلانك تضمن أرقامًا غير صحيحة فتم إقصاؤك من اللعب.';

  @override
  String get lastPlayerStanding =>
      'أُقصي جميع المنافسين الآخرين فأصبحت الفائز تلقائيًا!';

  @override
  String get playAgain => 'لعب مرة أخرى';

  @override
  String get backToHome => 'العودة للقائمة الرئيسية';

  @override
  String get deductionSheet => 'لوحة الاستنتاج';

  @override
  String get crossOut => 'شطب';

  @override
  String get undo => 'تراجع';

  @override
  String get clearAll => 'مسح الكل';

  @override
  String get notes => 'الملاحظات';

  @override
  String get candidateNumbers => 'الأرقام المرشحة';

  @override
  String get green => 'الأخضر';

  @override
  String get pink => 'الوردي';

  @override
  String get blue => 'الأزرق';

  @override
  String get red => 'الأحمر';

  @override
  String get yellow => 'الأصفر';

  @override
  String dots(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نقطة',
      many: '$count نقطة',
      few: '$count نقاط',
      two: 'نقطتان',
      one: 'نقطة واحدة',
    );
    return '$_temp0';
  }

  @override
  String slotBefore(String color) {
    return 'قبل الجميع (أصغر من $color)';
  }

  @override
  String slotBetween(String color1, String color2) {
    return 'بين $color1 و $color2';
  }

  @override
  String slotAfter(String color) {
    return 'بعد الجميع (أكبر من $color)';
  }

  @override
  String get matchYes => 'نعم (تتطابق في عدد النقاط)';

  @override
  String get matchNo => 'لا (تختلف في عدد النقاط)';

  @override
  String get tutorialTitle => 'كيف تلعب Got Five! خطوة بخطوة';

  @override
  String get tutorialStep1Title => 'هدف اللعبة وحوامل البلاطات';

  @override
  String get tutorialStep1Desc =>
      'كن أول من يستنتج أرقامه الخمسة المخفية على حامله. بلاطاتك الخمس مصفوفة تصاعديًا دائمًا من الأصغر إلى الأكبر، وترى ألوانها فقط دون أرقامها أو نقاطها!';

  @override
  String get tutorialStep2Title => 'رؤية الخصوم والمنطقة المشتركة';

  @override
  String get tutorialStep2Desc =>
      'تستطيع رؤية أرقام ونقاط جميع بلاطات المنافسين المكشوفة أمامك، بالإضافة إلى البلاطات الخمس المشتركة في الوسط. اشطب هذه الأرقام فورًا من لوحة الاستنتاج!';

  @override
  String get tutorialStep3Title => 'الخطوة الأولى: كشف بلاطة';

  @override
  String get tutorialStep3Desc =>
      'في بداية دورك، اختر لونًا لتكشف بلاطة عشوائية منه من الاحتياطي وتضعها في الوسط، فيصبح في الوسط 6 بلاطات.';

  @override
  String get tutorialStep4Title => 'الخطوة الثانية: طلب دليل';

  @override
  String get tutorialStep4Desc =>
      'اختر واحدة من بلاطات الوسط الست واطلب إما ترتيبها بين أرقامك (Sort) أو مقارنة عدد نقاطها مع إحدى بلاطاتك (Compare). ثم تنتقل البلاطة لسلة أدلتك الدائمة.';

  @override
  String get tutorialStep5Title => 'إعلان الحل والفوز أو الإقصاء';

  @override
  String get tutorialStep5Desc =>
      'عندما تتأكد من أرقامك، اضغط على إعلان الحل واذكر أرقامك الخمسة بالترتيب التصاعدي. لديك محاولة واحدة فقط: الصحة تعني الفوز الفوري، والخطأ يعني الإقصاء!';

  @override
  String get nextStep => 'الخطوة التالية';

  @override
  String get previousStep => 'الخطوة السابقة';

  @override
  String get finishTutorial => 'فهمت القواعد! فلنبدأ اللعب';

  @override
  String get pdfSheetsTitle => 'ملفات اللعب والطباعة (PDF)';

  @override
  String get pdfA4ColorSheet => 'لوحة استنتاج A4 ملونة كاملة';

  @override
  String get pdfBwEcoSheet => 'نسخة بالأبيض والأسود موفرة للحبر';

  @override
  String get pdfRulesSummary => 'ملخص القواعد الرسمية المطبوع';

  @override
  String get pdfCutoutTiles => 'بلاطات وحوامل ورقية قابلة للقص والطي';

  @override
  String get downloadOrPrint => 'طباعة / تصدير PDF';

  @override
  String get offlineReady => 'توليد محلي فوري دون الحاجة للإنترنت';

  @override
  String get onlineRooms => 'غرف اللعب عبر الإنترنت';

  @override
  String get roomCode => 'رمز الغرفة';

  @override
  String get createRoom => 'إنشاء غرفة جديدة';

  @override
  String get joinRoom => 'الانضمام برمز الغرفة';

  @override
  String get waitingForPlayers => 'في انتظار انضمام الأصدقاء...';

  @override
  String get ready => 'جاهز للعب';

  @override
  String get startOnlineMatch => 'بدء مباراة الإنترنت';

  @override
  String get tabletopPaperModeTitle => 'أوضاع اللعب على الطاولة والورق';

  @override
  String get tabletopModeADesc =>
      'أجهزة متصلة مع أوراق مطبوعة: تلعبون عبر الهواتف مع تدوين الملاحظات على لوحات A4 الورقية بدل الشاشة.';

  @override
  String get tabletopModeBDesc =>
      'هاتف واحد مشترك: يدير هاتف واحد المباراة ويُمرر بين اللاعبين مع شاشة خصوصية لمنع تلصص الخصوم.';

  @override
  String get tabletopModeCDesc =>
      'مساعد للبلاطات الفعلية: استخدم الهاتف كحاسب للأدلة لبلاطاتك وحواملك الحقيقية دون كشف الأرقام لأصحابها.';

  @override
  String passPhoneTo(String player) {
    return 'مرر الهاتف الآن إلى: $player';
  }

  @override
  String get privacyScreenNotice =>
      'اضغط على الزر أدناه عندما يكون الهاتف بيدك وحدك وبعيدًا عن أعين المنافسين.';

  @override
  String revealMyTurn(String player) {
    return 'أنا $player - ابدأ دوري الآن';
  }

  @override
  String get myGuesses => 'تخميناتي';

  @override
  String get announceNumbers => 'إعلان أرقامي';

  @override
  String get showPosition => 'تحديد الموضع';

  @override
  String get compareDots => 'مقارنة النقاط';

  @override
  String get confirmCompare => 'تأكيد المقارنة';

  @override
  String get chooseColorToReveal => 'اختر لوناً للكشف عن بلاطة.';

  @override
  String get chooseSharedTile => 'اختر بلاطة مشتركة.';

  @override
  String get chooseClueAction => 'حدد موضعها أو قارن نقاطها.';

  @override
  String get tapTileToCompare => 'المس إحدى بلاطاتك الخمس لمقارنة نقاطها.';

  @override
  String get clueSavedUpdateNotes => 'تم حفظ دليلك. حدّث ملاحظاتك الآن.';

  @override
  String get sameDots => 'نفس عدد النقاط';

  @override
  String get differentDots => 'عدد نقاط مختلف';

  @override
  String get posFirst => 'الأولى';

  @override
  String get posSecond => 'الثانية';

  @override
  String get posThird => 'الثالثة';

  @override
  String get posFourth => 'الرابعة';

  @override
  String get posFifth => 'الخامسة';

  @override
  String get gapBeforeFirst => 'قبل الأولى';

  @override
  String gapBetween(String pos1, String pos2) {
    return 'بين $pos1 و$pos2';
  }

  @override
  String get gapAfterLast => 'بعد الخامسة';

  @override
  String orderClueBeforeFirstDesc(int number, String color) {
    return 'الرقم $number يقع قبل بلاطتك الأولى ($color). جميع أرقامك الخمسة أكبر من $number.';
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
    return 'الرقم $number يقع بين بلاطتك الـ$pos1 ($color1) والـ$pos2 ($color2). أول $count1 أرقام أصغر من $number وباقي أرقامك ($count2) أكبر.';
  }

  @override
  String orderClueAfterLastDesc(int number, String color) {
    return 'الرقم $number يقع بعد بلاطتك الخامسة ($color). جميع أرقامك الخمسة أصغر من $number.';
  }

  @override
  String compareClueSameDesc(int number, int dots, String pos, String color) {
    return 'البلاطة #$number ($dots نقاط) لها نفس عدد نقاط بلاطتك الـ$pos ($color).';
  }

  @override
  String compareClueDiffDesc(int number, int dots, String pos, String color) {
    return 'البلاطة #$number ($dots نقاط) لها عدد نقاط مختلف عن بلاطتك الـ$pos ($color).';
  }

  @override
  String get confirmAnnouncementTitle => 'تأكيد أرقامك الخمسة';

  @override
  String get oneAttemptWarning =>
      'تحذير: لديك محاولة واحدة فقط في اللعبة بأكملها. إذا كانت الأرقام صحيحة تفوز فوراً، وإذا كان أي رقم خاطئاً تُستبعد.';

  @override
  String get confirmSubmission => 'تأكيد الإعلان النهائي';

  @override
  String allCluesInGap(Object count) {
    return 'الأدلة في هذا الموضع ($count)';
  }

  @override
  String playerRevealedTile(String player, int number) {
    return '$player كشف الرقم $number';
  }

  @override
  String get computer => 'الكمبيوتر';

  @override
  String inReserveCount(int count) {
    return '$count في الاحتياطي';
  }

  @override
  String comparedWithSlot(int slot) {
    return 'مقارن مع الخانة #$slot';
  }

  @override
  String comparisonCluesForSlot(int slot, int count) {
    return 'أدلة المقارنة للخانة #$slot ($count)';
  }

  @override
  String targetHiddenTile(Object color, Object slot) {
    return 'البلاطة المستهدفة: الخانة #$slot ($color)';
  }
}
