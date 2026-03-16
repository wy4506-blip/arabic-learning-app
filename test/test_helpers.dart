import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arabic_learning_app/app_scope.dart';
import 'package:arabic_learning_app/models/app_settings.dart';
import 'package:arabic_learning_app/services/alphabet_service.dart';

const AppSettings kEnglishTestSettings = AppSettings(
  appLanguage: AppLanguage.en,
  meaningLanguage: ContentLanguage.en,
  showTransliteration: true,
);

const AppSettings kChineseTestSettings = AppSettings(
  appLanguage: AppLanguage.zh,
  meaningLanguage: ContentLanguage.zh,
  showTransliteration: false,
);

Future<void> pumpTestFrames(
  WidgetTester tester, {
  int count = 6,
  Duration step = const Duration(milliseconds: 200),
}) async {
  for (var index = 0; index < count; index++) {
    await tester.pump(step);
  }
}

Future<void> pumpUntilLoaded(
  WidgetTester tester, {
  int maxTicks = 80,
  Duration step = const Duration(milliseconds: 200),
}) async {
  for (var index = 0; index < maxTicks; index++) {
    await tester.pump(step);
    if (find.byType(CircularProgressIndicator).evaluate().isEmpty) {
      break;
    }
  }
  await pumpTestFrames(tester, count: 4, step: step);
}

Future<void> pumpLocalizedTestPage(
  WidgetTester tester,
  Widget child, {
  AppSettings settings = kEnglishTestSettings,
  Map<String, Object> sharedPreferences = const <String, Object>{},
}) async {
  tester.view.physicalSize = const Size(1440, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  SharedPreferences.setMockInitialValues(sharedPreferences);

  await tester.pumpWidget(
    AppSettingsScope(
      settings: settings,
      onSettingsChanged: (_) {},
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: child,
      ),
    ),
  );

  await tester.pump();
  await pumpUntilLoaded(tester);
}

Future<List<String>> loadAllAlphabetLetters() async {
  final groups = await AlphabetService.loadAlphabetGroups();
  return groups
      .expand((group) => group.letters)
      .map((letter) => letter.arabic)
      .toList(growable: false);
}

Map<String, Object> completedAlphabetProgressPrefs(
  List<String> allLetters, {
  Map<String, Object> extra = const <String, Object>{},
}) {
  return <String, Object>{
    'alphabet_progress_viewed_letters_v1': allLetters,
    'alphabet_progress_listen_letters_v1': allLetters,
    'alphabet_progress_write_letters_v1': allLetters,
    ...extra,
  };
}

String collectVisibleText(WidgetTester tester) {
  final buffer = StringBuffer();

  for (final widget in tester.widgetList<Text>(find.byType(Text))) {
    final value = widget.data ?? widget.textSpan?.toPlainText() ?? '';
    final normalized = value.trim();
    if (normalized.isEmpty) continue;
    buffer.writeln(normalized);
  }

  return buffer.toString();
}

void expectNoVisibleChinese(WidgetTester tester) {
  final output = collectVisibleText(tester);
  expect(
    RegExp(r'[\u4E00-\u9FFF]').hasMatch(output),
    isFalse,
    reason: 'Visible Chinese text found in English mode:\n$output',
  );
}

void expectNoVisibleMojibake(WidgetTester tester) {
  final output = collectVisibleText(tester);
  expect(
    RegExp(
      r'�|鍥涚甯歌瀛楀舰|涔﹀啓|鐙珛|璇嶉|璇嶄腑|璇嶅熬|鍩虹|鍚|浠婃棩鐑韓|鍏堝揩閫熷洖椤|銆|鈥|€',
    ).hasMatch(output),
    isFalse,
    reason: 'Visible mojibake text found:\n$output',
  );
}
