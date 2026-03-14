import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../data/alphabet_quiz_data.dart';
import '../l10n/alphabet_content_localizer.dart';
import '../l10n/localized_text.dart';
import 'generic_quiz_page.dart';

class AlphabetRecognitionQuizPage extends StatelessWidget {
  const AlphabetRecognitionQuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericQuizPage(
      levelTitle: localizedText(
        context,
        zh: '第 1 级：字母识别',
        en: 'Level 1: Letter Recognition',
      ),
      subtitle: localizedText(
        context,
        zh: '看字母选名称、看名称选字母',
        en: 'Match letters and names in both directions.',
      ),
      resultTitle: localizedText(
        context,
        zh: '第 1 级完成',
        en: 'Level 1 Complete',
      ),
      emptyText: localizedText(
        context,
        zh: '暂无字母识别练习内容',
        en: 'No letter recognition drills yet.',
      ),
      questions: const [],
      questionsLoader: () async {
        await AlphabetQuizData.ensureLoaded();
        return AlphabetQuizData.recognitionQuestions
            .map(
              (question) => AlphabetContentLocalizer.localizeQuestion(
                question,
                context.appSettings.appLanguage,
              ),
            )
            .toList(growable: false);
      },
    );
  }
}
