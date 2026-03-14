import 'lesson_content_parts.dart';

class DialogueLine {
  final String speaker;
  final String arabic;
  final String? plainArabic;
  final String transliteration;
  final String chinese;
  final String? english;
  final String? audio;

  const DialogueLine({
    required this.speaker,
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

  factory DialogueLine.fromJson(Map<String, dynamic> json) {
    final textJson = lessonMapOf(json['text']);
    final meaningJson = lessonMapOf(json['meaning']);
    final mediaJson = lessonMapOf(json['media']);
    return DialogueLine(
      speaker: lessonString(json['speaker']),
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

  Map<String, dynamic> toJson() {
    return {
      'speaker': speaker,
      'arabic': arabic,
      'plainArabic': plainArabic,
      'transliteration': transliteration,
      'chinese': chinese,
      'english': english,
      'audio': audio,
    };
  }
}
