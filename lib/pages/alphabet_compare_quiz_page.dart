import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../data/alphabet_quiz_data.dart';
import '../l10n/alphabet_content_localizer.dart';
import '../l10n/localized_text.dart';
import 'generic_quiz_page.dart';

class AlphabetCompareQuizPage extends StatelessWidget {
  const AlphabetCompareQuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericQuizPage(
      levelTitle: localizedText(
        context,
        zh: '第 2 级：字母辨析',
        en: 'Level 2: Letter Contrast',
      ),
      subtitle: localizedText(
        context,
        zh: '区分易混淆字母',
        en: 'Separate look-alike letters.',
      ),
      resultTitle: localizedText(
        context,
        zh: '第 2 级完成',
        en: 'Level 2 Complete',
      ),
      emptyText: localizedText(
        context,
        zh: '暂无字母辨析练习内容',
        en: 'No letter contrast drills yet.',
      ),
      questions: const [],
      questionsLoader: () async {
        await AlphabetQuizData.ensureLoaded();
        return AlphabetQuizData.compareQuestions
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
