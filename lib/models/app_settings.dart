enum ArabicTextMode { withDiacritics, dual, withoutDiacritics, smart }

enum AppThemePreference { system, light, dark }

enum AppLanguage { zh, en }

enum ContentLanguage { zh, en }

enum ArabicFontScale { standard, large }

enum AudioVoicePreference { ai, human }

class AppSettings {
  final ArabicTextMode textMode;
  final AppThemePreference themePreference;
  final AppLanguage appLanguage;
  final ContentLanguage meaningLanguage;
  final bool showTransliteration;
  final ArabicFontScale arabicFontScale;
  final bool reminderEnabled;
  final String reminderTime;
  final AudioVoicePreference voicePreference;

  const AppSettings({
    this.textMode = ArabicTextMode.smart,
    this.themePreference = AppThemePreference.system,
    this.appLanguage = AppLanguage.zh,
    this.meaningLanguage = ContentLanguage.zh,
    this.showTransliteration = true,
    this.arabicFontScale = ArabicFontScale.standard,
    this.reminderEnabled = false,
    this.reminderTime = '20:00',
    this.voicePreference = AudioVoicePreference.ai,
  });

  AppSettings copyWith({
    ArabicTextMode? textMode,
    AppThemePreference? themePreference,
    AppLanguage? appLanguage,
    ContentLanguage? meaningLanguage,
    bool? showTransliteration,
    ArabicFontScale? arabicFontScale,
    bool? reminderEnabled,
    String? reminderTime,
    AudioVoicePreference? voicePreference,
  }) {
    return AppSettings(
      textMode: textMode ?? this.textMode,
      themePreference: themePreference ?? this.themePreference,
      appLanguage: appLanguage ?? this.appLanguage,
      meaningLanguage: meaningLanguage ?? this.meaningLanguage,
      showTransliteration: showTransliteration ?? this.showTransliteration,
      arabicFontScale: arabicFontScale ?? this.arabicFontScale,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      voicePreference: voicePreference ?? this.voicePreference,
    );
  }
}
