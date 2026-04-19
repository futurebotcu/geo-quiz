import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geo_quiz/core/models.dart';
import 'package:geo_quiz/services/settings_provider.dart';
import 'package:geo_quiz/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsProvider Tests', () {
    late SettingsProvider provider;

    setUp(() async {
      StorageService.resetForTesting();
      SharedPreferences.setMockInitialValues({});
      provider = SettingsProvider();
      await provider.initialize();
    });

    test('initialize returns default settings when storage is empty', () {
      expect(provider.settings.mode, equals(QuizMode.foodCountry));
      expect(provider.settings.timerEnabled, isFalse);
      expect(provider.settings.questionCount, equals(10));
      expect(provider.settings.difficulty, equals(DifficultyLevel.medium));
      expect(provider.settings.continentFilter, isNull);
      expect(provider.totalGamesPlayed, equals(0));
    });

    test('updateQuizMode persists and notifies', () async {
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.updateQuizMode(QuizMode.flagCountry);

      expect(provider.settings.mode, equals(QuizMode.flagCountry));
      expect(notifyCount, greaterThanOrEqualTo(1));

      // Reload through a fresh provider — should be persisted.
      final reloaded = SettingsProvider();
      await reloaded.initialize();
      expect(reloaded.settings.mode, equals(QuizMode.flagCountry));
    });

    test('updateQuizConfig applies 4 fields atomically (single notify)',
        () async {
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.updateQuizConfig(
        difficulty: DifficultyLevel.hard,
        questionCount: 20,
        timerEnabled: true,
        continentFilter: 'Europe',
      );

      expect(provider.settings.difficulty, equals(DifficultyLevel.hard));
      expect(provider.settings.questionCount, equals(20));
      expect(provider.settings.timerEnabled, isTrue);
      expect(provider.settings.continentFilter, equals('Europe'));
      // Atomic: exactly one notify, not four (one per field).
      expect(notifyCount, equals(1));
    });

    test('updateQuizConfig with continentFilter: null clears the filter',
        () async {
      await provider.updateQuizConfig(continentFilter: 'Asia');
      expect(provider.settings.continentFilter, equals('Asia'));

      await provider.updateQuizConfig(continentFilter: null);
      expect(provider.settings.continentFilter, isNull);
    });

    test('updateQuizConfig without continentFilter keeps existing value',
        () async {
      await provider.updateQuizConfig(continentFilter: 'Asia');
      expect(provider.settings.continentFilter, equals('Asia'));

      await provider.updateQuizConfig(difficulty: DifficultyLevel.easy);
      expect(provider.settings.continentFilter, equals('Asia'));
      expect(provider.settings.difficulty, equals(DifficultyLevel.easy));
    });

    test('saveQuizResult updates best percentage, average, gamesPerMode',
        () async {
      final result = QuizResult(
        answers: const [],
        score: 8,
        totalQuestions: 10,
        totalTime: const Duration(minutes: 3),
        mode: QuizMode.capitalPhoto,
        completedAt: DateTime.now(),
      );
      await provider.saveQuizResult(result);

      expect(provider.userStats.totalGamesPlayed, equals(1));
      // bestScores stores percentage now (0-100), so 8/10 → 80.
      expect(
          provider.userStats.getBestScore(QuizMode.capitalPhoto), equals(80));
      expect(provider.userStats.getAverageScore(QuizMode.capitalPhoto),
          equals(80.0));
      expect(provider.userStats.getGamesPlayed(QuizMode.capitalPhoto),
          equals(1));
    });

    test('bestScoreOverall returns max across modes (not sum)', () async {
      // Simulate 2 quiz results in different modes
      await provider.saveQuizResult(QuizResult(
        answers: const [],
        score: 6,
        totalQuestions: 10,
        totalTime: const Duration(minutes: 2),
        mode: QuizMode.capitalPhoto,
        completedAt: DateTime.now(),
      ));
      await provider.saveQuizResult(QuizResult(
        answers: const [],
        score: 9,
        totalQuestions: 10,
        totalTime: const Duration(minutes: 2),
        mode: QuizMode.flagCountry,
        completedAt: DateTime.now(),
      ));

      // max(60, 90) = 90 — not 150 (sum).
      expect(provider.bestScoreOverall, equals(90));
    });

    test('overallAverageScore is games-weighted across modes', () async {
      // Mode A: 3 games at 80% each → avg 80
      for (int i = 0; i < 3; i++) {
        await provider.saveQuizResult(QuizResult(
          answers: const [],
          score: 8,
          totalQuestions: 10,
          totalTime: const Duration(minutes: 1),
          mode: QuizMode.capitalPhoto,
          completedAt: DateTime.now(),
        ));
      }
      // Mode B: 1 game at 50%
      await provider.saveQuizResult(QuizResult(
        answers: const [],
        score: 5,
        totalQuestions: 10,
        totalTime: const Duration(minutes: 1),
        mode: QuizMode.flagCountry,
        completedAt: DateTime.now(),
      ));

      // Weighted: (80*3 + 50*1) / 4 = 72.5
      expect(provider.overallAverageScore, closeTo(72.5, 0.001));
    });

    test('clearAllData resets settings and stats to defaults', () async {
      await provider.updateQuizMode(QuizMode.flagCountry);
      await provider.saveQuizResult(QuizResult(
        answers: const [],
        score: 5,
        totalQuestions: 10,
        totalTime: const Duration(minutes: 1),
        mode: QuizMode.flagCountry,
        completedAt: DateTime.now(),
      ));
      expect(provider.totalGamesPlayed, equals(1));

      await provider.clearAllData();
      expect(provider.settings.mode, equals(QuizMode.foodCountry));
      expect(provider.totalGamesPlayed, equals(0));
      expect(provider.bestScoreOverall, equals(0));
    });
  });
}
