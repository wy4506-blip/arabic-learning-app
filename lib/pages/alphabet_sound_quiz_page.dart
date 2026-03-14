import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../data/alphabet_quiz_data.dart';
import '../l10n/alphabet_content_localizer.dart';
import '../l10n/localized_text.dart';
import 'generic_quiz_page.dart';

class AlphabetSoundQuizPage extends StatelessWidget {
  const AlphabetSoundQuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericQuizPage(
      levelTitle: localizedText(
        context,
        zh: '第 3 级：基础发音',
        en: 'Level 3: Core Sounds',
      ),
      subtitle: localizedText(
        context,
        zh: '听字母发音，再判断对应的音值或字母',
        en: 'Hear the letter sound, then identify the sound or letter.',
      ),
      resultTitle: localizedText(
        context,
        zh: '第 3 级完成',
        en: 'Level 3 Complete',
      ),
      emptyText: localizedText(
        context,
        zh: '暂无基础发音练习内容',
        en: 'No core sound drills yet.',
      ),
      questions: const [],
      questionsLoader: () async {
        await AlphabetQuizData.ensureLoaded();
        return AlphabetQuizData.soundQuestions
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
