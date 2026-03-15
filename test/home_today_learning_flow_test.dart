import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arabic_learning_app/features/onboarding/models/onboarding_state.dart';
import 'package:arabic_learning_app/services/alphabet_service.dart';
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
    final groups = await AlphabetService.loadAlphabetGroups();
    final allLetters = groups
        .expand((group) => group.letters)
        .map((letter) => letter.arabic)
        .toList(growable: false);

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
        'alphabet_progress_viewed_letters_v1': allLetters,
        'alphabet_progress_listen_letters_v1': allLetters,
        'alphabet_progress_write_letters_v1': allLetters,
      },
    );

    expect(find.widgetWithText(FilledButton, 'Start Formal Review'),
        findsOneWidget);
    expect(find.text('Enter Today\'s Lesson'), findsNothing);
    expect(find.text('Continue Alphabet Learning'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Start Formal Review'));
    await tester.pumpAndSettle();

    expect(find.text('Today\'s Learning'), findsOneWidget);
    expect(find.textContaining('Step 1 / 2'), findsOneWidget);
    expect(find.text('Skip Review'), findsOneWidget);
  });
}
