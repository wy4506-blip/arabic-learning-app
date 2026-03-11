import 'package:flutter/material.dart';
import '../data/alphabet_quiz_data.dart';
import 'generic_quiz_page.dart';

class AlabicPronunciationQuizPage extends StatelessWidget {
  const AlabicPronunciationQuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericQuizPage(
      levelTitle: '第 4 级：13 音位',
      subtitle: '进入短音、长音、静音、重音和尾音训练',
      resultTitle: '第 4 级完成',
      emptyText: '暂无 13 音位练习内容',
      questions: const [],
      questionsLoader: () async {
        await AlphabetQuizData.ensureLoaded();
        return AlphabetQuizData.pronunciationQuestions;
      },
    );
  }
}
