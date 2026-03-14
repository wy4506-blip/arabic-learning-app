import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arabic_learning_app/data/sample_lessons.dart';
import 'package:arabic_learning_app/models/lesson.dart';
import 'package:arabic_learning_app/models/lesson_practice_item.dart';
import 'package:arabic_learning_app/models/review_models.dart';
import 'package:arabic_learning_app/services/learning_state_service.dart';
import 'package:arabic_learning_app/services/lesson_practice_service.dart';
import 'package:arabic_learning_app/services/review_service.dart';

Map<String, dynamic> _nestedLessonJson() {
  return <String, dynamic>{
    'id': 'U9L1',
    'sequence': 1,
    'unitId': 'U9',
    'title': <String, dynamic>{
      'zh': '问候升级',
      'ar': 'التَّحِيَّاتُ الْمُتَقَدِّمَةُ',
      'en': 'Advanced Greetings',
    },
    'category': 'dialogue',
    'difficulty': 2,
    'estimatedMinutes': 10,
    'objectives': const <String>['识别职业类词形'],
    'letters': const <String>['م'],
    'vocabulary': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'w1',
        'text': <String, dynamic>{
          'vocalized': 'مُدَرِّسَةٌ',
          'plain': 'مدرسة',
        },
        'transliteration': 'mudarrisah',
        'meaning': <String, dynamic>{
          'zh': '女老师',
          'en': 'female teacher',
        },
        'grammar': <String, dynamic>{
          'partOfSpeech': 'noun',
          'gender': 'feminine',
          'number': 'singular',
          'morphology': '职业名词',
          'patternNote': '和阳性形式一起记忆',
        },
        'forms': <String, dynamic>{
          'plural': <String, dynamic>{
            'vocalized': 'مُدَرِّسَاتٌ',
            'plain': 'مدرسات',
          },
          'masculine': <String, dynamic>{
            'vocalized': 'مُدَرِّسٌ',
            'plain': 'مدرس',
          },
        },
        'example': <String, dynamic>{
          'text': <String, dynamic>{
            'vocalized': 'هٰذِهِ مُدَرِّسَةٌ.',
            'plain': 'هذه مدرسة.',
          },
          'meaning': <String, dynamic>{
            'zh': '这是一位女老师。',
            'en': 'This is a female teacher.',
          },
          'audio': <String, dynamic>{
            'asset': 'lesson_09/word/w1_example.mp3',
          },
        },
        'media': <String, dynamic>{
          'audio': 'lesson_09/word/w1.mp3',
          'image': 'teacher.png',
        },
      },
    ],
    'patterns': <Map<String, dynamic>>[
      <String, dynamic>{
        'text': <String, dynamic>{
          'vocalized': 'أَنَا مُسْتَعِدٌّ',
          'plain': 'انا مستعد',
        },
        'transliteration': 'ana mustaidd',
        'meaning': <String, dynamic>{
          'zh': '我准备好了',
          'en': 'I am ready',
        },
        'media': <String, dynamic>{
          'audio': 'lesson_09/pattern/p1.mp3',
        },
      },
      <String, dynamic>{
        'text': <String, dynamic>{
          'vocalized': 'أَنَا جَاهِزٌ',
          'plain': 'انا جاهز',
        },
        'transliteration': 'ana jahiz',
        'meaning': <String, dynamic>{
          'zh': '我已就绪',
          'en': 'I am set',
        },
        'media': <String, dynamic>{
          'audio': 'lesson_09/pattern/p2.mp3',
        },
      },
    ],
    'dialogues': <Map<String, dynamic>>[
      <String, dynamic>{
        'speaker': 'A',
        'text': <String, dynamic>{
          'vocalized': 'أَهْلًا',
          'plain': 'اهلا',
        },
        'transliteration': 'ahlan',
        'meaning': <String, dynamic>{
          'zh': '欢迎',
          'en': 'welcome',
        },
        'media': <String, dynamic>{
          'audio': 'lesson_09/dialogue/d1.mp3',
        },
      },
    ],
    'grammar': <String, dynamic>{
      'title': <String, dynamic>{
        'zh': '阴阳词尾',
        'en': 'Gender endings',
      },
      'explanation': <String, dynamic>{
        'zh': '先观察词尾变化。',
        'en': 'Notice the ending changes first.',
      },
    },
    'exercises': <Map<String, dynamic>>[
      <String, dynamic>{
        'question': '哪一个是“女老师”？',
        'options': const <String>['مُدَرِّسٌ', 'مُدَرِّسَةٌ'],
        'correctAnswer': 'مُدَرِّسَةٌ',
      },
    ],
    'isLocked': false,
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Lesson content structure', () {
    test('legacy sample data exposes structured accessors', () {
      final lesson = sampleLessons.first;
      final word = lesson.vocabulary.first;
      final pattern = lesson.patterns.first;
      final dialogue = lesson.dialogues.first;

      expect(lesson.title.zh, lesson.titleCn);
      expect(lesson.title.ar, lesson.titleAr);
      expect(lesson.grammar.titleZh, lesson.grammarTitle);
      expect(word.text.vocalized, word.arabic);
      expect(word.text.plain, word.plainArabic);
      expect(word.meaning.zh, word.chinese);
      expect(word.metadata.partOfSpeech, word.wordType);
      expect(pattern.content.arabic.vocalized, pattern.arabic);
      expect(pattern.content.meaning.zh, pattern.chinese);
      expect(dialogue.content.meaning.zh, dialogue.chinese);
    });

    test('parses nested lesson payload and keeps legacy getters working', () {
      final lesson = Lesson.fromJson(_nestedLessonJson());
      final word = lesson.vocabulary.single;
      final pattern = lesson.patterns.first;
      final dialogue = lesson.dialogues.single;

      expect(lesson.titleCn, '问候升级');
      expect(lesson.titleAr, 'التَّحِيَّاتُ الْمُتَقَدِّمَةُ');
      expect(lesson.titleEn, 'Advanced Greetings');
      expect(lesson.grammarTitle, '阴阳词尾');
      expect(lesson.grammarTitleEn, 'Gender endings');
      expect(lesson.grammarExplanationEn, 'Notice the ending changes first.');

      expect(word.arabic, 'مُدَرِّسَةٌ');
      expect(word.plainArabic, 'مدرسة');
      expect(word.english, 'female teacher');
      expect(word.metadata.gender, 'feminine');
      expect(word.pluralForm?.plain, 'مدرسات');
      expect(word.masculineForm?.vocalized, 'مُدَرِّسٌ');
      expect(word.example?.text.plain, 'هذه مدرسة.');
      expect(word.example?.meaning.en, 'This is a female teacher.');
      expect(word.example?.audio.asset, 'lesson_09/word/w1_example.mp3');
      expect(word.audioRef.asset, 'lesson_09/word/w1.mp3');

      expect(pattern.plainArabic, 'انا مستعد');
      expect(pattern.english, 'I am ready');
      expect(pattern.audioRef.asset, 'lesson_09/pattern/p1.mp3');

      expect(dialogue.plainArabic, 'اهلا');
      expect(dialogue.english, 'welcome');
      expect(dialogue.audioRef.asset, 'lesson_09/dialogue/d1.mp3');
    });

    test('review and practice systems accept nested lesson content', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final lesson = Lesson.fromJson(_nestedLessonJson());

      await ReviewService.recordLessonStarted(lesson);
      final states = await LearningStateService.getAllStates();
      final practiceItems = LessonPracticeService.buildItems(lesson);

      expect(states.containsKey(buildWordContentId('مدرسة')), isTrue);
      expect(states.containsKey(buildSentenceContentId('انا مستعد')), isTrue);
      expect(
        practiceItems.any(
          (item) =>
              item.type == LessonPracticeType.audioChoice &&
              item.audioType == 'word' &&
              item.audioText == 'مدرسة',
        ),
        isTrue,
      );
      expect(
        practiceItems.any(
          (item) =>
              item.type == LessonPracticeType.audioChoice &&
              item.audioType == 'sentence' &&
              <String>{'انا مستعد', 'انا جاهز'}.contains(item.audioText),
        ),
        isTrue,
      );
    });
  });
}
