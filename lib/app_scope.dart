import 'package:flutter/material.dart';

import 'l10n/app_strings.dart';
import 'models/app_settings.dart';

class AppSettingsScope extends InheritedWidget {
  final AppSettings settings;
  final ValueChanged<AppSettings> onSettingsChanged;

  const AppSettingsScope({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
    required super.child,
  });

  static AppSettingsScope of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppSettingsScope>();
    assert(scope != null, 'AppSettingsScope not found in widget tree.');
    return scope!;
  }

  static AppSettingsScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppSettingsScope>();
  }

  @override
  bool updateShouldNotify(AppSettingsScope oldWidget) {
    return oldWidget.settings != settings;
  }
}

extension AppScopeContext on BuildContext {
  AppSettings get appSettings {
    return AppSettingsScope.of(this).settings;
  }

  AppStrings get strings {
    final scope = AppSettingsScope.maybeOf(this);
    return AppStrings(scope?.settings.appLanguage ?? AppLanguage.zh);
  }

  void updateAppSettings(AppSettings settings) {
    AppSettingsScope.of(this).onSettingsChanged(settings);
  }
}
