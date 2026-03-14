import 'package:flutter/material.dart';

import 'app_scope.dart';
import 'features/onboarding/models/first_experience_content.dart';
import 'features/onboarding/models/onboarding_state.dart';
import 'features/onboarding/pages/first_experience_complete_page.dart';
import 'features/onboarding/pages/first_experience_flow_page.dart';
import 'features/onboarding/pages/welcome_page.dart';
import 'features/onboarding/services/onboarding_storage_service.dart';
import 'l10n/app_strings.dart';
import 'models/app_settings.dart';
import 'pages/app_shell.dart';
import 'services/audio_service.dart';
import 'services/settings_service.dart';
import 'theme/app_theme.dart';

enum _LaunchStage {
  welcome,
  experience,
  complete,
  shell,
}

class ArabicLearningApp extends StatefulWidget {
  const ArabicLearningApp({super.key});

  @override
  State<ArabicLearningApp> createState() => _ArabicLearningAppState();
}

class _ArabicLearningAppState extends State<ArabicLearningApp> {
  AppSettings _settings = const AppSettings();
  OnboardingState _onboarding = const OnboardingState.initial();
  bool _ready = false;
  _LaunchStage _launchStage = _LaunchStage.welcome;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final loaded = await SettingsService.loadSettings();
    var onboarding = await OnboardingStorageService.loadState();
    if (onboarding.firstLaunchDate == null) {
      onboarding = onboarding.copyWith(
        firstLaunchDate: DateTime.now().toIso8601String(),
      );
      await OnboardingStorageService.saveState(onboarding);
    }
    if (!mounted) return;
    setState(() {
      _settings = loaded;
      _onboarding = onboarding;
      _launchStage = _resolveLaunchStage(onboarding);
      _ready = true;
    });
    AudioService.setVoicePreference(loaded.voicePreference);
  }

  Future<void> _updateSettings(AppSettings settings) async {
    await SettingsService.saveSettings(settings);
    AudioService.setVoicePreference(settings.voicePreference);
    if (!mounted) return;
    setState(() => _settings = settings);
  }

  Future<void> _updateOnboarding(
    OnboardingState state, {
    _LaunchStage? launchStage,
  }) async {
    await OnboardingStorageService.saveState(state);
    if (!mounted) return;
    setState(() {
      _onboarding = state;
      _launchStage = launchStage ?? _resolveLaunchStage(state);
    });
  }

  _LaunchStage _resolveLaunchStage(OnboardingState state) {
    if (state.hasCompletedFirstExperience) {
      return _LaunchStage.shell;
    }
    if (state.hasSeenWelcome) {
      return _LaunchStage.experience;
    }
    return _LaunchStage.welcome;
  }

  Future<void> _handleWelcomeStart() async {
    await _updateOnboarding(
      _onboarding.copyWith(
        hasSeenWelcome: true,
        firstExperienceStep: _onboarding.firstExperienceStep == 0
            ? 1
            : _onboarding.firstExperienceStep,
      ),
      launchStage: _LaunchStage.experience,
    );
  }

  Future<void> _handleWelcomeHome() async {
    await _updateOnboarding(
      _onboarding.copyWith(hasSeenWelcome: true),
      launchStage: _LaunchStage.shell,
    );
  }

  Future<void> _handleExperienceStepChanged(int step) async {
    if (_onboarding.firstExperienceStep == step) {
      return;
    }
    await _updateOnboarding(
      _onboarding.copyWith(
        hasSeenWelcome: true,
        firstExperienceStep: step,
      ),
      launchStage: _LaunchStage.experience,
    );
  }

  Future<void> _handleExperienceCompleted() async {
    await _updateOnboarding(
      _onboarding.copyWith(
        hasSeenWelcome: true,
        hasCompletedFirstExperience: true,
        firstExperienceStep: 3,
      ),
      launchStage: _LaunchStage.complete,
    );
  }

  Future<void> _handleEnterHomeAfterExperience() async {
    await _updateOnboarding(
      _onboarding.copyWith(hasEnteredHomeAfterFirstExperience: true),
      launchStage: _LaunchStage.shell,
    );
  }

  Widget _buildHome() {
    switch (_launchStage) {
      case _LaunchStage.welcome:
        return WelcomePage(
          onStartLearning: _handleWelcomeStart,
          onGoHome: _handleWelcomeHome,
        );
      case _LaunchStage.experience:
        return FirstExperienceFlowPage(
          content: kFirstExperienceContent,
          initialStep: _onboarding.resumeStep,
          onStepChanged: _handleExperienceStepChanged,
          onCompleted: _handleExperienceCompleted,
          onGoHome: _handleWelcomeHome,
        );
      case _LaunchStage.complete:
        return FirstExperienceCompletePage(
          onContinueLearning: _handleEnterHomeAfterExperience,
          onGoHome: _handleEnterHomeAfterExperience,
        );
      case _LaunchStage.shell:
        return AppShell(
          settings: _settings,
          onSettingsChanged: _updateSettings,
          onboardingState: _onboarding,
        );
    }
  }

  ThemeMode get _themeMode {
    switch (_settings.themePreference) {
      case AppThemePreference.light:
        return ThemeMode.light;
      case AppThemePreference.dark:
        return ThemeMode.dark;
      case AppThemePreference.system:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appStrings = AppStrings(_settings.appLanguage);

    return AppSettingsScope(
      settings: _settings,
      onSettingsChanged: _updateSettings,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: appStrings.t('app.name'),
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _themeMode,
        home: _ready
            ? _buildHome()
            : const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
    );
  }
}
