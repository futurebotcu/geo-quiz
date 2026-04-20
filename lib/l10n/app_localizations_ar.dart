// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class SAr extends S {
  SAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'اختبار الجغرافيا: الأعلام والعواصم والأطعمة';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get languageSystemDefault => 'إعداد النظام';

  @override
  String get save => 'حفظ';

  @override
  String get menuTitle => 'اختر الوضع';

  @override
  String get statistics => 'الإحصائيات';

  @override
  String get debugCount => 'تصحيح';

  @override
  String get modeSelect => 'اختر الوضع';

  @override
  String get modeDescription =>
      'خمسة أوضاع: طعام ← بلد، صورة ← عاصمة، علم ← بلد، مدينة ← بلد، ومختلط.';

  @override
  String get modeFoodCountry => 'طعام ← بلد';

  @override
  String get modeFoodCountryDesc =>
      'حدّد البلد الذي ينتمي إليه الطعام في الصورة.';

  @override
  String get modeCapitalPhoto => 'صورة ← عاصمة';

  @override
  String get modeCapitalPhotoDesc => 'تعرّف على العاصمة من صورة المدينة.';

  @override
  String get modeFlagCountry => 'علم ← بلد';

  @override
  String get modeFlagCountryDesc => 'تعرّف على البلد من علمه.';

  @override
  String get modeCapitalCountry => 'مدينة ← بلد';

  @override
  String get modeCapitalCountryDesc => 'اختر البلد الذي تنتمي إليه المدينة.';

  @override
  String get modeMixed => 'مختلط';

  @override
  String get modeMixedDesc => 'الكل في واحد! الأسئلة تأتي بشكل متنوّع.';

  @override
  String get start => 'ابدأ';

  @override
  String get missingData => 'بيانات ناقصة';

  @override
  String get hintText =>
      'اضغط على وضع لاختيار الصعوبة والمؤقت والقارة قبل البدء.';

  @override
  String get difficulty => 'الصعوبة';

  @override
  String get difficultyEasy => 'سهل';

  @override
  String get difficultyMedium => 'متوسط';

  @override
  String get difficultyHard => 'صعب';

  @override
  String get questionCount => 'عدد الأسئلة';

  @override
  String get timer => 'المؤقت';

  @override
  String get timerEnabled => 'تفعيل المؤقت';

  @override
  String get countdownPerQuestion => 'عدّ تنازلي لكل سؤال';

  @override
  String get continentFilter => 'فلتر القارة';

  @override
  String get continentAll => 'الكل';

  @override
  String get continentEurope => 'أوروبا';

  @override
  String get continentAsia => 'آسيا';

  @override
  String get continentAfrica => 'أفريقيا';

  @override
  String get continentNorthAmerica => 'أمريكا الشمالية';

  @override
  String get continentSouthAmerica => 'أمريكا الجنوبية';

  @override
  String get continentOceania => 'أوقيانوسيا';

  @override
  String get quizSettings => 'إعدادات الاختبار';

  @override
  String get timerPerQuestionDesc => 'عدّ تنازلي لكل سؤال (حسب الصعوبة)';

  @override
  String questionsLabel(int count) {
    return 'الأسئلة: $count';
  }

  @override
  String get difficultyLevel => 'مستوى الصعوبة';

  @override
  String get about => 'حول التطبيق';

  @override
  String get appDescription => 'اختبر معلوماتك في الجغرافيا!';

  @override
  String get capitalMode => 'وضع العواصم';

  @override
  String get capitalModeDesc => 'تعرّف على العواصم من الصور';

  @override
  String get flagMode => 'وضع الأعلام';

  @override
  String get flagModeDesc => 'تعرّف على الدول من أعلامها';

  @override
  String get questionFoodCountry => 'إلى أي بلد ينتمي هذا الطعام؟';

  @override
  String get questionCapitalPhoto => 'أي عاصمة تظهر في الصورة؟';

  @override
  String get questionFlagCountry => 'إلى أي بلد ينتمي هذا العلم؟';

  @override
  String questionCapitalCountry(String capital) {
    return '$capital عاصمة أي بلد؟';
  }

  @override
  String get resultTitle => 'نتيجة الاختبار';

  @override
  String scoreLabel(int score, int total) {
    return '$score / $total صحيحة';
  }

  @override
  String durationLabel(String duration) {
    return 'الوقت: $duration';
  }

  @override
  String modeLabel(String mode) {
    return 'الوضع: $mode';
  }

  @override
  String get gradeExcellent => 'ممتاز!';

  @override
  String get gradeGreat => 'رائع!';

  @override
  String get gradeGood => 'جيد';

  @override
  String get gradeNeedsWork => 'تحتاج إلى تدريب';

  @override
  String get reviewAnswers => 'مراجعة الإجابات';

  @override
  String get backToMenu => 'القائمة';

  @override
  String get tryAgain => 'حاول مجددًا';

  @override
  String get correctAnswer => 'الإجابة الصحيحة';

  @override
  String get yourAnswer => 'إجابتك';

  @override
  String get statsTitle => 'الإحصائيات';

  @override
  String get overallStats => 'إحصائيات عامة';

  @override
  String get totalGames => 'إجمالي المباريات';

  @override
  String get bestScoreShort => 'أفضل نتيجة';

  @override
  String get recentResults => 'أحدث النتائج';

  @override
  String get noGamesPlayed => 'لا توجد مباريات بعد';

  @override
  String questionLabel(int current, int total) {
    return 'السؤال $current/$total';
  }

  @override
  String scoreCounter(int score) {
    return 'النقاط: $score';
  }

  @override
  String get explore => 'استكشف ←';

  @override
  String get quizLoading => 'جارٍ تحميل الاختبار…';

  @override
  String get error => 'خطأ';

  @override
  String get errorInsufficientData => 'بيانات غير كافية لهذا الوضع';

  @override
  String errorLoadingQuiz(String error) {
    return 'خطأ أثناء التحميل: $error';
  }

  @override
  String get errorQuestionsFailed =>
      'تعذّر تحميل الأسئلة. يرجى المحاولة مجددًا.';

  @override
  String get unanswered => 'لم يُجب';

  @override
  String get average => 'المتوسط';

  @override
  String get support => 'الدعم';

  @override
  String get supportIntro => 'هل لديك سؤال أو ملاحظة أو تقرير خطأ؟ تواصل معنا.';

  @override
  String get contactEmail => 'راسلنا عبر البريد';

  @override
  String get version => 'الإصدار';
}
