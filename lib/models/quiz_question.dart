class QuizQuestion {
  final String title;
  final String prompt;
  final String promptType;
  final String correct;
  final List<String> options;

  const QuizQuestion({
    required this.title,
    required this.prompt,
    required this.promptType,
    required this.correct,
    required this.options,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      title: json['title'] as String,
      prompt: json['prompt'] as String,
      promptType: json['promptType'] as String,
      correct: json['correct'] as String,
      options: (json['options'] as List).map((e) => e.toString()).toList(),
    );
  }
}
