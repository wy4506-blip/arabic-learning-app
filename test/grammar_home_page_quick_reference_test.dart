import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arabic_learning_app/pages/grammar_home_page.dart';

import 'test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows tool-style grammar entry sections in English',
      (tester) async {
    await pumpLocalizedTestPage(
      tester,
      const GrammarHomePage(settings: kEnglishTestSettings),
    );

    expect(find.text('Grammar Quick Reference'), findsWidgets);
    expect(find.text('Quick Lookup'), findsOneWidget);
    expect(find.text('Browse by Theme'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('You May Want to Check'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('You May Want to Check'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Featured Quick Cards'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Featured Quick Cards'), findsOneWidget);
  });

  testWidgets('filters results and expands a quick-scan card in English',
      (tester) async {
    await pumpLocalizedTestPage(
      tester,
      const GrammarHomePage(settings: kEnglishTestSettings),
    );

    await tester.enterText(find.byType(TextField), 'article');
    await pumpTestFrames(tester, count: 4);

    expect(find.text('Search Results'), findsOneWidget);
    expect(find.text('Quick-Scan Cards'), findsOneWidget);
    expect(find.text('Definite Article'), findsOneWidget);
    expect(find.text('Personal Pronouns'), findsNothing);

    await tester.tap(find.text('Definite Article'));
    await tester.pumpAndSettle();

    expect(find.text('Key Points'), findsOneWidget);
    expect(
      find.text(
        'Its pronunciation can assimilate before some letters, but recognition comes first.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows recent grammar topics from stored history', (tester) async {
    await pumpLocalizedTestPage(
      tester,
      const GrammarHomePage(settings: kEnglishTestSettings),
      sharedPreferences: <String, Object>{
        'grammar_recent_visits': jsonEncode(
          <Map<String, String>>[
            <String, String>{
              'pageId': 'negation',
              'visitedAt': '2026-03-12T10:00:00.000Z',
            },
          ],
        ),
        'grammar_favorites': <String>['negation'],
      },
    );

    await tester.scrollUntilVisible(
      find.text('Continue Reading'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Continue Reading'), findsOneWidget);
    expect(find.text('Negation'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('Saved Topics'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Saved Topics'), findsOneWidget);
  });
}
