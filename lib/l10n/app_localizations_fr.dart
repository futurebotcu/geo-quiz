// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class SFr extends S {
  SFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Geo Quiz : Drapeaux, Capitales et Plats';

  @override
  String get settings => 'Paramètres';

  @override
  String get language => 'Langue';

  @override
  String get languageSystemDefault => 'Paramètre du système';

  @override
  String get save => 'Enregistrer';

  @override
  String get menuTitle => 'Choisir un mode';

  @override
  String get statistics => 'Statistiques';

  @override
  String get debugCount => 'Debug';

  @override
  String get modeSelect => 'Choisir un mode';

  @override
  String get modeDescription =>
      'Cinq modes de jeu : Plat→Pays, Photo→Capitale, Drapeau→Pays, Ville→Pays et Mixte.';

  @override
  String get modeFoodCountry => 'Plat → Pays';

  @override
  String get modeFoodCountryDesc => 'Trouve le pays du plat sur la photo.';

  @override
  String get modeCapitalPhoto => 'Photo → Capitale';

  @override
  String get modeCapitalPhotoDesc => 'Reconnais la capitale sur la photo.';

  @override
  String get modeFlagCountry => 'Drapeau → Pays';

  @override
  String get modeFlagCountryDesc => 'Reconnais le pays à son drapeau.';

  @override
  String get modeCapitalCountry => 'Ville → Pays';

  @override
  String get modeCapitalCountryDesc =>
      'Choisis le pays auquel appartient la ville.';

  @override
  String get modeMixed => 'Mixte';

  @override
  String get modeMixedDesc => 'Tout-en-un ! Les questions arrivent mélangées.';

  @override
  String get start => 'Commencer';

  @override
  String get missingData => 'Données manquantes';

  @override
  String get hintText =>
      'Touche un mode pour choisir difficulté, minuteur et continent avant de commencer.';

  @override
  String get difficulty => 'Difficulté';

  @override
  String get difficultyEasy => 'Facile';

  @override
  String get difficultyMedium => 'Moyen';

  @override
  String get difficultyHard => 'Difficile';

  @override
  String get questionCount => 'Nombre de questions';

  @override
  String get timer => 'Minuteur';

  @override
  String get timerEnabled => 'Minuteur activé';

  @override
  String get countdownPerQuestion => 'Compte à rebours par question';

  @override
  String get continentFilter => 'Filtre par continent';

  @override
  String get continentAll => 'Tous';

  @override
  String get continentEurope => 'Europe';

  @override
  String get continentAsia => 'Asie';

  @override
  String get continentAfrica => 'Afrique';

  @override
  String get continentNorthAmerica => 'Amérique du Nord';

  @override
  String get continentSouthAmerica => 'Amérique du Sud';

  @override
  String get continentOceania => 'Océanie';

  @override
  String get quizSettings => 'Paramètres du quiz';

  @override
  String get timerPerQuestionDesc =>
      'Compte à rebours par question (varie selon la difficulté)';

  @override
  String questionsLabel(int count) {
    return 'Questions : $count';
  }

  @override
  String get difficultyLevel => 'Niveau de difficulté';

  @override
  String get about => 'À propos';

  @override
  String get appDescription => 'Teste tes connaissances en géographie !';

  @override
  String get capitalMode => 'Mode Capitales';

  @override
  String get capitalModeDesc => 'Reconnais les capitales sur les photos';

  @override
  String get flagMode => 'Mode Drapeaux';

  @override
  String get flagModeDesc => 'Identifie les pays grâce à leurs drapeaux';

  @override
  String get questionFoodCountry => 'De quel pays vient ce plat ?';

  @override
  String get questionCapitalPhoto => 'Quelle capitale voit-on sur la photo ?';

  @override
  String get questionFlagCountry => 'À quel pays appartient ce drapeau ?';

  @override
  String questionCapitalCountry(String capital) {
    return 'De quel pays $capital est-elle la capitale ?';
  }

  @override
  String get resultTitle => 'Résultat du quiz';

  @override
  String scoreLabel(int score, int total) {
    return '$score / $total correctes';
  }

  @override
  String durationLabel(String duration) {
    return 'Temps : $duration';
  }

  @override
  String modeLabel(String mode) {
    return 'Mode : $mode';
  }

  @override
  String get gradeExcellent => 'Excellent !';

  @override
  String get gradeGreat => 'Super !';

  @override
  String get gradeGood => 'Bien';

  @override
  String get gradeNeedsWork => 'À revoir';

  @override
  String get reviewAnswers => 'Revoir les réponses';

  @override
  String get backToMenu => 'Retour au menu';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get correctAnswer => 'Bonne réponse';

  @override
  String get yourAnswer => 'Ta réponse';

  @override
  String get statsTitle => 'Statistiques';

  @override
  String get overallStats => 'Statistiques globales';

  @override
  String get totalGames => 'Parties jouées';

  @override
  String get bestScoreShort => 'Meilleur score';

  @override
  String get recentResults => 'Résultats récents';

  @override
  String get noGamesPlayed => 'Aucune partie jouée';

  @override
  String questionLabel(int current, int total) {
    return 'Question $current/$total';
  }

  @override
  String scoreCounter(int score) {
    return 'Score : $score';
  }

  @override
  String get explore => 'Découvrir →';

  @override
  String get quizLoading => 'Chargement du quiz…';

  @override
  String get error => 'Erreur';

  @override
  String get errorInsufficientData => 'Pas assez de données pour ce mode';

  @override
  String errorLoadingQuiz(String error) {
    return 'Erreur de chargement : $error';
  }

  @override
  String get errorQuestionsFailed =>
      'Impossible de charger les questions. Réessaie.';

  @override
  String get unanswered => 'Sans réponse';

  @override
  String get average => 'Moyenne';

  @override
  String get support => 'Assistance';

  @override
  String get supportIntro =>
      'Une question, un bug ou une suggestion ? Écris-nous.';

  @override
  String get contactEmail => 'Nous écrire';

  @override
  String get version => 'Version';
}
