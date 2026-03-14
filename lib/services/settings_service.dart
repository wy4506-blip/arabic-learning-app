import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

class SettingsService {
  static const _textModeKey = 'app_text_mode';
  static const _themeKey = 'app_theme_pref';
  static const _languageKey = 'app_language';
  static const _meaningLanguageKey = 'app_meaning_language';
  static const _showTransliterationKey = 'app_show_transliteration';
  static const _arabicFontScaleKey = 'app_arabic_font_scale';
  static const _reminderEnabledKey = 'app_reminder_enabled';
  static const _reminderTimeKey = 'app_reminder_time';
  static const _voicePreferenceKey = 'app_voice_preference';

  static Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      textMode: ArabicTextMode.values[
          (prefs.getInt(_textModeKey) ?? ArabicTextMode.smart.index)
              .clamp(0, ArabicTextMode.values.length - 1)],
      themePreference: AppThemePreference.values[
          (prefs.getInt(_themeKey) ?? AppThemePreference.system.index)
              .clamp(0, AppThemePreference.values.length - 1)],
      appLanguage: AppLanguage.values[
          (prefs.getInt(_languageKey) ?? AppLanguage.zh.index)
              .clamp(0, AppLanguage.values.length - 1)],
      meaningLanguage: ContentLanguage.values[
          (prefs.getInt(_meaningLanguageKey) ?? ContentLanguage.zh.index)
              .clamp(0, ContentLanguage.values.length - 1)],
      showTransliteration: prefs.getBool(_showTransliterationKey) ?? true,
      arabicFontScale: ArabicFontScale.values[
          (prefs.getInt(_arabicFontScaleKey) ?? ArabicFontScale.standard.index)
              .clamp(0, ArabicFontScale.values.length - 1)],
      reminderEnabled: prefs.getBool(_reminderEnabledKey) ?? false,
      reminderTime: prefs.getString(_reminderTimeKey) ?? '20:00',
      voicePreference: AudioVoicePreference.values[
          (prefs.getInt(_voicePreferenceKey) ?? AudioVoicePreference.ai.index)
              .clamp(0, AudioVoicePreference.values.length - 1)],
    );
  }

  static Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_textModeKey, settings.textMode.index);
    await prefs.setInt(_themeKey, settings.themePreference.index);
    await prefs.setInt(_languageKey, settings.appLanguage.index);
    await prefs.setInt(_meaningLanguageKey, settings.meaningLanguage.index);
    await prefs.setBool(
      _showTransliterationKey,
      settings.showTransliteration,
    );
    await prefs.setInt(_arabicFontScaleKey, settings.arabicFontScale.index);
    await prefs.setBool(_reminderEnabledKey, settings.reminderEnabled);
    await prefs.setString(_reminderTimeKey, settings.reminderTime);
    await prefs.setInt(_voicePreferenceKey, settings.voicePreference.index);
  }
}
