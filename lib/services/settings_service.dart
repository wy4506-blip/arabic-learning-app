import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

class SettingsService {
  static const _textModeKey = 'app_text_mode';
  static const _themeKey = 'app_theme_pref';
  static const _reminderEnabledKey = 'app_reminder_enabled';
  static const _reminderTimeKey = 'app_reminder_time';

  static Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      textMode: ArabicTextMode.values[
          (prefs.getInt(_textModeKey) ?? ArabicTextMode.dual.index)
              .clamp(0, ArabicTextMode.values.length - 1)],
      themePreference: AppThemePreference.values[
          (prefs.getInt(_themeKey) ?? AppThemePreference.system.index)
              .clamp(0, AppThemePreference.values.length - 1)],
      reminderEnabled: prefs.getBool(_reminderEnabledKey) ?? false,
      reminderTime: prefs.getString(_reminderTimeKey) ?? '20:00',
    );
  }

  static Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_textModeKey, settings.textMode.index);
    await prefs.setInt(_themeKey, settings.themePreference.index);
    await prefs.setBool(_reminderEnabledKey, settings.reminderEnabled);
    await prefs.setString(_reminderTimeKey, settings.reminderTime);
  }
}
