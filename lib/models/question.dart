/// A single quiz question fetched from the API.
class Question {
  final int id;
  final int categoryId;
  final String question;
  final List<String> options;
  final int answerIndex;
  final int mark;

  const Question({
    required this.id,
    required this.categoryId,
    required this.question,
    required this.options,
    required this.answerIndex,
    required this.mark,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawOptions = json['options'] as List<dynamic>? ?? [];

    return Question(
      id: json['id'] as int,
      categoryId: json['categoryId'] as int,
      question: json['question'] as String? ?? '',
      options: rawOptions.map((option) => option.toString()).toList(),
      answerIndex: json['answerIndex'] as int? ?? 0,
      mark: json['mark'] as int? ?? 0,
    );
  }

  /// Returns true if [selectedIndex] is the correct option.
  bool isCorrect(int selectedIndex) {
    return selectedIndex == answerIndex;
  }
}
