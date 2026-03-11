import 'dialogue_line.dart';

class LessonWord {
  final String arabic;
  final String transliteration;
  final String chinese;
  final String wordType;
  final String? image;
  final String? audio;

  const LessonWord({
    required this.arabic,
    required this.transliteration,
    required this.chinese,
    required this.wordType,
    this.image,
    this.audio,
  });

  factory LessonWord.fromJson(Map<String, dynamic> json) {
    return LessonWord(
      arabic: json['arabic'] ?? '',
      transliteration: json['transliteration'] ?? '',
      chinese: json['chinese'] ?? '',
      wordType: json['wordType'] ?? '',
      image: json['image'],
      audio: json['audio'],
    );
  }
}

class LessonPattern {
  final String arabic;
  final String transliteration;
  final String chinese;
  final String? audio;

  const LessonPattern({
    required this.arabic,
    required this.transliteration,
    required this.chinese,
    this.audio,
  });

  factory LessonPattern.fromJson(Map<String, dynamic> json) {
    return LessonPattern(
      arabic: json['arabic'] ?? '',
      transliteration: json['transliteration'] ?? '',
      chinese: json['chinese'] ?? '',
      audio: json['audio'],
    );
  }
}

class LessonExercise {
  final String question;
  final List<String> options;
  final String correctAnswer;

  const LessonExercise({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  factory LessonExercise.fromJson(Map<String, dynamic> json) {
    return LessonExercise(
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? const []),
      correctAnswer: json['correctAnswer'] ?? '',
    );
  }
}

class Lesson {
  final String id;
  final String unitId;
  final String titleCn;
  final String titleAr;
  final String category;
  final int difficulty;
  final int estimatedMinutes;
  final List<String> objectives;
  final List<String> letters;
  final List<LessonWord> vocabulary;
  final List<LessonPattern> patterns;
  final List<DialogueLine> dialogues;
  final String grammarTitle;
  final String grammarExplanation;
  final List<LessonExercise> exercises;
  final bool isLocked;
  final String? coverImage;

  const Lesson({
    required this.id,
    required this.unitId,
    required this.titleCn,
    required this.titleAr,
    required this.category,
    required this.difficulty,
    required this.estimatedMinutes,
    required this.objectives,
    required this.letters,
    required this.vocabulary,
    required this.patterns,
    required this.dialogues,
    required this.grammarTitle,
    required this.grammarExplanation,
    required this.exercises,
    required this.isLocked,
    this.coverImage,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] ?? '',
      unitId: json['unitId'] ?? '',
      titleCn: json['titleCn'] ?? '',
      titleAr: json['titleAr'] ?? '',
      category: json['category'] ?? '',
      difficulty: json['difficulty'] ?? 1,
      estimatedMinutes: json['estimatedMinutes'] ?? 15,
      objectives: List<String>.from(json['objectives'] ?? const []),
      letters: List<String>.from(json['letters'] ?? const []),
      vocabulary: (json['vocabulary'] as List? ?? const [])
          .map((e) => LessonWord.fromJson(e))
          .toList(),
      patterns: (json['patterns'] as List? ?? const [])
          .map((e) => LessonPattern.fromJson(e))
          .toList(),
      dialogues: (json['dialogues'] as List? ?? const [])
          .map((e) => DialogueLine.fromJson(e))
          .toList(),
      grammarTitle: json['grammarTitle'] ?? '',
      grammarExplanation: json['grammarExplanation'] ?? '',
      exercises: (json['exercises'] as List? ?? const [])
          .map((e) => LessonExercise.fromJson(e))
          .toList(),
      isLocked: json['isLocked'] ?? false,
      coverImage: json['coverImage'],
    );
  }
}
