import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arabic_learning_app/pages/profile_page.dart';
import 'package:arabic_learning_app/pages/v2_micro_lesson_completion_page.dart';
import 'package:arabic_learning_app/pages/v2_micro_lesson_page.dart';
import 'package:arabic_learning_app/pages/v2_stage_b_preview_page.dart';

import 'test_helpers.dart';
import 'v2_home_flow_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'profile stage B preview opens the chapter page and launches lesson 5 then lesson 6',
    (tester) async {
      await pumpLocalizedTestPage(
        tester,
        ProfilePage(
          settings: kEnglishTestSettings,
          onSettingsChanged: (_) {},
        ),
      );

      final previewEntry = find.text('Preview Stage B Chapter');
      await tester.scrollUntilVisible(
        previewEntry,
        240,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(previewEntry);
      await pumpForTransition(tester);

      expect(find.byType(V2StageBPreviewPage), findsOneWidget);
      expect(find.text('Stage B Preview'), findsOneWidget);
      expect(find.text('Usable Arabic Chapter'), findsOneWidget);
      expect(find.text('One More Real Word: قلم'), findsOneWidget);
      expect(find.text('Your First Usable Arabic Pack'), findsOneWidget);

      await tester.tap(
        find.byKey(
          const ValueKey<String>(
            'open_stage_b_preview_lesson_05_qalam_first_real_word_extension',
          ),
        ),
      );
      await pumpForTransition(tester);

      expect(find.byType(V2MicroLessonPage), findsOneWidget);
      expect(find.text('One More Real Word: قلم'), findsWidgets);
      expect(find.text('Lesson 5 of 8'), findsOneWidget);
      expect(find.text('Back to Chapter'), findsOneWidget);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Next Lesson'));
      await pumpForTransition(tester);

      expect(find.byType(V2MicroLessonPage), findsOneWidget);
      expect(find.text('This Is... Your First Fixed Expression'), findsWidgets);
      expect(find.text('Lesson 6 of 8'), findsOneWidget);
    },
  );

  testWidgets(
    'stage B quick jump opens lesson 8 and returns to chapter',
    (tester) async {
      await pumpLocalizedTestPage(
        tester,
        ProfilePage(
          settings: kEnglishTestSettings,
          onSettingsChanged: (_) {},
        ),
      );

      final previewEntry = find.text('Preview Stage B Chapter');
      await tester.scrollUntilVisible(
        previewEntry,
        240,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(previewEntry);
      await pumpForTransition(tester);

      expect(find.byType(V2StageBPreviewPage), findsOneWidget);

      await tester.tap(
        find.byKey(
          const ValueKey<String>(
            'stage_b_quick_jump_lesson_08_first_usable_arabic_pack',
          ),
        ),
      );
      await pumpForTransition(tester);

      expect(find.byType(V2MicroLessonPage), findsOneWidget);
      expect(find.text('Your First Usable Arabic Pack'), findsWidgets);
      expect(find.text('Lesson 8 of 8'), findsOneWidget);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Back to Chapter'));
      await pumpForTransition(tester);

      expect(find.byType(V2StageBPreviewPage), findsOneWidget);
      expect(find.text('Stage B Preview'), findsOneWidget);
    },
  );

  testWidgets(
    'lesson 5 can complete from the stage B chapter and returns to chapter',
    (tester) async {
      await pumpLocalizedTestPage(
        tester,
        ProfilePage(
          settings: kEnglishTestSettings,
          onSettingsChanged: (_) {},
        ),
      );

      final previewEntry = find.text('Preview Stage B Chapter');
      await tester.scrollUntilVisible(
        previewEntry,
        240,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(previewEntry);
      await pumpForTransition(tester);

      await tester.tap(
        find.byKey(
          const ValueKey<String>(
            'open_stage_b_preview_lesson_05_qalam_first_real_word_extension',
          ),
        ),
      );
      await pumpForTransition(tester);

      await tester.tap(find.widgetWithText(OutlinedButton, 'pen').first);
      await pumpForTransition(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
      await pumpForTransition(tester);

      await tester.tap(find.widgetWithText(OutlinedButton, 'قلم').first);
      await pumpForTransition(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
      await pumpForTransition(tester);

      await tester.tap(find.widgetWithText(OutlinedButton, 'قلم').first);
      await pumpForTransition(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
      await pumpForTransition(tester);

      await tester.enterText(find.byType(TextField), 'قلم');
      await pumpForTransition(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Check Answer'));
      await pumpForTransition(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
      await pumpForTransition(tester);

      await tester.enterText(find.byType(TextField), 'قلم');
      await pumpForTransition(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Check Answer'));
      await pumpForTransition(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
      await pumpForTransition(tester);

      expect(find.byType(V2MicroLessonCompletionPage), findsOneWidget);
      expect(find.text('Lesson Complete'), findsOneWidget);
      expect(find.text('Stage B progress'), findsOneWidget);
      expect(find.textContaining('pen'), findsWidgets);

      await tester.tap(find.widgetWithText(FilledButton, 'Back to Chapter'));
      await pumpForTransition(tester);

      expect(find.byType(V2StageBPreviewPage), findsOneWidget);
      expect(find.text('Stage B Preview'), findsOneWidget);
    },
  );
}
