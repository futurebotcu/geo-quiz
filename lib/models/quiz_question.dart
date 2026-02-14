import 'country.dart';

class QuizQuestion {
  final String question;
  final List<String> choices;
  final int correctIndex;
  final Country? country; // Optional country data for capital questions
  QuizQuestion({
    required this.question,
    required this.choices,
    required this.correctIndex,
    this.country,
  });
}
