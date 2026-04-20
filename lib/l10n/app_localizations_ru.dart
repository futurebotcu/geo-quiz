// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class SRu extends S {
  SRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Гео-квиз: флаги, столицы и блюда';

  @override
  String get settings => 'Настройки';

  @override
  String get language => 'Язык';

  @override
  String get languageSystemDefault => 'Как в системе';

  @override
  String get save => 'Сохранить';

  @override
  String get menuTitle => 'Выберите режим';

  @override
  String get statistics => 'Статистика';

  @override
  String get debugCount => 'Debug';

  @override
  String get modeSelect => 'Выберите режим';

  @override
  String get modeDescription =>
      'Пять режимов: Блюдо→Страна, Фото→Столица, Флаг→Страна, Город→Страна и Микс.';

  @override
  String get modeFoodCountry => 'Блюдо → Страна';

  @override
  String get modeFoodCountryDesc => 'Угадайте страну блюда на фото.';

  @override
  String get modeCapitalPhoto => 'Фото → Столица';

  @override
  String get modeCapitalPhotoDesc => 'Узнайте столицу по фото города.';

  @override
  String get modeFlagCountry => 'Флаг → Страна';

  @override
  String get modeFlagCountryDesc => 'Узнайте страну по флагу.';

  @override
  String get modeCapitalCountry => 'Город → Страна';

  @override
  String get modeCapitalCountryDesc =>
      'Выберите страну, к которой относится город.';

  @override
  String get modeMixed => 'Микс';

  @override
  String get modeMixedDesc => 'Всё в одном! Вопросы идут вперемешку.';

  @override
  String get start => 'Начать';

  @override
  String get missingData => 'Нет данных';

  @override
  String get hintText =>
      'Нажмите режим, чтобы выбрать сложность, таймер и континент перед стартом.';

  @override
  String get difficulty => 'Сложность';

  @override
  String get difficultyEasy => 'Лёгкий';

  @override
  String get difficultyMedium => 'Средний';

  @override
  String get difficultyHard => 'Сложный';

  @override
  String get questionCount => 'Количество вопросов';

  @override
  String get timer => 'Таймер';

  @override
  String get timerEnabled => 'Таймер включён';

  @override
  String get countdownPerQuestion => 'Обратный отсчёт на вопрос';

  @override
  String get continentFilter => 'Фильтр по континенту';

  @override
  String get continentAll => 'Все';

  @override
  String get continentEurope => 'Европа';

  @override
  String get continentAsia => 'Азия';

  @override
  String get continentAfrica => 'Африка';

  @override
  String get continentNorthAmerica => 'Северная Америка';

  @override
  String get continentSouthAmerica => 'Южная Америка';

  @override
  String get continentOceania => 'Океания';

  @override
  String get quizSettings => 'Настройки квиза';

  @override
  String get timerPerQuestionDesc => 'Отсчёт на вопрос (зависит от сложности)';

  @override
  String questionsLabel(int count) {
    return 'Вопросы: $count';
  }

  @override
  String get difficultyLevel => 'Уровень сложности';

  @override
  String get about => 'О приложении';

  @override
  String get appDescription => 'Проверьте свои знания географии!';

  @override
  String get capitalMode => 'Режим столиц';

  @override
  String get capitalModeDesc => 'Узнавайте столицы по фото';

  @override
  String get flagMode => 'Режим флагов';

  @override
  String get flagModeDesc => 'Узнавайте страны по флагам';

  @override
  String get questionFoodCountry => 'Какой стране принадлежит это блюдо?';

  @override
  String get questionCapitalPhoto => 'Какая столица на фото?';

  @override
  String get questionFlagCountry => 'Какой стране принадлежит этот флаг?';

  @override
  String questionCapitalCountry(String capital) {
    return 'Столицей какой страны является $capital?';
  }

  @override
  String get resultTitle => 'Результат квиза';

  @override
  String scoreLabel(int score, int total) {
    return '$score / $total верно';
  }

  @override
  String durationLabel(String duration) {
    return 'Время: $duration';
  }

  @override
  String modeLabel(String mode) {
    return 'Режим: $mode';
  }

  @override
  String get gradeExcellent => 'Отлично!';

  @override
  String get gradeGreat => 'Здорово!';

  @override
  String get gradeGood => 'Хорошо';

  @override
  String get gradeNeedsWork => 'Надо тренироваться';

  @override
  String get reviewAnswers => 'Разбор ответов';

  @override
  String get backToMenu => 'В меню';

  @override
  String get tryAgain => 'Ещё раз';

  @override
  String get correctAnswer => 'Правильный ответ';

  @override
  String get yourAnswer => 'Ваш ответ';

  @override
  String get statsTitle => 'Статистика';

  @override
  String get overallStats => 'Общая статистика';

  @override
  String get totalGames => 'Всего игр';

  @override
  String get bestScoreShort => 'Лучший результат';

  @override
  String get recentResults => 'Недавние результаты';

  @override
  String get noGamesPlayed => 'Игр ещё не было';

  @override
  String questionLabel(int current, int total) {
    return 'Вопрос $current/$total';
  }

  @override
  String scoreCounter(int score) {
    return 'Очки: $score';
  }

  @override
  String get explore => 'Открыть →';

  @override
  String get quizLoading => 'Загрузка квиза…';

  @override
  String get error => 'Ошибка';

  @override
  String get errorInsufficientData => 'Для этого режима недостаточно данных';

  @override
  String errorLoadingQuiz(String error) {
    return 'Ошибка загрузки: $error';
  }

  @override
  String get errorQuestionsFailed =>
      'Не удалось загрузить вопросы. Попробуйте ещё раз.';

  @override
  String get unanswered => 'Без ответа';

  @override
  String get average => 'Среднее';

  @override
  String get support => 'Поддержка';

  @override
  String get supportIntro => 'Вопрос, ошибка или пожелание? Напишите нам.';

  @override
  String get contactEmail => 'Написать нам';

  @override
  String get version => 'Версия';
}
