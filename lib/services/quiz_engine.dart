import 'dart:math';
import '../models/quiz_question.dart';
import '../services/country_repo.dart';

class QuizEngine {
  final _rand = Random();

  /// Generates N capital questions: "What is the capital of X?"
  Future<List<QuizQuestion>> generateCapitalQuiz({int count = 10}) async {
    final repo = CountryRepository();
    final all = await repo.getAll();
    // filter out empty capitals
    final withCap = all.where((c) => (c.capitalEN.trim().isNotEmpty)).toList();

    final List<QuizQuestion> out = [];
    final used = <String>{};
    while (out.length < count && used.length < withCap.length) {
      final country = withCap[_rand.nextInt(withCap.length)];
      if (!used.add(country.iso2)) continue;

      final correct = country.capitalEN;
      // distractors
      final distractors = <String>{};
      while (distractors.length < 3) {
        final other = withCap[_rand.nextInt(withCap.length)].capitalEN;
        if (other != correct) distractors.add(other);
      }
      final choices = [...distractors, correct]..shuffle(_rand);

      out.add(QuizQuestion(
        question: "What is the capital of ${country.countryEN}?",
        choices: choices,
        correctIndex: choices.indexOf(correct),
        country: country,
      ));
    }
    return out;
  }

  /// Generates N flag questions: shows flag emoji, asks for country name
  Future<List<QuizQuestion>> generateFlagQuiz({int count = 10}) async {
    final repo = CountryRepository();
    final all = await repo.getAll();
    // filter out empty flags
    final withFlag = all.where((c) => (c.flag.trim().isNotEmpty)).toList();

    final List<QuizQuestion> out = [];
    final used = <String>{};
    while (out.length < count && used.length < withFlag.length) {
      final country = withFlag[_rand.nextInt(withFlag.length)];
      if (!used.add(country.iso2)) continue;

      final correct = country.countryEN;
      // distractors
      final distractors = <String>{};
      while (distractors.length < 3) {
        final other = withFlag[_rand.nextInt(withFlag.length)].countryEN;
        if (other != correct) distractors.add(other);
      }
      final choices = [...distractors, correct]..shuffle(_rand);

      out.add(QuizQuestion(
        question: country.flag, // flag emoji as question
        choices: choices,
        correctIndex: choices.indexOf(correct),
      ));
    }
    return out;
  }

  /// Generates mixed questions: combination of capital and flag questions
  Future<List<QuizQuestion>> generateMixedQuiz(
      {int count = 10, double flagRatio = 0.5}) async {
    final flagCount = (count * flagRatio).round();
    final capitalCount = count - flagCount;

    final flagQuestions = await generateFlagQuiz(count: flagCount);
    final capitalQuestions = await generateCapitalQuiz(count: capitalCount);

    final allQuestions = [...flagQuestions, ...capitalQuestions];
    allQuestions.shuffle(_rand);

    return allQuestions;
  }
}
