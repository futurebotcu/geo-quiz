import 'package:flutter/material.dart';
import '../core/models.dart';

/// Radius scale. 4 fixed steps — replaces the 5-value drift
/// (8/12/14/16/20) observed in the pre-consolidation audit.
class AppRadius {
  const AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;

  static const Radius rSm = Radius.circular(sm);
  static const Radius rMd = Radius.circular(md);
  static const Radius rLg = Radius.circular(lg);
  static const Radius rXl = Radius.circular(xl);

  static const BorderRadius brSm = BorderRadius.all(rSm);
  static const BorderRadius brMd = BorderRadius.all(rMd);
  static const BorderRadius brLg = BorderRadius.all(rLg);
  static const BorderRadius brXl = BorderRadius.all(rXl);
}

/// Spacing scale (5 steps) — replaces 4/6/8/10/12/14/16/24 drift.
/// Pick the closest step when touching existing layouts.
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;

  // Convenience SizedBox constants for vertical gaps.
  static const SizedBox vXs = SizedBox(height: xs);
  static const SizedBox vSm = SizedBox(height: sm);
  static const SizedBox vMd = SizedBox(height: md);
  static const SizedBox vLg = SizedBox(height: lg);
  static const SizedBox vXl = SizedBox(height: xl);

  // Horizontal gaps.
  static const SizedBox hXs = SizedBox(width: xs);
  static const SizedBox hSm = SizedBox(width: sm);
  static const SizedBox hMd = SizedBox(width: md);
  static const SizedBox hLg = SizedBox(width: lg);
}

/// Per-mode accent colors. Previously hardcoded as bare `Colors.X`
/// across menu/stats screens; centralized here so a future palette
/// swap edits one file.
class AppModeColors {
  const AppModeColors._();

  static const Color foodCountry = Colors.orange;
  static const Color capitalPhoto = Colors.blue;
  static const Color flagCountry = Colors.green;
  static const Color capitalCountry = Colors.purple;
  static const Color mixed = Colors.teal;

  static Color forMode(QuizMode mode) {
    switch (mode) {
      case QuizMode.foodCountry:
        return foodCountry;
      case QuizMode.capitalPhoto:
      case QuizMode.capitalFromImage:
        return capitalPhoto;
      case QuizMode.flagCountry:
        return flagCountry;
      case QuizMode.capitalCountry:
        return capitalCountry;
      case QuizMode.mixed:
        return mixed;
    }
  }
}

/// Semantic feedback colors (answer states etc.). Thin wrapper so
/// screens don't reach for bare `Colors.green/red` directly.
class AppFeedbackColors {
  const AppFeedbackColors._();

  static const Color correct = Color(0xFF2E7D32); // green 800
  static const Color correctSurface = Color(0xFFE8F5E9); // green 50
  static const Color wrong = Color(0xFFC62828); // red 800
  static const Color wrongSurface = Color(0xFFFFEBEE); // red 50
  static const Color neutral = Color(0xFF9E9E9E); // grey 500
}
