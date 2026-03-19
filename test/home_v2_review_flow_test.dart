import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arabic_learning_app/data/v2_micro_lessons.dart';
import 'package:arabic_learning_app/models/learning_state_models.dart';
import 'package:arabic_learning_app/models/review_models.dart';
import 'package:arabic_learning_app/models/v2_lesson_progress_models.dart';
import 'package:arabic_learning_app/pages/home_page.dart';
import 'package:arabic_learning_app/pages/review_session_page.dart';
import 'package:arabic_learning_app/services/review_sync_service.dart';

import 'v2_home_flow_test_helpers.dart';

ReviewTask _buildDueTask({
  String contentId = 'sentence_pattern:氐亘丕丨 丕賱禺賷乇',
  String lessonId = 'V2-U1-01',
}) {
  return ReviewTask(
    contentId: contentId,
    type: ReviewContentType.sentence,
    objectType: ReviewObjectType.sentencePattern,
    actionType: ReviewActionType.repeat,
    origin: ReviewTaskOrigin.due,
    title: 'Morning greeting',
    subtitle: 'Repeat the greeting naturally.',
    arabicText: '氐賻亘賻丕丨購 丕賱賿禺賻賷賿乇賽',
    transliteration: 'sabah al-khayr',
    helperText: 'Use it as a complete greeting.',
    lessonId: lessonId,
    sourceId: '氐亘丕丨 丕賱禺賷乇',
    estimatedSeconds: 30,
    priority: 5,
  );
}

Map<String, Object> _reviewPrefs({
  required List<V2LessonProgressRecord> lessonRecords,
  required List<LearningContentState> learningStates,
}) {
  final now = DateTime.now();
  final reviewPlan = DailyReviewPlan(
    dateKey: reviewDateKey(now),
    tasks: <ReviewTask>[
      _buildDueTask(
        contentId: learningStates.first.contentId,
        lessonId: learningStates.first.lessonId!,
      ),
    ],
    completedTaskIds: const <String>[],
    startedAt: now,
  );
  final lessonProgressJson = jsonEncode(
    lessonRecords.map((record) => record.toJson()).toList(growable: false),
  );
  final learningStatesJson = jsonEncode(
    learningStates.map((state) => state.toJson()).toList(growable: false),
  );
  final reviewPlanJson = jsonEncode(reviewPlan.toJson());
  return <String, Object>{
    'v2_lesson_progress_records_v1': lessonProgressJson,
    'learning_content_states_v1': learningStatesJson,
    'review_today_plan_v1': reviewPlanJson,
  };
}

Map<String, Object> _reviewFirstPrefs() {
  return _reviewPrefs(
    lessonRecords: const <V2LessonProgressRecord>[
      V2LessonProgressRecord(
        lessonId: 'V2-U1-01',
        status: V2LessonStatus.completed,
      ),
    ],
    learningStates: const <LearningContentState>[
      LearningContentState(
        contentId: 'sentence_pattern:氐亘丕丨 丕賱禺賷乇',
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
      ),
    ],
  );
}

Map<String, Object> _completedForTodayPrefs() {
  final completedRecords = v2PilotMicroLessons
      .map(
        (lesson) => V2LessonProgressRecord(
          lessonId: lesson.lessonId,
          status: V2LessonStatus.completed,
        ),
      )
      .toList(growable: false);
  return _reviewPrefs(
    lessonRecords: completedRecords,
    learningStates: const <LearningContentState>[
      LearningContentState(
        contentId: 'sentence_pattern:鬲賲丕賲',
        type: ReviewContentType.sentence,
        objectType: ReviewObjectType.sentencePattern,
        lessonId: 'V2-U1-05',
        isStarted: true,
        isCompleted: true,
        needsReview: true,
        isWeak: true,
        isFavorited: false,
        reviewPriority: 5,
        stage: LearningStage.weak,
      ),
    ],
  );
}

Map<String, Object> _partialTodayPlanPrefs() {
  return _reviewPrefs(
    lessonRecords: const <V2LessonProgressRecord>[
      V2LessonProgressRecord(
        lessonId: 'V2-U1-01',
        status: V2LessonStatus.completed,
      ),
    ],
    learningStates: const <LearningContentState>[
      LearningContentState(
        contentId: 'sentence_pattern:氐亘丕丨 丕賱禺賷乇',
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
      ),
      LearningContentState(
        contentId: 'sentence_pattern:ana_bikhayr',
        type: ReviewContentType.sentence,
        objectType: ReviewObjectType.sentencePattern,
        lessonId: 'V2-U1-01',
        isStarted: true,
        isCompleted: true,
        needsReview: true,
        isWeak: false,
        isFavorited: false,
        reviewPriority: 4,
        stage: LearningStage.reviewDue,
      ),
    ],
  );
}

Map<String, Object> _nonV2DuePrefs() {
  return _reviewPrefs(
    lessonRecords: const <V2LessonProgressRecord>[],
    learningStates: const <LearningContentState>[
      LearningContentState(
        contentId: 'sentence_pattern:legacy_due_item',
        type: ReviewContentType.sentence,
        objectType: ReviewObjectType.sentencePattern,
        lessonId: 'L03',
        isStarted: true,
        isCompleted: true,
        needsReview: true,
        isWeak: true,
        isFavorited: false,
        reviewPriority: 5,
        stage: LearningStage.weak,
      ),
    ],
  );
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

  Future<void> settleTail(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 120));
    await tester.pump(const Duration(milliseconds: 120));
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

    expect(find.text('This Review Pass Is Complete'), findsOneWidget);
    expect(find.text('Today\'s Review Is Complete'), findsNothing);
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

    await settleTail(tester);
  });

  testWidgets(
      'home review-first flow returns to a completed-for-today card when no mainline lesson remains',
      (tester) async {
    await pumpV2Home(
      tester,
      sharedPreferences: _completedForTodayPrefs(),
    );

    expect(find.text('Clear Pilot Review First'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Start Pilot Review'),
        findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Start Pilot Review'));
    await pumpReviewFlowLaunch(tester);
    await waitForReviewSession(tester);

    expect(find.byType(ReviewSessionPage), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'I Can Say It'));
    await pumpForTransition(tester);

    expect(find.text('This Review Pass Is Complete'), findsOneWidget);
    expect(find.text('Today\'s Review Is Complete'), findsNothing);
    expect(find.text('Return to Learning'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Return to Learning'));
    await pumpForTransition(tester);

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Clear Pilot Review First'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Start Pilot Review'),
        findsNothing);
    expect(find.text('Today\'s V2 Mainline Is Clear'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Start This V2 Lesson'),
        findsNothing);
    expect(find.widgetWithText(FilledButton, 'Continue This V2 Lesson'),
        findsNothing);
    expect(find.widgetWithText(FilledButton, 'View Learning Path'),
        findsOneWidget);

    await settleTail(tester);
  });

  testWidgets(
      'home review-first flow keeps the review-first card when the review session exits without completion',
      (tester) async {
    await pumpV2Home(
      tester,
      sharedPreferences: _reviewFirstPrefs(),
    );

    expect(find.text('Clear Pilot Review First'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Start Pilot Review'),
        findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Start Pilot Review'));
    await pumpReviewFlowLaunch(tester);
    await waitForReviewSession(tester);

    expect(find.byType(ReviewSessionPage), findsOneWidget);

    await tester.pageBack();
    await pumpForTransition(tester);
    await pumpForTransition(tester);

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Clear Pilot Review First'), findsOneWidget);
    expect(find.textContaining('1 item due'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Start Pilot Review'),
        findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Start This V2 Lesson'),
        findsNothing);

    await settleTail(tester);
  });

  testWidgets(
      'home returns to the mainline after pilot review even if extra review sync notifications fire during the session',
      (tester) async {
    await pumpV2Home(
      tester,
      sharedPreferences: _reviewFirstPrefs(),
    );

    expect(find.widgetWithText(FilledButton, 'Start Pilot Review'),
        findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Start Pilot Review'));
    await pumpReviewFlowLaunch(tester);
    await waitForReviewSession(tester);

    expect(find.byType(ReviewSessionPage), findsOneWidget);

    ReviewSyncService.markStageChanged();
    await tester.pump(const Duration(milliseconds: 80));
    ReviewSyncService.markPlanChanged();
    await pumpForTransition(tester);

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

    await settleTail(tester);
  });

  testWidgets(
      'home review-first flow clears every due item even when the stored today plan only includes a subset',
      (tester) async {
    await pumpV2Home(
      tester,
      sharedPreferences: _partialTodayPlanPrefs(),
    );

    expect(find.text('Clear Pilot Review First'), findsOneWidget);
    expect(find.textContaining('2 items due'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Start Pilot Review'));
    await pumpReviewFlowLaunch(tester);
    await waitForReviewSession(tester);

    expect(find.byType(ReviewSessionPage), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'I Can Say It'));
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'I Can Say It'));
    await pumpForTransition(tester);

    expect(find.text('Return to Learning'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Return to Learning'));
    await pumpForTransition(tester);

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Clear Pilot Review First'), findsNothing);
    expect(find.textContaining('items due'), findsNothing);
    expect(
        find.widgetWithText(FilledButton, 'Start Pilot Review'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Start This V2 Lesson'),
        findsOneWidget);

    await settleTail(tester);
  });

  testWidgets(
      'home ignores due review that does not belong to a V2 lesson',
      (tester) async {
    await pumpV2Home(
      tester,
      sharedPreferences: _nonV2DuePrefs(),
    );

    expect(find.text('Clear Pilot Review First'), findsNothing);
    expect(find.textContaining('item due'), findsNothing);
    expect(
        find.widgetWithText(FilledButton, 'Start Pilot Review'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Start This V2 Lesson'),
        findsOneWidget);

    await settleTail(tester);
  });
}
