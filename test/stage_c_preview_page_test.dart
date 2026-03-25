import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arabic_learning_app/pages/profile_page.dart';
import 'package:arabic_learning_app/pages/v2_micro_lesson_page.dart';
import 'package:arabic_learning_app/pages/v2_stage_c_preview_page.dart';

import 'test_helpers.dart';
import 'v2_home_flow_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'profile stage C preview opens the chapter page and launches lesson 9 then lesson 10',
    (tester) async {
      await pumpLocalizedTestPage(
        tester,
        ProfilePage(
          settings: kEnglishTestSettings,
          onSettingsChanged: (_) {},
        ),
      );

      final previewEntry = find.text('Preview Stage C Chapter');
      await tester.scrollUntilVisible(
        previewEntry,
        240,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(previewEntry);
      await pumpForTransition(tester);

      expect(find.byType(V2StageCPreviewPage), findsOneWidget);
      expect(find.text('Stage C Preview'), findsOneWidget);
      expect(find.text('Pattern Growth Chapter'), findsOneWidget);
      expect(find.text('بيت Means House'), findsOneWidget);
      expect(find.text('You Can Read a Tiny Arabic Card'), findsOneWidget);

      await tester.tap(
        find.byKey(
          const ValueKey<String>(
            'open_stage_c_preview_lesson_09_bayt_make_it_stick',
          ),
        ),
      );
      await pumpForTransition(tester);

      expect(find.byType(V2MicroLessonPage), findsOneWidget);
      expect(find.text('بيت Means House'), findsWidgets);
      expect(find.text('Lesson 9 of 12'), findsOneWidget);
      expect(find.text('Back to Chapter'), findsOneWidget);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Next Lesson'));
      await pumpForTransition(tester);

      expect(find.byType(V2MicroLessonPage), findsOneWidget);
      expect(find.text('Arabic Gives You a Clue: ة'), findsWidgets);
      expect(find.text('Lesson 10 of 12'), findsOneWidget);
    },
  );

  testWidgets(
    'stage C quick jump keeps lessons 10 and 11 framed as clue lessons',
    (tester) async {
      await pumpLocalizedTestPage(
        tester,
        ProfilePage(
          settings: kEnglishTestSettings,
          onSettingsChanged: (_) {},
        ),
      );

      final previewEntry = find.text('Preview Stage C Chapter');
      await tester.scrollUntilVisible(
        previewEntry,
        240,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(previewEntry);
      await pumpForTransition(tester);

      expect(find.text('Find one page clue'), findsWidgets);
      expect(find.text('Find a quantity clue in one tiny pair'), findsWidgets);

      await tester.tap(
        find.byKey(
          const ValueKey<String>(
            'stage_c_quick_jump_lesson_10_arabic_gives_you_a_clue_ta_marbuta',
          ),
        ),
      );
      await pumpForTransition(tester);

      expect(find.byType(V2MicroLessonPage), findsOneWidget);
      expect(find.text('Arabic Gives You a Clue: ة'), findsWidgets);
      expect(find.text('Lesson 10 of 12'), findsOneWidget);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Back to Chapter'));
      await pumpForTransition(tester);

      expect(find.byType(V2StageCPreviewPage), findsOneWidget);

      await tester.tap(
        find.byKey(
          const ValueKey<String>(
            'stage_c_quick_jump_lesson_11_one_or_more_another_arabic_clue',
          ),
        ),
      );
      await pumpForTransition(tester);

      expect(find.byType(V2MicroLessonPage), findsOneWidget);
      expect(find.text('One Or More? A Tiny Arabic Clue'), findsWidgets);
      expect(find.text('Lesson 11 of 12'), findsOneWidget);
    },
  );

  testWidgets(
    'stage C quick jump opens lesson 12 and returns to chapter',
    (tester) async {
      await pumpLocalizedTestPage(
        tester,
        ProfilePage(
          settings: kEnglishTestSettings,
          onSettingsChanged: (_) {},
        ),
      );

      final previewEntry = find.text('Preview Stage C Chapter');
      await tester.scrollUntilVisible(
        previewEntry,
        240,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(previewEntry);
      await pumpForTransition(tester);

      expect(find.byType(V2StageCPreviewPage), findsOneWidget);

      await tester.tap(
        find.byKey(
          const ValueKey<String>(
            'stage_c_quick_jump_lesson_12_you_can_read_a_tiny_arabic_card',
          ),
        ),
      );
      await pumpForTransition(tester);

      expect(find.byType(V2MicroLessonPage), findsOneWidget);
      expect(find.text('You Can Read a Tiny Arabic Card'), findsWidgets);
      expect(find.text('Lesson 12 of 12'), findsOneWidget);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Back to Chapter'));
      await pumpForTransition(tester);

      expect(find.byType(V2StageCPreviewPage), findsOneWidget);
      expect(find.text('Stage C Preview'), findsOneWidget);
    },
  );
}
