import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arabic_learning_app/pages/quiz_scaffold.dart';
import 'package:arabic_learning_app/widgets/arabic_text_with_audio.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('arabic quiz keeps audio on prompt but not on every option', (
    tester,
  ) async {
    await pumpLocalizedTestPage(
      tester,
      QuizScaffold(
        levelTitle: 'Alphabet Quiz',
        subtitle: 'Pick the matching letter',
        currentIndex: 0,
        total: 3,
        questionTitle: 'Choose the correct answer',
        prompt: 'ب',
        promptType: 'arabic',
        options: const <String>['ب', 'ت', 'ث'],
        correct: 'ب',
        selectedAnswer: null,
        answered: false,
        onSelect: (_) {},
        onNext: () {},
      ),
    );

    expect(find.byType(LearningAudioIconButton), findsOneWidget);
    expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);
  });
}