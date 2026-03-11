import 'package:shared_preferences/shared_preferences.dart';

class UnlockService {
  static const String _unlockKey = 'is_unlocked';

  static Future<bool> isUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_unlockKey) ?? false;
  }

  static Future<void> unlockAllCourses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_unlockKey, true);
  }

  static Future<void> resetUnlock() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_unlockKey, false);
  }
}
