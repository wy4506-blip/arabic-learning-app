import '../../../models/app_settings.dart';

class FirstExperienceContent {
  final String id;
  final String letterArabic;
  final String letterName;
  final String transliteration;
  final String exampleArabic;
  final String exampleArabicWithDiacritics;
  final String exampleTransliteration;
  final Map<String, String> title;
  final Map<String, String> subtitle;
  final String? letterAudioPath;
  final String? exampleAudioPath;
  final List<String> quizOptions;
  final String correctOption;

  const FirstExperienceContent({
    required this.id,
    required this.letterArabic,
    required this.letterName,
    required this.transliteration,
    required this.exampleArabic,
    required this.exampleArabicWithDiacritics,
    required this.exampleTransliteration,
    required this.title,
    required this.subtitle,
    required this.quizOptions,
    required this.correctOption,
    this.letterAudioPath,
    this.exampleAudioPath,
  });

  String titleFor(AppLanguage language) {
    return title[language.name] ?? title['en'] ?? title['zh'] ?? '';
  }

  String subtitleFor(AppLanguage language) {
    return subtitle[language.name] ?? subtitle['en'] ?? subtitle['zh'] ?? '';
  }
}

const FirstExperienceContent kFirstExperienceContent = FirstExperienceContent(
  id: 'first_experience_alif',
  letterArabic: 'ا',
  letterName: 'Alif',
  transliteration: 'a',
  exampleArabic: 'ا',
  exampleArabicWithDiacritics: 'أَ',
  exampleTransliteration: 'a',
  title: <String, String>{
    'zh': '认识你的第一个阿拉伯字母',
    'en': 'Meet your first Arabic letter',
  },
  subtitle: <String, String>{
    'zh': '这是阿拉伯语里最基础的字母之一。',
    'en': 'This is one of the most basic Arabic letters.',
  },
  quizOptions: <String>['ا', 'ب'],
  correctOption: 'ا',
);
