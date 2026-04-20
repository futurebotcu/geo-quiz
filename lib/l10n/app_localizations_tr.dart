// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class STr extends S {
  STr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'Geo Quiz: Bayraklar, Başkentler & Yemekler';

  @override
  String get settings => 'Ayarlar';

  @override
  String get language => 'Dil';

  @override
  String get languageSystemDefault => 'Sistem Varsayılanı';

  @override
  String get save => 'Kaydet';

  @override
  String get menuTitle => 'Mod Seç';

  @override
  String get statistics => 'İstatistikler';

  @override
  String get debugCount => 'Debug Sayım';

  @override
  String get modeSelect => 'Mod Seç';

  @override
  String get modeDescription =>
      'Beş farklı oyun: Yemek→Ülke, Foto→Başkent, Bayrak→Ülke, Şehir→Ülke, ve Karma.';

  @override
  String get modeFoodCountry => 'Yemek → Ülke';

  @override
  String get modeFoodCountryDesc =>
      'Fotoğraftaki yemeğin hangi ülkeye ait olduğunu bul.';

  @override
  String get modeCapitalPhoto => 'Foto → Başkent';

  @override
  String get modeCapitalPhotoDesc => 'Şehir fotoğrafından başkenti tanı.';

  @override
  String get modeFlagCountry => 'Bayrak → Ülke';

  @override
  String get modeFlagCountryDesc => 'Bayraktan ülkeyi tanı.';

  @override
  String get modeCapitalCountry => 'Şehir → Ülke';

  @override
  String get modeCapitalCountryDesc =>
      'Verilen şehrin bağlı olduğu ülkeyi seç.';

  @override
  String get modeMixed => 'Karma';

  @override
  String get modeMixedDesc => 'Hepsi bir arada! Sorular karışık gelir.';

  @override
  String get start => 'Başlat';

  @override
  String get missingData => 'Veri eksik';

  @override
  String get hintText =>
      'Modu seç, başlamadan önce zorluk, sayaç ve kıta filtresini ayarla.';

  @override
  String get difficulty => 'Zorluk';

  @override
  String get difficultyEasy => 'Kolay';

  @override
  String get difficultyMedium => 'Orta';

  @override
  String get difficultyHard => 'Zor';

  @override
  String get questionCount => 'Soru Sayısı';

  @override
  String get timer => 'Zamanlayıcı';

  @override
  String get timerEnabled => 'Zamanlayıcı aktif';

  @override
  String get countdownPerQuestion => 'Soru başına geri sayım';

  @override
  String get continentFilter => 'Kıta Filtresi';

  @override
  String get continentAll => 'Tümü';

  @override
  String get continentEurope => 'Avrupa';

  @override
  String get continentAsia => 'Asya';

  @override
  String get continentAfrica => 'Afrika';

  @override
  String get continentNorthAmerica => 'Kuzey Amerika';

  @override
  String get continentSouthAmerica => 'Güney Amerika';

  @override
  String get continentOceania => 'Okyanusya';

  @override
  String get quizSettings => 'Quiz Ayarları';

  @override
  String get timerPerQuestionDesc =>
      'Soru başına geri sayım (zorluk ile değişir)';

  @override
  String questionsLabel(int count) {
    return 'Soru: $count';
  }

  @override
  String get difficultyLevel => 'Zorluk Seviyesi';

  @override
  String get about => 'Hakkında';

  @override
  String get appDescription => 'Coğrafya bilgini test et!';

  @override
  String get capitalMode => 'Başkent Modu';

  @override
  String get capitalModeDesc => 'Fotoğraflardan başkentleri tanı';

  @override
  String get flagMode => 'Bayrak Modu';

  @override
  String get flagModeDesc => 'Bayraklarından ülkeleri tanı';

  @override
  String get questionFoodCountry => 'Bu yemek hangi ülkeye ait?';

  @override
  String get questionCapitalPhoto => 'Fotoğrafta hangi başkent var?';

  @override
  String get questionFlagCountry => 'Bu bayrak hangi ülkeye aittir?';

  @override
  String questionCapitalCountry(String capital) {
    return '$capital şehri hangi ülkenin başkentidir?';
  }

  @override
  String get resultTitle => 'Quiz Sonucu';

  @override
  String scoreLabel(int score, int total) {
    return '$score / $total doğru';
  }

  @override
  String durationLabel(String duration) {
    return 'Süre: $duration';
  }

  @override
  String modeLabel(String mode) {
    return 'Mod: $mode';
  }

  @override
  String get gradeExcellent => 'Mükemmel!';

  @override
  String get gradeGreat => 'Harika!';

  @override
  String get gradeGood => 'İyi';

  @override
  String get gradeNeedsWork => 'Gelişmeli';

  @override
  String get reviewAnswers => 'Cevapları İncele';

  @override
  String get backToMenu => 'Ana Menü';

  @override
  String get tryAgain => 'Tekrar Dene';

  @override
  String get correctAnswer => 'Doğru Cevap';

  @override
  String get yourAnswer => 'Cevabınız';

  @override
  String get statsTitle => 'İstatistikler';

  @override
  String get overallStats => 'Genel İstatistikler';

  @override
  String get totalGames => 'Toplam Oyun';

  @override
  String get bestScoreShort => 'En İyi Skor';

  @override
  String get recentResults => 'Son Sonuçlar';

  @override
  String get noGamesPlayed => 'Henüz oyun oynanmadı';

  @override
  String questionLabel(int current, int total) {
    return 'Soru $current/$total';
  }

  @override
  String scoreCounter(int score) {
    return 'Puan: $score';
  }

  @override
  String get explore => 'Keşfet →';

  @override
  String get quizLoading => 'Quiz Yükleniyor...';

  @override
  String get error => 'Hata';

  @override
  String get errorInsufficientData => 'Bu mod için yeterli veri bulunamadı';

  @override
  String errorLoadingQuiz(String error) {
    return 'Quiz yüklenirken hata: $error';
  }

  @override
  String get errorQuestionsFailed =>
      'Sorular yüklenemedi. Lütfen tekrar deneyin.';

  @override
  String get unanswered => 'Cevaplanmadı';

  @override
  String get average => 'Ortalama';

  @override
  String get support => 'Destek';

  @override
  String get supportIntro => 'Soru, hata veya geri bildirim mi var? Bize yaz.';

  @override
  String get contactEmail => 'E-posta gönder';

  @override
  String get version => 'Sürüm';
}
