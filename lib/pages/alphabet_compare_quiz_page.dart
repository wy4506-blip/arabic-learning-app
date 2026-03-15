import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../data/alphabet_quiz_data.dart';
import '../l10n/alphabet_content_localizer.dart';
import '../l10n/localized_text.dart';
import '../models/alphabet_group.dart';
import '../models/quiz_question.dart';
import '../models/review_models.dart';
import '../services/alphabet_service.dart';
import '../services/learning_state_service.dart';
import 'generic_quiz_page.dart';

class AlphabetCompareQuizPage extends StatelessWidget {
  const AlphabetCompareQuizPage({super.key});

  static Future<void> _markCompareCompleted(
    List<QuizQuestion> questions,
  ) async {
    final letters = await _resolveLetters(questions);
    for (final letter in letters) {
      await LearningStateService.markPracticeCompleted(
        contentId: buildLetterFormContentId(letter.arabic),
        type: ReviewContentType.alphabet,
        objectType: ReviewObjectType.letterForm,
        practiceKind: LearningPracticeKind.compare,
      );
    }
  }

  static Future<List<AlphabetLetter>> _resolveLetters(
    List<QuizQuestion> questions,
  ) async {
    final groups = await AlphabetService.loadAlphabetGroups();
    final lettersByArabic = <String, AlphabetLetter>{
      for (final group in groups)
        for (final letter in group.letters) letter.arabic.trim(): letter,
    };
    final matched = <String, AlphabetLetter>{};

    for (final question in questions) {
      final candidates = <String>[
        question.prompt,
        question.correct,
        ...question.options,
      ];
      for (final candidate in candidates) {
        final letter = lettersByArabic[candidate.trim()];
        if (letter != null) {
          matched[letter.arabic] = letter;
        }
      }
    }

    return matched.values.toList(growable: false);
  }

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
      onCompleted: (questions, _) => _markCompareCompleted(questions),
    );
  }
}
