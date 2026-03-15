import 'package:flutter_test/flutter_test.dart';
import 'package:arabic_learning_app/data/sample_alphabet_data.dart';
import 'package:arabic_learning_app/pages/alphabet_group_detail_page.dart';
import 'package:arabic_learning_app/pages/alphabet_letter_home_page.dart';
import 'package:arabic_learning_app/pages/alphabet_listen_read_page.dart';
import 'package:arabic_learning_app/pages/alphabet_write_page.dart';

import 'test_helpers.dart';

void main() {
  final group = sampleAlphabetGroups.first;
  final firstLetter = group.letters.first;
  final secondLetter = group.letters[1];

  Future<void> pumpGroupPage(WidgetTester tester) {
    return pumpLocalizedTestPage(
      tester,
      AlphabetGroupDetailPage(group: group),
    );
  }

  testWidgets('letter home shows a lighter first screen by default',
      (tester) async {
    await pumpLocalizedTestPage(
      tester,
      AlphabetLetterHomePage(letter: firstLetter),
    );

    expect(find.text('Remember These 2 Things First'), findsOneWidget);
    expect(find.text('Start Light Listening'), findsOneWidget);
    expect(find.text('Go Deeper Later'), findsOneWidget);

    expect(find.text('Four Common Forms'), findsNothing);
    expect(find.text('Writing Practice Later'), findsNothing);
  });

  testWidgets('letter home primary CTA opens listen page, not writing page',
      (tester) async {
    await pumpLocalizedTestPage(
      tester,
      AlphabetLetterHomePage(letter: firstLetter),
    );

    await tester.tap(find.text('Start Light Listening'));
    await tester.pumpAndSettle();

    expect(find.byType(AlphabetListenReadPage), findsOneWidget);
    expect(find.text('Finish This Letter'), findsOneWidget);
    expect(find.byType(AlphabetWritePage), findsNothing);
    expect(find.text('Practice This Later'), findsNothing);
  });

  testWidgets('listen page keeps advanced content folded by default',
      (tester) async {
    await pumpLocalizedTestPage(
      tester,
      AlphabetListenReadPage(letter: firstLetter),
    );

    expect(find.text('Advanced Pronunciation Later'), findsOneWidget);
    expect(find.text('Play All Sounds'), findsNothing);
    expect(find.text('Finish This Letter'), findsOneWidget);

    await tester.tap(find.text('Advanced Pronunciation Later'));
    await tester.pumpAndSettle();

    expect(find.text('Play All Sounds'), findsOneWidget);
  });

  testWidgets(
      'finishing a letter returns to group page and second letter repeats cleanly',
      (tester) async {
    await pumpGroupPage(tester);

    await tester.ensureVisible(find.text(firstLetter.latinName));
    await tester.tap(find.text(firstLetter.latinName));
    await tester.pumpAndSettle();
    expect(find.byType(AlphabetLetterHomePage), findsOneWidget);

    await tester.tap(find.text('Start Light Listening'));
    await tester.pumpAndSettle();
    expect(find.byType(AlphabetListenReadPage), findsOneWidget);

    await tester.tap(find.text('Finish This Letter'));
    await tester.pumpAndSettle();

    expect(find.byType(AlphabetGroupDetailPage), findsOneWidget);
    expect(find.byType(AlphabetLetterHomePage), findsNothing);
    expect(find.byType(AlphabetListenReadPage), findsNothing);
    expect(find.text('Group progress 1 / 4'), findsWidgets);

    await tester.ensureVisible(find.text(secondLetter.latinName));
    await tester.tap(find.text(secondLetter.latinName));
    await tester.pumpAndSettle();
    expect(find.byType(AlphabetLetterHomePage), findsOneWidget);

    await tester.tap(find.text('Start Light Listening'));
    await tester.pumpAndSettle();
    expect(find.byType(AlphabetListenReadPage), findsOneWidget);

    await tester.tap(find.text('Finish This Letter'));
    await tester.pumpAndSettle();

    expect(find.byType(AlphabetGroupDetailPage), findsOneWidget);
    expect(find.byType(AlphabetLetterHomePage), findsNothing);
    expect(find.byType(AlphabetWritePage), findsNothing);
    expect(find.text('Group progress 2 / 4'), findsWidgets);
  });

  testWidgets('writing practice stays available but optional', (tester) async {
    await pumpLocalizedTestPage(
      tester,
      AlphabetLetterHomePage(letter: firstLetter),
    );

    await tester.tap(find.text('Go Deeper Later'));
    await tester.pumpAndSettle();

    expect(find.text('Four Common Forms'), findsOneWidget);
    expect(find.text('Writing Practice Later'), findsOneWidget);

    await tester.tap(find.text('Writing Practice Later'));
    await tester.pumpAndSettle();

    expect(find.byType(AlphabetWritePage), findsOneWidget);
    expect(find.text('Practice This Later'), findsOneWidget);

    await tester.tap(find.text('Practice This Later'));
    await tester.pumpAndSettle();

    expect(find.byType(AlphabetLetterHomePage), findsOneWidget);
    expect(find.byType(AlphabetWritePage), findsNothing);
  });
}
