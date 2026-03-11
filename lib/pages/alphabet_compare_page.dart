import 'package:flutter/material.dart';
import '../data/alphabet_quiz_data.dart';
import 'generic_quiz_page.dart';

class AlphabetCompareQuizPage extends StatelessWidget {
  const AlphabetCompareQuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericQuizPage(
      levelTitle: '第 2 级：字母辨析',
      subtitle: '区分易混淆字母',
      resultTitle: '第 2 级完成',
      emptyText: '暂无字母辨析练习内容',
      questions: AlphabetQuizData.compareQuestions,
    );
  }
}
