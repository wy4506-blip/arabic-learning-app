import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arabic_learning_app/data/v2_micro_lessons.dart';
import 'package:arabic_learning_app/features/onboarding/models/onboarding_state.dart';
import 'package:arabic_learning_app/models/app_settings.dart';
import 'package:arabic_learning_app/models/learning_state_models.dart';
import 'package:arabic_learning_app/pages/home_page.dart';
import 'package:arabic_learning_app/services/learning_state_service.dart';
import 'package:arabic_learning_app/services/lesson_progress_service.dart';
import 'package:arabic_learning_app/services/review_sync_service.dart';

import 'test_helpers.dart';

class V2HomeTabShell extends StatefulWidget {
  final AppSettings settings;
  final OnboardingState onboardingState;

  const V2HomeTabShell({
    super.key,
    required this.settings,
    required this.onboardingState,
  });

  @override
  State<V2HomeTabShell> createState() => _V2HomeTabShellState();
}

class _V2HomeTabShellState extends State<V2HomeTabShell> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    if (_currentTab == 0) {
      return HomePage(
        settings: widget.settings,
        onboardingState: widget.onboardingState,
        onOpenTab: (index) {
          setState(() => _currentTab = index);
        },
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _currentTab == 1
                    ? (widget.settings.appLanguage == AppLanguage.en
                        ? 'Learning Path Tab'
                        : '学习路径 Tab')
                    : (widget.settings.appLanguage == AppLanguage.en
                        ? 'Other Tab'
                        : '其他 Tab'),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => setState(() => _currentTab = 0),
                child: Text(
                  widget.settings.appLanguage == AppLanguage.en
                      ? 'Back Home'
                      : '返回首页',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const v2CompletedOnboarding = OnboardingState(
  hasSeenWelcome: true,
  hasCompletedFirstExperience: true,
  firstExperienceStep: 3,
  firstLaunchDate: '2026-03-13',
  hasEnteredHomeAfterFirstExperience: true,
);

List<String>? _cachedAllAlphabetLetters;

Future<List<String>> getCachedAllAlphabetLetters() async {
  if (_cachedAllAlphabetLetters != null) {
    return _cachedAllAlphabetLetters!;
  }
  _cachedAllAlphabetLetters = await loadAllAlphabetLetters();
  return _cachedAllAlphabetLetters!;
}

Future<void> resetV2HomeFlowState() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  await LessonProgressService.debugClearAll();
  await LearningStateService.saveAllStates(
    const <LearningContentState>[],
    notify: false,
  );
  await LearningStateService.saveAllPracticeStates(
    const <LearningPracticeState>[],
    notify: false,
  );
  ReviewSyncService.lastReason = ReviewSyncReason.manual;
  ReviewSyncService.lastUpdatedAt = null;
  ReviewSyncService.changes.value = 0;
}

Future<void> pumpV2Home(
  WidgetTester tester, {
  AppSettings settings = kEnglishTestSettings,
  Map<String, Object> sharedPreferences = const <String, Object>{},
}) async {
  final allLetters = await getCachedAllAlphabetLetters();
  await pumpLocalizedTestPage(
    tester,
    HomePage(
      settings: settings,
      onboardingState: v2CompletedOnboarding,
      onOpenTab: (_) {},
    ),
    settings: settings,
    sharedPreferences: completedAlphabetProgressPrefs(
      allLetters,
      extra: <String, Object>{
        'v2_lesson_progress_records_v1': '[]',
        'learning_content_states_v1': '[]',
        'learning_practice_states_v1': '[]',
        ...sharedPreferences,
      },
    ),
  );
}

Future<void> pumpV2HomeShell(
  WidgetTester tester, {
  AppSettings settings = kEnglishTestSettings,
  Map<String, Object> sharedPreferences = const <String, Object>{},
}) async {
  final allLetters = await getCachedAllAlphabetLetters();
  await pumpLocalizedTestPage(
    tester,
    V2HomeTabShell(
      settings: settings,
      onboardingState: v2CompletedOnboarding,
    ),
    settings: settings,
    sharedPreferences: completedAlphabetProgressPrefs(
      allLetters,
      extra: <String, Object>{
        'v2_lesson_progress_records_v1': '[]',
        'learning_content_states_v1': '[]',
        'learning_practice_states_v1': '[]',
        ...sharedPreferences,
      },
    ),
  );
}

Future<void> pumpReviewFlowLaunch(WidgetTester tester) async {
  await pumpUntilLoaded(tester);
  await pumpForTransition(tester);
}

Future<void> pumpForTransition(
  WidgetTester tester, {
  int maxTicks = 30,
  Duration step = const Duration(milliseconds: 120),
}) async {
  for (var index = 0; index < maxTicks; index += 1) {
    await tester.pump(step);
    if (!tester.binding.hasScheduledFrame) {
      break;
    }
  }
}

Future<void> completeAlphabetClosureLesson(
  WidgetTester tester, {
  required AppLanguage language,
}) async {
  final lesson = v2PilotMicroLessons.firstWhere(
    (item) => item.lessonId == 'V2-ALPHA-CL-01',
  );
  final continueLabel = language == AppLanguage.en ? 'Continue' : '继续';
  final finalAnswer =
      (lesson.practiceItems.last.expectedAnswer ??
              lesson.practiceItems.last.arabicText ??
              '')
          .trim();

  await tester.tap(find.widgetWithText(OutlinedButton, 'ث'));
  await pumpForTransition(tester);
  await tester.tap(find.widgetWithText(FilledButton, continueLabel));
  await pumpForTransition(tester);

  await tester.tap(find.widgetWithText(OutlinedButton, 'ذ'));
  await pumpForTransition(tester);
  await tester.tap(find.widgetWithText(FilledButton, continueLabel));
  await pumpForTransition(tester);

  await tester.enterText(find.byType(TextField), finalAnswer);
  await pumpForTransition(tester);
  await tester.tap(find.byType(FilledButton).first);
  await pumpForTransition(tester);
  await tester.tap(find.widgetWithText(FilledButton, continueLabel));
  await pumpForTransition(tester);
}
