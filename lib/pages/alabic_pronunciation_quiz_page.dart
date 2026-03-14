import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../data/alphabet_quiz_data.dart';
import '../l10n/alphabet_content_localizer.dart';
import '../l10n/localized_text.dart';
import 'generic_quiz_page.dart';

class AlabicPronunciationQuizPage extends StatelessWidget {
  const AlabicPronunciationQuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GenericQuizPage(
      levelTitle: localizedText(
        context,
        zh: '第 4 级：13 音位',
        en: 'Level 4: 13 Sound Forms',
      ),
      subtitle: localizedText(
        context,
        zh: '听读音形式，再判断转写和类别',
        en: 'Hear the sound form, then identify its transliteration or type.',
      ),
      resultTitle: localizedText(
        context,
        zh: '第 4 级完成',
        en: 'Level 4 Complete',
      ),
      emptyText: localizedText(
        context,
        zh: '暂无 13 音位练习内容',
        en: 'No 13-form drills yet.',
      ),
      questions: const [],
      questionsLoader: () async {
        await AlphabetQuizData.ensureLoaded();
        return AlphabetQuizData.pronunciationQuestions
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
