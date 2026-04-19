import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class HeaderCarousel extends StatefulWidget {
  final List<String> images;
  final double height;
  final Duration interval;
  /// Called when a slide is tapped. If null, the slide is non-interactive.
  final void Function(int index)? onItemTap;

  const HeaderCarousel({
    super.key,
    required this.images,
    this.height = 220,
    this.interval = const Duration(seconds: 4),
    this.onItemTap,
  });

  @override
  State<HeaderCarousel> createState() => _HeaderCarouselState();
}

class _HeaderCarouselState extends State<HeaderCarousel> {
  late final PageController _c;
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _c = PageController(viewportFraction: 0.95);
    _timer = Timer.periodic(widget.interval, (_) {
      if (!mounted || widget.images.isEmpty) return;
      _index = (_index + 1) % widget.images.length;
      _c.animateToPage(
        _index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: widget.height,
      child: PageView.builder(
        controller: _c,
        itemCount: widget.images.length,
        itemBuilder: (context, i) {
          final img = widget.images[i];
          final content = ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  img,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, _) => Container(
                    color: Colors.grey.shade900,
                    child: const Center(
                      child: Icon(Icons.image_not_supported,
                          color: Colors.white54, size: 48),
                    ),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black54, Colors.transparent],
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: 12,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        S.of(context).explore,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                      ),
                      if (widget.onItemTap != null)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(Icons.arrow_forward_rounded,
                              color: Colors.white, size: 20),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );

          Widget slide = Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: widget.onItemTap == null
                ? content
                : Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => widget.onItemTap!(i),
                      child: content,
                    ),
                  ),
          );
          return slide;
        },
      ),
    );
  }
}
