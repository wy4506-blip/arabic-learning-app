import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arabic_learning_app/data/generated_stage_c_preview_lessons.dart';
import 'package:arabic_learning_app/models/app_settings.dart';
import 'package:arabic_learning_app/models/v2_micro_lesson.dart';
import 'package:arabic_learning_app/pages/v2_micro_lesson_completion_page.dart';
import 'package:arabic_learning_app/pages/v2_micro_lesson_page.dart';
import 'package:arabic_learning_app/services/v2_micro_lesson_completion_orchestrator.dart';

import 'test_helpers.dart';
import 'v2_home_flow_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const lesson = lesson11OneOrMoreAnotherArabicCluePreviewLesson;
  const requiredFlow = <String>[
    'recognize_more_than_one_main_pair',
    'match_many_cars_main_pair',
    'confirm_more_than_one_support_pair',
    'recover_more_than_one_main_pair',
    'sort_main_pair_one_vs_more',
  ];

  test('lesson 11 keeps the evidence-bearing flow and review priority locked', () {
    expect(lesson.lessonId, 'lesson_11_one_or_more_another_arabic_clue');
    expect(lesson.objectives, hasLength(1));
    expect(
      lesson.practiceItems.map((item) => item.itemId).toList(growable: false),
      requiredFlow,
    );
    expect(lesson.completionRule.requiredPracticeItemIds, requiredFlow);
    expect(lesson.completionRule.minimumPracticeCount, 5);
    expect(lesson.reviewSeedRules.map((rule) => rule.ruleId), <String>[
      'one_vs_more_main_pair_sayyara',
      'recover_more_than_one_form_sayyaraat',
      'main_pair_quantity_match',
      'one_vs_more_support_pair_kalima',
    ]);
    expect(
      lesson.practiceItems.last.type,
      V2MicroPracticeType.arrangeResponse,
    );
  });

  test('lesson 11 weak preview completion prioritizes the expected review seeds',
      () async {
    final result = await V2MicroLessonCompletionOrchestrator.completePreviewLesson(
      lesson: lesson,
      practiceOutcomes: const <V2MicroPracticeOutcome>[
        V2MicroPracticeOutcome(
          itemId: 'recognize_more_than_one_main_pair',
          passed: true,
        ),
        V2MicroPracticeOutcome(
          itemId: 'match_many_cars_main_pair',
          passed: false,
        ),
        V2MicroPracticeOutcome(
          itemId: 'confirm_more_than_one_support_pair',
          passed: false,
        ),
        V2MicroPracticeOutcome(
          itemId: 'recover_more_than_one_main_pair',
          passed: false,
        ),
        V2MicroPracticeOutcome(
          itemId: 'sort_main_pair_one_vs_more',
          passed: false,
        ),
      ],
    );

    expect(result.currentStatus, V2CanonicalLessonStatus.coreCompleted);
    expect(result.createdReviewSeeds.map((seed) => seed.itemRefId), <String>[
      'one_vs_more_main_pair_sayyara',
      'recover_more_than_one_form_sayyaraat',
      'main_pair_quantity_match',
      'one_vs_more_support_pair_kalima',
    ]);
    expect(
      result.recommendedAction.actionType,
      V2RecommendedActionType.startReview,
    );
  });

  testWidgets('lesson 11 preview lesson runs through the required learner win',
      (tester) async {
    await pumpLocalizedTestPage(
      tester,
      const V2MicroLessonPage(
        settings: AppSettings(
          appLanguage: AppLanguage.en,
          meaningLanguage: ContentLanguage.en,
          showTransliteration: true,
        ),
        lesson: lesson11OneOrMoreAnotherArabicCluePreviewLesson,
      ),
    );

    expect(find.text('One Or More? A Tiny Arabic Clue'), findsWidgets);
    expect(find.text('سيارة / سيارات'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'سيارات').first);
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await pumpForTransition(tester);

    await tester.tap(find.widgetWithText(OutlinedButton, 'سيارات').first);
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await pumpForTransition(tester);

    await tester.tap(find.widgetWithText(OutlinedButton, 'كلمات').first);
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await pumpForTransition(tester);

    await tester.enterText(find.byType(TextField), 'سيارات');
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Check Answer'));
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await pumpForTransition(tester);

    await tester.tap(find.widgetWithText(ActionChip, 'one'));
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(ActionChip, 'سيارة'));
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(ActionChip, 'more-than-one'));
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(ActionChip, 'سيارات'));
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Check Answer'));
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await pumpForTransition(tester);

    expect(find.byType(V2MicroLessonCompletionPage), findsOneWidget);
    expect(find.text('Lesson Complete'), findsOneWidget);
    expect(find.text('Stage C progress'), findsOneWidget);
    expect(find.textContaining('one car or more than one car'), findsWidgets);
  });
}


