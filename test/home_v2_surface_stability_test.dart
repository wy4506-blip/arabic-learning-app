import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arabic_learning_app/data/sample_alphabet_data.dart';
import 'package:arabic_learning_app/data/sample_lessons.dart';
import 'package:arabic_learning_app/models/app_settings.dart';
import 'package:arabic_learning_app/models/learning_state_models.dart';
import 'package:arabic_learning_app/models/review_models.dart';
import 'package:arabic_learning_app/models/v2_lesson_progress_models.dart';
import 'package:arabic_learning_app/models/word_item.dart';
import 'package:arabic_learning_app/pages/alphabet_detail_page.dart';
import 'package:arabic_learning_app/pages/alphabet_write_page.dart';
import 'package:arabic_learning_app/pages/grammar_detail_page.dart';
import 'package:arabic_learning_app/pages/home_page.dart';
import 'package:arabic_learning_app/pages/lesson_detail_page.dart';
import 'package:arabic_learning_app/pages/lesson_quiz_page.dart';
import 'package:arabic_learning_app/pages/v2_micro_lesson_completion_page.dart';
import 'package:arabic_learning_app/pages/v2_micro_lesson_page.dart';
import 'package:arabic_learning_app/pages/vocab_book_page.dart';
import 'package:arabic_learning_app/services/review_service.dart';

import 'test_helpers.dart';
import 'v2_home_flow_test_helpers.dart';

Map<String, Object> _reviewFirstPrefs() {
  final dueTask = ReviewTask(
    contentId: 'sentence_pattern:صباح الخير',
    type: ReviewContentType.sentence,
    objectType: ReviewObjectType.sentencePattern,
    actionType: ReviewActionType.repeat,
    origin: ReviewTaskOrigin.due,
    title: 'Morning greeting',
    subtitle: 'Repeat the greeting naturally.',
    arabicText: 'صَبَاحُ الْخَيْرِ',
    transliteration: 'sabah al-khayr',
    helperText: 'Use it as a complete greeting.',
    lessonId: 'V2-U1-01',
    sourceId: 'صباح الخير',
    estimatedSeconds: 30,
    priority: 5,
  );
  final reviewPlan = DailyReviewPlan(
    dateKey: '2026-03-15',
    tasks: <ReviewTask>[dueTask],
    completedTaskIds: const <String>[],
    startedAt: DateTime(2026, 3, 15, 9),
  );
  return <String, Object>{
    'v2_lesson_progress_records_v1': jsonEncode(
      <Map<String, dynamic>>[
        const V2LessonProgressRecord(
          lessonId: 'V2-U1-01',
          status: V2LessonStatus.completed,
        ).toJson(),
      ],
    ),
    'learning_content_states_v1': jsonEncode(
      <Map<String, dynamic>>[
        LearningContentState(
          contentId: 'sentence_pattern:صباح الخير',
          type: ReviewContentType.sentence,
          objectType: ReviewObjectType.sentencePattern,
          lessonId: 'V2-U1-01',
          isStarted: true,
          isCompleted: true,
          needsReview: true,
          isWeak: true,
          isFavorited: false,
          reviewPriority: 5,
          stage: LearningStage.weak,
        ).toJson(),
      ],
    ),
    'review_today_plan_v1': jsonEncode(reviewPlan.toJson()),
  };
}

const AppSettings _englishUiZhMeaningSettings = AppSettings(
  appLanguage: AppLanguage.en,
  meaningLanguage: ContentLanguage.zh,
  showTransliteration: true,
);

String _sessionSurfaceText(ReviewSession session) {
  return <String>[
    session.title,
    session.subtitle,
    for (final task in session.tasks) ...<String>[
      task.title,
      task.subtitle,
      task.helperText ?? '',
    ],
  ].join('\n');
}

final WordItem _savedWord = WordItem(
  arabic: 'مَرْحَبًا',
  plainArabic: 'مرحبا',
  pronunciation: 'marhaban',
  meaning: '你好',
  partOfSpeech: '固定表达',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await resetV2HomeFlowState();
  });

  testWidgets('english V2 home surfaces do not expose Chinese core copy',
      (tester) async {
    await pumpV2Home(tester);

    expectNoVisibleChinese(tester);
    expectNoVisibleMojibake(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Start This V2 Lesson'));
    await pumpForTransition(tester);

    expect(find.byType(V2MicroLessonPage), findsOneWidget);
    expectNoVisibleChinese(tester);
    expectNoVisibleMojibake(tester);

    await completeAlphabetClosureLesson(
      tester,
      language: AppLanguage.en,
    );

    expect(find.byType(V2MicroLessonCompletionPage), findsOneWidget);
    expect(find.text('Lesson Complete'), findsOneWidget);
    expect(find.text('You Can Already Do'), findsOneWidget);
    expect(find.text('Review Result'), findsOneWidget);
    expect(find.text('Next Step'), findsOneWidget);
    expectNoVisibleChinese(tester);
    expectNoVisibleMojibake(tester);
  });

  testWidgets(
      'lesson detail stays English even when meaning language is still Chinese',
      (tester) async {
    await pumpLocalizedTestPage(
      tester,
      LessonDetailPage(
        lesson: sampleLessons.first,
        settings: _englishUiZhMeaningSettings,
        isUnlocked: true,
      ),
      settings: _englishUiZhMeaningSettings,
    );

    expect(find.text('Greetings and Essential Expressions'), findsWidgets);
    expect(find.text('Hello'), findsWidgets);
    expectNoVisibleChinese(tester);

    await tester.tap(find.text('Hello').first);
    await pumpTestFrames(tester, count: 4);

    expect(find.text('Play Audio'), findsOneWidget);
    expectNoVisibleChinese(tester);
  });

  testWidgets(
      'alphabet detail stays English even when meaning language is still Chinese',
      (tester) async {
    await pumpLocalizedTestPage(
      tester,
      AlphabetDetailPage(
        letter: sampleAlphabetGroups.first.letters.first,
      ),
      settings: _englishUiZhMeaningSettings,
    );

    expect(find.text('Letter Detail'), findsOneWidget);
    expect(find.text('Open Listening Practice'), findsOneWidget);
    expectNoVisibleChinese(tester);
  });

  testWidgets(
      'alphabet writing page stays English even when meaning language is still Chinese',
      (tester) async {
    await pumpLocalizedTestPage(
      tester,
      AlphabetWritePage(
        letter: sampleAlphabetGroups.first.letters.first,
      ),
      settings: _englishUiZhMeaningSettings,
    );

    expect(find.text('Writing Practice'), findsOneWidget);
    expect(find.text('Start with the Isolated Form'), findsOneWidget);
    expectNoVisibleChinese(tester);
  });

  testWidgets(
      'grammar detail stays English even when meaning language is still Chinese',
      (tester) async {
    await pumpLocalizedTestPage(
      tester,
      const GrammarDetailPage(
        pageId: 'personal_pronouns',
        settings: _englishUiZhMeaningSettings,
      ),
      settings: _englishUiZhMeaningSettings,
    );

    expect(find.textContaining('Pronouns'), findsWidgets);
    expectNoVisibleChinese(tester);
  });

  testWidgets(
      'lesson quiz stays English even when meaning language is still Chinese',
      (tester) async {
    await pumpLocalizedTestPage(
      tester,
      LessonQuizPage(lesson: sampleLessons.first),
      settings: _englishUiZhMeaningSettings,
    );

    expect(find.textContaining('Practice'), findsWidgets);
    expect(find.textContaining('Question'), findsWidgets);
    expectNoVisibleChinese(tester);
  });

  testWidgets(
      'vocab book stays English even when meaning language is still Chinese',
      (tester) async {
    await pumpLocalizedTestPage(
      tester,
      const VocabBookPage(),
      settings: _englishUiZhMeaningSettings,
      sharedPreferences: <String, Object>{
        'favorite_words': <String>[jsonEncode(_savedWord.toJson())],
      },
    );

    expect(find.text('Wordbook'), findsWidgets);
    expect(find.text('Hello'), findsOneWidget);
    expectNoVisibleChinese(tester);
  });

  testWidgets(
      'v2 micro lesson stays English even when meaning language is still Chinese',
      (tester) async {
    await pumpLocalizedTestPage(
      tester,
      const V2MicroLessonPage(
        lessonId: 'V2-U1-01',
        settings: _englishUiZhMeaningSettings,
      ),
      settings: _englishUiZhMeaningSettings,
    );

    expect(find.text('Lesson Goal'), findsOneWidget);
    expectNoVisibleChinese(tester);
  });

  testWidgets(
      'alphabet review tasks stay English when UI is English',
      (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'completed_lessons': <String>['U1L1'],
      'started_lessons': <String>['U1L1'],
      'last_lesson_id': 'U1L1',
      'learning_content_states_v1': jsonEncode(
        <Map<String, dynamic>>[
          LearningContentState(
            contentId: buildAlphabetContentId('ذ'),
            type: ReviewContentType.alphabet,
            objectType: ReviewObjectType.letterSound,
            lessonId: 'U1L1',
            isStarted: true,
            isCompleted: true,
            needsReview: true,
            isWeak: true,
            isFavorited: false,
            reviewPriority: 5,
            stage: LearningStage.weak,
          ).toJson(),
        ],
      ),
    });

    final alphabetSession = await ReviewService.createTypeSession(
      _englishUiZhMeaningSettings,
      ReviewContentType.alphabet,
    );
    expect(alphabetSession, isNotNull);
    expect(
      RegExp(r'[\u4E00-\u9FFF]').hasMatch(_sessionSurfaceText(alphabetSession!)),
      isFalse,
      reason: _sessionSurfaceText(alphabetSession),
    );
  });

  testWidgets(
      'quick review relocalizes a started today plan after switching the UI to English',
      (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'completed_lessons': <String>['U1L1'],
      'started_lessons': <String>['U1L1'],
      'last_lesson_id': 'U1L1',
    });

    final chineseSession = await ReviewService.createTodaySession(
      kChineseTestSettings,
    );
    expect(chineseSession, isNotNull);
    expect(chineseSession!.tasks, isNotEmpty);

    final quickSession = await ReviewService.createQuickSession(
      _englishUiZhMeaningSettings,
    );
    expect(quickSession, isNotNull);
    expect(
      RegExp(r'[\u4E00-\u9FFF]').hasMatch(_sessionSurfaceText(quickSession!)),
      isFalse,
      reason: _sessionSurfaceText(quickSession),
    );
  });

  testWidgets('english home secondary action opens learning path and returns to a stable V2 lesson card',
      (tester) async {
    await pumpV2HomeShell(tester);

    expect(find.text('Alphabet Closure: Hear ث / ذ / ظ Clearly'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'See Full Learning Path'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'See Full Learning Path'));
    await pumpForTransition(tester);

    expect(find.text('Learning Path Tab'), findsOneWidget);
    expect(find.byType(HomePage), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Back Home'));
    await pumpForTransition(tester);

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Alphabet Closure: Hear ث / ذ / ظ Clearly'), findsOneWidget);
    expect(
      find.text('Home now sends you straight into the next real action in the pilot path.'),
      findsOneWidget,
    );
    expect(find.widgetWithText(TextButton, 'See Full Learning Path'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Start This V2 Lesson'), findsOneWidget);
  });

  testWidgets('chinese review-first secondary action opens learning path and returns to a stable review-first card',
      (tester) async {
    await pumpV2HomeShell(
      tester,
      settings: kChineseTestSettings,
      sharedPreferences: _reviewFirstPrefs(),
    );

    expect(find.text('先完成样板复习'), findsOneWidget);
    expect(find.textContaining('待复习 1 项'), findsOneWidget);
    expect(find.widgetWithText(TextButton, '查看完整学习路径'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, '查看完整学习路径'));
    await pumpForTransition(tester);

    expect(find.text('学习路径 Tab'), findsOneWidget);
    expect(find.byType(HomePage), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, '返回首页'));
    await pumpForTransition(tester);

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('先完成样板复习'), findsOneWidget);
    expect(find.textContaining('待复习 1 项'), findsOneWidget);
    expect(find.text('系统检测到样板链路里已有到期或薄弱复习，先处理它，再继续主线。'), findsOneWidget);
    expect(find.widgetWithText(TextButton, '查看完整学习路径'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '开始样板复习'), findsOneWidget);
  });
}
