// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class SIt extends S {
  SIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'Geo Quiz: Bandiere, Capitali e Piatti';

  @override
  String get settings => 'Impostazioni';

  @override
  String get language => 'Lingua';

  @override
  String get languageSystemDefault => 'Predefinito di sistema';

  @override
  String get save => 'Salva';

  @override
  String get menuTitle => 'Scegli modalità';

  @override
  String get statistics => 'Statistiche';

  @override
  String get debugCount => 'Debug';

  @override
  String get modeSelect => 'Scegli modalità';

  @override
  String get modeDescription =>
      'Cinque modalità di gioco: Piatto→Paese, Foto→Capitale, Bandiera→Paese, Città→Paese e Mista.';

  @override
  String get modeFoodCountry => 'Piatto → Paese';

  @override
  String get modeFoodCountryDesc => 'Indovina il paese del piatto nella foto.';

  @override
  String get modeCapitalPhoto => 'Foto → Capitale';

  @override
  String get modeCapitalPhotoDesc =>
      'Riconosci la capitale dalla foto della città.';

  @override
  String get modeFlagCountry => 'Bandiera → Paese';

  @override
  String get modeFlagCountryDesc => 'Riconosci il paese dalla bandiera.';

  @override
  String get modeCapitalCountry => 'Città → Paese';

  @override
  String get modeCapitalCountryDesc =>
      'Scegli il paese a cui appartiene la città.';

  @override
  String get modeMixed => 'Mista';

  @override
  String get modeMixedDesc => 'Tutto in uno! Le domande arrivano mescolate.';

  @override
  String get start => 'Inizia';

  @override
  String get missingData => 'Dati mancanti';

  @override
  String get hintText =>
      'Tocca una modalità per scegliere difficoltà, timer e continente prima di iniziare.';

  @override
  String get difficulty => 'Difficoltà';

  @override
  String get difficultyEasy => 'Facile';

  @override
  String get difficultyMedium => 'Media';

  @override
  String get difficultyHard => 'Difficile';

  @override
  String get questionCount => 'Numero di domande';

  @override
  String get timer => 'Timer';

  @override
  String get timerEnabled => 'Timer attivo';

  @override
  String get countdownPerQuestion => 'Conto alla rovescia per domanda';

  @override
  String get continentFilter => 'Filtro per continente';

  @override
  String get continentAll => 'Tutti';

  @override
  String get continentEurope => 'Europa';

  @override
  String get continentAsia => 'Asia';

  @override
  String get continentAfrica => 'Africa';

  @override
  String get continentNorthAmerica => 'America del Nord';

  @override
  String get continentSouthAmerica => 'America del Sud';

  @override
  String get continentOceania => 'Oceania';

  @override
  String get quizSettings => 'Impostazioni quiz';

  @override
  String get timerPerQuestionDesc =>
      'Conto alla rovescia per domanda (in base alla difficoltà)';

  @override
  String questionsLabel(int count) {
    return 'Domande: $count';
  }

  @override
  String get difficultyLevel => 'Livello di difficoltà';

  @override
  String get about => 'Informazioni';

  @override
  String get appDescription => 'Metti alla prova la tua geografia!';

  @override
  String get capitalMode => 'Modalità Capitali';

  @override
  String get capitalModeDesc => 'Riconosci le capitali dalle foto';

  @override
  String get flagMode => 'Modalità Bandiere';

  @override
  String get flagModeDesc => 'Riconosci i paesi dalle bandiere';

  @override
  String get questionFoodCountry => 'A quale paese appartiene questo piatto?';

  @override
  String get questionCapitalPhoto => 'Quale capitale vedi nella foto?';

  @override
  String get questionFlagCountry => 'A quale paese appartiene questa bandiera?';

  @override
  String questionCapitalCountry(String capital) {
    return '$capital è la capitale di quale paese?';
  }

  @override
  String get resultTitle => 'Risultato quiz';

  @override
  String scoreLabel(int score, int total) {
    return '$score / $total corrette';
  }

  @override
  String durationLabel(String duration) {
    return 'Tempo: $duration';
  }

  @override
  String modeLabel(String mode) {
    return 'Modalità: $mode';
  }

  @override
  String get gradeExcellent => 'Eccellente!';

  @override
  String get gradeGreat => 'Ottimo!';

  @override
  String get gradeGood => 'Bene';

  @override
  String get gradeNeedsWork => 'Da migliorare';

  @override
  String get reviewAnswers => 'Rivedi risposte';

  @override
  String get backToMenu => 'Torna al menu';

  @override
  String get tryAgain => 'Riprova';

  @override
  String get correctAnswer => 'Risposta corretta';

  @override
  String get yourAnswer => 'La tua risposta';

  @override
  String get statsTitle => 'Statistiche';

  @override
  String get overallStats => 'Statistiche generali';

  @override
  String get totalGames => 'Partite totali';

  @override
  String get bestScoreShort => 'Miglior punteggio';

  @override
  String get recentResults => 'Risultati recenti';

  @override
  String get noGamesPlayed => 'Nessuna partita giocata';

  @override
  String questionLabel(int current, int total) {
    return 'Domanda $current/$total';
  }

  @override
  String scoreCounter(int score) {
    return 'Punti: $score';
  }

  @override
  String get explore => 'Esplora →';

  @override
  String get quizLoading => 'Caricamento quiz…';

  @override
  String get error => 'Errore';

  @override
  String get errorInsufficientData => 'Dati insufficienti per questa modalità';

  @override
  String errorLoadingQuiz(String error) {
    return 'Errore nel caricamento: $error';
  }

  @override
  String get errorQuestionsFailed =>
      'Impossibile caricare le domande. Riprova.';

  @override
  String get unanswered => 'Senza risposta';

  @override
  String get average => 'Media';

  @override
  String get support => 'Assistenza';

  @override
  String get supportIntro => 'Domande, bug o idee? Scrivici quando vuoi.';

  @override
  String get contactEmail => 'Scrivici un\'email';

  @override
  String get version => 'Versione';
}
