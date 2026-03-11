import 'package:flutter/material.dart';
import '../data/alphabet_quiz_data.dart';
import 'generic_quiz_page.dart';

class AlphabetSoundQuizPage extends StatelessWidget {
  const AlphabetSoundQuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericQuizPage(
      levelTitle: '第 3 级：基础发音',
      subtitle: '把字母和基础音值建立对应关系',
      resultTitle: '第 3 级完成',
      emptyText: '暂无基础发音练习内容',
      questions: const [],
      questionsLoader: () async {
        await AlphabetQuizData.ensureLoaded();
        return AlphabetQuizData.soundQuestions;
      },
    );
  }
}
