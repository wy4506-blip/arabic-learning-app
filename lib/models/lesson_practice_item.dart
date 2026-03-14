enum LessonPracticeType {
  choice,
  audioChoice,
  audioWrite,
}

enum LessonPracticeAudioScope {
  lesson,
  alphabet,
}

class LessonPracticeItem {
  final LessonPracticeType type;
  final String title;
  final String prompt;
  final List<String> options;
  final String correctAnswer;
  final String? audioAsset;
  final String? audioText;
  final String? audioType;
  final LessonPracticeAudioScope audioScope;
  final String? helperText;
  final String? explanation;

  const LessonPracticeItem({
    required this.type,
    required this.title,
    required this.prompt,
    required this.options,
    required this.correctAnswer,
    this.audioAsset,
    this.audioText,
    this.audioType,
    this.audioScope = LessonPracticeAudioScope.lesson,
    this.helperText,
    this.explanation,
  });

  bool get requiresAudio => type != LessonPracticeType.choice;

  bool get requiresWriting => type == LessonPracticeType.audioWrite;
}
