import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
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
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

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
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('ru'),
    Locale('tr'),
    Locale('zh')
  ];

  /// Brand app name for the app bar and tab title
  ///
  /// In en, this message translates to:
  /// **'Geo Quiz: Flags, Capitals & Foods'**
  String get appName;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// System default language option
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get languageSystemDefault;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Main menu title
  ///
  /// In en, this message translates to:
  /// **'Select Mode'**
  String get menuTitle;

  /// Statistics menu item
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// Debug count button tooltip
  ///
  /// In en, this message translates to:
  /// **'Debug Count'**
  String get debugCount;

  /// Mode selection header
  ///
  /// In en, this message translates to:
  /// **'Select Mode'**
  String get modeSelect;

  /// Mode selection description
  ///
  /// In en, this message translates to:
  /// **'Five different game modes: Food→Country, Photo→Capital, Flag→Country, City→Country, and Mixed.'**
  String get modeDescription;

  /// Food to Country mode name
  ///
  /// In en, this message translates to:
  /// **'Food → Country'**
  String get modeFoodCountry;

  /// Food to Country mode description
  ///
  /// In en, this message translates to:
  /// **'Identify which country the food in the photo belongs to.'**
  String get modeFoodCountryDesc;

  /// Photo to Capital mode name
  ///
  /// In en, this message translates to:
  /// **'Photo → Capital'**
  String get modeCapitalPhoto;

  /// Photo to Capital mode description
  ///
  /// In en, this message translates to:
  /// **'Identify the capital from the city photo.'**
  String get modeCapitalPhotoDesc;

  /// Flag to Country mode name
  ///
  /// In en, this message translates to:
  /// **'Flag → Country'**
  String get modeFlagCountry;

  /// Flag to Country mode description
  ///
  /// In en, this message translates to:
  /// **'Identify the country from the flag.'**
  String get modeFlagCountryDesc;

  /// Capital to Country mode name
  ///
  /// In en, this message translates to:
  /// **'City → Country'**
  String get modeCapitalCountry;

  /// Capital to Country mode description
  ///
  /// In en, this message translates to:
  /// **'Select the country that the given city belongs to.'**
  String get modeCapitalCountryDesc;

  /// Mixed mode name
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get modeMixed;

  /// Mixed mode description
  ///
  /// In en, this message translates to:
  /// **'All in one! Questions come in a mix.'**
  String get modeMixedDesc;

  /// Start button
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// Missing data warning
  ///
  /// In en, this message translates to:
  /// **'Missing data'**
  String get missingData;

  /// Hint text on main menu
  ///
  /// In en, this message translates to:
  /// **'Tap a mode to pick difficulty, timer, and continent before you start.'**
  String get hintText;

  /// Difficulty label
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// Easy difficulty level
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficultyEasy;

  /// Medium difficulty level
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get difficultyMedium;

  /// Hard difficulty level
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficultyHard;

  /// Question count label
  ///
  /// In en, this message translates to:
  /// **'Question Count'**
  String get questionCount;

  /// Timer label
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get timer;

  /// Timer enabled label
  ///
  /// In en, this message translates to:
  /// **'Timer enabled'**
  String get timerEnabled;

  /// Countdown per question description
  ///
  /// In en, this message translates to:
  /// **'Countdown per question'**
  String get countdownPerQuestion;

  /// Continent filter label
  ///
  /// In en, this message translates to:
  /// **'Continent Filter'**
  String get continentFilter;

  /// All continents option
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get continentAll;

  /// Europe continent
  ///
  /// In en, this message translates to:
  /// **'Europe'**
  String get continentEurope;

  /// Asia continent
  ///
  /// In en, this message translates to:
  /// **'Asia'**
  String get continentAsia;

  /// Africa continent
  ///
  /// In en, this message translates to:
  /// **'Africa'**
  String get continentAfrica;

  /// North America continent
  ///
  /// In en, this message translates to:
  /// **'North America'**
  String get continentNorthAmerica;

  /// South America continent
  ///
  /// In en, this message translates to:
  /// **'South America'**
  String get continentSouthAmerica;

  /// Oceania continent
  ///
  /// In en, this message translates to:
  /// **'Oceania'**
  String get continentOceania;

  /// Quiz settings section title
  ///
  /// In en, this message translates to:
  /// **'Quiz Settings'**
  String get quizSettings;

  /// Timer per question description
  ///
  /// In en, this message translates to:
  /// **'Countdown per question (varies by difficulty)'**
  String get timerPerQuestionDesc;

  /// Questions count label
  ///
  /// In en, this message translates to:
  /// **'Questions: {count}'**
  String questionsLabel(int count);

  /// Difficulty level label
  ///
  /// In en, this message translates to:
  /// **'Difficulty Level'**
  String get difficultyLevel;

  /// About section title
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// App description
  ///
  /// In en, this message translates to:
  /// **'Test your geography knowledge!'**
  String get appDescription;

  /// Capital mode label
  ///
  /// In en, this message translates to:
  /// **'Capital Mode'**
  String get capitalMode;

  /// Capital mode description
  ///
  /// In en, this message translates to:
  /// **'Recognise capital cities from photos'**
  String get capitalModeDesc;

  /// Flag mode label
  ///
  /// In en, this message translates to:
  /// **'Flag Mode'**
  String get flagMode;

  /// Flag mode description
  ///
  /// In en, this message translates to:
  /// **'Identify countries by their flags'**
  String get flagModeDesc;

  /// Food to country question text
  ///
  /// In en, this message translates to:
  /// **'Which country does this food belong to?'**
  String get questionFoodCountry;

  /// Photo to capital question text
  ///
  /// In en, this message translates to:
  /// **'Which capital is in the photo?'**
  String get questionCapitalPhoto;

  /// Flag to country question text
  ///
  /// In en, this message translates to:
  /// **'Which country does this flag belong to?'**
  String get questionFlagCountry;

  /// Capital to country question text
  ///
  /// In en, this message translates to:
  /// **'Which country is {capital} the capital of?'**
  String questionCapitalCountry(String capital);

  /// Result screen title
  ///
  /// In en, this message translates to:
  /// **'Quiz Result'**
  String get resultTitle;

  /// Score label
  ///
  /// In en, this message translates to:
  /// **'{score} / {total} correct'**
  String scoreLabel(int score, int total);

  /// Duration label
  ///
  /// In en, this message translates to:
  /// **'Time: {duration}'**
  String durationLabel(String duration);

  /// Mode label
  ///
  /// In en, this message translates to:
  /// **'Mode: {mode}'**
  String modeLabel(String mode);

  /// Grade: Excellent (90-100%)
  ///
  /// In en, this message translates to:
  /// **'Excellent!'**
  String get gradeExcellent;

  /// Grade: Great (75-89%)
  ///
  /// In en, this message translates to:
  /// **'Great!'**
  String get gradeGreat;

  /// Grade: Good (50-69%)
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get gradeGood;

  /// Grade: Needs Work (<50%)
  ///
  /// In en, this message translates to:
  /// **'Needs Work'**
  String get gradeNeedsWork;

  /// Review answers button
  ///
  /// In en, this message translates to:
  /// **'Review Answers'**
  String get reviewAnswers;

  /// Back to menu button
  ///
  /// In en, this message translates to:
  /// **'Back to Menu'**
  String get backToMenu;

  /// Try again button
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Correct answer label
  ///
  /// In en, this message translates to:
  /// **'Correct Answer'**
  String get correctAnswer;

  /// Your answer label
  ///
  /// In en, this message translates to:
  /// **'Your Answer'**
  String get yourAnswer;

  /// Statistics screen title
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statsTitle;

  /// Overall statistics section
  ///
  /// In en, this message translates to:
  /// **'Overall Statistics'**
  String get overallStats;

  /// Total games played
  ///
  /// In en, this message translates to:
  /// **'Total Games'**
  String get totalGames;

  /// Best score label
  ///
  /// In en, this message translates to:
  /// **'Best Score'**
  String get bestScoreShort;

  /// Recent results section
  ///
  /// In en, this message translates to:
  /// **'Recent Results'**
  String get recentResults;

  /// No games played message
  ///
  /// In en, this message translates to:
  /// **'No games played yet'**
  String get noGamesPlayed;

  /// Question counter
  ///
  /// In en, this message translates to:
  /// **'Question {current}/{total}'**
  String questionLabel(int current, int total);

  /// Score counter during quiz
  ///
  /// In en, this message translates to:
  /// **'Score: {score}'**
  String scoreCounter(int score);

  /// Explore button on carousel
  ///
  /// In en, this message translates to:
  /// **'Explore →'**
  String get explore;

  /// Quiz loading screen title
  ///
  /// In en, this message translates to:
  /// **'Loading Quiz...'**
  String get quizLoading;

  /// Error screen title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Snackbar when quiz engine cannot generate questions
  ///
  /// In en, this message translates to:
  /// **'Not enough data for this mode'**
  String get errorInsufficientData;

  /// Snackbar when quiz initialization fails
  ///
  /// In en, this message translates to:
  /// **'Error loading quiz: {error}'**
  String errorLoadingQuiz(String error);

  /// Fallback text when question list is empty on quiz screen
  ///
  /// In en, this message translates to:
  /// **'Could not load questions. Please try again.'**
  String get errorQuestionsFailed;

  /// Label shown for questions the user did not answer in time
  ///
  /// In en, this message translates to:
  /// **'Not answered'**
  String get unanswered;

  /// Average score label in stats mode card
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// Settings support section title
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// Short blurb above the contact email
  ///
  /// In en, this message translates to:
  /// **'Questions, bugs, or feedback? We\'d love to hear from you.'**
  String get supportIntro;

  /// Tap label that opens the mail app
  ///
  /// In en, this message translates to:
  /// **'Email us'**
  String get contactEmail;

  /// Version label in About
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'de',
        'en',
        'es',
        'fr',
        'it',
        'ja',
        'ko',
        'pt',
        'ru',
        'tr',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return SAr();
    case 'de':
      return SDe();
    case 'en':
      return SEn();
    case 'es':
      return SEs();
    case 'fr':
      return SFr();
    case 'it':
      return SIt();
    case 'ja':
      return SJa();
    case 'ko':
      return SKo();
    case 'pt':
      return SPt();
    case 'ru':
      return SRu();
    case 'tr':
      return STr();
    case 'zh':
      return SZh();
  }

  throw FlutterError(
      'S.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
