import 'dialogue_line.dart';
import 'lesson_content_parts.dart';

class LessonWord {
  final String? id;
  final String arabic;
  final String plainArabic;
  final String transliteration;
  final String chinese;
  final String? english;
  final String wordType;
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
  final String? exampleTranslationEn;
  final String? exampleAudio;
  final String? image;
  final String? audio;

  const LessonWord({
    this.id,
    required this.arabic,
    required this.plainArabic,
    required this.transliteration,
    required this.chinese,
    this.english,
    required this.wordType,
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
    this.exampleTranslationEn,
    this.exampleAudio,
    this.image,
    this.audio,
  });

  LessonArabicText get text => LessonArabicText(
        vocalized: arabic,
        plain: plainArabic,
      );

  LessonMeaning get meaning => LessonMeaning(
        zh: chinese,
        en: english,
      );

  LessonWordMetadata get metadata => LessonWordMetadata(
        partOfSpeech: wordType,
        gender: gender,
        number: number,
        morphology: morphology,
        patternNote: patternNote,
      );

  LessonWordForms get forms => LessonWordForms(
        plural: pluralForm,
        feminine: feminineForm,
        masculine: masculineForm,
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
    final exampleMeaning = LessonMeaning(
      zh: exampleTranslationZh ?? '',
      en: exampleTranslationEn,
    );
    final exampleAudioRef = LessonAudioRef(asset: exampleAudio);
    if (exampleText == null &&
        exampleMeaning.primary.trim().isEmpty &&
        !exampleAudioRef.hasAsset) {
      return null;
    }
    return LessonExample(
      text: exampleText ?? const LessonArabicText(vocalized: ''),
      meaning: exampleMeaning,
      audio: exampleAudioRef,
    );
  }

  LessonAudioRef get audioRef => LessonAudioRef(asset: audio);

  factory LessonWord.fromJson(Map<String, dynamic> json) {
    final textJson = lessonMapOf(json['text']);
    final meaningJson = lessonMapOf(json['meaning']);
    final grammarJson = lessonMapOf(json['grammar']);
    final formsJson = lessonMapOf(json['forms']);
    final mediaJson = lessonMapOf(json['media']);
    final pluralJson = lessonMapOf(lessonFirstOf(formsJson, const ['plural']));
    final feminineJson =
        lessonMapOf(lessonFirstOf(formsJson, const ['feminine']));
    final masculineJson =
        lessonMapOf(lessonFirstOf(formsJson, const ['masculine']));
    final exampleJson = lessonMapOf(json['example']);
    final exampleTextJson =
        lessonMapOf(lessonFirstOf(exampleJson, const ['text', 'sentence']));
    final exampleMeaningJson = lessonMapOf(
      lessonFirstOf(exampleJson, const ['meaning', 'translation']),
    );
    final arabic = lessonString(
      lessonFirstOf(textJson, const ['vocalized', 'arabic']) ??
          json['word_ar_vocalized'] ??
          json['arabic'],
    );

    return LessonWord(
      id: json['id'],
      arabic: arabic,
      plainArabic: lessonString(
        lessonFirstOf(textJson, const ['plain', 'plainArabic']) ??
            json['word_ar_plain'] ??
            json['plainArabic'] ??
            arabic,
      ),
      transliteration: lessonString(json['transliteration']),
      chinese: lessonString(
        lessonFirstOf(meaningJson, const ['zh', 'chinese']) ??
            json['meaning_zh'] ??
            json['chinese'],
      ),
      english: lessonNullableString(
        lessonFirstOf(meaningJson, const ['en', 'english']) ??
            json['meaning_en'] ??
            json['english'],
      ),
      wordType: lessonString(
        lessonFirstOf(
              grammarJson,
              const ['partOfSpeech', 'part_of_speech', 'wordType'],
            ) ??
            json['part_of_speech'] ??
            json['wordType'],
      ),
      gender: lessonNullableString(
        lessonFirstOf(grammarJson, const ['gender']) ?? json['gender'],
      ),
      number: lessonNullableString(
        lessonFirstOf(grammarJson, const ['number']) ?? json['number'],
      ),
      pluralFormVocalized: lessonNullableString(
        lessonFirstOf(pluralJson, const ['vocalized', 'arabic']) ??
            lessonFirstOf(
              formsJson,
              const ['pluralVocalized', 'plural_form_vocalized'],
            ) ??
            json['plural_form_vocalized'],
      ),
      pluralFormPlain: lessonNullableString(
        lessonFirstOf(pluralJson, const ['plain', 'plainArabic']) ??
            lessonFirstOf(
                formsJson, const ['pluralPlain', 'plural_form_plain']) ??
            json['plural_form_plain'],
      ),
      feminineFormVocalized: lessonNullableString(
        lessonFirstOf(feminineJson, const ['vocalized', 'arabic']) ??
            lessonFirstOf(
              formsJson,
              const ['feminineVocalized', 'feminine_form_vocalized'],
            ) ??
            json['feminine_form_vocalized'],
      ),
      feminineFormPlain: lessonNullableString(
        lessonFirstOf(
              feminineJson,
              const ['plain', 'plainArabic'],
            ) ??
            lessonFirstOf(
              formsJson,
              const ['femininePlain', 'feminine_form_plain'],
            ) ??
            json['feminine_form_plain'],
      ),
      masculineFormVocalized: lessonNullableString(
        lessonFirstOf(masculineJson, const ['vocalized', 'arabic']) ??
            lessonFirstOf(
              formsJson,
              const ['masculineVocalized', 'masculine_form_vocalized'],
            ) ??
            json['masculine_form_vocalized'],
      ),
      masculineFormPlain: lessonNullableString(
        lessonFirstOf(
              masculineJson,
              const ['plain', 'plainArabic'],
            ) ??
            lessonFirstOf(
              formsJson,
              const ['masculinePlain', 'masculine_form_plain'],
            ) ??
            json['masculine_form_plain'],
      ),
      morphology: lessonNullableString(
        lessonFirstOf(grammarJson, const ['morphology']) ?? json['morphology'],
      ),
      patternNote: lessonNullableString(
        lessonFirstOf(
              grammarJson,
              const ['patternNote', 'pattern_note', 'note'],
            ) ??
            json['pattern_note'],
      ),
      exampleSentenceVocalized: lessonNullableString(
        lessonFirstOf(exampleTextJson, const ['vocalized', 'arabic']) ??
            lessonFirstOf(exampleJson, const ['arabic']) ??
            json['example_sentence_vocalized'],
      ),
      exampleSentencePlain: lessonNullableString(
        lessonFirstOf(exampleTextJson, const ['plain', 'plainArabic']) ??
            lessonFirstOf(exampleJson, const ['plainArabic']) ??
            json['example_sentence_plain'],
      ),
      exampleTranslationZh: lessonNullableString(
        lessonFirstOf(exampleMeaningJson, const ['zh', 'chinese']) ??
            lessonFirstOf(exampleJson, const ['translationZh']) ??
            json['example_translation_zh'],
      ),
      exampleTranslationEn: lessonNullableString(
        lessonFirstOf(exampleMeaningJson, const ['en', 'english']) ??
            lessonFirstOf(exampleJson, const ['translationEn']) ??
            json['example_translation_en'],
      ),
      exampleAudio: LessonAudioRef.fromJson(
        lessonFirstOf(exampleJson, const ['audio']),
      ).asset,
      image: lessonNullableString(
        lessonFirstOf(mediaJson, const ['image']) ?? json['image'],
      ),
      audio: LessonAudioRef.fromJson(
        lessonFirstOf(mediaJson, const ['audio']) ?? json['audio'],
      ).asset,
    );
  }
}

class LessonPattern {
  final String arabic;
  final String? plainArabic;
  final String transliteration;
  final String chinese;
  final String? english;
  final String? audio;

  const LessonPattern({
    required this.arabic,
    this.plainArabic,
    required this.transliteration,
    required this.chinese,
    this.english,
    this.audio,
  });

  LessonArabicText get text => LessonArabicText(
        vocalized: arabic,
        plain: plainArabic,
      );

  LessonMeaning get meaning => LessonMeaning(
        zh: chinese,
        en: english,
      );

  LessonAudioRef get audioRef => LessonAudioRef(asset: audio);

  LessonStudyText get content => LessonStudyText(
        arabic: text,
        transliteration: transliteration,
        meaning: meaning,
        audio: audioRef,
      );

  factory LessonPattern.fromJson(Map<String, dynamic> json) {
    final textJson = lessonMapOf(json['text']);
    final meaningJson = lessonMapOf(json['meaning']);
    final mediaJson = lessonMapOf(json['media']);
    return LessonPattern(
      arabic: lessonString(
        lessonFirstOf(textJson, const ['vocalized', 'arabic']) ??
            json['arabic'],
      ),
      plainArabic: lessonNullableString(
        lessonFirstOf(textJson, const ['plain', 'plainArabic']) ??
            json['plainArabic'],
      ),
      transliteration: lessonString(json['transliteration']),
      chinese: lessonString(
        lessonFirstOf(meaningJson, const ['zh', 'chinese']) ?? json['chinese'],
      ),
      english: lessonNullableString(
        lessonFirstOf(meaningJson, const ['en', 'english']) ?? json['english'],
      ),
      audio: LessonAudioRef.fromJson(
        lessonFirstOf(mediaJson, const ['audio']) ?? json['audio'],
      ).asset,
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
  final int sequence;
  final String unitId;
  final String titleCn;
  final String titleAr;
  final String? titleEn;
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
  final String? grammarTitleEn;
  final String? grammarExplanationEn;
  final List<LessonExercise> exercises;
  final bool isLocked;
  final String? coverImage;

  const Lesson({
    required this.id,
    required this.sequence,
    required this.unitId,
    required this.titleCn,
    required this.titleAr,
    this.titleEn,
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
    this.grammarTitleEn,
    this.grammarExplanationEn,
    required this.exercises,
    required this.isLocked,
    this.coverImage,
  });

  LessonTitle get title => LessonTitle(
        zh: titleCn,
        ar: titleAr,
        en: titleEn,
      );

  LessonGrammarNote get grammar => LessonGrammarNote(
        titleZh: grammarTitle,
        explanationZh: grammarExplanation,
        titleEn: grammarTitleEn,
        explanationEn: grammarExplanationEn,
      );

  bool get hasGrammar => grammar.hasContent;

  factory Lesson.fromJson(Map<String, dynamic> json) {
    final titleJson = lessonMapOf(json['title']);
    final grammarJson = lessonMapOf(json['grammar']);
    final grammarTitleJson =
        lessonMapOf(lessonFirstOf(grammarJson, const ['title']));
    final grammarExplanationJson =
        lessonMapOf(lessonFirstOf(grammarJson, const ['explanation']));
    return Lesson(
      id: lessonString(json['id']),
      sequence: json['sequence'] ?? 1,
      unitId: lessonString(json['unitId']),
      titleCn: lessonString(
        lessonFirstOf(titleJson, const ['zh', 'titleCn']) ?? json['titleCn'],
      ),
      titleAr: lessonString(
        lessonFirstOf(titleJson, const ['ar', 'titleAr']) ?? json['titleAr'],
      ),
      titleEn: lessonNullableString(
        lessonFirstOf(titleJson, const ['en', 'titleEn']) ?? json['titleEn'],
      ),
      category: lessonString(json['category']),
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
      grammarTitle: lessonString(
        lessonFirstOf(grammarTitleJson, const ['zh', 'text']) ??
            lessonFirstOf(grammarJson, const ['titleZh', 'grammarTitle']) ??
            json['grammarTitle'],
      ),
      grammarExplanation: lessonString(
        lessonFirstOf(grammarExplanationJson, const ['zh', 'text']) ??
            lessonFirstOf(
              grammarJson,
              const ['explanationZh', 'grammarExplanation'],
            ) ??
            json['grammarExplanation'],
      ),
      grammarTitleEn: lessonNullableString(
        lessonFirstOf(grammarTitleJson, const ['en']) ??
            lessonFirstOf(grammarJson, const ['titleEn', 'grammarTitleEn']) ??
            json['grammarTitleEn'],
      ),
      grammarExplanationEn: lessonNullableString(
        lessonFirstOf(grammarExplanationJson, const ['en']) ??
            lessonFirstOf(
              grammarJson,
              const ['explanationEn', 'grammarExplanationEn'],
            ) ??
            json['grammarExplanationEn'],
      ),
      exercises: (json['exercises'] as List? ?? const [])
          .map((e) => LessonExercise.fromJson(e))
          .toList(),
      isLocked: json['isLocked'] ?? false,
      coverImage: json['coverImage'],
    );
  }
}
