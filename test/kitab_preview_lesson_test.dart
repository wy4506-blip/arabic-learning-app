import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arabic_learning_app/data/generated_preview_lessons.dart';
import 'package:arabic_learning_app/models/app_settings.dart';
import 'package:arabic_learning_app/pages/profile_page.dart';
import 'package:arabic_learning_app/pages/v2_micro_lesson_completion_page.dart';
import 'package:arabic_learning_app/pages/v2_micro_lesson_page.dart';

import 'test_helpers.dart';
import 'v2_home_flow_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'profile preview opens the generated kitab lesson and returns to profile after completion',
      (tester) async {
    await pumpLocalizedTestPage(
      tester,
      ProfilePage(
        settings: kEnglishTestSettings,
        onSettingsChanged: (_) {},
      ),
    );

    final previewEntry = find.text('Preview Generated Lesson');
    await tester.scrollUntilVisible(
      previewEntry,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(previewEntry);
    await pumpForTransition(tester);

    expect(find.byType(V2MicroLessonPage), findsOneWidget);
    expect(find.text('Preview Lesson'), findsOneWidget);
    expect(find.text('Preview: كتاب means "book"'), findsWidgets);

    await tester.tap(find.widgetWithText(OutlinedButton, 'كتاب').first);
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await pumpForTransition(tester);

    await tester.tap(find.widgetWithText(OutlinedButton, 'كتاب').first);
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await pumpForTransition(tester);

    await tester.enterText(find.byType(TextField), 'كتاب');
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Check Answer'));
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await pumpForTransition(tester);

    await tester.enterText(find.byType(TextField), 'كتاب');
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Check Answer'));
    await pumpForTransition(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await pumpForTransition(tester);

    expect(find.byType(V2MicroLessonCompletionPage), findsOneWidget);
    expect(find.text('Lesson Complete'), findsOneWidget);
    expect(
      find.textContaining('local preview run'),
      findsOneWidget,
    );
    expect(find.widgetWithText(FilledButton, 'Back to Profile'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Back to Profile'));
    await pumpForTransition(tester);

    expect(find.byType(ProfilePage), findsOneWidget);
    expect(find.text('Preview Generated Lesson'), findsOneWidget);
  });

  testWidgets('direct kitab preview lesson surfaces the beginner word flow',
      (tester) async {
    await pumpLocalizedTestPage(
      tester,
      const V2MicroLessonPage(
        settings: AppSettings(
          appLanguage: AppLanguage.en,
          meaningLanguage: ContentLanguage.en,
          showTransliteration: true,
        ),
        lesson: kitabPreviewLesson,
      ),
    );

    expect(find.text('Lesson Goal'), findsOneWidget);
    expect(find.text('Listen First'), findsOneWidget);
    expect(find.text('book'), findsWidgets);
  });
}
