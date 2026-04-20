// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class SZh extends S {
  SZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => '地理问答：国旗、首都与美食';

  @override
  String get settings => '设置';

  @override
  String get language => '语言';

  @override
  String get languageSystemDefault => '跟随系统';

  @override
  String get save => '保存';

  @override
  String get menuTitle => '选择模式';

  @override
  String get statistics => '统计';

  @override
  String get debugCount => '调试';

  @override
  String get modeSelect => '选择模式';

  @override
  String get modeDescription => '五种模式：美食→国家、照片→首都、国旗→国家、城市→国家、混合。';

  @override
  String get modeFoodCountry => '美食 → 国家';

  @override
  String get modeFoodCountryDesc => '猜一猜照片里的美食来自哪个国家。';

  @override
  String get modeCapitalPhoto => '照片 → 首都';

  @override
  String get modeCapitalPhotoDesc => '从城市照片中识别首都。';

  @override
  String get modeFlagCountry => '国旗 → 国家';

  @override
  String get modeFlagCountryDesc => '根据国旗识别国家。';

  @override
  String get modeCapitalCountry => '城市 → 国家';

  @override
  String get modeCapitalCountryDesc => '选择该城市所属的国家。';

  @override
  String get modeMixed => '混合';

  @override
  String get modeMixedDesc => '多合一！题目随机混合出题。';

  @override
  String get start => '开始';

  @override
  String get missingData => '数据不足';

  @override
  String get hintText => '点击模式，开始前可选择难度、计时器和大陆筛选。';

  @override
  String get difficulty => '难度';

  @override
  String get difficultyEasy => '简单';

  @override
  String get difficultyMedium => '中等';

  @override
  String get difficultyHard => '困难';

  @override
  String get questionCount => '题目数量';

  @override
  String get timer => '计时器';

  @override
  String get timerEnabled => '开启计时器';

  @override
  String get countdownPerQuestion => '每题倒计时';

  @override
  String get continentFilter => '大陆筛选';

  @override
  String get continentAll => '全部';

  @override
  String get continentEurope => '欧洲';

  @override
  String get continentAsia => '亚洲';

  @override
  String get continentAfrica => '非洲';

  @override
  String get continentNorthAmerica => '北美洲';

  @override
  String get continentSouthAmerica => '南美洲';

  @override
  String get continentOceania => '大洋洲';

  @override
  String get quizSettings => '问答设置';

  @override
  String get timerPerQuestionDesc => '每题倒计时（随难度变化）';

  @override
  String questionsLabel(int count) {
    return '题目：$count';
  }

  @override
  String get difficultyLevel => '难度等级';

  @override
  String get about => '关于';

  @override
  String get appDescription => '测试你的地理知识！';

  @override
  String get capitalMode => '首都模式';

  @override
  String get capitalModeDesc => '从照片中识别首都';

  @override
  String get flagMode => '国旗模式';

  @override
  String get flagModeDesc => '根据国旗识别国家';

  @override
  String get questionFoodCountry => '这道美食来自哪个国家？';

  @override
  String get questionCapitalPhoto => '照片里的首都是哪座？';

  @override
  String get questionFlagCountry => '这面国旗属于哪个国家？';

  @override
  String questionCapitalCountry(String capital) {
    return '$capital是哪个国家的首都？';
  }

  @override
  String get resultTitle => '问答结果';

  @override
  String scoreLabel(int score, int total) {
    return '$score / $total 正确';
  }

  @override
  String durationLabel(String duration) {
    return '用时：$duration';
  }

  @override
  String modeLabel(String mode) {
    return '模式：$mode';
  }

  @override
  String get gradeExcellent => '非常棒！';

  @override
  String get gradeGreat => '很棒！';

  @override
  String get gradeGood => '不错';

  @override
  String get gradeNeedsWork => '继续加油';

  @override
  String get reviewAnswers => '查看答案';

  @override
  String get backToMenu => '返回菜单';

  @override
  String get tryAgain => '再来一次';

  @override
  String get correctAnswer => '正确答案';

  @override
  String get yourAnswer => '你的答案';

  @override
  String get statsTitle => '统计';

  @override
  String get overallStats => '整体统计';

  @override
  String get totalGames => '总局数';

  @override
  String get bestScoreShort => '最佳成绩';

  @override
  String get recentResults => '最近结果';

  @override
  String get noGamesPlayed => '还没有游戏记录';

  @override
  String questionLabel(int current, int total) {
    return '题目 $current/$total';
  }

  @override
  String scoreCounter(int score) {
    return '得分：$score';
  }

  @override
  String get explore => '探索 →';

  @override
  String get quizLoading => '正在加载问答…';

  @override
  String get error => '错误';

  @override
  String get errorInsufficientData => '该模式的数据不足';

  @override
  String errorLoadingQuiz(String error) {
    return '加载失败：$error';
  }

  @override
  String get errorQuestionsFailed => '无法加载题目，请重试。';

  @override
  String get unanswered => '未作答';

  @override
  String get average => '平均';

  @override
  String get support => '支持';

  @override
  String get supportIntro => '有问题、发现 Bug 或有建议？欢迎随时联系我们。';

  @override
  String get contactEmail => '发送邮件';

  @override
  String get version => '版本';
}
