// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'World Geo Quiz';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageTurkish => 'Turkish';

  @override
  String get languageSystemDefault => 'System Default';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get menuTitle => 'Select Mode';

  @override
  String get statistics => 'Statistics';

  @override
  String get debugCount => 'Debug Count';

  @override
  String get modeSelect => 'Select Mode';

  @override
  String get modeDescription =>
      'Five different game modes: Food→Country, Photo→Capital, Flag→Country, City→Country, and Mixed.';

  @override
  String get modeFoodCountry => 'Food → Country';

  @override
  String get modeFoodCountryDesc =>
      'Identify which country the food in the photo belongs to.';

  @override
  String get modeCapitalPhoto => 'Photo → Capital';

  @override
  String get modeCapitalPhotoDesc =>
      'Identify the capital from the city photo.';

  @override
  String get modeFlagCountry => 'Flag → Country';

  @override
  String get modeFlagCountryDesc => 'Identify the country from the flag.';

  @override
  String get modeCapitalCountry => 'City → Country';

  @override
  String get modeCapitalCountryDesc =>
      'Select the country that the given city belongs to.';

  @override
  String get modeMixed => 'Mixed';

  @override
  String get modeMixedDesc => 'All in one! Questions come in a mix.';

  @override
  String get start => 'Start';

  @override
  String get missingData => 'Missing data';

  @override
  String get hintText =>
      'Hint: You can select difficulty before starting. Continent filter in settings!';

  @override
  String get difficulty => 'Difficulty';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get questionCount => 'Question Count';

  @override
  String get timer => 'Timer';

  @override
  String get timerEnabled => 'Timer enabled';

  @override
  String get countdownPerQuestion => 'Countdown per question';

  @override
  String get continentFilter => 'Continent Filter';

  @override
  String get continentAll => 'All';

  @override
  String get continentEurope => 'Europe';

  @override
  String get continentAsia => 'Asia';

  @override
  String get continentAfrica => 'Africa';

  @override
  String get continentNorthAmerica => 'North America';

  @override
  String get continentSouthAmerica => 'South America';

  @override
  String get continentOceania => 'Oceania';

  @override
  String get quizSettings => 'Quiz Settings';

  @override
  String get timerPerQuestionDesc => '30 seconds per question';

  @override
  String questionsLabel(int count) {
    return 'Questions: $count';
  }

  @override
  String get difficultyLevel => 'Difficulty Level';

  @override
  String get about => 'About';

  @override
  String get appDescription => 'Test your geography knowledge!';

  @override
  String get capitalMode => 'Capital Mode';

  @override
  String get capitalModeDesc => '183 capital photos available';

  @override
  String get flagMode => 'Flag Mode';

  @override
  String get flagModeDesc => '195 country flags (PNG + Emoji)';

  @override
  String get difficultyLevels => 'Difficulty Levels';

  @override
  String get difficultyEasyDesc =>
      '1 option from same continent, 2 from others';

  @override
  String get difficultyMediumDesc =>
      '1 option from same continent, 2 from others';

  @override
  String get difficultyHardDesc =>
      '2 options from same continent, 1 from others';

  @override
  String get questionFoodCountry => 'Which country does this food belong to?';

  @override
  String get questionCapitalPhoto => 'Which capital is in the photo?';

  @override
  String get questionFlagCountry => 'Which country does this flag belong to?';

  @override
  String questionCapitalCountry(String capital) {
    return 'Which country is $capital the capital of?';
  }

  @override
  String get resultTitle => 'Quiz Result';

  @override
  String scoreLabel(int score, int total) {
    return '$score / $total correct';
  }

  @override
  String durationLabel(String duration) {
    return 'Time: $duration';
  }

  @override
  String modeLabel(String mode) {
    return 'Mode: $mode';
  }

  @override
  String get gradeExcellent => 'Excellent!';

  @override
  String get gradeGreat => 'Great!';

  @override
  String get gradeGood => 'Good';

  @override
  String get gradeFair => 'Fair';

  @override
  String get gradeNeedsWork => 'Needs Work';

  @override
  String get reviewAnswers => 'Review Answers';

  @override
  String get backToMenu => 'Back to Menu';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get correctAnswer => 'Correct Answer';

  @override
  String get yourAnswer => 'Your Answer';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get overallStats => 'Overall Statistics';

  @override
  String get totalGames => 'Total Games';

  @override
  String get bestScoreShort => 'Best Score';

  @override
  String get recentResults => 'Recent Results';

  @override
  String bestScoreLabel(int score) {
    return 'Best: $score';
  }

  @override
  String averageScoreLabel(String score) {
    return 'Average: $score';
  }

  @override
  String get noGamesPlayed => 'No games played yet';

  @override
  String questionLabel(int current, int total) {
    return 'Question $current/$total';
  }

  @override
  String scoreCounter(int score) {
    return 'Score: $score';
  }

  @override
  String get explore => 'Explore →';

  @override
  String get quizLoading => 'Loading Quiz...';

  @override
  String get error => 'Error';
}
