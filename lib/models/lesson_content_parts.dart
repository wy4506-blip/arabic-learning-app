Map<String, dynamic>? lessonMapOf(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map(
      (key, item) => MapEntry(key.toString(), item),
    );
  }
  return null;
}

Object? lessonFirstOf(Map<String, dynamic>? json, List<String> keys) {
  if (json == null) return null;
  for (final key in keys) {
    if (json.containsKey(key)) {
      return json[key];
    }
  }
  return null;
}

String lessonString(Object? value, {String fallback = ''}) {
  if (value is String) {
    return value;
  }
  if (value == null) {
    return fallback;
  }
  return value.toString();
}

String? lessonNullableString(Object? value) {
  final text = lessonString(value).trim();
  return text.isEmpty ? null : text;
}

/// Stores the teaching form and the normalized plain form together.
class LessonArabicText {
  final String vocalized;
  final String plain;

  const LessonArabicText({
    required this.vocalized,
    String? plain,
  }) : plain = plain ?? vocalized;

  String get preferred => vocalized.trim().isNotEmpty ? vocalized : plain;

  bool get hasDistinctPlainText =>
      plain.trim().isNotEmpty && plain.trim() != vocalized.trim();

  bool get hasValue => preferred.trim().isNotEmpty;

  static LessonArabicText? optional(String? vocalized, String? plain) {
    final vocalizedValue = lessonNullableString(vocalized);
    final plainValue = lessonNullableString(plain);
    if (vocalizedValue == null && plainValue == null) {
      return null;
    }
    return LessonArabicText(
      vocalized: vocalizedValue ?? plainValue ?? '',
      plain: plainValue,
    );
  }
}

/// Keeps multilingual meaning data together so UI can avoid scattered fields.
class LessonMeaning {
  final String zh;
  final String? en;

  const LessonMeaning({
    required this.zh,
    this.en,
  });

  String get primary => zh.trim().isNotEmpty ? zh : (en ?? '');
}

class LessonAudioRef {
  final String? asset;

  const LessonAudioRef({
    this.asset,
  });

  factory LessonAudioRef.fromJson(Object? value) {
    final json = lessonMapOf(value);
    if (json != null) {
      return LessonAudioRef(
        asset: lessonNullableString(
          lessonFirstOf(json, const <String>['asset', 'path', 'uri']),
        ),
      );
    }
    return LessonAudioRef(asset: lessonNullableString(value));
  }

  bool get hasAsset => asset?.trim().isNotEmpty ?? false;
}

class LessonWordForms {
  final LessonArabicText? plural;
  final LessonArabicText? feminine;
  final LessonArabicText? masculine;

  const LessonWordForms({
    this.plural,
    this.feminine,
    this.masculine,
  });

  bool get hasAny => plural != null || feminine != null || masculine != null;
}

class LessonWordMetadata {
  final String partOfSpeech;
  final String? gender;
  final String? number;
  final String? morphology;
  final String? patternNote;

  const LessonWordMetadata({
    required this.partOfSpeech,
    this.gender,
    this.number,
    this.morphology,
    this.patternNote,
  });
}

class LessonExample {
  final LessonArabicText text;
  final LessonMeaning meaning;
  final LessonAudioRef audio;

  const LessonExample({
    required this.text,
    required this.meaning,
    this.audio = const LessonAudioRef(),
  });
}

class LessonStudyText {
  final LessonArabicText arabic;
  final String transliteration;
  final LessonMeaning meaning;
  final LessonAudioRef audio;

  const LessonStudyText({
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    this.audio = const LessonAudioRef(),
  });
}

class LessonTitle {
  final String zh;
  final String ar;
  final String? en;

  const LessonTitle({
    required this.zh,
    required this.ar,
    this.en,
  });
}

class LessonGrammarNote {
  final String titleZh;
  final String explanationZh;
  final String? titleEn;
  final String? explanationEn;

  const LessonGrammarNote({
    required this.titleZh,
    required this.explanationZh,
    this.titleEn,
    this.explanationEn,
  });

  bool get hasContent =>
      titleZh.trim().isNotEmpty || explanationZh.trim().isNotEmpty;
}
