import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arabic_learning_app/models/learning_state_models.dart';
import 'package:arabic_learning_app/models/review_models.dart';
import 'package:arabic_learning_app/models/v2_lesson_progress_models.dart';
import 'package:arabic_learning_app/pages/review_session_page.dart';
import 'package:arabic_learning_app/pages/v2_review_entry_page.dart';

import 'v2_home_flow_test_helpers.dart';

Map<String, Object> _reviewFirstPrefs() {
  final now = DateTime.now();
  final dueTask = ReviewTask(
    contentId: 'word:warmup-item',
    type: ReviewContentType.word,
    objectType: ReviewObjectType.wordReading,
    actionType: ReviewActionType.repeat,
    origin: ReviewTaskOrigin.due,
    title: 'Warm-up item',
    subtitle: 'Review this first.',
    arabicText: '氐賻亘賻丕丨購 丕賱賿禺賻賷賿乇賽',
    transliteration: 'sabah al-khayr',
    helperText: 'This should trigger pilot review first.',
    lessonId: 'V2-U1-01',
    sourceId: 'warmup-item',
    estimatedSeconds: 20,
    priority: 1,
  );
  final reviewPlan = DailyReviewPlan(
    dateKey: reviewDateKey(now),
    tasks: <ReviewTask>[dueTask],
    completedTaskIds: const <String>[],
    startedAt: now,
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
          contentId: 'word:warmup-item',
          type: ReviewContentType.word,
          objectType: ReviewObjectType.wordReading,
          lessonId: 'V2-U1-01',
          isStarted: true,
          isCompleted: true,
          needsReview: true,
          isWeak: false,
          isFavorited: false,
          reviewPriority: 1,
          stage: LearningStage.reviewDue,
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

  Future<void> step(
    String label,
    Future<void> Function() action,
  ) async {
    try {
      await action().timeout(
        const Duration(seconds: 8),
        onTimeout: () => throw TestFailure('TODAY timeout at: $label'),
      );
    } catch (error) {
      throw TestFailure('TODAY failed at: $label -> $error');
    }
  }

  Future<void> waitForReviewSession(WidgetTester tester) async {
    for (var index = 0; index < 20; index += 1) {
      await tester.pump(const Duration(milliseconds: 200));
      if (find.byType(ReviewSessionPage).evaluate().isNotEmpty) {
        return;
      }
    }
  }

  testWidgets('home today learning card prioritizes due review first', (tester) async {
    await step(
      'pump review-first home',
      () => pumpV2Home(
        tester,
        sharedPreferences: _reviewFirstPrefs(),
      ),
    );

    expect(find.widgetWithText(FilledButton, 'Start Pilot Review'),
        findsOneWidget);
    expect(find.text('Start Warm-Up'), findsNothing);
    expect(find.text('Enter Today\'s Lesson'), findsNothing);
    expect(find.text('Continue Alphabet Learning'), findsNothing);

    await step('tap Start Pilot Review', () async {
      await tester.tap(find.widgetWithText(FilledButton, 'Start Pilot Review'));
      await pumpReviewFlowLaunch(tester);
    });
    await step('wait for review surface', () => waitForReviewSession(tester));

    final enteredReviewFlow =
        find.byType(V2ReviewEntryPage).evaluate().isNotEmpty ||
            find.byType(ReviewSessionPage).evaluate().isNotEmpty;
    expect(enteredReviewFlow, isTrue);
    expect(find.text('Pilot Review'), findsWidgets);
  });
}
