import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arabic_learning_app/app_scope.dart';
import 'package:arabic_learning_app/data/sample_alphabet_data.dart';
import 'package:arabic_learning_app/models/alphabet_group.dart';
import 'package:arabic_learning_app/pages/alphabet_letter_home_page.dart';
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

  Future<void> pumpGroupPage(
    WidgetTester tester, {
    Map<String, Object> sharedPreferences = const <String, Object>{},
  }) async {
    tester.view.physicalSize = const Size(1440, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues(sharedPreferences);
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (sharedPreferences.isEmpty) {
      await prefs.setStringList(viewedKey, const <String>[]);
      await prefs.setStringList(listenKey, const <String>[]);
      await prefs.setStringList(writeKey, const <String>[]);
    } else {
      final viewed = (sharedPreferences[viewedKey] as List<dynamic>? ?? const [])
          .cast<String>();
      final listened =
          (sharedPreferences[listenKey] as List<dynamic>? ?? const [])
              .cast<String>();
      final written = (sharedPreferences[writeKey] as List<dynamic>? ?? const [])
          .cast<String>();
      await prefs.setStringList(viewedKey, viewed);
      await prefs.setStringList(listenKey, listened);
      await prefs.setStringList(writeKey, written);
    }

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

  Future<void> openLetterAndFinishListening(
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
  }

  Future<void> waitForPostCompletionState(WidgetTester tester) async {
    for (var index = 0; index < 30; index++) {
      await tester.pump(const Duration(milliseconds: 200));
      final onLetterPage = find.byType(AlphabetLetterHomePage).evaluate().isNotEmpty;
      final groupCompleteVisible =
          find.text('This Group Is Complete').evaluate().isNotEmpty;
      if (!onLetterPage || groupCompleteVisible) {
        break;
      }
    }
  }

  testWidgets('group flow naturally hands off to the next incomplete letter', (
    tester,
  ) async {
    await pumpGroupPage(tester);

    await openLetterAndFinishListening(tester, firstLetter);

    expect(find.byType(AlphabetLetterHomePage), findsOneWidget);
    final currentPage = tester.widget<AlphabetLetterHomePage>(
      find.byType(AlphabetLetterHomePage),
    );
    expect(currentPage.letter.arabic, secondLetter.arabic);
  });

  testWidgets('finishing the last incomplete letter returns to the group page', (
    tester,
  ) async {
    await pumpGroupPage(
      tester,
      sharedPreferences: <String, Object>{
        viewedKey: <String>[
          firstLetter.arabic,
          secondLetter.arabic,
          thirdLetter.arabic,
        ],
        listenKey: <String>[
          firstLetter.arabic,
          secondLetter.arabic,
          thirdLetter.arabic,
        ],
        writeKey: const <String>[],
      },
    );

    await openLetterAndFinishListening(tester, fourthLetter);
    await waitForPostCompletionState(tester);
    await waitForGroupRefresh(tester);

    expect(find.byType(AlphabetLetterHomePage), findsNothing);
    expect(find.byType(AlphabetGroupDetailPage), findsOneWidget);
  });
}
