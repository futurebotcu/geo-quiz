// lib/widgets/quiz_header.dart
import 'package:flutter/material.dart';

class QuizHeader extends StatelessWidget {
  final String modeTitle;
  final int currentQuestion;
  final int totalQuestions;
  final double progress;
  final int? remainingSeconds;

  const QuizHeader({
    super.key,
    required this.modeTitle,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.progress,
    this.remainingSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primaryContainer.withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          modeTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Soru $currentQuestion/$totalQuestions',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (remainingSeconds != null)
                    TimerChip(seconds: remainingSeconds!),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TimerChip extends StatelessWidget {
  final int seconds;

  const TimerChip({super.key, required this.seconds});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLowTime = seconds <= 5;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isLowTime
            ? Colors.red.shade100
            : theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLowTime ? Colors.red : theme.colorScheme.secondary,
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 18,
            color:
                isLowTime ? Colors.red.shade900 : theme.colorScheme.secondary,
          ),
          const SizedBox(width: 6),
          Text(
            '${seconds}s',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color:
                  isLowTime ? Colors.red.shade900 : theme.colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
