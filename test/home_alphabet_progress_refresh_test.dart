import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arabic_learning_app/features/onboarding/models/onboarding_state.dart';
import 'package:arabic_learning_app/pages/alphabet_hub_page.dart';
import 'package:arabic_learning_app/pages/alphabet_letter_home_page.dart';
import 'package:arabic_learning_app/pages/home_page.dart';
import 'package:arabic_learning_app/services/alphabet_service.dart';

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
      'home alphabet stats refresh after returning from alphabet learning',
      (tester) async {
    final groups = await AlphabetService.loadAlphabetGroups();
    final firstGroupLetters = groups.first.letters
        .map((letter) => letter.arabic)
        .toList(growable: false);
    final totalGroupCount = groups.length;

    await pumpLocalizedTestPage(
      tester,
      HomePage(
        settings: kEnglishTestSettings,
        onboardingState: completedOnboarding,
        onOpenTab: (_) {},
      ),
      sharedPreferences: const <String, Object>{
        'alphabet_progress_viewed_letters_v1': <String>[],
        'alphabet_progress_listen_letters_v1': <String>[],
        'alphabet_progress_write_letters_v1': <String>[],
      },
    );

    expect(
      collectVisibleText(tester),
      contains('0/$totalGroupCount groups completed'),
    );

    await tester.tap(find.text('Start Alphabet Learning'));
    await tester.pumpAndSettle();

    expect(find.byType(AlphabetLetterHomePage), findsOneWidget);
    expect(find.byType(AlphabetHubPage), findsNothing);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'alphabet_progress_viewed_letters_v1',
      firstGroupLetters,
    );
    await prefs.setStringList(
      'alphabet_progress_listen_letters_v1',
      firstGroupLetters,
    );
    await prefs.setStringList(
      'alphabet_progress_write_letters_v1',
      firstGroupLetters,
    );

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded).first);
    await tester.pumpAndSettle();

    expect(
      collectVisibleText(tester),
      contains('1/$totalGroupCount groups completed'),
    );
  });
}
