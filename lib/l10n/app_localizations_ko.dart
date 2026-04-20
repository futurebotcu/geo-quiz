// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class SKo extends S {
  SKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => '지오 퀴즈: 국기, 수도, 음식';

  @override
  String get settings => '설정';

  @override
  String get language => '언어';

  @override
  String get languageSystemDefault => '시스템 기본값';

  @override
  String get save => '저장';

  @override
  String get menuTitle => '모드 선택';

  @override
  String get statistics => '통계';

  @override
  String get debugCount => '디버그';

  @override
  String get modeSelect => '모드 선택';

  @override
  String get modeDescription => '다섯 가지 모드: 음식→나라, 사진→수도, 국기→나라, 도시→나라, 혼합.';

  @override
  String get modeFoodCountry => '음식 → 나라';

  @override
  String get modeFoodCountryDesc => '사진 속 음식이 어느 나라 것인지 맞혀보세요.';

  @override
  String get modeCapitalPhoto => '사진 → 수도';

  @override
  String get modeCapitalPhotoDesc => '도시 사진을 보고 수도를 맞혀보세요.';

  @override
  String get modeFlagCountry => '국기 → 나라';

  @override
  String get modeFlagCountryDesc => '국기를 보고 나라를 맞혀보세요.';

  @override
  String get modeCapitalCountry => '도시 → 나라';

  @override
  String get modeCapitalCountryDesc => '도시가 속한 나라를 선택하세요.';

  @override
  String get modeMixed => '혼합';

  @override
  String get modeMixedDesc => '모두 한 번에! 문제가 섞여서 나옵니다.';

  @override
  String get start => '시작';

  @override
  String get missingData => '데이터 부족';

  @override
  String get hintText => '모드를 탭해 난이도, 타이머, 대륙을 선택한 뒤 시작하세요.';

  @override
  String get difficulty => '난이도';

  @override
  String get difficultyEasy => '쉬움';

  @override
  String get difficultyMedium => '보통';

  @override
  String get difficultyHard => '어려움';

  @override
  String get questionCount => '문제 수';

  @override
  String get timer => '타이머';

  @override
  String get timerEnabled => '타이머 사용';

  @override
  String get countdownPerQuestion => '문제별 카운트다운';

  @override
  String get continentFilter => '대륙 필터';

  @override
  String get continentAll => '전체';

  @override
  String get continentEurope => '유럽';

  @override
  String get continentAsia => '아시아';

  @override
  String get continentAfrica => '아프리카';

  @override
  String get continentNorthAmerica => '북아메리카';

  @override
  String get continentSouthAmerica => '남아메리카';

  @override
  String get continentOceania => '오세아니아';

  @override
  String get quizSettings => '퀴즈 설정';

  @override
  String get timerPerQuestionDesc => '문제별 카운트다운 (난이도에 따라 달라짐)';

  @override
  String questionsLabel(int count) {
    return '문제: $count';
  }

  @override
  String get difficultyLevel => '난이도';

  @override
  String get about => '정보';

  @override
  String get appDescription => '지리 지식을 시험해 보세요!';

  @override
  String get capitalMode => '수도 모드';

  @override
  String get capitalModeDesc => '사진으로 수도 맞히기';

  @override
  String get flagMode => '국기 모드';

  @override
  String get flagModeDesc => '국기로 나라 맞히기';

  @override
  String get questionFoodCountry => '이 음식은 어느 나라의 것일까요?';

  @override
  String get questionCapitalPhoto => '사진 속 수도는 어디일까요?';

  @override
  String get questionFlagCountry => '이 국기는 어느 나라의 것일까요?';

  @override
  String questionCapitalCountry(String capital) {
    return '$capital은(는) 어느 나라의 수도일까요?';
  }

  @override
  String get resultTitle => '퀴즈 결과';

  @override
  String scoreLabel(int score, int total) {
    return '$score / $total 정답';
  }

  @override
  String durationLabel(String duration) {
    return '시간: $duration';
  }

  @override
  String modeLabel(String mode) {
    return '모드: $mode';
  }

  @override
  String get gradeExcellent => '훌륭해요!';

  @override
  String get gradeGreat => '잘했어요!';

  @override
  String get gradeGood => '좋아요';

  @override
  String get gradeNeedsWork => '연습이 필요해요';

  @override
  String get reviewAnswers => '답변 확인';

  @override
  String get backToMenu => '메뉴로';

  @override
  String get tryAgain => '다시 시도';

  @override
  String get correctAnswer => '정답';

  @override
  String get yourAnswer => '내 답변';

  @override
  String get statsTitle => '통계';

  @override
  String get overallStats => '전체 통계';

  @override
  String get totalGames => '총 게임';

  @override
  String get bestScoreShort => '최고 점수';

  @override
  String get recentResults => '최근 결과';

  @override
  String get noGamesPlayed => '게임 기록이 없어요';

  @override
  String questionLabel(int current, int total) {
    return '문제 $current/$total';
  }

  @override
  String scoreCounter(int score) {
    return '점수: $score';
  }

  @override
  String get explore => '둘러보기 →';

  @override
  String get quizLoading => '퀴즈 불러오는 중…';

  @override
  String get error => '오류';

  @override
  String get errorInsufficientData => '이 모드에 필요한 데이터가 부족해요';

  @override
  String errorLoadingQuiz(String error) {
    return '불러오기 오류: $error';
  }

  @override
  String get errorQuestionsFailed => '문제를 불러올 수 없어요. 다시 시도해 주세요.';

  @override
  String get unanswered => '답하지 않음';

  @override
  String get average => '평균';

  @override
  String get support => '지원';

  @override
  String get supportIntro => '문의, 버그, 의견이 있다면 언제든 알려 주세요.';

  @override
  String get contactEmail => '이메일 보내기';

  @override
  String get version => '버전';
}
