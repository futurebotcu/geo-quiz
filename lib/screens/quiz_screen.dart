import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../core/models.dart';
import '../core/question_engine.dart';
import '../services/settings_provider.dart';
import '../theme/app_tokens.dart';
import 'result_screen.dart';
import '../widgets/answer_option.dart';
import '../widgets/language_flag_button.dart';
import '../utils/country_localizer.dart';
import '../l10n/app_localizations.dart';
import '../utils/mode_labels.dart';
import '../generated/asset_version.dart';

class QuizScreen extends StatefulWidget {
  final QuizSettings settings;

  const QuizScreen({super.key, required this.settings});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuestionEngine _engine = QuestionEngine();
  List<QuizQuestion> _questions = [];
  final List<QuizAnswer> _answers = [];
  int _currentQuestionIndex = 0;
  int? _selectedOption;
  bool _isLoading = true;
  bool _hasAnswered = false;
  Timer? _timer;
  Timer? _postAnswerTimer;
  DateTime? _quizStartTime;

  bool _didInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // `Localizations.localeOf` needs InheritedWidgets resolved, so it must
    // run after initState. Guarded so we only kick off the quiz once.
    if (!_didInit) {
      _didInit = true;
      _initializeQuiz();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _postAnswerTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeQuiz() async {
    setState(() => _isLoading = true);

    // Capture the active locale before the first await so answer options
    // are generated in the language the user is seeing.
    final languageCode = Localizations.localeOf(context).languageCode;

    try {
      await _engine.initialize();
      final questions = await _engine.generateQuestions(
        widget.settings,
        languageCode: languageCode,
      );

      if (questions.isEmpty) {
        if (kDebugMode) debugPrint('[QUIZ] No questions generated for ${widget.settings.mode.wireName}');
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(S.of(context).errorInsufficientData)),
          );
          Navigator.pop(context);
        }
        return;
      }

      setState(() {
        _questions = questions;
        _isLoading = false;
        _quizStartTime = DateTime.now();
      });

      // Precache food and capital photo images for better performance
      if (mounted) {
        for (final question in questions) {
          if (question.imagePath != null &&
              (question.imagePath!.contains('food_photos') ||
                  question.imagePath!.contains('capital_photos'))) {
            try {
              precacheImage(AssetImage(question.imagePath!), context);
            } catch (_) {
              // Ignore precache errors
            }
          }
        }
      }

      if (widget.settings.timerEnabled) {
        _startTimer();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[QUIZ] Error initializing quiz: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).errorLoadingQuiz(e.toString()))),
        );
      }
    }
  }

  int _secondsFor(DifficultyLevel d) {
    switch (d) {
      case DifficultyLevel.easy:
        return 25; // Kolay: uzun süre
      case DifficultyLevel.medium:
        return 20; // Orta
      case DifficultyLevel.hard:
        return 12; // Zor: kısa süre
    }
  }

  void _startTimer() {
    final perQuestionSeconds = _secondsFor(widget.settings.difficulty);
    _timer = Timer.periodic(Duration(seconds: perQuestionSeconds), (timer) {
      if (_hasAnswered) return;
      _autoSubmitAnswer();
    });
  }

  void _autoSubmitAnswer() {
    if (!_hasAnswered) {
      _submitAnswer(-1);
    }
  }

  void _submitAnswer(int selectedIndex) {
    if (_hasAnswered) return;

    setState(() {
      _selectedOption = selectedIndex;
      _hasAnswered = true;
    });

    final question = _questions[_currentQuestionIndex];
    // iso2-based correctness — survives mid-quiz locale switches that may
    // have re-rendered option text in a different language.
    final isCorrect = selectedIndex == question.correctOptionIndex;

    final answer = QuizAnswer(
      questionIndex: _currentQuestionIndex,
      selectedIndex: selectedIndex,
      isCorrect: isCorrect,
      timestamp: DateTime.now(),
    );

    _answers.add(answer);

    _postAnswerTimer?.cancel();
    // Post-answer pause: long enough to register the green/red feedback,
    // short enough to keep the quiz feeling snappy. Previously 2000ms —
    // tightened to 1200ms on user feedback ("too slow").
    _postAnswerTimer = Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      if (_currentQuestionIndex < _questions.length - 1) {
        _nextQuestion();
      } else {
        _finishQuiz();
      }
    });
  }

  void _nextQuestion() {
    if (!mounted) return;
    setState(() {
      _currentQuestionIndex++;
      _selectedOption = null;
      _hasAnswered = false;
    });

    if (widget.settings.timerEnabled) {
      _timer?.cancel();
      _startTimer();
    }
  }

  Future<void> _finishQuiz() async {
    _timer?.cancel();
    _postAnswerTimer?.cancel();

    if (!mounted) return;

    final totalTime = DateTime.now().difference(_quizStartTime!);
    final score = _answers.where((a) => a.isCorrect).length;

    final result = QuizResult(
      answers: _answers,
      score: score,
      totalQuestions: _questions.length,
      totalTime: totalTime,
      mode: widget.settings.mode,
      completedAt: DateTime.now(),
    );

    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    await settingsProvider.saveQuizResult(result);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          result: result,
          questions: _questions,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(S.of(context).quizLoading)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(S.of(context).error)),
        body: Center(
          child: Text(S.of(context).errorQuestionsFailed),
        ),
      );
    }

    final question = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              localizedModeName(S.of(context), widget.settings.mode),
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              localizedModeSubtitle(S.of(context), widget.settings.mode),
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        centerTitle: true,
        actions: const [LanguageFlagButton()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: progress),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Padding(
            // Tighter top padding so the info card doesn't crowd the
            // progress bar on small screens. Bottom keeps 16 + SafeArea.
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    // Slimmer info-card padding: the single row of text
                    // doesn't need the same breathing room as the question
                    // card below.
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            S.of(context).questionLabel(
                                _currentQuestionIndex + 1, _questions.length),
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            S.of(context).scoreCounter(
                                _answers.where((a) => a.isCorrect).length),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Soru değiştiğinde fade-through geçişi. Ani içerik değişimini
                // yumuşatır; quiz akışını daha akıcı hissettirir.
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.025),
                        end: Offset.zero,
                      ).animate(anim),
                      child: child,
                    ),
                  ),
                  child: Column(
                    key: ValueKey(_currentQuestionIndex),
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                _getLocalizedQuestionText(question),
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              _buildQuestionImage(question),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(question.options.length, (index) {
                        // Resolve option text against the live locale so a
                        // mid-quiz language switch re-renders all options.
                        final iso2 = index < question.optionIso2s.length
                            ? question.optionIso2s[index]
                            : '';
                        final fallback = question.options[index];
                        final label = iso2.isNotEmpty
                            ? CountryLocalizer.labelFor(
                                iso2: iso2,
                                kind: question.optionKind,
                                languageCode:
                                    Localizations.localeOf(context).languageCode,
                                fallback: fallback,
                              )
                            : fallback;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildOptionButton(index, label, question),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getLocalizedQuestionText(QuizQuestion question) {
    final s = S.of(context);
    switch (question.mode) {
      case QuizMode.foodCountry:
        return s.questionFoodCountry;
      case QuizMode.capitalPhoto:
      case QuizMode.capitalFromImage:
        return s.questionCapitalPhoto;
      case QuizMode.flagCountry:
        return s.questionFlagCountry;
      case QuizMode.capitalCountry:
        // Resolve the capital name against the live locale so the question
        // text also updates on mid-quiz language switches. Fall back to
        // the quiz-start metadata if the localizer hasn't loaded yet.
        final lang = Localizations.localeOf(context).languageCode;
        final live = CountryLocalizer.capitalOf(question.iso2, lang);
        final frozen = question.metadata['capital'] as String? ?? '';
        final capital = (live != null && live.isNotEmpty) ? live : frozen;
        return s.questionCapitalCountry(capital);
      case QuizMode.mixed:
        // In practice, each generated question carries a concrete mode
        // (food/capital/flag/capitalCountry), so this branch is a safety net.
        return s.questionFoodCountry;
    }
  }

  Widget _buildQuestionImage(QuizQuestion question) {
    // Bayrak modunda özel widget kullan
    if (widget.settings.mode == QuizMode.flagCountry) {
      return SizedBox(
        height: 180,
        child: _FlagBox(
          assetPath: question.imagePath,
          emoji: question.emoji ?? '',
        ),
      );
    }

    // Diğer modlar için mevcut mantık
    if (question.emoji != null) {
      return Container(
        width: 280,
        height: 180,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.all(AppRadius.rMd),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FittedBox(
            fit: BoxFit.contain,
            child: Text(
              question.emoji!,
              style: const TextStyle(fontSize: 200, height: 1.0),
            ),
          ),
        ),
      );
    } else if (question.imagePath != null) {
      // Food mode için caption kontrolü
      final dishName = question.metadata['dishName'] as String?;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            height: 200,
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.all(AppRadius.rMd),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.all(AppRadius.rMd),
              child: Image.asset(
                question.imagePath!,
                key: ValueKey('${question.imagePath}-${AssetVersion.value}'),
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error, stackTrace) {
                  if (kDebugMode) {
                    debugPrint(
                        'CAPITAL_IMG_FAIL path=${question.imagePath} mode=${question.mode} error=$error');
                  }
                  // Flag görseli yüklenemezse emojiye düşelim
                  if (question.emoji != null) {
                    return Container(
                      color: Colors.grey.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            question.emoji!,
                            style:
                                const TextStyle(fontSize: 200, height: 1.0),
                          ),
                        ),
                      ),
                    );
                  }
                  // Son fallback
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.image_not_supported,
                          color: Colors.grey, size: 48),
                    ),
                  );
                },
              ),
            ),
          ),
          if (dishName != null && dishName.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              dishName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                    fontStyle: FontStyle.italic,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      );
    } else {
      return Container(
        width: 280,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.all(AppRadius.rMd),
        ),
        child: const Center(
          child: Icon(Icons.help, color: Colors.grey),
        ),
      );
    }
  }

  Widget _buildOptionButton(int index, String option, QuizQuestion question) {
    return AnswerOption(
      index: index,
      label: option,
      hasAnswered: _hasAnswered,
      isCorrect: index == question.correctIndex,
      isUserSelection: index == _selectedOption,
      onTap: _hasAnswered ? null : () => _submitAnswer(index),
    );
  }
}

class _FlagBox extends StatelessWidget {
  final String? assetPath;
  final String emoji;
  const _FlagBox({required this.assetPath, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: ClipRRect(
        borderRadius: BorderRadius.all(AppRadius.rMd),
        child: Container(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withValues(alpha: 0.35),
          child: assetPath != null && assetPath!.isNotEmpty
              ? Image.asset(
                  assetPath!,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => _EmojiFlag(emoji: emoji),
                )
              : _EmojiFlag(emoji: emoji),
        ),
      ),
    );
  }
}

class _EmojiFlag extends StatelessWidget {
  final String emoji;
  const _EmojiFlag({required this.emoji});

  @override
  Widget build(BuildContext context) {
    // FittedBox.contain: emoji'yi container'a orantılı sığdırır, her zaman
    // tam ortalı ve symmetric padding ile. Sabit fontSize'ın yol açtığı
    // baseline/ascent dengesizliğini çözer.
    return Padding(
      padding: const EdgeInsets.all(12),
      child: FittedBox(
        fit: BoxFit.contain,
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 200, height: 1.0),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
