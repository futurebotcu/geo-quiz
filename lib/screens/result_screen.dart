import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/models.dart';
import '../services/settings_provider.dart';
import '../theme/app_tokens.dart';
import '../utils/country_localizer.dart';
import '../utils/mode_labels.dart';
import 'menu_screen.dart';
import 'quiz_screen.dart';
import '../l10n/app_localizations.dart';

class ResultScreen extends StatelessWidget {
  final QuizResult result;
  final List<QuizQuestion> questions;

  const ResultScreen({
    super.key,
    required this.result,
    required this.questions,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = result.percentage;
    final gradeColor = _getGradeColor(percentage);
    final gradeText = _getGradeText(context, percentage);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).resultTitle),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Score ring — animated count-up from 0 to %value on
                    // screen entry. Creates a small "reveal" moment so the
                    // result doesn't feel like a static label.
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: percentage),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return SizedBox(
                          width: 120,
                          height: 120,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Background track ring.
                              SizedBox.expand(
                                child: CircularProgressIndicator(
                                  value: 1.0,
                                  strokeWidth: 6,
                                  valueColor: AlwaysStoppedAnimation(
                                    gradeColor.withValues(alpha: 0.12),
                                  ),
                                ),
                              ),
                              // Animated progress ring.
                              SizedBox.expand(
                                child: CircularProgressIndicator(
                                  value: value / 100.0,
                                  strokeWidth: 6,
                                  strokeCap: StrokeCap.round,
                                  valueColor:
                                      AlwaysStoppedAnimation(gradeColor),
                                ),
                              ),
                              // Center number — counts up with the ring.
                              Text(
                                '${value.round()}%',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: gradeColor,
                                  height: 1.0,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      gradeText,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: gradeColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      S
                          .of(context)
                          .scoreLabel(result.score, result.totalQuestions),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      S
                          .of(context)
                          .durationLabel(_formatDuration(result.totalTime)),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      S.of(context).modeLabel(
                          localizedModeName(S.of(context), result.mode)),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _playAgain(context),
                    icon: const Icon(Icons.refresh),
                    label: Text(S.of(context).tryAgain),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MenuScreen()),
                      (route) => false,
                    ),
                    icon: const Icon(Icons.home),
                    label: Text(S.of(context).backToMenu),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        S.of(context).reviewAnswers,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: questions.length,
                        itemBuilder: (context, index) {
                          final question = questions[index];
                          final answer = result.answers[index];
                          final isCorrect = answer.isCorrect;
                          final lang =
                              Localizations.localeOf(context).languageCode;

                          // Locale-reactive labels so the review screen
                          // follows a language switch performed after the
                          // quiz ended.
                          String labelAt(int i) {
                            if (i < 0 || i >= question.options.length) {
                              return S.of(context).unanswered;
                            }
                            final iso2 = i < question.optionIso2s.length
                                ? question.optionIso2s[i]
                                : '';
                            final fallback = question.options[i];
                            return iso2.isNotEmpty
                                ? CountryLocalizer.labelFor(
                                    iso2: iso2,
                                    kind: question.optionKind,
                                    languageCode: lang,
                                    fallback: fallback,
                                  )
                                : fallback;
                          }

                          final userAnswer = answer.selectedIndex >= 0
                              ? labelAt(answer.selectedIndex)
                              : S.of(context).unanswered;
                          final correctLabel =
                              labelAt(question.correctOptionIndex);

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isCorrect
                                  ? AppFeedbackColors.correct
                                  : AppFeedbackColors.wrong,
                              child: Icon(
                                isCorrect ? Icons.check : Icons.close,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              S
                                  .of(context)
                                  .questionLabel(index + 1, questions.length),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    '${S.of(context).correctAnswer}: $correctLabel'),
                                Text(
                                  '${S.of(context).yourAnswer}: $userAnswer',
                                  style: TextStyle(
                                    color: isCorrect
                                        ? AppFeedbackColors.correct
                                        : AppFeedbackColors.wrong,
                                  ),
                                ),
                              ],
                            ),
                            trailing: question.emoji != null
                                ? Text(question.emoji!,
                                    style: const TextStyle(fontSize: 24))
                                : const Icon(Icons.image),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  // Grade color + text bands harmonized (earlier audit flagged them out of
  // sync: 90/70/50 vs 90/75/60/50). Now both use 90 / 70 / 50 thresholds.
  Color _getGradeColor(double percentage) {
    if (percentage >= 90) return AppFeedbackColors.correct;
    if (percentage >= 70) return Colors.orange.shade700;
    if (percentage >= 50) return Colors.amber.shade700;
    return AppFeedbackColors.wrong;
  }

  String _getGradeText(BuildContext context, double percentage) {
    final s = S.of(context);
    if (percentage >= 90) return s.gradeExcellent;
    if (percentage >= 70) return s.gradeGreat;
    if (percentage >= 50) return s.gradeGood;
    return s.gradeNeedsWork;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _playAgain(BuildContext context) {
    final provider = Provider.of<SettingsProvider>(context, listen: false);
    final settings = provider.settings.copyWith(
      mode: result.mode,
      questionCount: result.totalQuestions,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(settings: settings),
      ),
    );
  }
}
