import 'package:flutter_test/flutter_test.dart';
import 'package:geo_quiz/core/models.dart';
import 'package:geo_quiz/core/question_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('QuestionEngine Tests', () {
    late QuestionEngine questionEngine;

    setUp(() {
      questionEngine = QuestionEngine();
    });

    test('should initialize successfully', () async {
      await questionEngine.initialize();

      final counts = await questionEngine.getAvailableItemsCount();
      expect(counts['capitalPhoto'], greaterThan(0));
      expect(counts['flagCountry'], greaterThan(0));
      expect(counts['total'], greaterThan(0));
    });

    test('should generate capital mode questions', () async {
      await questionEngine.initialize();

      final questions = await questionEngine.generateQuestions(
        const QuizSettings(mode: QuizMode.capitalPhoto, questionCount: 5),
      );

      expect(questions.length, lessThanOrEqualTo(5));

      for (final question in questions) {
        expect(question.questionText, isNotEmpty);
        expect(question.correctAnswer, isNotEmpty);
        expect(question.options.length, equals(4));
        expect(question.options.contains(question.correctAnswer), isTrue);
        expect(question.iso2, isNotEmpty);
        expect(question.continent, isNotEmpty);

        // Capital mode should have image path or placeholder
        expect(question.imagePath, isNotNull);
      }
    });

    test('should generate flag mode questions', () async {
      await questionEngine.initialize();

      final questions = await questionEngine.generateQuestions(
        const QuizSettings(mode: QuizMode.flagCountry, questionCount: 5),
      );

      expect(questions.length, lessThanOrEqualTo(5));

      for (final question in questions) {
        expect(question.questionText, isNotEmpty);
        expect(question.correctAnswer, isNotEmpty);
        expect(question.options.length, equals(4));
        expect(question.options.contains(question.correctAnswer), isTrue);
        expect(question.iso2, isNotEmpty);
        expect(question.continent, isNotEmpty);

        // Flag mode should have either image path or emoji
        expect(
          question.imagePath != null || question.emoji != null,
          isTrue,
        );
      }
    });

    test('should generate unique options for each question', () async {
      await questionEngine.initialize();

      final questions = await questionEngine.generateQuestions(
        const QuizSettings(mode: QuizMode.capitalPhoto, questionCount: 3),
      );

      for (final question in questions) {
        final uniqueOptions = question.options.toSet();
        expect(uniqueOptions.length, equals(4));
      }
    });

    test('should handle different difficulty levels', () async {
      await questionEngine.initialize();

      final easyQuestions = await questionEngine.generateQuestions(
        const QuizSettings(
          mode: QuizMode.capitalPhoto,
          questionCount: 3,
          difficulty: DifficultyLevel.easy,
        ),
      );

      final hardQuestions = await questionEngine.generateQuestions(
        const QuizSettings(
          mode: QuizMode.capitalPhoto,
          questionCount: 3,
          difficulty: DifficultyLevel.hard,
        ),
      );

      expect(easyQuestions.length, lessThanOrEqualTo(3));
      expect(hardQuestions.length, lessThanOrEqualTo(3));
    });

    test('should return continents', () async {
      await questionEngine.initialize();

      final continents = questionEngine.getContinents();

      expect(continents, isNotEmpty);
      expect(continents.contains('Europe'), isTrue);
      expect(continents.contains('Asia'), isTrue);
      expect(continents.contains('Africa'), isTrue);
      expect(continents.contains('North America'), isTrue);
      expect(continents.contains('South America'), isTrue);
      expect(continents.contains('Oceania'), isTrue);
    });

    test('should return countries in continent', () async {
      await questionEngine.initialize();

      final europeanCountries =
          questionEngine.getCountriesInContinent('Europe');

      expect(europeanCountries, isNotEmpty);
      expect(europeanCountries.contains('de'), isTrue); // Germany
      expect(europeanCountries.contains('fr'), isTrue); // France
      expect(europeanCountries.contains('it'), isTrue); // Italy
    });

    test('should not generate duplicate countries in same quiz', () async {
      await questionEngine.initialize();

      final questions = await questionEngine.generateQuestions(
        const QuizSettings(mode: QuizMode.capitalPhoto, questionCount: 10),
      );

      final usedCountries = <String>{};
      for (final question in questions) {
        expect(usedCountries.contains(question.iso2), isFalse);
        usedCountries.add(question.iso2);
      }
    });

    test('should generate foodCountry mode questions', () async {
      await questionEngine.initialize();

      final questions = await questionEngine.generateQuestions(
        const QuizSettings(mode: QuizMode.foodCountry, questionCount: 3),
      );
      expect(questions, isNotEmpty);
      for (final q in questions) {
        expect(q.mode, equals(QuizMode.foodCountry));
        expect(q.options.length, equals(4));
        expect(q.options.contains(q.correctAnswer), isTrue);
        expect(q.imagePath, isNotNull);
        // Food mode metadata should carry dish name.
        expect(q.metadata['dishName'], isNotNull);
      }
    });

    test('should generate capitalCountry mode questions', () async {
      await questionEngine.initialize();

      final questions = await questionEngine.generateQuestions(
        const QuizSettings(mode: QuizMode.capitalCountry, questionCount: 3),
      );
      expect(questions, isNotEmpty);
      for (final q in questions) {
        expect(q.mode, equals(QuizMode.capitalCountry));
        expect(q.options.length, equals(4));
        expect(q.options.contains(q.correctAnswer), isTrue);
        // Text-only mode — no image.
        expect(q.imagePath, isNull);
        // Capital carried via metadata.
        expect(q.metadata['capital'], isNotNull);
        expect((q.metadata['capital'] as String).isNotEmpty, isTrue);
      }
    });

    test('mixed mode produces concrete (non-mixed) question modes', () async {
      await questionEngine.initialize();

      final questions = await questionEngine.generateQuestions(
        const QuizSettings(mode: QuizMode.mixed, questionCount: 8),
      );
      expect(questions, isNotEmpty);
      final modes = questions.map((q) => q.mode).toSet();
      // Each question carries a concrete mode (not "mixed").
      expect(modes.contains(QuizMode.mixed), isFalse);
      // At least 2 distinct concrete modes in a mixed quiz of 8.
      expect(modes.length, greaterThanOrEqualTo(2));
    });

    test('continentFilter restricts questions to Europe', () async {
      await questionEngine.initialize();

      final questions = await questionEngine.generateQuestions(
        const QuizSettings(
          mode: QuizMode.capitalPhoto,
          questionCount: 5,
          continentFilter: 'Europe',
        ),
      );
      expect(questions, isNotEmpty);
      for (final q in questions) {
        expect(q.continent, equals('Europe'));
      }
    });

    test('continentFilter supports North America split', () async {
      await questionEngine.initialize();

      final questions = await questionEngine.generateQuestions(
        const QuizSettings(
          mode: QuizMode.capitalCountry,
          questionCount: 5,
          continentFilter: 'North America',
        ),
      );
      expect(questions, isNotEmpty);
      for (final q in questions) {
        expect(q.continent, equals('North America'));
      }
    });

    test('all three difficulty levels produce 4 options each', () async {
      await questionEngine.initialize();
      for (final d in DifficultyLevel.values) {
        final qs = await questionEngine.generateQuestions(
          QuizSettings(
            mode: QuizMode.capitalPhoto,
            questionCount: 3,
            difficulty: d,
          ),
        );
        expect(qs, isNotEmpty, reason: 'Difficulty $d produced no questions');
        for (final q in qs) {
          expect(q.options.length, equals(4));
          expect(q.options.toSet().length, equals(4)); // unique
          expect(q.options.contains(q.correctAnswer), isTrue);
        }
      }
    });
  });

  group('QuizResult Tests', () {
    test('should calculate percentage correctly', () {
      final result = QuizResult(
        answers: [],
        score: 8,
        totalQuestions: 10,
        totalTime: const Duration(minutes: 5),
        mode: QuizMode.capitalPhoto,
        completedAt: DateTime.now(),
      );

      expect(result.percentage, equals(80.0));
    });

    test('should serialize and deserialize correctly', () {
      final original = QuizResult(
        answers: [],
        score: 7,
        totalQuestions: 10,
        totalTime: const Duration(minutes: 3, seconds: 30),
        mode: QuizMode.flagCountry,
        completedAt: DateTime.now(),
      );

      final json = original.toJson();
      final restored = QuizResult.fromJson(json);

      expect(restored.score, equals(original.score));
      expect(restored.totalQuestions, equals(original.totalQuestions));
      expect(restored.mode, equals(original.mode));
      expect(restored.percentage, equals(original.percentage));
    });
  });

  group('UserStats Tests', () {
    test('should copy with new values', () {
      final original = UserStats(
        totalGamesPlayed: 5,
        bestScores: {QuizMode.capitalPhoto: 8, QuizMode.flagCountry: 6},
        averageScores: {QuizMode.capitalPhoto: 70.0, QuizMode.flagCountry: 60.0},
      );

      final updated = original.copyWith(
        totalGamesPlayed: 6,
        bestScores: {QuizMode.capitalPhoto: 9, QuizMode.flagCountry: 6},
      );

      expect(updated.totalGamesPlayed, equals(6));
      expect(updated.getBestScore(QuizMode.capitalPhoto), equals(9));
      expect(updated.getBestScore(QuizMode.flagCountry), equals(6));
      expect(updated.getAverageScore(QuizMode.capitalPhoto), equals(70.0)); // preserved from original
    });

    test('should serialize and deserialize correctly', () {
      final original = UserStats(
        totalGamesPlayed: 10,
        bestScores: {QuizMode.capitalPhoto: 9, QuizMode.flagCountry: 8},
        averageScores: {QuizMode.capitalPhoto: 75.5, QuizMode.flagCountry: 68.3},
      );

      final json = original.toJson();
      final restored = UserStats.fromJson(json);

      expect(restored.totalGamesPlayed, equals(original.totalGamesPlayed));
      expect(restored.getBestScore(QuizMode.capitalPhoto),
          equals(original.getBestScore(QuizMode.capitalPhoto)));
      expect(restored.getBestScore(QuizMode.flagCountry),
          equals(original.getBestScore(QuizMode.flagCountry)));
      expect(restored.getAverageScore(QuizMode.capitalPhoto),
          equals(original.getAverageScore(QuizMode.capitalPhoto)));
      expect(restored.getAverageScore(QuizMode.flagCountry),
          equals(original.getAverageScore(QuizMode.flagCountry)));
    });
  });
}
