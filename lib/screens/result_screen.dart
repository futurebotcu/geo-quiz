import 'package:flutter/material.dart';
import '../core/models.dart';
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: gradeColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: gradeColor, width: 3),
                      ),
                      child: Center(
                        child: Text(
                          '${percentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: gradeColor,
                          ),
                        ),
                      ),
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
                      S.of(context).modeLabel(result.mode.displayName),
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
                          final userAnswer = answer.selectedIndex >= 0
                              ? question.options[answer.selectedIndex]
                              : 'CevaplanmadÄ±';

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  isCorrect ? Colors.green : Colors.red,
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
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    '${S.of(context).correctAnswer}: ${question.correctAnswer}'),
                                Text(
                                  '${S.of(context).yourAnswer}: $userAnswer',
                                  style: TextStyle(
                                    color:
                                        isCorrect ? Colors.green : Colors.red,
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
    );
  }

  Color _getGradeColor(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 70) return Colors.orange;
    if (percentage >= 50) return Colors.amber;
    return Colors.red;
  }

  String _getGradeText(BuildContext context, double percentage) {
    final s = S.of(context);
    if (percentage >= 90) return s.gradeExcellent;
    if (percentage >= 75) return s.gradeGreat;
    if (percentage >= 60) return s.gradeGood;
    if (percentage >= 50) return s.gradeFair;
    return s.gradeNeedsWork;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _playAgain(BuildContext context) {
    final settings = QuizSettings(
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
