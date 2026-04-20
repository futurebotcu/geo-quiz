// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class SEs extends S {
  SEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Geo Quiz: Banderas, Capitales y Comidas';

  @override
  String get settings => 'Ajustes';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystemDefault => 'Predeterminado del sistema';

  @override
  String get save => 'Guardar';

  @override
  String get menuTitle => 'Elegir modo';

  @override
  String get statistics => 'Estadísticas';

  @override
  String get debugCount => 'Debug';

  @override
  String get modeSelect => 'Elegir modo';

  @override
  String get modeDescription =>
      'Cinco modos de juego: Comida→País, Foto→Capital, Bandera→País, Ciudad→País y Mixto.';

  @override
  String get modeFoodCountry => 'Comida → País';

  @override
  String get modeFoodCountryDesc => 'Descubre el país del plato de la foto.';

  @override
  String get modeCapitalPhoto => 'Foto → Capital';

  @override
  String get modeCapitalPhotoDesc =>
      'Identifica la capital a partir de la foto.';

  @override
  String get modeFlagCountry => 'Bandera → País';

  @override
  String get modeFlagCountryDesc => 'Reconoce el país por su bandera.';

  @override
  String get modeCapitalCountry => 'Ciudad → País';

  @override
  String get modeCapitalCountryDesc =>
      'Elige el país al que pertenece la ciudad.';

  @override
  String get modeMixed => 'Mixto';

  @override
  String get modeMixedDesc => '¡Todo en uno! Las preguntas llegan mezcladas.';

  @override
  String get start => 'Empezar';

  @override
  String get missingData => 'Faltan datos';

  @override
  String get hintText =>
      'Toca un modo para elegir dificultad, temporizador y continente antes de empezar.';

  @override
  String get difficulty => 'Dificultad';

  @override
  String get difficultyEasy => 'Fácil';

  @override
  String get difficultyMedium => 'Media';

  @override
  String get difficultyHard => 'Difícil';

  @override
  String get questionCount => 'Número de preguntas';

  @override
  String get timer => 'Temporizador';

  @override
  String get timerEnabled => 'Temporizador activo';

  @override
  String get countdownPerQuestion => 'Cuenta atrás por pregunta';

  @override
  String get continentFilter => 'Filtro por continente';

  @override
  String get continentAll => 'Todos';

  @override
  String get continentEurope => 'Europa';

  @override
  String get continentAsia => 'Asia';

  @override
  String get continentAfrica => 'África';

  @override
  String get continentNorthAmerica => 'América del Norte';

  @override
  String get continentSouthAmerica => 'América del Sur';

  @override
  String get continentOceania => 'Oceanía';

  @override
  String get quizSettings => 'Ajustes del quiz';

  @override
  String get timerPerQuestionDesc =>
      'Cuenta atrás por pregunta (según la dificultad)';

  @override
  String questionsLabel(int count) {
    return 'Preguntas: $count';
  }

  @override
  String get difficultyLevel => 'Nivel de dificultad';

  @override
  String get about => 'Acerca de';

  @override
  String get appDescription => '¡Pon a prueba tus conocimientos de geografía!';

  @override
  String get capitalMode => 'Modo Capitales';

  @override
  String get capitalModeDesc => 'Reconoce capitales en fotos';

  @override
  String get flagMode => 'Modo Banderas';

  @override
  String get flagModeDesc => 'Identifica países por sus banderas';

  @override
  String get questionFoodCountry => '¿De qué país es este plato?';

  @override
  String get questionCapitalPhoto => '¿Qué capital aparece en la foto?';

  @override
  String get questionFlagCountry => '¿De qué país es esta bandera?';

  @override
  String questionCapitalCountry(String capital) {
    return '¿De qué país es capital $capital?';
  }

  @override
  String get resultTitle => 'Resultado del quiz';

  @override
  String scoreLabel(int score, int total) {
    return '$score / $total correctas';
  }

  @override
  String durationLabel(String duration) {
    return 'Tiempo: $duration';
  }

  @override
  String modeLabel(String mode) {
    return 'Modo: $mode';
  }

  @override
  String get gradeExcellent => '¡Excelente!';

  @override
  String get gradeGreat => '¡Genial!';

  @override
  String get gradeGood => 'Bien';

  @override
  String get gradeNeedsWork => 'Sigue practicando';

  @override
  String get reviewAnswers => 'Revisar respuestas';

  @override
  String get backToMenu => 'Al menú';

  @override
  String get tryAgain => 'Reintentar';

  @override
  String get correctAnswer => 'Respuesta correcta';

  @override
  String get yourAnswer => 'Tu respuesta';

  @override
  String get statsTitle => 'Estadísticas';

  @override
  String get overallStats => 'Estadísticas generales';

  @override
  String get totalGames => 'Partidas totales';

  @override
  String get bestScoreShort => 'Mejor puntuación';

  @override
  String get recentResults => 'Resultados recientes';

  @override
  String get noGamesPlayed => 'Aún no has jugado';

  @override
  String questionLabel(int current, int total) {
    return 'Pregunta $current/$total';
  }

  @override
  String scoreCounter(int score) {
    return 'Puntos: $score';
  }

  @override
  String get explore => 'Explorar →';

  @override
  String get quizLoading => 'Cargando quiz…';

  @override
  String get error => 'Error';

  @override
  String get errorInsufficientData => 'No hay datos suficientes para este modo';

  @override
  String errorLoadingQuiz(String error) {
    return 'Error al cargar: $error';
  }

  @override
  String get errorQuestionsFailed =>
      'No se pudieron cargar las preguntas. Inténtalo de nuevo.';

  @override
  String get unanswered => 'Sin responder';

  @override
  String get average => 'Media';

  @override
  String get support => 'Soporte';

  @override
  String get supportIntro =>
      '¿Preguntas, errores o sugerencias? Nos encantará leerte.';

  @override
  String get contactEmail => 'Escríbenos';

  @override
  String get version => 'Versión';
}
