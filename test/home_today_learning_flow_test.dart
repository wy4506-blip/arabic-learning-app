import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arabic_learning_app/features/onboarding/models/onboarding_state.dart';
import 'package:arabic_learning_app/models/learning_state_models.dart';
import 'package:arabic_learning_app/models/review_models.dart';
import 'package:arabic_learning_app/pages/review_session_page.dart';
import 'package:arabic_learning_app/pages/v2_review_entry_page.dart';
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

  testWidgets('home today learning card prioritizes due review first', (
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
        'learning_content_states_v1': jsonEncode(
          <Map<String, dynamic>>[
            LearningContentState(
              contentId: 'word:warmup-item',
              type: ReviewContentType.word,
              objectType: ReviewObjectType.wordReading,
              lessonId: 'V2-U1-01',
              isStarted: true,
              isCompleted: true,
              needsReview: true,
              isWeak: false,
              isFavorited: false,
              reviewPriority: 1,
              stage: LearningStage.reviewDue,
            ).toJson(),
          ],
        ),
      },
    );

    expect(find.widgetWithText(FilledButton, 'Start Pilot Review'),
        findsOneWidget);
    expect(find.text('Start Warm-Up'), findsNothing);
    expect(find.text('Enter Today\'s Lesson'), findsNothing);
    expect(find.text('Continue Alphabet Learning'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Start Pilot Review'));
    await tester.pumpAndSettle();

    final enteredReviewFlow =
        find.byType(V2ReviewEntryPage).evaluate().isNotEmpty ||
            find.byType(ReviewSessionPage).evaluate().isNotEmpty;
    expect(enteredReviewFlow, isTrue);
    expect(find.text('Pilot Review'), findsWidgets);
  });
}
