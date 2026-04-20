// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class SJa extends S {
  SJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'ジオクイズ：国旗・首都・料理';

  @override
  String get settings => '設定';

  @override
  String get language => '言語';

  @override
  String get languageSystemDefault => 'システムのデフォルト';

  @override
  String get save => '保存';

  @override
  String get menuTitle => 'モードを選ぶ';

  @override
  String get statistics => '統計';

  @override
  String get debugCount => 'デバッグ';

  @override
  String get modeSelect => 'モードを選ぶ';

  @override
  String get modeDescription => '5つのモード：料理→国、写真→首都、国旗→国、都市→国、ミックス。';

  @override
  String get modeFoodCountry => '料理 → 国';

  @override
  String get modeFoodCountryDesc => '写真の料理がどの国のものか当てよう。';

  @override
  String get modeCapitalPhoto => '写真 → 首都';

  @override
  String get modeCapitalPhotoDesc => '都市の写真から首都を当てよう。';

  @override
  String get modeFlagCountry => '国旗 → 国';

  @override
  String get modeFlagCountryDesc => '国旗からその国を当てよう。';

  @override
  String get modeCapitalCountry => '都市 → 国';

  @override
  String get modeCapitalCountryDesc => '示された都市がどの国のものか選ぼう。';

  @override
  String get modeMixed => 'ミックス';

  @override
  String get modeMixedDesc => '全部入り！ 問題はランダムに出題されます。';

  @override
  String get start => 'スタート';

  @override
  String get missingData => 'データ不足';

  @override
  String get hintText => 'モードをタップして、難易度・タイマー・大陸を選んでからスタート。';

  @override
  String get difficulty => '難易度';

  @override
  String get difficultyEasy => 'やさしい';

  @override
  String get difficultyMedium => 'ふつう';

  @override
  String get difficultyHard => 'むずかしい';

  @override
  String get questionCount => '問題数';

  @override
  String get timer => 'タイマー';

  @override
  String get timerEnabled => 'タイマーON';

  @override
  String get countdownPerQuestion => '1問ごとのカウントダウン';

  @override
  String get continentFilter => '大陸フィルタ';

  @override
  String get continentAll => 'すべて';

  @override
  String get continentEurope => 'ヨーロッパ';

  @override
  String get continentAsia => 'アジア';

  @override
  String get continentAfrica => 'アフリカ';

  @override
  String get continentNorthAmerica => '北アメリカ';

  @override
  String get continentSouthAmerica => '南アメリカ';

  @override
  String get continentOceania => 'オセアニア';

  @override
  String get quizSettings => 'クイズ設定';

  @override
  String get timerPerQuestionDesc => '1問ごとのカウントダウン（難易度で変動）';

  @override
  String questionsLabel(int count) {
    return '問題数：$count';
  }

  @override
  String get difficultyLevel => '難易度レベル';

  @override
  String get about => 'アプリについて';

  @override
  String get appDescription => '地理の知識を試そう！';

  @override
  String get capitalMode => '首都モード';

  @override
  String get capitalModeDesc => '写真から首都を当てよう';

  @override
  String get flagMode => '国旗モード';

  @override
  String get flagModeDesc => '国旗から国を当てよう';

  @override
  String get questionFoodCountry => 'この料理はどの国のもの？';

  @override
  String get questionCapitalPhoto => '写真に写っている首都は？';

  @override
  String get questionFlagCountry => 'この国旗はどの国のもの？';

  @override
  String questionCapitalCountry(String capital) {
    return '$capitalはどの国の首都？';
  }

  @override
  String get resultTitle => 'クイズ結果';

  @override
  String scoreLabel(int score, int total) {
    return '$score / $total 正解';
  }

  @override
  String durationLabel(String duration) {
    return '時間：$duration';
  }

  @override
  String modeLabel(String mode) {
    return 'モード：$mode';
  }

  @override
  String get gradeExcellent => '素晴らしい！';

  @override
  String get gradeGreat => 'すごい！';

  @override
  String get gradeGood => 'いいね';

  @override
  String get gradeNeedsWork => 'もう一歩';

  @override
  String get reviewAnswers => '解答を見直す';

  @override
  String get backToMenu => 'メニューへ';

  @override
  String get tryAgain => 'もう一度';

  @override
  String get correctAnswer => '正解';

  @override
  String get yourAnswer => 'あなたの回答';

  @override
  String get statsTitle => '統計';

  @override
  String get overallStats => '全体の統計';

  @override
  String get totalGames => '総プレイ数';

  @override
  String get bestScoreShort => 'ベストスコア';

  @override
  String get recentResults => '最近の結果';

  @override
  String get noGamesPlayed => 'まだプレイしていません';

  @override
  String questionLabel(int current, int total) {
    return '問題 $current/$total';
  }

  @override
  String scoreCounter(int score) {
    return 'スコア：$score';
  }

  @override
  String get explore => '見てみる →';

  @override
  String get quizLoading => 'クイズを読み込み中…';

  @override
  String get error => 'エラー';

  @override
  String get errorInsufficientData => 'このモードには十分なデータがありません';

  @override
  String errorLoadingQuiz(String error) {
    return '読み込みエラー：$error';
  }

  @override
  String get errorQuestionsFailed => '問題を読み込めませんでした。もう一度お試しください。';

  @override
  String get unanswered => '未回答';

  @override
  String get average => '平均';

  @override
  String get support => 'サポート';

  @override
  String get supportIntro => 'ご質問・不具合・ご要望などお気軽にお知らせください。';

  @override
  String get contactEmail => 'メールで連絡';

  @override
  String get version => 'バージョン';
}
