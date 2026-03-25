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

  const lesson = lesson10ArabicGivesYouAClueTaMarbutaPreviewLesson;
  const requiredFlow = <String>[
    'spot_ta_marbuta_in_sayyara',
    'recognize_kalima_shares_clue',
    'clue_vs_no_clue_contrast',
    'recognize_sayyara_meaning',
    'restore_ta_marbuta_in_context',
    'mark_ta_marbuta_output',
  ];

  test('lesson 10 keeps one clue objective with sayyara as the main carrier', () {
    expect(lesson.lessonId, 'lesson_10_arabic_gives_you_a_clue_ta_marbuta');
    expect(lesson.objectives, hasLength(1));
    expect(
      lesson.practiceItems.map((item) => item.itemId).toList(growable: false),
      requiredFlow,
    );
    expect(lesson.completionRule.requiredPracticeItemIds, <String>[
      'spot_ta_marbuta_in_sayyara',
      'recognize_kalima_shares_clue',
      'clue_vs_no_clue_contrast',
      'restore_ta_marbuta_in_context',
      'mark_ta_marbuta_output',
    ]);
    expect(lesson.practiceItems.last.type, V2MicroPracticeType.arrangeResponse);
    expect(lesson.reviewSeedRules.map((rule) => rule.ruleId), <String>[
      'clue_spot_ta_marbuta',
      'clue_contrast_ta_marbuta_vs_no_clue',
      'clue_word_sayyara_primary',
      'clue_word_kalima_support',
      'clue_meaning_feminine_hint',
      'restore_ta_marbuta_in_context',
    ]);
  });

  test('lesson 10 weak preview completion creates the expected clue review stack',
      () async {
    final result = await V2MicroLessonCompletionOrchestrator.completePreviewLesson(
      lesson: lesson,
      practiceOutcomes: const <V2MicroPracticeOutcome>[
        V2MicroPracticeOutcome(itemId: 'spot_ta_marbuta_in_sayyara', passed: true),
        V2MicroPracticeOutcome(itemId: 'recognize_kalima_shares_clue', passed: false),
        V2MicroPracticeOutcome(itemId: 'clue_vs_no_clue_contrast', passed: false),
        V2MicroPracticeOutcome(itemId: 'recognize_sayyara_meaning', passed: false),
        V2MicroPracticeOutcome(itemId: 'restore_ta_marbuta_in_context', passed: false),
        V2MicroPracticeOutcome(itemId: 'mark_ta_marbuta_output', passed: false),
      ],
    );

    expect(result.currentStatus, V2CanonicalLessonStatus.coreCompleted);
    expect(result.createdReviewSeeds.map((seed) => seed.itemRefId), <String>[
      'clue_spot_ta_marbuta',
      'clue_contrast_ta_marbuta_vs_no_clue',
      'clue_word_sayyara_primary',
      'clue_word_kalima_support',
      'clue_meaning_feminine_hint',
      'restore_ta_marbuta_in_context',
    ]);
    expect(
      result.recommendedAction.actionType,
      V2RecommendedActionType.startReview,
    );
  });

  testWidgets('lesson 10 preview lesson runs through the clue-discovery flow',
      (tester) async {
    await pumpLocalizedTestPage(
      tester,
      const V2MicroLessonPage(
        settings: AppSettings(
          appLanguage: AppLanguage.en,
          meaningLanguage: ContentLanguage.en,
          showTransliteration: true,
        ),
        lesson: lesson10ArabicGivesYouAClueTaMarbutaPreviewLesson,
      ),
    );

    expect(find.text('Arabic Gives You a Clue: ة'), findsWidgets);
    expect(find.text('سيارة'), findsWidgets);

    await tester.tap(find.widgetWithText(OutlinedButton, 'ة').first);
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await pumpForTransition(tester);

    await tester.tap(find.widgetWithText(OutlinedButton, 'كلمة').first);
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await pumpForTransition(tester);

    await tester.tap(find.widgetWithText(OutlinedButton, 'سيارة').first);
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await pumpForTransition(tester);

    await tester.tap(find.widgetWithText(OutlinedButton, 'car').first);
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await pumpForTransition(tester);

    await tester.enterText(find.byType(TextField), 'سيارة');
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Check Answer'));
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await pumpForTransition(tester);

    await tester.tap(find.widgetWithText(ActionChip, 'سيار'));
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(ActionChip, 'ة'));
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Check Answer'));
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await pumpForTransition(tester);

    expect(find.byType(V2MicroLessonCompletionPage), findsOneWidget);
    expect(find.text('Lesson Complete'), findsOneWidget);
    expect(find.textContaining('helpful clue'), findsWidgets);
  });
}



