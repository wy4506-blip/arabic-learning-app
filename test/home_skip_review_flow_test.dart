import 'package:flutter_test/flutter_test.dart';

import 'package:arabic_learning_app/features/onboarding/models/onboarding_state.dart';
import 'package:arabic_learning_app/pages/home_page.dart';
import 'package:arabic_learning_app/pages/lesson_detail_page.dart';
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
      'alphabet stage completion naturally hands off to the first lesson', (
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
        'alphabet_progress_viewed_letters_v1': allLetters,
        'alphabet_progress_listen_letters_v1': allLetters,
        'alphabet_progress_write_letters_v1': allLetters,
      },
    );

    expect(find.text('Start Lesson 1'), findsOneWidget);
    expect(find.text('Start Formal Review'), findsNothing);

    await tester.tap(find.text('Start Lesson 1').first);
    await tester.pumpAndSettle();

    expect(find.byType(LessonDetailPage), findsOneWidget);
  });
}
