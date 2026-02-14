import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../core/models.dart';
import '../core/question_engine.dart';
import '../services/settings_provider.dart';
import 'result_screen.dart';
import '../widgets/top_lang_toggle.dart';
import '../l10n/app_localizations.dart';
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
  DateTime? _quizStartTime;
  DateTime? _questionStartTime;

  @override
  void initState() {
    super.initState();
    _initializeQuiz();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initializeQuiz() async {
    setState(() => _isLoading = true);

    try {
      await _engine.initialize();
      final questions = await _engine.generateQuestions(widget.settings);

      if (questions.isEmpty) {
        print(
            '[QUIZ] No questions generated for ${widget.settings.mode.wireName}');
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Bu mod için yeterli veri bulunamadı')),
          );
          Navigator.pop(context);
        }
        return;
      }

      setState(() {
        _questions = questions;
        _isLoading = false;
        _quizStartTime = DateTime.now();
        _questionStartTime = DateTime.now();
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
      print('[QUIZ] Error initializing quiz: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Quiz yüklenirken hata: $e')),
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
    final isCorrect = selectedIndex == question.correctIndex;

    final answer = QuizAnswer(
      questionIndex: _currentQuestionIndex,
      selectedIndex: selectedIndex,
      isCorrect: isCorrect,
      timestamp: DateTime.now(),
    );

    _answers.add(answer);

    Timer(const Duration(seconds: 2), () {
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
      _questionStartTime = DateTime.now();
    });

    if (widget.settings.timerEnabled) {
      _timer?.cancel();
      _startTimer();
    }
  }

  Future<void> _finishQuiz() async {
    _timer?.cancel();

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

    // Save result to provider
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    await settingsProvider.saveQuizResult(result);

    if (context.mounted) {
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
        body: const Center(
          child: Text('Sorular yüklenemedi. Lütfen tekrar deneyin.'),
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
              widget.settings.mode.displayName,
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              widget.settings.mode.subtitle,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: progress),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TopLangToggle(),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        S.of(context).questionLabel(
                            _currentQuestionIndex + 1, _questions.length),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        S.of(context).scoreCounter(
                            _answers.where((a) => a.isCorrect).length),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        _getLocalizedQuestionText(question),
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      _buildQuestionImage(question),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...question.options.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildOptionButton(index, option, question),
                );
              }),
            ],
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
        // For capitalCountry mode, we need the capital name from metadata
        final capital = question.metadata['capital'] as String? ?? '';
        return s.questionCapitalCountry(capital);
      case QuizMode.mixed:
        return question.questionText; // Fallback for mixed mode
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
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            question.emoji!,
            style: const TextStyle(fontSize: 80),
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
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                question.imagePath!,
                key: ValueKey('${question.imagePath}-${AssetVersion.value}'),
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error, stackTrace) {
                  // Flag görseli yüklenemezse emojiye düşelim
                  if (question.emoji != null) {
                    return Container(
                      color: Colors.grey.shade50,
                      child: Center(
                        child: Text(
                          question.emoji!,
                          style: const TextStyle(fontSize: 80),
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
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(Icons.help, color: Colors.grey),
        ),
      );
    }
  }

  Widget _buildOptionButton(int index, String option, QuizQuestion question) {
    Color? backgroundColor;
    Color? foregroundColor;

    if (_hasAnswered) {
      if (index == question.correctIndex) {
        backgroundColor = Colors.green;
        foregroundColor = Colors.white;
      } else if (index == _selectedOption && index != question.correctIndex) {
        backgroundColor = Colors.red;
        foregroundColor = Colors.white;
      }
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _hasAnswered ? null : () => _submitAnswer(index),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          option,
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
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
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withOpacity(.35),
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
    return Center(
      child: Text(
        emoji,
        style: const TextStyle(
          fontSize: 96,
          height: 1.0,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
