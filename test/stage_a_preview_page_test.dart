import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arabic_learning_app/pages/home_page.dart';
import 'package:arabic_learning_app/pages/profile_page.dart';
import 'package:arabic_learning_app/pages/v2_micro_lesson_page.dart';
import 'package:arabic_learning_app/pages/v2_stage_a_preview_page.dart';

import 'test_helpers.dart';
import 'v2_home_flow_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'profile stage A preview opens the chapter page and launches lesson 1',
    (tester) async {
      await pumpLocalizedTestPage(
        tester,
        ProfilePage(
          settings: kEnglishTestSettings,
          onSettingsChanged: (_) {},
        ),
      );

      final previewEntry = find.text('Preview Stage A Chapter');
      await tester.scrollUntilVisible(
        previewEntry,
        240,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(previewEntry);
      await pumpForTransition(tester);

      expect(find.byType(V2StageAPreviewPage), findsOneWidget);
      expect(find.text('Stage A Preview'), findsOneWidget);
      expect(find.text('Arabic Starts Here'), findsOneWidget);
      expect(find.text('Reading Support For Real Words'), findsOneWidget);

      await tester.tap(
        find.byKey(
          const ValueKey<String>('open_stage_a_preview_V2-A1-01-PREVIEW'),
        ),
      );
      await pumpForTransition(tester);

      expect(find.byType(V2MicroLessonPage), findsOneWidget);
      expect(find.text('Arabic Starts Here'), findsWidgets);
      expect(find.text('Preview Lesson'), findsOneWidget);
      expect(find.text('Lesson 1 of 4'), findsOneWidget);
      expect(find.text('Back to Chapter'), findsOneWidget);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Next Lesson'));
      await pumpForTransition(tester);

      expect(find.byType(V2MicroLessonPage), findsOneWidget);
      expect(find.text('First Real Word Success'), findsWidgets);
      expect(find.text('Lesson 2 of 4'), findsOneWidget);
    },
  );

  testWidgets(
    'home debug preview card opens the stage A preview page',
    (tester) async {
      await pumpV2Home(tester);

      expect(find.byType(HomePage), findsOneWidget);
      expect(find.text('Preview Stage A Chapter'), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey<String>('home_open_stage_a_preview')),
      );
      await pumpForTransition(tester);

      expect(find.byType(V2StageAPreviewPage), findsOneWidget);
      expect(find.text('Stage A Preview'), findsOneWidget);
      expect(find.text('First Chapter'), findsOneWidget);
    },
  );
}
