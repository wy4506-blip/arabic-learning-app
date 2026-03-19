import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arabic_learning_app/data/v2_micro_lessons.dart';
import 'package:arabic_learning_app/models/app_settings.dart';
import 'package:arabic_learning_app/models/v2_lesson_progress_models.dart';
import 'package:arabic_learning_app/pages/home_page.dart';
import 'package:arabic_learning_app/pages/v2_micro_lesson_completion_page.dart';
import 'package:arabic_learning_app/pages/v2_micro_lesson_page.dart';
import 'package:arabic_learning_app/widgets/arabic_text_with_audio.dart';

import 'test_helpers.dart';
import 'v2_home_flow_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await resetV2HomeFlowState().timeout(
      const Duration(seconds: 8),
      onTimeout: () => throw TestFailure('ENTRY timeout at: setUp reset'),
    );
  });

  Future<void> step(
    String label,
    Future<void> Function() action,
  ) async {
    try {
      await action().timeout(
        const Duration(seconds: 8),
        onTimeout: () => throw TestFailure('ENTRY timeout at: $label'),
      );
    } catch (error) {
      throw TestFailure('ENTRY failed at: $label -> $error');
    }
  }

  Future<void> settleTail(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 120));
    await tester.pump(const Duration(milliseconds: 120));
  }

  Map<String, Object> u104ReadyPrefs() {
    final completedLessonIds = <String>[
      'V2-ALPHA-CL-01',
      'V2-BRIDGE-01',
      'V2-U1-01',
      'V2-U1-02',
      'V2-U1-03',
    ];
    return <String, Object>{
      'v2_lesson_progress_records_v1': jsonEncode(
        completedLessonIds
            .map(
              (lessonId) => V2LessonProgressRecord(
                lessonId: lessonId,
                status: V2LessonStatus.completed,
              ).toJson(),
            )
            .toList(growable: false),
      ),
    };
  }

  Future<void> completeU104Lesson(WidgetTester tester) async {
    final lesson = v2PilotMicroLessons.firstWhere(
      (item) => item.lessonId == 'V2-U1-04',
    );
    final hearWhereFrom = lesson.practiceItems.firstWhere(
      (item) => item.itemId == 'hear_where_from',
    );
    final sayFromChina = lesson.practiceItems.firstWhere(
      (item) => item.itemId == 'say_from_china',
    );
    final fullIdentity = lesson.practiceItems.firstWhere(
      (item) => item.itemId == 'full_identity_sentence',
    );

    await tester.tap(
      find.widgetWithText(OutlinedButton, hearWhereFrom.arabicText!),
    );
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await pumpForTransition(tester);

    await tester.enterText(
      find.byType(TextField),
      sayFromChina.expectedAnswer ?? sayFromChina.arabicText!,
    );
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Check Answer'));
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await pumpForTransition(tester);

    await tester.tap(find.byType(ActionChip).last);
    await tester.pump();
    await tester.tap(find.byType(ActionChip).first);
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Check Answer'));
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await pumpForTransition(tester);

    await tester.enterText(
      find.byType(TextField),
      fullIdentity.expectedAnswer ?? fullIdentity.arabicText!,
    );
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Check Answer'));
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await pumpForTransition(tester);
  }

  testWidgets('[en] home card shows the next V2 lesson and enters it directly',
      (tester) async {
    await step('pump V2 home', () => pumpV2Home(tester));

    expect(find.text('V2 Pilot Path'), findsOneWidget);
    expect(find.textContaining('Alphabet Closure: Hear'), findsOneWidget);
    expect(
      find.text('Home now sends you straight into the next real action in the pilot path.'),
      findsOneWidget,
    );
    expect(find.widgetWithText(FilledButton, 'Start This V2 Lesson'), findsOneWidget);
    expect(find.byType(V2MicroLessonPage), findsNothing);

    await step('enter V2 lesson', () async {
      await tester.tap(find.widgetWithText(FilledButton, 'Start This V2 Lesson'));
      await pumpForTransition(tester);
    });

    expect(find.byType(V2MicroLessonPage), findsOneWidget);
    expect(find.textContaining('Alphabet Closure: Hear'), findsWidgets);

    await step(
      'complete alphabet closure lesson',
      () => completeAlphabetClosureLesson(
        tester,
        language: AppLanguage.en,
      ),
    );

    expect(find.byType(V2MicroLessonCompletionPage), findsOneWidget);
    expect(find.text('Lesson Complete'), findsOneWidget);
    expect(find.text('You Can Already Do'), findsOneWidget);
    expect(
      find.textContaining('After this lesson, you can hear and pick out'),
      findsOneWidget,
    );

    await step('return home from completion', () async {
      await tester.tap(find.widgetWithText(FilledButton, 'Back Home'));
      await pumpForTransition(tester);
    });

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Short Vowel Bridge: Hear a / i / u'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Start This V2 Lesson'), findsOneWidget);
    await settleTail(tester);
  });

  testWidgets('[en] direct micro lesson page shows structured content sections',
      (tester) async {
    await step(
      'pump direct U1-03 page',
      () => pumpLocalizedTestPage(
        tester,
        const V2MicroLessonPage(
          lessonId: 'V2-U1-03',
          settings: kEnglishTestSettings,
        ),
      ),
    );

    expect(find.text('Lesson Goal'), findsOneWidget);
    expect(find.text('Listen First'), findsOneWidget);
    expect(find.text('Use This Pattern'), findsOneWidget);
    expect(find.byType(LearningAudioIconButton), findsNWidgets(3));
    await settleTail(tester);
  });

  testWidgets('[en] micro lesson completion returns home with a refreshed next recommendation',
      (tester) async {
    await step('pump V2 home', () => pumpV2Home(tester));

    expect(find.widgetWithText(FilledButton, 'Start This V2 Lesson'), findsOneWidget);

    await step('enter V2 lesson', () async {
      await tester.tap(find.widgetWithText(FilledButton, 'Start This V2 Lesson'));
      await pumpForTransition(tester);
    });

    await step(
      'complete alphabet closure lesson',
      () => completeAlphabetClosureLesson(
        tester,
        language: AppLanguage.en,
      ),
    );

    expect(find.byType(V2MicroLessonCompletionPage), findsOneWidget);
    expect(find.textContaining('Alphabet Closure: Hear'), findsNothing);

    await step('return home from completion', () async {
      await tester.tap(find.widgetWithText(FilledButton, 'Back Home'));
      await pumpForTransition(tester);
    });

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.textContaining('Alphabet Closure: Hear'), findsNothing);
    expect(find.text('Short Vowel Bridge: Hear a / i / u'), findsOneWidget);
    expect(find.text('Continue This V2 Lesson'), findsNothing);
    await settleTail(tester);
  });

  testWidgets('[zh] home card shows the next V2 lesson and enters it directly',
      (tester) async {
    await step(
      'pump Chinese V2 home',
      () => pumpV2Home(
        tester,
        settings: kChineseTestSettings,
      ),
    );

    expect(find.byType(FilledButton), findsWidgets);

    await step('enter Chinese V2 lesson', () async {
      await tester.tap(find.byType(FilledButton).first);
      await pumpForTransition(tester);
    });

    expect(find.byType(V2MicroLessonPage), findsOneWidget);
    await settleTail(tester);
  });

  testWidgets('[zh] micro lesson completion refreshes home recommendation',
      (tester) async {
    await step(
      'pump Chinese V2 home',
      () => pumpV2Home(
        tester,
        settings: kChineseTestSettings,
      ),
    );

    await step('enter Chinese V2 lesson', () async {
      await tester.tap(find.byType(FilledButton).first);
      await pumpForTransition(tester);
    });

    await step(
      'complete Chinese alphabet closure lesson',
      () => completeAlphabetClosureLesson(
        tester,
        language: AppLanguage.zh,
      ),
    );

    expect(find.byType(V2MicroLessonCompletionPage), findsOneWidget);
    expect(find.byType(FilledButton), findsWidgets);

    await step('return home from Chinese completion', () async {
      await tester.tap(find.byType(FilledButton).first);
      await pumpForTransition(tester);
    });

    expect(find.byType(HomePage), findsOneWidget);
    expect(collectVisibleText(tester).contains('V2'), isTrue);
    expect(find.byType(FilledButton), findsWidgets);
    await settleTail(tester);
  });

  testWidgets(
      '[en] typed and arrange micro lesson completion returns home with the next mainline recommendation',
      (tester) async {
    await step(
      'pump V2 home for U1-04',
      () => pumpV2Home(
        tester,
        sharedPreferences: u104ReadyPrefs(),
      ),
    );

    expect(find.text('Introduce Yourself: I Am From China'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Start This V2 Lesson'),
        findsOneWidget);

    await step('enter U1-04 lesson', () async {
      await tester.tap(find.widgetWithText(FilledButton, 'Start This V2 Lesson'));
      await pumpForTransition(tester);
    });

    expect(find.byType(V2MicroLessonPage), findsOneWidget);
    expect(find.text('Introduce Yourself: I Am From China'), findsWidgets);

    await step('complete U1-04 typed and arrange lesson', () async {
      await completeU104Lesson(tester);
    });

    expect(find.byType(V2MicroLessonCompletionPage), findsOneWidget);
    expect(find.text('Lesson Complete'), findsOneWidget);

    await step('return home from U1-04 completion', () async {
      await tester.tap(find.widgetWithText(FilledButton, 'Back Home'));
      await pumpForTransition(tester);
    });

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.textContaining('Classroom Commands'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Start This V2 Lesson'),
        findsOneWidget);
    await settleTail(tester);
  });
}
