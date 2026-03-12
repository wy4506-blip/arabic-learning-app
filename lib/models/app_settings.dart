enum ArabicTextMode { withDiacritics, dual, withoutDiacritics }
enum AppThemePreference { system, light, dark }

class AppSettings {
  final ArabicTextMode textMode;
  final AppThemePreference themePreference;
  final bool reminderEnabled;
  final String reminderTime;

  const AppSettings({
    this.textMode = ArabicTextMode.dual,
    this.themePreference = AppThemePreference.system,
    this.reminderEnabled = false,
    this.reminderTime = '20:00',
  });

  AppSettings copyWith({
    ArabicTextMode? textMode,
    AppThemePreference? themePreference,
    bool? reminderEnabled,
    String? reminderTime,
  }) {
    return AppSettings(
      textMode: textMode ?? this.textMode,
      themePreference: themePreference ?? this.themePreference,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}
