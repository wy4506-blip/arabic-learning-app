import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arabic_learning_app/pages/profile_page.dart';
import 'package:arabic_learning_app/pages/v2_foundation_preview_page.dart';
import 'package:arabic_learning_app/pages/v2_stage_b_preview_page.dart';

import 'test_helpers.dart';
import 'v2_home_flow_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'profile foundation preview opens the unified overview',
    (tester) async {
      await pumpLocalizedTestPage(
        tester,
        ProfilePage(
          settings: kEnglishTestSettings,
          onSettingsChanged: (_) {},
        ),
      );

      final previewEntry = find.text('Preview Foundation Path');
      await tester.scrollUntilVisible(
        previewEntry,
        240,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(previewEntry);
      await pumpForTransition(tester);

      expect(find.byType(V2FoundationPreviewPage), findsOneWidget);
      expect(find.text('Foundation Preview'), findsOneWidget);
      expect(find.text('12-Lesson Free Path'), findsOneWidget);
      expect(find.text('Stage A · Lessons 1-4'), findsOneWidget);
      expect(find.text('Stage B · Lessons 5-8'), findsOneWidget);
      expect(find.text('Stage C · Lessons 9-12'), findsOneWidget);
    },
  );

  testWidgets(
    'foundation preview opens Stage B chapter from the unified hub',
    (tester) async {
      await pumpLocalizedTestPage(
        tester,
        ProfilePage(
          settings: kEnglishTestSettings,
          onSettingsChanged: (_) {},
        ),
      );

      final previewEntry = find.text('Preview Foundation Path');
      await tester.scrollUntilVisible(
        previewEntry,
        240,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(previewEntry);
      await pumpForTransition(tester);

      expect(find.byType(V2FoundationPreviewPage), findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey<String>('foundation_open_stage_b')),
      );
      await pumpForTransition(tester);

      expect(find.byType(V2StageBPreviewPage), findsOneWidget);
      expect(find.text('Stage B Preview'), findsOneWidget);
      expect(find.text('Usable Arabic Chapter'), findsOneWidget);
    },
  );
}
