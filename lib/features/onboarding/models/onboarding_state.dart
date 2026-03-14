class OnboardingState {
  final bool hasSeenWelcome;
  final bool hasCompletedFirstExperience;
  final int firstExperienceStep;
  final String? firstLaunchDate;
  final bool hasEnteredHomeAfterFirstExperience;

  const OnboardingState({
    required this.hasSeenWelcome,
    required this.hasCompletedFirstExperience,
    required this.firstExperienceStep,
    required this.firstLaunchDate,
    required this.hasEnteredHomeAfterFirstExperience,
  });

  const OnboardingState.initial()
      : hasSeenWelcome = false,
        hasCompletedFirstExperience = false,
        firstExperienceStep = 0,
        firstLaunchDate = null,
        hasEnteredHomeAfterFirstExperience = false;

  int get normalizedStep => firstExperienceStep.clamp(0, 3);

  int get resumeStep {
    if (hasCompletedFirstExperience) {
      return 3;
    }
    return normalizedStep == 0 ? 1 : normalizedStep;
  }

  OnboardingState copyWith({
    bool? hasSeenWelcome,
    bool? hasCompletedFirstExperience,
    int? firstExperienceStep,
    String? firstLaunchDate,
    bool clearFirstLaunchDate = false,
    bool? hasEnteredHomeAfterFirstExperience,
  }) {
    return OnboardingState(
      hasSeenWelcome: hasSeenWelcome ?? this.hasSeenWelcome,
      hasCompletedFirstExperience:
          hasCompletedFirstExperience ?? this.hasCompletedFirstExperience,
      firstExperienceStep: firstExperienceStep ?? this.firstExperienceStep,
      firstLaunchDate:
          clearFirstLaunchDate ? null : firstLaunchDate ?? this.firstLaunchDate,
      hasEnteredHomeAfterFirstExperience: hasEnteredHomeAfterFirstExperience ??
          this.hasEnteredHomeAfterFirstExperience,
    );
  }
}
