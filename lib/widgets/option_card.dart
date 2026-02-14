// lib/widgets/option_card.dart
import 'package:flutter/material.dart';

enum OptionState { neutral, selected, correct, wrong }

class OptionCard extends StatefulWidget {
  final int index;
  final String text;
  final OptionState state;
  final VoidCallback? onTap;

  const OptionCard({
    super.key,
    required this.index,
    required this.text,
    required this.state,
    this.onTap,
  });

  @override
  State<OptionCard> createState() => _OptionCardState();
}

class _OptionCardState extends State<OptionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _shakeAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
          tween: Tween(begin: Offset.zero, end: const Offset(-0.02, 0)),
          weight: 1),
      TweenSequenceItem(
          tween:
              Tween(begin: const Offset(-0.02, 0), end: const Offset(0.02, 0)),
          weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(0.02, 0), end: Offset.zero),
          weight: 1),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(OptionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == OptionState.correct &&
        oldWidget.state != OptionState.correct) {
      _controller.forward(from: 0).then((_) => _controller.reverse());
    } else if (widget.state == OptionState.wrong &&
        oldWidget.state != OptionState.wrong) {
      _controller.forward(from: 0).then((_) => _controller.reverse());
    }
  }

  Color _getBackgroundColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (widget.state) {
      case OptionState.selected:
        return theme.colorScheme.primary.withOpacity(0.12);
      case OptionState.correct:
        return Colors.green.shade50;
      case OptionState.wrong:
        return Colors.red.shade50;
      case OptionState.neutral:
        return theme.colorScheme.surface;
    }
  }

  Color _getBorderColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (widget.state) {
      case OptionState.selected:
        return theme.colorScheme.primary;
      case OptionState.correct:
        return Colors.green;
      case OptionState.wrong:
        return Colors.red;
      case OptionState.neutral:
        return theme.dividerColor;
    }
  }

  IconData? _getIcon() {
    switch (widget.state) {
      case OptionState.correct:
        return Icons.check_circle;
      case OptionState.wrong:
        return Icons.cancel;
      default:
        return null;
    }
  }

  Color _getIconColor() {
    switch (widget.state) {
      case OptionState.correct:
        return Colors.green;
      case OptionState.wrong:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = _getIcon();

    Widget card = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: _getBackgroundColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getBorderColor(context),
          width: widget.state == OptionState.neutral ? 1 : 2,
        ),
        boxShadow: widget.state != OptionState.neutral
            ? [
                BoxShadow(
                  color: _getBorderColor(context).withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: _getIconColor(), size: 22),
                  const SizedBox(width: 12),
                ] else ...[
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    widget.text,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: widget.state == OptionState.neutral
                          ? theme.colorScheme.onSurface
                          : widget.state == OptionState.correct
                              ? Colors.green.shade900
                              : widget.state == OptionState.wrong
                                  ? Colors.red.shade900
                                  : theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Animasyonlar
    if (widget.state == OptionState.correct) {
      card = ScaleTransition(scale: _scaleAnimation, child: card);
    } else if (widget.state == OptionState.wrong) {
      card = SlideTransition(position: _shakeAnimation, child: card);
    }

    return card;
  }
}

// Options grid (2x2 veya column)
class OptionsLayout extends StatelessWidget {
  final List<Widget> options;

  const OptionsLayout({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Geniş ekranda 2x2 grid
        if (constraints.maxWidth >= 900) {
          return GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 3.5,
            children: options,
          );
        }

        // Dar ekranda dikey liste
        return Column(
          children: options.map((option) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: option,
            );
          }).toList(),
        );
      },
    );
  }
}
