// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class SPt extends S {
  SPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Geo Quiz: Bandeiras, Capitais e Pratos';

  @override
  String get settings => 'Definições';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystemDefault => 'Predefinição do sistema';

  @override
  String get save => 'Guardar';

  @override
  String get menuTitle => 'Escolher modo';

  @override
  String get statistics => 'Estatísticas';

  @override
  String get debugCount => 'Debug';

  @override
  String get modeSelect => 'Escolher modo';

  @override
  String get modeDescription =>
      'Cinco modos de jogo: Prato→País, Foto→Capital, Bandeira→País, Cidade→País e Misto.';

  @override
  String get modeFoodCountry => 'Prato → País';

  @override
  String get modeFoodCountryDesc => 'Descobre de que país é o prato da foto.';

  @override
  String get modeCapitalPhoto => 'Foto → Capital';

  @override
  String get modeCapitalPhotoDesc => 'Reconhece a capital pela foto.';

  @override
  String get modeFlagCountry => 'Bandeira → País';

  @override
  String get modeFlagCountryDesc => 'Reconhece o país pela bandeira.';

  @override
  String get modeCapitalCountry => 'Cidade → País';

  @override
  String get modeCapitalCountryDesc =>
      'Escolhe o país a que a cidade pertence.';

  @override
  String get modeMixed => 'Misto';

  @override
  String get modeMixedDesc => 'Tudo num só! As perguntas vêm misturadas.';

  @override
  String get start => 'Começar';

  @override
  String get missingData => 'Dados em falta';

  @override
  String get hintText =>
      'Toca num modo para escolher dificuldade, temporizador e continente antes de começar.';

  @override
  String get difficulty => 'Dificuldade';

  @override
  String get difficultyEasy => 'Fácil';

  @override
  String get difficultyMedium => 'Média';

  @override
  String get difficultyHard => 'Difícil';

  @override
  String get questionCount => 'Número de perguntas';

  @override
  String get timer => 'Temporizador';

  @override
  String get timerEnabled => 'Temporizador ativo';

  @override
  String get countdownPerQuestion => 'Contagem por pergunta';

  @override
  String get continentFilter => 'Filtro por continente';

  @override
  String get continentAll => 'Todos';

  @override
  String get continentEurope => 'Europa';

  @override
  String get continentAsia => 'Ásia';

  @override
  String get continentAfrica => 'África';

  @override
  String get continentNorthAmerica => 'América do Norte';

  @override
  String get continentSouthAmerica => 'América do Sul';

  @override
  String get continentOceania => 'Oceânia';

  @override
  String get quizSettings => 'Definições do quiz';

  @override
  String get timerPerQuestionDesc =>
      'Contagem por pergunta (varia com a dificuldade)';

  @override
  String questionsLabel(int count) {
    return 'Perguntas: $count';
  }

  @override
  String get difficultyLevel => 'Nível de dificuldade';

  @override
  String get about => 'Sobre';

  @override
  String get appDescription =>
      'Põe à prova os teus conhecimentos de geografia!';

  @override
  String get capitalMode => 'Modo Capitais';

  @override
  String get capitalModeDesc => 'Reconhece capitais em fotos';

  @override
  String get flagMode => 'Modo Bandeiras';

  @override
  String get flagModeDesc => 'Identifica países pelas bandeiras';

  @override
  String get questionFoodCountry => 'De que país é este prato?';

  @override
  String get questionCapitalPhoto => 'Que capital aparece na foto?';

  @override
  String get questionFlagCountry => 'A que país pertence esta bandeira?';

  @override
  String questionCapitalCountry(String capital) {
    return 'De que país é capital $capital?';
  }

  @override
  String get resultTitle => 'Resultado do quiz';

  @override
  String scoreLabel(int score, int total) {
    return '$score / $total corretas';
  }

  @override
  String durationLabel(String duration) {
    return 'Tempo: $duration';
  }

  @override
  String modeLabel(String mode) {
    return 'Modo: $mode';
  }

  @override
  String get gradeExcellent => 'Excelente!';

  @override
  String get gradeGreat => 'Muito bem!';

  @override
  String get gradeGood => 'Bom';

  @override
  String get gradeNeedsWork => 'Podes melhorar';

  @override
  String get reviewAnswers => 'Rever respostas';

  @override
  String get backToMenu => 'Voltar ao menu';

  @override
  String get tryAgain => 'Tentar de novo';

  @override
  String get correctAnswer => 'Resposta correta';

  @override
  String get yourAnswer => 'A tua resposta';

  @override
  String get statsTitle => 'Estatísticas';

  @override
  String get overallStats => 'Estatísticas gerais';

  @override
  String get totalGames => 'Jogos totais';

  @override
  String get bestScoreShort => 'Melhor pontuação';

  @override
  String get recentResults => 'Resultados recentes';

  @override
  String get noGamesPlayed => 'Ainda sem jogos';

  @override
  String questionLabel(int current, int total) {
    return 'Pergunta $current/$total';
  }

  @override
  String scoreCounter(int score) {
    return 'Pontos: $score';
  }

  @override
  String get explore => 'Explorar →';

  @override
  String get quizLoading => 'A carregar quiz…';

  @override
  String get error => 'Erro';

  @override
  String get errorInsufficientData => 'Dados insuficientes para este modo';

  @override
  String errorLoadingQuiz(String error) {
    return 'Erro ao carregar: $error';
  }

  @override
  String get errorQuestionsFailed =>
      'Não foi possível carregar as perguntas. Tenta novamente.';

  @override
  String get unanswered => 'Sem resposta';

  @override
  String get average => 'Média';

  @override
  String get support => 'Suporte';

  @override
  String get supportIntro => 'Dúvidas, erros ou sugestões? Fala connosco.';

  @override
  String get contactEmail => 'Envia-nos um e-mail';

  @override
  String get version => 'Versão';
}
