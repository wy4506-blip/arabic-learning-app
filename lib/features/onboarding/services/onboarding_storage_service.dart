import 'package:shared_preferences/shared_preferences.dart';

import '../models/onboarding_state.dart';

class OnboardingStorageService {
  static const _hasSeenWelcomeKey = 'onboarding_has_seen_welcome';
  static const _hasCompletedFirstExperienceKey =
      'onboarding_has_completed_first_experience';
  static const _firstExperienceStepKey = 'onboarding_first_experience_step';
  static const _firstLaunchDateKey = 'onboarding_first_launch_date';
  static const _hasEnteredHomeAfterFirstExperienceKey =
      'onboarding_has_entered_home_after_first_experience';

  static Future<OnboardingState> loadState() async {
    final prefs = await SharedPreferences.getInstance();
    return OnboardingState(
      hasSeenWelcome: prefs.getBool(_hasSeenWelcomeKey) ?? false,
      hasCompletedFirstExperience:
          prefs.getBool(_hasCompletedFirstExperienceKey) ?? false,
      firstExperienceStep: prefs.getInt(_firstExperienceStepKey) ?? 0,
      firstLaunchDate: prefs.getString(_firstLaunchDateKey),
      hasEnteredHomeAfterFirstExperience:
          prefs.getBool(_hasEnteredHomeAfterFirstExperienceKey) ?? false,
    );
  }

  static Future<void> saveState(OnboardingState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenWelcomeKey, state.hasSeenWelcome);
    await prefs.setBool(
      _hasCompletedFirstExperienceKey,
      state.hasCompletedFirstExperience,
    );
    await prefs.setInt(_firstExperienceStepKey, state.firstExperienceStep);
    final launchDate = state.firstLaunchDate;
    if (launchDate == null || launchDate.isEmpty) {
      await prefs.remove(_firstLaunchDateKey);
    } else {
      await prefs.setString(_firstLaunchDateKey, launchDate);
    }
    await prefs.setBool(
      _hasEnteredHomeAfterFirstExperienceKey,
      state.hasEnteredHomeAfterFirstExperience,
    );
  }
}
