import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geo_quiz/core/models.dart';
import 'package:geo_quiz/services/storage_service.dart';

void main() {
  group('StorageService Tests', () {
    late StorageService storageService;

    setUp(() {
      // Reset singleton to pick up fresh mock each time
      StorageService.resetForTesting();
      SharedPreferences.setMockInitialValues({});
      storageService = StorageService.instance;
    });

    group('Settings Management', () {
      test('should save and load settings', () async {
        const testSettings = QuizSettings(
          mode: QuizMode.flagCountry,
          timerEnabled: true,
          questionCount: 15,
          difficulty: DifficultyLevel.hard,
        );

        await storageService.saveSettings(testSettings);
        final loadedSettings = await storageService.loadSettings();

        expect(loadedSettings.mode, equals(testSettings.mode));
        expect(loadedSettings.timerEnabled, equals(testSettings.timerEnabled));
        expect(
            loadedSettings.questionCount, equals(testSettings.questionCount));
        expect(loadedSettings.difficulty, equals(testSettings.difficulty));
      });

      test('should return default settings when no data exists', () async {
        SharedPreferences.setMockInitialValues({});

        final settings = await storageService.loadSettings();

        expect(settings.mode, equals(QuizMode.foodCountry));
        expect(settings.timerEnabled, equals(false));
        expect(settings.questionCount, equals(10));
        expect(settings.difficulty, equals(DifficultyLevel.medium));
      });
    });

    group('User Stats Management', () {
      test('should save and load user stats', () async {
        final testStats = UserStats(
          totalGamesPlayed: 5,
          bestScores: {QuizMode.capitalPhoto: 8, QuizMode.flagCountry: 7},
          averageScores: {
            QuizMode.capitalPhoto: 75.5,
            QuizMode.flagCountry: 68.3,
          },
        );

        await storageService.saveUserStats(testStats);
        final loadedStats = await storageService.loadUserStats();

        expect(
            loadedStats.totalGamesPlayed, equals(testStats.totalGamesPlayed));
        expect(loadedStats.getBestScore(QuizMode.capitalPhoto),
            equals(testStats.getBestScore(QuizMode.capitalPhoto)));
        expect(loadedStats.getBestScore(QuizMode.flagCountry),
            equals(testStats.getBestScore(QuizMode.flagCountry)));
        expect(loadedStats.getAverageScore(QuizMode.capitalPhoto),
            equals(testStats.getAverageScore(QuizMode.capitalPhoto)));
        expect(loadedStats.getAverageScore(QuizMode.flagCountry),
            equals(testStats.getAverageScore(QuizMode.flagCountry)));
      });

      test('should return default stats when no data exists', () async {
        SharedPreferences.setMockInitialValues({});

        final stats = await storageService.loadUserStats();

        expect(stats.totalGamesPlayed, equals(0));
        expect(stats.getBestScore(QuizMode.capitalPhoto), equals(0));
        expect(stats.getBestScore(QuizMode.flagCountry), equals(0));
        expect(stats.getAverageScore(QuizMode.capitalPhoto), equals(0.0));
        expect(stats.getAverageScore(QuizMode.flagCountry), equals(0.0));
      });
    });

    group('Quiz Results Management', () {
      test('should save and load quiz results', () async {
        final testResult = QuizResult(
          answers: [
            QuizAnswer(
              questionIndex: 0,
              selectedIndex: 1,
              isCorrect: true,
              timestamp: DateTime.now(),
            ),
          ],
          score: 8,
          totalQuestions: 10,
          totalTime: const Duration(minutes: 5),
          mode: QuizMode.capitalPhoto,
          completedAt: DateTime.now(),
        );

        await storageService.saveQuizResult(testResult);
        final results = await storageService.loadRecentResults();

        expect(results.length, equals(1));
        expect(results.first.score, equals(testResult.score));
        expect(results.first.totalQuestions, equals(testResult.totalQuestions));
        expect(results.first.mode, equals(testResult.mode));
      });

      test('should limit recent results to 20', () async {
        // Clear existing data
        SharedPreferences.setMockInitialValues({});

        // Add 25 results
        for (int i = 0; i < 25; i++) {
          final result = QuizResult(
            answers: [],
            score: i,
            totalQuestions: 10,
            totalTime: const Duration(minutes: 3),
            mode: QuizMode.capitalPhoto,
            completedAt: DateTime.now().add(Duration(seconds: i)),
          );
          await storageService.saveQuizResult(result);
        }

        final results = await storageService.loadRecentResults();
        expect(results.length, equals(20));
      });

      test('should update user stats when saving quiz result', () async {
        SharedPreferences.setMockInitialValues({});

        final result = QuizResult(
          answers: [],
          score: 8,
          totalQuestions: 10,
          totalTime: const Duration(minutes: 3),
          mode: QuizMode.capitalPhoto,
          completedAt: DateTime.now(),
        );

        await storageService.saveQuizResult(result);
        final stats = await storageService.loadUserStats();

        expect(stats.totalGamesPlayed, equals(1));
        // bestScores now stores best PERCENTAGE (0-100), not absolute score.
        // score=8/10 → 80%
        expect(stats.getBestScore(QuizMode.capitalPhoto), equals(80));
        expect(stats.getAverageScore(QuizMode.capitalPhoto), equals(80.0));
        expect(stats.getGamesPlayed(QuizMode.capitalPhoto), equals(1));
      });
    });

    group('Data Management', () {
      test('should clear all data', () async {
        // Add some data first
        const settings = QuizSettings(mode: QuizMode.flagCountry);
        await storageService.saveSettings(settings);

        await storageService.clearAllData();

        final loadedSettings = await storageService.loadSettings();
        final loadedStats = await storageService.loadUserStats();
        final loadedResults = await storageService.loadRecentResults();

        expect(loadedSettings.mode, equals(QuizMode.foodCountry)); // default
        expect(loadedStats.totalGamesPlayed, equals(0)); // default
        expect(loadedResults.length, equals(0));
      });

      test('should export and import data', () async {
        const settings = QuizSettings(
          mode: QuizMode.flagCountry,
          timerEnabled: true,
        );
        final stats = UserStats(
          totalGamesPlayed: 5,
          bestScores: {QuizMode.capitalPhoto: 8},
        );

        await storageService.saveSettings(settings);
        await storageService.saveUserStats(stats);

        final exportedData = await storageService.exportData();
        expect(exportedData.containsKey('settings'), isTrue);
        expect(exportedData.containsKey('userStats'), isTrue);
        expect(exportedData.containsKey('exportDate'), isTrue);

        // Clear and import
        await storageService.clearAllData();
        await storageService.importData(exportedData);

        final importedSettings = await storageService.loadSettings();
        final importedStats = await storageService.loadUserStats();

        expect(importedSettings.mode, equals(settings.mode));
        expect(importedSettings.timerEnabled, equals(settings.timerEnabled));
        expect(importedStats.totalGamesPlayed, equals(stats.totalGamesPlayed));
        expect(importedStats.getBestScore(QuizMode.capitalPhoto),
            equals(stats.getBestScore(QuizMode.capitalPhoto)));
      });
    });

    group('Error Handling', () {
      test('should handle corrupted data gracefully', () async {
        // Set invalid JSON in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('quiz_settings', 'invalid json');

        final settings = await storageService.loadSettings();

        // Should return default settings
        expect(settings.mode, equals(QuizMode.foodCountry));
      });
    });
  });
}
