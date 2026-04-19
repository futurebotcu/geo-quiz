import 'dart:ui';
import 'package:flutter/material.dart';

class MenuBackground extends StatelessWidget {
  final String imagePath;
  final Widget child;
  final double blur; // 0–10
  final double darken; // 0–1
  const MenuBackground({
    super.key,
    required this.imagePath,
    required this.child,
    this.blur = 6,
    this.darken = 0.35,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(imagePath, fit: BoxFit.cover),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: const SizedBox.expand(),
        ),
        Container(color: Colors.black.withValues(alpha: darken)),
        child,
      ],
    );
  }
}
