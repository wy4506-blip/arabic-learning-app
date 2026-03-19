import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arabic_learning_app/models/learning_state_models.dart';
import 'package:arabic_learning_app/models/review_models.dart';
import 'package:arabic_learning_app/models/v2_lesson_progress_models.dart';

import 'v2_home_flow_test_helpers.dart';

Map<String, Object> _reviewFirstPrefs() {
  final now = DateTime.now();
  final dueTask = ReviewTask(
    contentId: 'word:due-item',
    type: ReviewContentType.word,
    objectType: ReviewObjectType.wordReading,
    actionType: ReviewActionType.repeat,
    origin: ReviewTaskOrigin.due,
    title: 'Due item',
    subtitle: 'Review this item first.',
    arabicText: '氐賻亘賻丕丨購 丕賱賿禺賻賷賿乇賽',
    transliteration: 'sabah al-khayr',
    helperText: 'This review should block the next lesson.',
    lessonId: 'V2-U1-01',
    sourceId: 'due-item',
    estimatedSeconds: 20,
    priority: 3,
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
          contentId: 'word:due-item',
          type: ReviewContentType.word,
          objectType: ReviewObjectType.wordReading,
          lessonId: 'V2-U1-01',
          isStarted: true,
          isCompleted: true,
          needsReview: true,
          isWeak: false,
          isFavorited: false,
          reviewPriority: 3,
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

  testWidgets('home prioritizes formal review when due items exist', (tester) async {
    await pumpV2Home(
      tester,
      sharedPreferences: _reviewFirstPrefs(),
    );

    expect(find.widgetWithText(FilledButton, 'Start Pilot Review'),
        findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Start This V2 Lesson'),
        findsNothing);
    expect(find.widgetWithText(FilledButton, 'Start Warm-Up'), findsNothing);
  });
}
