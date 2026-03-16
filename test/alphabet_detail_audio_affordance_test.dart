import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arabic_learning_app/data/sample_alphabet_data.dart';
import 'package:arabic_learning_app/pages/alphabet_detail_page.dart';
import 'package:arabic_learning_app/widgets/arabic_text_with_audio.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('alphabet detail keeps quick audio on content blocks and uses module entry cards for training', (
    tester,
  ) async {
    final letter = sampleAlphabetGroups.first.letters.first;

    await pumpLocalizedTestPage(
      tester,
      AlphabetDetailPage(letter: letter),
    );

    expect(find.byType(LearningAudioIconButton), findsOneWidget);
    expect(find.text('Open Listening Practice'), findsOneWidget);
    expect(find.text('Open Writing Practice'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Example Word'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Example Word'), findsOneWidget);
    expect(find.byType(LearningAudioIconButton), findsOneWidget);
    expect(find.text('Play Letter Audio'), findsNothing);
  });
}