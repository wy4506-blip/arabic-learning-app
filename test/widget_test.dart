import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arabic_learning_app/app.dart';

import 'test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app launches into the main shell after onboarding',
      (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'app_language': 1,
      'app_meaning_language': 1,
      'onboarding_has_seen_welcome': true,
      'onboarding_has_completed_first_experience': true,
      'onboarding_first_experience_step': 3,
    });

    await tester.pumpWidget(const ArabicLearningApp());
    await pumpTestFrames(tester, count: 8);

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Lessons'), findsOneWidget);
    expectNoVisibleChinese(tester);
  });
}
