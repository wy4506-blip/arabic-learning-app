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

class AlphabetSoundQuizPage extends StatelessWidget {
  const AlphabetSoundQuizPage({super.key});

  static Future<void> _markSoundCompleted(
    List<QuizQuestion> questions,
  ) async {
    final letters = await _resolveLetters(questions);
    for (final letter in letters) {
      await LearningStateService.markPracticeCompleted(
        contentId: buildLetterSoundContentId(letter.arabic),
        type: ReviewContentType.alphabet,
        objectType: ReviewObjectType.letterSound,
        practiceKind: LearningPracticeKind.pronounce,
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
      onCompleted: (questions, _) => _markSoundCompleted(questions),
    );
  }
}
