import 'package:flutter/material.dart';

import '../l10n/localized_text.dart';
import '../models/quiz_question.dart';
import 'generic_quiz_page.dart';

class AlphabetQuizPage extends StatelessWidget {
  const AlphabetQuizPage({super.key});

  List<QuizQuestion> _questions() {
    return const <QuizQuestion>[
      QuizQuestion(
        title: '这个字母叫什么？',
        prompt: 'ب',
        promptType: 'arabic',
        correct: 'Ba',
        options: <String>['Ba', 'Ta', 'Jim'],
      ),
      QuizQuestion(
        title: '这个字母叫什么？',
        prompt: 'ت',
        promptType: 'arabic',
        correct: 'Ta',
        options: <String>['Tha', 'Ta', 'Ra'],
      ),
      QuizQuestion(
        title: '这个字母叫什么？',
        prompt: 'ث',
        promptType: 'arabic',
        correct: 'Tha',
        options: <String>['Ba', 'Tha', 'Kha'],
      ),
      QuizQuestion(
        title: '这个字母叫什么？',
        prompt: 'ج',
        promptType: 'arabic',
        correct: 'Jim',
        options: <String>['Jim', 'Ha', 'Dal'],
      ),
      QuizQuestion(
        title: '这个字母叫什么？',
        prompt: 'ح',
        promptType: 'arabic',
        correct: 'Ha',
        options: <String>['Kha', 'Ha', 'Zay'],
      ),
      QuizQuestion(
        title: '这个字母叫什么？',
        prompt: 'خ',
        promptType: 'arabic',
        correct: 'Kha',
        options: <String>['Jim', 'Kha', 'Ra'],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return GenericQuizPage(
      levelTitle: localizedText(
        context,
        zh: '字母练习',
        en: 'Alphabet Drill',
      ),
      subtitle: localizedText(
        context,
        zh: '看字母，选择正确名称',
        en: 'See the letter and choose the correct name.',
      ),
      resultTitle: localizedText(
        context,
        zh: '练习完成',
        en: 'Practice Complete',
      ),
      emptyText: localizedText(
        context,
        zh: '暂无练习内容',
        en: 'No drill content yet.',
      ),
      questions: _questions()
          .map(
            (item) => QuizQuestion(
              title: localizedText(
                context,
                zh: item.title,
                en: 'What is the name of this letter?',
              ),
              prompt: item.prompt,
              promptType: item.promptType,
              correct: item.correct,
              options: item.options,
            ),
          )
          .toList(growable: false),
    );
  }
}
