import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arabic_learning_app/pages/v2_foundation_pilot_page.dart';
import 'package:arabic_learning_app/pages/v2_micro_lesson_page.dart';

import 'test_helpers.dart';
import 'v2_home_flow_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await resetV2HomeFlowState();
  });

  testWidgets(
    'home keeps the live V2 pilot when foundation promotion is off',
    (tester) async {
      await pumpV2Home(tester);

      expect(find.text('V2 Pilot Path'), findsOneWidget);
      expect(
        find.textContaining('Alphabet Closure: Hear'),
        findsOneWidget,
      );
      expect(find.text('Pilot progress 0/7'), findsOneWidget);
      expect(
        find.widgetWithText(TextButton, 'See Full Learning Path'),
        findsOneWidget,
      );
      expect(find.text('Foundation Pilot'), findsNothing);
    },
  );

  testWidgets(
    'home can open the controlled foundation pilot when the promotion toggle is enabled',
    (tester) async {
      await pumpV2Home(
        tester,
        settings: kEnglishTestSettings.copyWith(
          homeUsesFoundationPilot: true,
        ),
      );

      expect(find.text('Foundation Pilot'), findsOneWidget);
      expect(find.text('Arabic Starts Here'), findsOneWidget);
      expect(find.text('Foundation progress 0/12'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, 'Open Foundation Pilot'));
      await pumpForTransition(tester);

      expect(find.byType(V2FoundationPilotPage), findsOneWidget);
    },
  );

  testWidgets(
    'home launches the formal foundation lesson flow when the promotion toggle is enabled',
    (tester) async {
      await pumpV2Home(
        tester,
        settings: kEnglishTestSettings.copyWith(
          homeUsesFoundationPilot: true,
        ),
      );

      await tester.tap(
        find.widgetWithText(FilledButton, 'Start This Foundation Lesson'),
      );
      await pumpForTransition(tester);

      expect(find.byType(V2MicroLessonPage), findsOneWidget);
      expect(find.text('Preview Lesson'), findsNothing);
      expect(find.text('Arabic Starts Here'), findsWidgets);
    },
  );
}
