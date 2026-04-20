// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class SDe extends S {
  SDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Geo Quiz: Flaggen, Hauptstädte & Gerichte';

  @override
  String get settings => 'Einstellungen';

  @override
  String get language => 'Sprache';

  @override
  String get languageSystemDefault => 'Systemstandard';

  @override
  String get save => 'Speichern';

  @override
  String get menuTitle => 'Modus wählen';

  @override
  String get statistics => 'Statistik';

  @override
  String get debugCount => 'Debug-Zählung';

  @override
  String get modeSelect => 'Modus wählen';

  @override
  String get modeDescription =>
      'Fünf Spielmodi: Speise→Land, Foto→Hauptstadt, Flagge→Land, Stadt→Land und Gemischt.';

  @override
  String get modeFoodCountry => 'Speise → Land';

  @override
  String get modeFoodCountryDesc =>
      'Erkenne das Land an der Speise auf dem Foto.';

  @override
  String get modeCapitalPhoto => 'Foto → Hauptstadt';

  @override
  String get modeCapitalPhotoDesc =>
      'Erkenne die Hauptstadt auf dem Stadtfoto.';

  @override
  String get modeFlagCountry => 'Flagge → Land';

  @override
  String get modeFlagCountryDesc => 'Erkenne das Land an seiner Flagge.';

  @override
  String get modeCapitalCountry => 'Stadt → Land';

  @override
  String get modeCapitalCountryDesc =>
      'Wähle das Land, zu dem die Stadt gehört.';

  @override
  String get modeMixed => 'Gemischt';

  @override
  String get modeMixedDesc => 'Alles in einem! Die Fragen kommen gemischt.';

  @override
  String get start => 'Starten';

  @override
  String get missingData => 'Daten fehlen';

  @override
  String get hintText =>
      'Tippe auf einen Modus, um Schwierigkeit, Timer und Kontinent einzustellen.';

  @override
  String get difficulty => 'Schwierigkeit';

  @override
  String get difficultyEasy => 'Leicht';

  @override
  String get difficultyMedium => 'Mittel';

  @override
  String get difficultyHard => 'Schwer';

  @override
  String get questionCount => 'Fragenanzahl';

  @override
  String get timer => 'Timer';

  @override
  String get timerEnabled => 'Timer aktiv';

  @override
  String get countdownPerQuestion => 'Countdown pro Frage';

  @override
  String get continentFilter => 'Kontinent-Filter';

  @override
  String get continentAll => 'Alle';

  @override
  String get continentEurope => 'Europa';

  @override
  String get continentAsia => 'Asien';

  @override
  String get continentAfrica => 'Afrika';

  @override
  String get continentNorthAmerica => 'Nordamerika';

  @override
  String get continentSouthAmerica => 'Südamerika';

  @override
  String get continentOceania => 'Ozeanien';

  @override
  String get quizSettings => 'Quiz-Einstellungen';

  @override
  String get timerPerQuestionDesc =>
      'Countdown pro Frage (je nach Schwierigkeit)';

  @override
  String questionsLabel(int count) {
    return 'Fragen: $count';
  }

  @override
  String get difficultyLevel => 'Schwierigkeitsgrad';

  @override
  String get about => 'Über';

  @override
  String get appDescription => 'Teste dein Erdkundewissen!';

  @override
  String get capitalMode => 'Hauptstadt-Modus';

  @override
  String get capitalModeDesc => 'Erkenne Hauptstädte auf Fotos';

  @override
  String get flagMode => 'Flaggen-Modus';

  @override
  String get flagModeDesc => 'Erkenne Länder an ihren Flaggen';

  @override
  String get questionFoodCountry => 'Aus welchem Land stammt dieses Gericht?';

  @override
  String get questionCapitalPhoto => 'Welche Hauptstadt ist auf dem Foto?';

  @override
  String get questionFlagCountry => 'Zu welchem Land gehört diese Flagge?';

  @override
  String questionCapitalCountry(String capital) {
    return 'Hauptstadt welches Landes ist $capital?';
  }

  @override
  String get resultTitle => 'Quiz-Ergebnis';

  @override
  String scoreLabel(int score, int total) {
    return '$score / $total richtig';
  }

  @override
  String durationLabel(String duration) {
    return 'Zeit: $duration';
  }

  @override
  String modeLabel(String mode) {
    return 'Modus: $mode';
  }

  @override
  String get gradeExcellent => 'Ausgezeichnet!';

  @override
  String get gradeGreat => 'Super!';

  @override
  String get gradeGood => 'Gut';

  @override
  String get gradeNeedsWork => 'Ausbaufähig';

  @override
  String get reviewAnswers => 'Antworten prüfen';

  @override
  String get backToMenu => 'Zum Menü';

  @override
  String get tryAgain => 'Erneut versuchen';

  @override
  String get correctAnswer => 'Richtige Antwort';

  @override
  String get yourAnswer => 'Deine Antwort';

  @override
  String get statsTitle => 'Statistik';

  @override
  String get overallStats => 'Gesamtstatistik';

  @override
  String get totalGames => 'Spiele gesamt';

  @override
  String get bestScoreShort => 'Bestwert';

  @override
  String get recentResults => 'Letzte Ergebnisse';

  @override
  String get noGamesPlayed => 'Noch keine Spiele gespielt';

  @override
  String questionLabel(int current, int total) {
    return 'Frage $current/$total';
  }

  @override
  String scoreCounter(int score) {
    return 'Punkte: $score';
  }

  @override
  String get explore => 'Entdecken →';

  @override
  String get quizLoading => 'Quiz wird geladen …';

  @override
  String get error => 'Fehler';

  @override
  String get errorInsufficientData =>
      'Für diesen Modus reichen die Daten nicht';

  @override
  String errorLoadingQuiz(String error) {
    return 'Fehler beim Laden: $error';
  }

  @override
  String get errorQuestionsFailed =>
      'Fragen konnten nicht geladen werden. Bitte erneut versuchen.';

  @override
  String get unanswered => 'Nicht beantwortet';

  @override
  String get average => 'Durchschnitt';

  @override
  String get support => 'Support';

  @override
  String get supportIntro =>
      'Fragen, Fehler oder Feedback? Wir freuen uns auf deine Nachricht.';

  @override
  String get contactEmail => 'E-Mail schreiben';

  @override
  String get version => 'Version';
}
