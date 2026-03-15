import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arabic_learning_app/app_scope.dart';
import 'package:arabic_learning_app/data/sample_alphabet_data.dart';
import 'package:arabic_learning_app/models/alphabet_group.dart';
import 'package:arabic_learning_app/pages/alphabet_group_detail_page.dart';

import 'test_helpers.dart';

void main() {
  final group = sampleAlphabetGroups.first;
  final firstLetter = group.letters.first;
  final secondLetter = group.letters[1];
  final thirdLetter = group.letters[2];
  final fourthLetter = group.letters[3];

  const viewedKey = 'alphabet_progress_viewed_letters_v1';
  const listenKey = 'alphabet_progress_listen_letters_v1';
  const writeKey = 'alphabet_progress_write_letters_v1';

  Future<void> waitForGroupRefresh(WidgetTester tester) async {
    for (var index = 0; index < 40; index++) {
      await tester.pump(const Duration(milliseconds: 200));
      if (find.text('Refreshing this group progress...').evaluate().isEmpty) {
        break;
      }
    }
  }

  Future<void> pumpGroupPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues(const <String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.setStringList(viewedKey, const <String>[]);
    await prefs.setStringList(listenKey, const <String>[]);
    await prefs.setStringList(writeKey, const <String>[]);

    await tester.pumpWidget(
      AppSettingsScope(
        settings: kEnglishTestSettings,
        onSettingsChanged: (_) {},
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: AlphabetGroupDetailPage(group: group),
        ),
      ),
    );

    await tester.pump();
    await pumpUntilLoaded(tester);
    await waitForGroupRefresh(tester);
  }

  Future<void> completeLetterFromGroup(
    WidgetTester tester,
    AlphabetLetter letter,
  ) async {
    await tester.ensureVisible(find.text(letter.latinName));
    await tester.tap(find.text(letter.latinName));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start Light Listening'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Finish This Letter'));
    await tester.pumpAndSettle();
    await waitForGroupRefresh(tester);
  }

  testWidgets(
      'group flow refreshes, accumulates progress, and shows completion CTAs',
      (tester) async {
    await pumpGroupPage(tester);

    await completeLetterFromGroup(tester, firstLetter);

    expect(find.text('Group progress 1 / 4'), findsWidgets);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Not completed'), findsNWidgets(3));

    await completeLetterFromGroup(tester, secondLetter);

    expect(find.text('Group progress 2 / 4'), findsWidgets);
    expect(find.text('Completed'), findsNWidgets(2));
    expect(find.text('Not completed'), findsNWidgets(2));

    await completeLetterFromGroup(tester, thirdLetter);
    await completeLetterFromGroup(tester, fourthLetter);

    expect(find.text('This Group Is Complete'), findsOneWidget);
    expect(find.text('Continue Next Group'), findsOneWidget);
    expect(find.text('Practice This Group'), findsOneWidget);
    expect(find.text('Back to Alphabet Overview'), findsOneWidget);
    expect(find.text('Group progress 4 / 4'), findsWidgets);
  });
}
