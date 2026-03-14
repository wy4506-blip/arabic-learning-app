import '../models/app_settings.dart';
import '../models/lesson.dart';
import '../widgets/app_widgets.dart';

enum ArabicLearningContentType {
  word,
  sentence,
  grammar,
}

class ArabicLearningDisplayService {
  ArabicLearningDisplayService._();

  static ArabicTextMode resolveMode({
    required AppSettings settings,
    required Lesson lesson,
    required ArabicLearningContentType contentType,
  }) {
    if (settings.textMode != ArabicTextMode.smart) {
      return settings.textMode;
    }

    final lessonOrder = _lessonOrderOf(lesson);
    if (lessonOrder <= 10) {
      return ArabicTextMode.withDiacritics;
    }

    if (lessonOrder <= 20) {
      switch (contentType) {
        case ArabicLearningContentType.word:
          return ArabicTextMode.withDiacritics;
        case ArabicLearningContentType.sentence:
        case ArabicLearningContentType.grammar:
          return ArabicTextMode.dual;
      }
    }

    switch (contentType) {
      case ArabicLearningContentType.word:
        return ArabicTextMode.dual;
      case ArabicLearningContentType.sentence:
      case ArabicLearningContentType.grammar:
        return ArabicTextMode.withoutDiacritics;
    }
  }

  static String displayText({
    required String text,
    required AppSettings settings,
    required Lesson lesson,
    required ArabicLearningContentType contentType,
  }) {
    final mode = resolveMode(
      settings: settings,
      lesson: lesson,
      contentType: contentType,
    );
    final plain = plainText(text);

    switch (mode) {
      case ArabicTextMode.withDiacritics:
      case ArabicTextMode.smart:
        return text;
      case ArabicTextMode.dual:
        return plain == text ? text : '$text\n$plain';
      case ArabicTextMode.withoutDiacritics:
        return plain;
    }
  }

  static String plainText(String text) {
    return removeArabicDiacritics(text).replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static int _lessonOrderOf(Lesson lesson) {
    if (lesson.sequence > 0) {
      return lesson.sequence;
    }
    final match = RegExp(r'L(\d+)$').firstMatch(lesson.id);
    return int.tryParse(match?.group(1) ?? '') ?? 1;
  }
}
