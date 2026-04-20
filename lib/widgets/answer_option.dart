import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

/// Quiz answer row. Replaces the bare `ElevatedButton` that previously
/// handled all four quiz-option states. Adds:
///   - letter badge (A/B/C/D) for scannability,
///   - state-aware surface + border + icon (neutral/correct/wrong/dimmed),
///   - press ripple via InkWell with a micro scale-down (tactile feedback),
///   - smooth color transition when the answer is revealed.
class AnswerOption extends StatefulWidget {
  final int index;
  final String label;

  /// Whether any answer has been submitted on this question yet.
  final bool hasAnswered;

  /// True if this option is the correct answer.
  final bool isCorrect;

  /// True if the user actually tapped this option.
  final bool isUserSelection;

  final VoidCallback? onTap;

  const AnswerOption({
    super.key,
    required this.index,
    required this.label,
    required this.hasAnswered,
    required this.isCorrect,
    required this.isUserSelection,
    required this.onTap,
  });

  @override
  State<AnswerOption> createState() => _AnswerOptionState();
}

class _AnswerOptionState extends State<AnswerOption> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final state = _resolveState();

    final (bg, border, fg, icon) = switch (state) {
      _OptionState.neutral => (
          scheme.surfaceContainerHigh,
          scheme.outlineVariant.withValues(alpha: 0.6),
          scheme.onSurface,
          null as IconData?,
        ),
      _OptionState.dimmed => (
          scheme.surfaceContainer,
          scheme.outlineVariant.withValues(alpha: 0.3),
          scheme.onSurfaceVariant.withValues(alpha: 0.6),
          null as IconData?,
        ),
      _OptionState.correct => (
          AppFeedbackColors.correctSurface,
          AppFeedbackColors.correct,
          AppFeedbackColors.correct,
          Icons.check_circle,
        ),
      _OptionState.wrong => (
          AppFeedbackColors.wrongSurface,
          AppFeedbackColors.wrong,
          AppFeedbackColors.wrong,
          Icons.cancel,
        ),
    };

    // Micro scale-down on press, fast release. Kept subtle (0.985) so it
    // reads as tactile, not as a squishy toy.
    return AnimatedScale(
      scale: _pressed && widget.onTap != null ? 0.985 : 1.0,
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border, width: state.isStrong ? 2 : 1),
          borderRadius: AppRadius.brMd,
          // Soft lift for revealed answer (correct/wrong). Very subtle, no
          // big shadow — keeps the premium quiet direction.
          boxShadow: state.isStrong
              ? [
                  BoxShadow(
                    color: border.withValues(alpha: 0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: AppRadius.brMd,
          child: InkWell(
            borderRadius: AppRadius.brMd,
            onTap: widget.onTap,
            onHighlightChanged: widget.onTap == null
                ? null
                : (h) => setState(() => _pressed = h),
            splashColor: scheme.primary.withValues(alpha: 0.06),
            highlightColor: scheme.primary.withValues(alpha: 0.03),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: 14),
              child: Row(
                children: [
                  _LetterBadge(
                    letter: _letterFor(widget.index),
                    foreground: fg,
                    border: border,
                    emphasis: state.isStrong,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: fg,
                            fontWeight: state.isStrong
                                ? FontWeight.w700
                                : FontWeight.w600,
                            height: 1.2,
                          ),
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    // Fade-in the verdict icon to match the state transition.
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 120),
                      child: Icon(icon, key: ValueKey(icon), color: fg, size: 22),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _OptionState _resolveState() {
    if (!widget.hasAnswered) return _OptionState.neutral;
    if (widget.isCorrect) return _OptionState.correct;
    if (widget.isUserSelection) return _OptionState.wrong;
    return _OptionState.dimmed;
  }

  static String _letterFor(int index) {
    const letters = ['A', 'B', 'C', 'D', 'E', 'F'];
    return index >= 0 && index < letters.length ? letters[index] : '?';
  }
}

enum _OptionState { neutral, dimmed, correct, wrong }

extension on _OptionState {
  bool get isStrong => this == _OptionState.correct || this == _OptionState.wrong;
}

class _LetterBadge extends StatelessWidget {
  final String letter;
  final Color foreground;
  final Color border;
  final bool emphasis;

  const _LetterBadge({
    required this.letter,
    required this.foreground,
    required this.border,
    required this.emphasis,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: emphasis ? foreground.withValues(alpha: 0.12) : Colors.transparent,
        border: Border.all(color: border, width: emphasis ? 1.5 : 1),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: foreground,
          height: 1.0,
        ),
      ),
    );
  }
}
