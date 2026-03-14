import 'lesson_content_parts.dart';

class WordItem {
  final String arabic;
  final String plainArabic;
  final String pronunciation;
  final String meaning;
  final String? partOfSpeech;
  final String? gender;
  final String? number;
  final String? pluralFormVocalized;
  final String? pluralFormPlain;
  final String? feminineFormVocalized;
  final String? feminineFormPlain;
  final String? masculineFormVocalized;
  final String? masculineFormPlain;
  final String? morphology;
  final String? patternNote;
  final String? exampleSentenceVocalized;
  final String? exampleSentencePlain;
  final String? exampleTranslationZh;

  WordItem({
    required this.arabic,
    required this.plainArabic,
    required this.pronunciation,
    required this.meaning,
    this.partOfSpeech,
    this.gender,
    this.number,
    this.pluralFormVocalized,
    this.pluralFormPlain,
    this.feminineFormVocalized,
    this.feminineFormPlain,
    this.masculineFormVocalized,
    this.masculineFormPlain,
    this.morphology,
    this.patternNote,
    this.exampleSentenceVocalized,
    this.exampleSentencePlain,
    this.exampleTranslationZh,
  });

  LessonArabicText get text => LessonArabicText(
        vocalized: arabic,
        plain: plainArabic,
      );

  LessonWordMetadata get metadata => LessonWordMetadata(
        partOfSpeech: partOfSpeech ?? '',
        gender: gender,
        number: number,
        morphology: morphology,
        patternNote: patternNote,
      );

  LessonArabicText? get pluralForm =>
      LessonArabicText.optional(pluralFormVocalized, pluralFormPlain);

  LessonArabicText? get feminineForm =>
      LessonArabicText.optional(feminineFormVocalized, feminineFormPlain);

  LessonArabicText? get masculineForm =>
      LessonArabicText.optional(masculineFormVocalized, masculineFormPlain);

  LessonExample? get example {
    final exampleText = LessonArabicText.optional(
      exampleSentenceVocalized,
      exampleSentencePlain,
    );
    if (exampleText == null && (exampleTranslationZh?.trim().isEmpty ?? true)) {
      return null;
    }
    return LessonExample(
      text: exampleText ?? const LessonArabicText(vocalized: ''),
      meaning: LessonMeaning(zh: exampleTranslationZh ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'arabic': arabic,
      'plainArabic': plainArabic,
      'pronunciation': pronunciation,
      'meaning': meaning,
      'partOfSpeech': partOfSpeech,
      'gender': gender,
      'number': number,
      'pluralFormVocalized': pluralFormVocalized,
      'pluralFormPlain': pluralFormPlain,
      'feminineFormVocalized': feminineFormVocalized,
      'feminineFormPlain': feminineFormPlain,
      'masculineFormVocalized': masculineFormVocalized,
      'masculineFormPlain': masculineFormPlain,
      'morphology': morphology,
      'patternNote': patternNote,
      'exampleSentenceVocalized': exampleSentenceVocalized,
      'exampleSentencePlain': exampleSentencePlain,
      'exampleTranslationZh': exampleTranslationZh,
    };
  }

  factory WordItem.fromJson(Map<String, dynamic> json) {
    return WordItem(
      arabic: json['arabic'] as String,
      plainArabic: (json['plainArabic'] ?? json['arabic']) as String,
      pronunciation: json['pronunciation'] as String,
      meaning: json['meaning'] as String,
      partOfSpeech: json['partOfSpeech'] as String?,
      gender: json['gender'] as String?,
      number: json['number'] as String?,
      pluralFormVocalized: json['pluralFormVocalized'] as String?,
      pluralFormPlain: json['pluralFormPlain'] as String?,
      feminineFormVocalized: json['feminineFormVocalized'] as String?,
      feminineFormPlain: json['feminineFormPlain'] as String?,
      masculineFormVocalized: json['masculineFormVocalized'] as String?,
      masculineFormPlain: json['masculineFormPlain'] as String?,
      morphology: json['morphology'] as String?,
      patternNote: json['patternNote'] as String?,
      exampleSentenceVocalized: json['exampleSentenceVocalized'] as String?,
      exampleSentencePlain: json['exampleSentencePlain'] as String?,
      exampleTranslationZh: json['exampleTranslationZh'] as String?,
    );
  }
}
