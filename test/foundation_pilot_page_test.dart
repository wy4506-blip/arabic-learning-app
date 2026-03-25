import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arabic_learning_app/data/generated_stage_a_preview_lessons.dart';
import 'package:arabic_learning_app/models/learning_state_models.dart';
import 'package:arabic_learning_app/models/review_models.dart';
import 'package:arabic_learning_app/models/v2_lesson_progress_models.dart';
import 'package:arabic_learning_app/pages/profile_page.dart';
import 'package:arabic_learning_app/pages/review_session_page.dart';
import 'package:arabic_learning_app/pages/v2_foundation_pilot_page.dart';
import 'package:arabic_learning_app/pages/v2_micro_lesson_completion_page.dart';
import 'package:arabic_learning_app/pages/v2_micro_lesson_page.dart';
import 'package:arabic_learning_app/services/learning_state_service.dart';
import 'package:arabic_learning_app/services/lesson_progress_service.dart';

import 'test_helpers.dart';
import 'v2_home_flow_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await LessonProgressService.debugClearAll();
    await LearningStateService.saveAllStates(
      const <LearningContentState>[],
      notify: false,
    );
    await LearningStateService.saveAllPracticeStates(
      const <LearningPracticeState>[],
      notify: false,
    );
  });

  Future<void> openFoundationPilotFromProfile(WidgetTester tester) async {
    await pumpLocalizedTestPage(
      tester,
      ProfilePage(
        settings: kEnglishTestSettings,
        onSettingsChanged: (_) {},
      ),
    );

    final pilotEntry = find.text('Foundation Pilot Candidate');
    await tester.scrollUntilVisible(
      pilotEntry,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(pilotEntry);
    await pumpForTransition(tester);
  }

  Future<void> waitForReviewSession(WidgetTester tester) async {
    for (var index = 0; index < 20; index += 1) {
      await tester.pump(const Duration(milliseconds: 200));
      if (find.byType(ReviewSessionPage).evaluate().isNotEmpty) {
        return;
      }
    }
  }

  Future<void> completeFoundationEntryLesson(WidgetTester tester) async {
    final hearKitab = stageAOrientationPreviewLesson.practiceItems.firstWhere(
      (item) => item.itemId == 'hear_kitab_anchor',
    );
    final recognizeStartSide =
        stageAOrientationPreviewLesson.practiceItems.firstWhere(
      (item) => item.itemId == 'recognize_start_side_kitab',
    );
    final recognizeMeaning =
        stageAOrientationPreviewLesson.practiceItems.firstWhere(
      (item) => item.itemId == 'recognize_kitab_meaning',
    );
    final recallStartSide =
        stageAOrientationPreviewLesson.practiceItems.firstWhere(
      (item) => item.itemId == 'recall_start_side_kitab',
    );
    final recallMeaning =
        stageAOrientationPreviewLesson.practiceItems.firstWhere(
      (item) => item.itemId == 'recall_kitab_meaning',
    );
    final buildPair = stageAOrientationPreviewLesson.practiceItems.firstWhere(
      (item) => item.itemId == 'build_kitab_pair',
    );
    final arrangeTokens = (buildPair.expectedAnswer ?? '').split(' ');

    await tester.tap(
      find.widgetWithText(OutlinedButton, hearKitab.arabicText!).first,
    );
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await pumpForTransition(tester);

    await tester.tap(
      find.widgetWithText(OutlinedButton, recognizeStartSide.arabicText!).first,
    );
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await pumpForTransition(tester);

    await tester.tap(
      find.widgetWithText(OutlinedButton, recognizeMeaning.arabicText!).first,
    );
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await pumpForTransition(tester);

    await tester.enterText(
      find.byType(TextField),
      recallStartSide.expectedAnswer ?? recallStartSide.arabicText!,
    );
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Check Answer'));
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await pumpForTransition(tester);

    await tester.enterText(
      find.byType(TextField),
      recallMeaning.expectedAnswer ?? recallMeaning.arabicText!,
    );
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Check Answer'));
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await pumpForTransition(tester);

    await tester.tap(find.widgetWithText(ActionChip, arrangeTokens.first));
    await tester.pump();
    await tester.tap(find.widgetWithText(ActionChip, arrangeTokens.last));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Check Answer'));
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await pumpForTransition(tester);
  }

  Map<String, Object> foundationReviewFirstPrefs() {
    final now = DateTime.now();
    final contentId = buildWordContentId('word_kitab_anchor');
    final lessonRecordsJson = jsonEncode(
      const <V2LessonProgressRecord>[
        V2LessonProgressRecord(
          lessonId: 'V2-A1-01-PREVIEW',
          status: V2LessonStatus.completed,
        ),
      ].map((record) => record.toJson()).toList(growable: false),
    );
    final learningStatesJson = jsonEncode(
      <LearningContentState>[
        LearningContentState(
          contentId: contentId,
          type: ReviewContentType.word,
          objectType: ReviewObjectType.wordReading,
          lessonId: 'V2-A1-01-PREVIEW',
          isStarted: true,
          isCompleted: true,
          needsReview: true,
          isWeak: true,
          isFavorited: false,
          reviewPriority: 5,
          stage: LearningStage.weak,
          nextReviewAt: now.subtract(const Duration(minutes: 1)),
        ),
      ].map((state) => state.toJson()).toList(growable: false),
    );
    final reviewPlan = DailyReviewPlan(
      dateKey: reviewDateKey(now),
      tasks: <ReviewTask>[
        ReviewTask(
          contentId: contentId,
          type: ReviewContentType.word,
          objectType: ReviewObjectType.wordReading,
          actionType: ReviewActionType.read,
          origin: ReviewTaskOrigin.weak,
          title: 'Kitab Anchor',
          subtitle: 'Read the anchor once to clear this blocker.',
          arabicText: 'كتاب',
          audioQueryText: 'كتاب',
          lessonId: 'V2-A1-01-PREVIEW',
          sourceId: 'word_kitab_anchor',
          estimatedSeconds: 20,
          priority: 5,
        ),
      ],
      completedTaskIds: const <String>[],
      startedAt: now,
    );

    return <String, Object>{
      'v2_lesson_progress_records_v1': lessonRecordsJson,
      'learning_content_states_v1': learningStatesJson,
      'review_today_plan_v1': jsonEncode(reviewPlan.toJson()),
    };
  }

  testWidgets(
    'profile foundation pilot opens the controlled pilot page',
    (tester) async {
      await openFoundationPilotFromProfile(tester);

      expect(find.byType(V2FoundationPilotPage), findsOneWidget);
      expect(find.text('Foundation Pilot Candidate'), findsOneWidget);
      expect(find.text('CONTROLLED PILOT'), findsOneWidget);
      expect(find.text('Stage A - Lessons 1-4'), findsOneWidget);
      expect(find.text('Stage B - Lessons 5-8'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Stage C - Lessons 9-12'),
        240,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Stage C - Lessons 9-12'), findsOneWidget);
    },
  );

  testWidgets(
    'foundation pilot primary action opens a formal lesson flow',
    (tester) async {
      await openFoundationPilotFromProfile(tester);

      expect(find.byType(V2FoundationPilotPage), findsOneWidget);
      expect(find.text('Next Lesson: Arabic Starts Here'), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey<String>('foundation_pilot_primary_action')),
      );
      await pumpForTransition(tester);

      expect(find.byType(V2MicroLessonPage), findsOneWidget);
      expect(find.text('Arabic Starts Here'), findsWidgets);
      expect(find.text('Preview Lesson'), findsNothing);
    },
  );

  testWidgets(
    'foundation pilot completion returns to the refreshed next lesson recommendation',
    (tester) async {
      await pumpLocalizedTestPage(
        tester,
        const V2FoundationPilotPage(
          settings: kEnglishTestSettings,
        ),
      );

      expect(find.byType(V2FoundationPilotPage), findsOneWidget);
      expect(find.text('Next Lesson: Arabic Starts Here'), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey<String>('foundation_pilot_primary_action')),
      );
      await pumpForTransition(tester);

      expect(find.byType(V2MicroLessonPage), findsOneWidget);

      await completeFoundationEntryLesson(tester);

      expect(find.byType(V2MicroLessonCompletionPage), findsOneWidget);
      expect(find.text('Lesson Complete'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Back Home'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Back Home'));
      await pumpForTransition(tester);
      await pumpForTransition(tester);

      expect(find.byType(V2FoundationPilotPage), findsOneWidget);
      expect(find.text('Next Lesson: First Real Word Success'), findsOneWidget);
      expect(find.text('Completed 1 / 12'), findsOneWidget);
    },
  );

  testWidgets(
    'foundation pilot review-first flow clears the blocker and returns to the next lesson',
    (tester) async {
      await pumpLocalizedTestPage(
        tester,
        const V2FoundationPilotPage(
          settings: kEnglishTestSettings,
        ),
        sharedPreferences: foundationReviewFirstPrefs(),
      );

      expect(find.byType(V2FoundationPilotPage), findsOneWidget);
      expect(find.text('Clear Foundation Review First'), findsOneWidget);
      expect(find.textContaining('1 due or weak item'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Start Review'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Start Review'));
      await pumpReviewFlowLaunch(tester);
      await waitForReviewSession(tester);

      expect(find.byType(ReviewSessionPage), findsOneWidget);
      expect(find.text('Pilot Review'), findsWidgets);

      await tester.tap(find.widgetWithText(FilledButton, 'I Read It'));
      await pumpForTransition(tester);

      expect(find.text('This Review Pass Is Complete'), findsOneWidget);
      expect(find.text('Return to Learning'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Return to Learning'));
      await pumpForTransition(tester);
      await pumpForTransition(tester);

      expect(find.byType(V2FoundationPilotPage), findsOneWidget);
      expect(find.text('Clear Foundation Review First'), findsNothing);
      expect(find.widgetWithText(FilledButton, 'Start Review'), findsNothing);
      expect(find.text('Next Lesson: First Real Word Success'), findsOneWidget);
    },
  );
}
