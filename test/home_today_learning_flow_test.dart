import 'package:flutter_test/flutter_test.dart';

import 'package:arabic_learning_app/features/onboarding/models/onboarding_state.dart';
import 'package:arabic_learning_app/pages/home_page.dart';

import 'test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const completedOnboarding = OnboardingState(
    hasSeenWelcome: true,
    hasCompletedFirstExperience: true,
    firstExperienceStep: 3,
    firstLaunchDate: '2026-03-13',
    hasEnteredHomeAfterFirstExperience: true,
  );

  testWidgets('home today learning card opens the warm-up flow', (
    tester,
  ) async {
    await pumpLocalizedTestPage(
      tester,
      HomePage(
        settings: kEnglishTestSettings,
        onboardingState: completedOnboarding,
        onOpenTab: (_) {},
      ),
      sharedPreferences: <String, Object>{
        'completed_lessons': <String>['U1L1'],
        'started_lessons': <String>['U1L1'],
        'last_lesson_id': 'U1L1',
      },
    );

    expect(find.text('Start Today\'s Learning'), findsOneWidget);
    expect(find.text('Formal Review Only'), findsOneWidget);
    expect(find.text('Skip Review and Learn'), findsOneWidget);

    await tester.tap(find.text('Start with Formal Review').first);
    await tester.pumpAndSettle();

    expect(find.text('Today\'s Learning'), findsOneWidget);
    expect(find.textContaining('Step 1 / 2'), findsOneWidget);
    expect(find.text('Skip Review'), findsOneWidget);
  });
}
