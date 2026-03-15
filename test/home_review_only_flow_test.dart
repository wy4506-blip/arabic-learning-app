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

  testWidgets(
      'alphabet stage stays as the only home primary recommendation before completion',
      (
    tester,
  ) async {
    await pumpLocalizedTestPage(
      tester,
      HomePage(
        settings: kEnglishTestSettings,
        onboardingState: completedOnboarding,
        onOpenTab: (_) {},
      ),
    );

    expect(find.text('Start Alphabet Learning'), findsOneWidget);
    expect(find.text('Open Alphabet Path'), findsOneWidget);
    expect(find.text('Start Lesson 1'), findsNothing);
    expect(find.text('Start Formal Review'), findsNothing);
  });
}
