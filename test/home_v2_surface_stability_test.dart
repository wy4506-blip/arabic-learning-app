import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arabic_learning_app/models/app_settings.dart';
import 'package:arabic_learning_app/models/learning_state_models.dart';
import 'package:arabic_learning_app/models/review_models.dart';
import 'package:arabic_learning_app/models/v2_lesson_progress_models.dart';
import 'package:arabic_learning_app/pages/home_page.dart';
import 'package:arabic_learning_app/pages/v2_micro_lesson_completion_page.dart';
import 'package:arabic_learning_app/pages/v2_micro_lesson_page.dart';

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