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

  const lesson = lesson9BaytMakeItStickPreviewLesson;
  const requiredFlow = <String>[
    'recognize_bayt_meaning',
    'choose_bayt_from_pack',
    'hear_bayt_and_tap',
    'recognize_bayt_note',
    'recall_bayt_from_house',
    'say_bayt_once',
  ];

  test('lesson 9 keeps one real-word objective with recall-bearing evidence', () {
    expect(lesson.lessonId, 'lesson_09_bayt_make_it_stick');
    expect(lesson.objectives, hasLength(1));
    expect(
      lesson.practiceItems.map((item) => item.itemId).toList(growable: false),
      requiredFlow,
    );
    expect(lesson.completionRule.requiredPracticeItemIds, <String>[
      'recognize_bayt_meaning',
      'choose_bayt_from_pack',
      'hear_bayt_and_tap',
      'recognize_bayt_note',
      'recall_bayt_from_house',
    ]);
    expect(lesson.practiceItems.last.type, V2MicroPracticeType.speakResponse);
    expect(lesson.reviewSeedRules.map((rule) => rule.ruleId), <String>[
      'word_meaning_recall_bayt',
      'audio_to_word_bayt',
      'pack_contrast_bayt_vs_kitab_bab_qalam',
      'word_note_bayt_singular',
      'supported_rebuild_bayt',
    ]);
  });

  test('lesson 9 weak preview completion creates the expected review stack',
      () async {
    final result = await V2MicroLessonCompletionOrchestrator.completePreviewLesson(
      lesson: lesson,
      practiceOutcomes: const <V2MicroPracticeOutcome>[
        V2MicroPracticeOutcome(itemId: 'recognize_bayt_meaning', passed: true),
        V2MicroPracticeOutcome(itemId: 'choose_bayt_from_pack', passed: false),
        V2MicroPracticeOutcome(itemId: 'hear_bayt_and_tap', passed: false),
        V2MicroPracticeOutcome(itemId: 'recognize_bayt_note', passed: false),
        V2MicroPracticeOutcome(itemId: 'recall_bayt_from_house', passed: false),
        V2MicroPracticeOutcome(itemId: 'say_bayt_once', passed: false),
      ],
    );

    expect(result.currentStatus, V2CanonicalLessonStatus.coreCompleted);
    expect(result.createdReviewSeeds.map((seed) => seed.itemRefId), <String>[
      'word_meaning_recall_bayt',
      'audio_to_word_bayt',
      'pack_contrast_bayt_vs_kitab_bab_qalam',
      'word_note_bayt_singular',
      'supported_rebuild_bayt',
    ]);
    expect(
      result.recommendedAction.actionType,
      V2RecommendedActionType.startReview,
    );
  });

  testWidgets('lesson 9 preview lesson runs through the new-word flow',
      (tester) async {
    await pumpLocalizedTestPage(
      tester,
      const V2MicroLessonPage(
        settings: AppSettings(
          appLanguage: AppLanguage.en,
          meaningLanguage: ContentLanguage.en,
          showTransliteration: true,
        ),
        lesson: lesson9BaytMakeItStickPreviewLesson,
      ),
    );

    expect(find.text('بيت Means House'), findsWidgets);
    expect(find.text('house'), findsWidgets);

    await tester.tap(find.widgetWithText(OutlinedButton, 'house').first);
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await pumpForTransition(tester);

    await tester.tap(find.widgetWithText(OutlinedButton, 'بيت').first);
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await pumpForTransition(tester);

    await tester.tap(find.widgetWithText(OutlinedButton, 'بيت').first);
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await pumpForTransition(tester);

    await tester.tap(find.widgetWithText(OutlinedButton, 'one house').first);
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await pumpForTransition(tester);

    await tester.enterText(find.byType(TextField), 'بيت');
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
    expect(find.textContaining('house'), findsWidgets);
  });
}

