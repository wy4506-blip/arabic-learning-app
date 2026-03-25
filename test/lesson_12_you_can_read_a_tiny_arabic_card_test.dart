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

  const lesson = lesson12YouCanReadATinyArabicCardPreviewLesson;
  const requiredFlow = <String>[
    'hear_bayt_on_tiny_card',
    'main_meaning_house_on_tiny_card',
    'spot_clue_item_on_tiny_card',
    'spot_more_than_one_on_tiny_card',
    'rebuild_tiny_card_order',
    'recall_house_from_tiny_card',
  ];

  test('lesson 12 keeps one tiny-card objective with multi-skill evidence', () {
    expect(lesson.lessonId, 'lesson_12_you_can_read_a_tiny_arabic_card');
    expect(lesson.objectives, hasLength(1));
    expect(
      lesson.practiceItems.map((item) => item.itemId).toList(growable: false),
      requiredFlow,
    );
    expect(lesson.completionRule.requiredPracticeItemIds, requiredFlow);
    expect(lesson.practiceItems[0].type, V2MicroPracticeType.listenTap);
    expect(lesson.practiceItems[4].type, V2MicroPracticeType.arrangeResponse);
    expect(lesson.reviewSeedRules.map((rule) => rule.ruleId), <String>[
      'tiny_card_order_instability',
      'supported_card_house_bayt',
      'supported_card_audio_bayt',
      'supported_card_clue_item_sayyara',
      'supported_card_more_than_one_sayyaraat',
      'supported_card_anchor_pack',
    ]);

    final tinyCard = lesson.contentItems.firstWhere(
      (item) => item.itemId == 'input_tiny_supported_card',
    );
    expect(tinyCard.arabicText, contains('كتاب'));
    expect(tinyCard.arabicText, contains('بيت'));
    expect(tinyCard.arabicText, contains('سيارات'));
    expect(lesson.practiceItems[4].expectedAnswer, 'كتاب قلم بيت سيارة سيارات');
  });

  test('lesson 12 weak preview completion creates the expected supported-card review stack',
      () async {
    final result = await V2MicroLessonCompletionOrchestrator.completePreviewLesson(
      lesson: lesson,
      practiceOutcomes: const <V2MicroPracticeOutcome>[
        V2MicroPracticeOutcome(itemId: 'hear_bayt_on_tiny_card', passed: false),
        V2MicroPracticeOutcome(itemId: 'main_meaning_house_on_tiny_card', passed: true),
        V2MicroPracticeOutcome(itemId: 'spot_clue_item_on_tiny_card', passed: false),
        V2MicroPracticeOutcome(itemId: 'spot_more_than_one_on_tiny_card', passed: false),
        V2MicroPracticeOutcome(itemId: 'rebuild_tiny_card_order', passed: false),
        V2MicroPracticeOutcome(itemId: 'recall_house_from_tiny_card', passed: false),
      ],
    );

    expect(result.currentStatus, V2CanonicalLessonStatus.coreCompleted);
    expect(result.createdReviewSeeds.map((seed) => seed.itemRefId), <String>[
      'tiny_card_order_instability',
      'supported_card_house_bayt',
      'supported_card_audio_bayt',
      'supported_card_clue_item_sayyara',
      'supported_card_more_than_one_sayyaraat',
      'supported_card_anchor_pack',
    ]);
    expect(
      result.recommendedAction.actionType,
      V2RecommendedActionType.startReview,
    );
  });

  testWidgets('lesson 12 preview lesson ends with a visible Stage C payoff',
      (tester) async {
    await pumpLocalizedTestPage(
      tester,
      const V2MicroLessonPage(
        settings: AppSettings(
          appLanguage: AppLanguage.en,
          meaningLanguage: ContentLanguage.en,
          showTransliteration: true,
        ),
        lesson: lesson12YouCanReadATinyArabicCardPreviewLesson,
      ),
    );

    expect(find.text('You Can Read a Tiny Arabic Card'), findsWidgets);
    expect(find.text('كتاب\nقلم\nبيت\nسيارة\nسيارات'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, 'بيت').first);
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await pumpForTransition(tester);

    await tester.tap(find.widgetWithText(OutlinedButton, 'بيت').first);
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await pumpForTransition(tester);

    await tester.tap(find.widgetWithText(OutlinedButton, 'سيارة').first);
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await pumpForTransition(tester);

    await tester.tap(find.widgetWithText(OutlinedButton, 'سيارات').first);
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await pumpForTransition(tester);

    await tester.tap(find.widgetWithText(ActionChip, 'كتاب'));
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(ActionChip, 'قلم'));
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(ActionChip, 'بيت'));
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(ActionChip, 'سيارة'));
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(ActionChip, 'سيارات'));
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Check Answer'));
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await pumpForTransition(tester);

    await tester.enterText(find.byType(TextField), 'بيت');
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Check Answer'));
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await pumpForTransition(tester);

    expect(find.byType(V2MicroLessonCompletionPage), findsOneWidget);
    expect(find.text('Lesson Complete'), findsOneWidget);
    expect(find.text('Stage C progress'), findsOneWidget);
    expect(find.textContaining('tiny Arabic card'), findsWidgets);
  });
}
