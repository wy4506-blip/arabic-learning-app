import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arabic_learning_app/features/onboarding/models/onboarding_state.dart';
import 'package:arabic_learning_app/models/learning_state_models.dart';
import 'package:arabic_learning_app/models/review_models.dart';
import 'package:arabic_learning_app/models/v2_lesson_progress_models.dart';
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

  testWidgets('home prioritizes formal review when due items exist', (
    tester,
  ) async {
    final allLetters = <String>[
      'ا',
      'ب',
      'ت',
      'ث',
      'ج',
      'ح',
      'خ',
      'د',
      'ذ',
      'ر',
      'ز',
      'س',
      'ش',
      'ص',
      'ض',
      'ط',
      'ظ',
      'ع',
      'غ',
      'ف',
      'ق',
      'ك',
      'ل',
      'م',
      'ن',
      'ه',
      'و',
      'ي',
    ];

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
        'v2_lesson_progress_records_v1': jsonEncode(
          <Map<String, dynamic>>[
            V2LessonProgressRecord(
              lessonId: 'U1L1',
              status: V2LessonStatus.completed,
            ).toJson(),
          ],
        ),
        'learning_content_states_v1': jsonEncode(
          <Map<String, dynamic>>[
            LearningContentState(
              contentId: 'word:due-item',
              type: ReviewContentType.word,
              objectType: ReviewObjectType.wordReading,
              lessonId: 'U1L1',
              isStarted: true,
              isCompleted: true,
              needsReview: true,
              isWeak: false,
              isFavorited: false,
              reviewPriority: 3,
              stage: LearningStage.reviewDue,
            ).toJson(),
          ],
        ),
      },
    );

    expect(find.widgetWithText(FilledButton, 'Start Pilot Review'),
        findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Start Warm-Up'), findsNothing);
  });
}
