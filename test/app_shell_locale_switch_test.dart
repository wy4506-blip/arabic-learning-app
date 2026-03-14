import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arabic_learning_app/app_scope.dart';
import 'package:arabic_learning_app/features/onboarding/models/onboarding_state.dart';
import 'package:arabic_learning_app/models/app_settings.dart';
import 'package:arabic_learning_app/pages/app_shell.dart';

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

  testWidgets('app shell refreshes localized UI after language switches', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(
      const _LocaleSwitchHarness(onboardingState: completedOnboarding),
    );
    await pumpUntilLoaded(tester);

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Start Here Today'), findsOneWidget);
    expectNoVisibleChinese(tester);

    await tester.tap(find.byKey(const ValueKey('toggle-language')));
    await pumpUntilLoaded(tester);

    expect(find.text('首页'), findsOneWidget);
    expect(find.text('今天从这里开始'), findsOneWidget);
    expectNoVisibleMojibake(tester);

    await tester.tap(find.text('课程'));
    await pumpUntilLoaded(tester);
    expect(find.text('当前推荐单元'), findsOneWidget);

    await tester.tap(find.text('复习'));
    await pumpUntilLoaded(tester);
    expect(find.text('今天的状态'), findsOneWidget);

    await tester.tap(find.text('我的'));
    await pumpUntilLoaded(tester);
    expect(find.text('界面语言'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('toggle-language')));
    await pumpUntilLoaded(tester);

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Profile'), findsWidgets);
    expect(find.text('Interface Language'), findsOneWidget);
    expectNoVisibleChinese(tester);
  });
}

class _LocaleSwitchHarness extends StatefulWidget {
  final OnboardingState onboardingState;

  const _LocaleSwitchHarness({
    required this.onboardingState,
  });

  @override
  State<_LocaleSwitchHarness> createState() => _LocaleSwitchHarnessState();
}

class _LocaleSwitchHarnessState extends State<_LocaleSwitchHarness> {
  AppSettings _settings = kEnglishTestSettings;

  void _toggleLanguage() {
    setState(() {
      final toEnglish = _settings.appLanguage != AppLanguage.en;
      _settings = _settings.copyWith(
        appLanguage: toEnglish ? AppLanguage.en : AppLanguage.zh,
        meaningLanguage: toEnglish ? ContentLanguage.en : ContentLanguage.zh,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppSettingsScope(
      settings: _settings,
      onSettingsChanged: (settings) {
        setState(() => _settings = settings);
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Stack(
          children: [
            AppShell(
              settings: _settings,
              onSettingsChanged: (settings) {
                setState(() => _settings = settings);
              },
              onboardingState: widget.onboardingState,
            ),
            Positioned(
              top: 12,
              right: 12,
              child: TextButton(
                key: const ValueKey('toggle-language'),
                onPressed: _toggleLanguage,
                child: const Text('toggle'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
