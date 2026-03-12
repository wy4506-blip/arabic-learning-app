import 'package:flutter/material.dart';

import 'models/app_settings.dart';
import 'pages/app_shell.dart';
import 'services/settings_service.dart';
import 'theme/app_theme.dart';

class ArabicLearningApp extends StatefulWidget {
  const ArabicLearningApp({super.key});

  @override
  State<ArabicLearningApp> createState() => _ArabicLearningAppState();
}

class _ArabicLearningAppState extends State<ArabicLearningApp> {
  AppSettings _settings = const AppSettings();
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final loaded = await SettingsService.loadSettings();
    if (!mounted) return;
    setState(() {
      _settings = loaded;
      _ready = true;
    });
  }

  Future<void> _updateSettings(AppSettings settings) async {
    await SettingsService.saveSettings(settings);
    if (!mounted) return;
    setState(() => _settings = settings);
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'abaaba',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: _ready
          ? AppShell(
              settings: _settings,
              onSettingsChanged: _updateSettings,
            )
          : const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
