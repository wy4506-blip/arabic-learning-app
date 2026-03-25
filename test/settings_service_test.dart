import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arabic_learning_app/models/app_settings.dart';
import 'package:arabic_learning_app/services/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('settings service defaults foundation home promotion to off', () async {
    final loaded = await SettingsService.loadSettings();

    expect(loaded.homeUsesFoundationPilot, isFalse);
  });

  test('settings service persists foundation home promotion toggle', () async {
    const settings = AppSettings(
      homeUsesFoundationPilot: true,
    );

    await SettingsService.saveSettings(settings);
    final loaded = await SettingsService.loadSettings();

    expect(loaded.homeUsesFoundationPilot, isTrue);
  });
}
