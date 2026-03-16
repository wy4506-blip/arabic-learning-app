import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arabic_learning_app/models/learning_state_models.dart';
import 'package:arabic_learning_app/models/review_models.dart';
import 'package:arabic_learning_app/models/v2_lesson_progress_models.dart';
import 'package:arabic_learning_app/pages/home_page.dart';
import 'package:arabic_learning_app/pages/review_session_page.dart';
import 'package:arabic_learning_app/pages/v2_review_entry_page.dart';

import 'test_helpers.dart';
import 'v2_home_flow_test_helpers.dart';

ReviewTask _buildDueTask() {
  return ReviewTask(
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
}

Map<String, Object> _reviewFirstPrefs() {
  final now = DateTime.now();
  final dueTask = _buildDueTask();
  final reviewPlan = DailyReviewPlan(
    dateKey: reviewDateKey(now),
    tasks: <ReviewTask>[dueTask],
    completedTaskIds: const <String>[],
    startedAt: now,
  );
  final lessonProgressJson = jsonEncode(
    <Map<String, dynamic>>[
      const V2LessonProgressRecord(
        lessonId: 'V2-U1-01',
        status: V2LessonStatus.completed,
      ).toJson(),
    ],
  );
  final learningStatesJson = jsonEncode(
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
  );
  final reviewPlanJson = jsonEncode(reviewPlan.toJson());
  return <String, Object>{
    'v2_lesson_progress_records_v1': lessonProgressJson,
    'learning_content_states_v1': learningStatesJson,
    'review_today_plan_v1': reviewPlanJson,
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await resetV2HomeFlowState();
  });

  Future<void> waitForReviewSession(WidgetTester tester) async {
    for (var index = 0; index < 20; index += 1) {
      await tester.pump(const Duration(milliseconds: 200));
      if (find.byType(ReviewSessionPage).evaluate().isNotEmpty) {
        return;
      }
    }
  }

  testWidgets(
      'home review-first card enters V2 review entry, completes review, and refreshes to the mainline',
      (tester) async {
    await pumpV2Home(
      tester,
      sharedPreferences: _reviewFirstPrefs(),
    );

    expect(find.text('Clear Pilot Review First'), findsOneWidget);
    expect(find.textContaining('1 item due'), findsOneWidget);
    expect(find.text('Greeting Response: Say Ana Bikhayr'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Start Pilot Review'),
        findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Start Pilot Review'));
    await pumpReviewFlowLaunch(tester);
    await waitForReviewSession(tester);

    expect(find.byType(ReviewSessionPage), findsOneWidget);
    expect(find.text('Pilot Review'), findsWidgets);

    await tester.tap(find.widgetWithText(FilledButton, 'I Can Say It'));
    await pumpForTransition(tester);

    expect(find.text('Return to Learning'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Return to Learning'));
    await pumpForTransition(tester);

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Clear Pilot Review First'), findsNothing);
    expect(find.textContaining('1 item due'), findsNothing);
    expect(
        find.widgetWithText(FilledButton, 'Start Pilot Review'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Start This V2 Lesson'),
        findsOneWidget);
  });

  testWidgets(
      'chinese home review-first path enters V2 review entry and returns to the mainline',
      (tester) async {
    await pumpV2Home(
      tester,
      settings: kChineseTestSettings,
      sharedPreferences: _reviewFirstPrefs(),
    );

    expect(find.text('先完成样板复习'), findsOneWidget);
    expect(find.textContaining('待复习 1 项'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '开始样板复习'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, '开始样板复习'));
    await pumpReviewFlowLaunch(tester);

    final enteredReviewFlow =
        find.byType(V2ReviewEntryPage).evaluate().isNotEmpty ||
            find.byType(ReviewSessionPage).evaluate().isNotEmpty;
    expect(enteredReviewFlow, isTrue);
    expect(find.text('样板复习'), findsWidgets);
  });
}
