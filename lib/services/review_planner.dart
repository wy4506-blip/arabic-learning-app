import '../l10n/grammar_text.dart';
import '../l10n/lesson_content_localizer.dart';
import '../l10n/lesson_localizer.dart';
import '../models/alphabet_group.dart';
import '../models/app_settings.dart';
import '../models/grammar_home_models.dart';
import '../models/grammar_models.dart';
import '../models/learning_state_models.dart';
import '../models/lesson.dart';
import '../models/review_models.dart';
import '../models/word_item.dart';
import '../services/alphabet_service.dart';
import '../services/grammar_service.dart';
import '../services/grammar_state_service.dart';
import '../services/learning_state_service.dart';
import '../services/lesson_service.dart';
import '../services/progress_service.dart';
import '../services/vocab_service.dart';
import '../widgets/app_widgets.dart';

class ReviewPlannerContext {
  final AppSettings settings;
  final DateTime now;
  final List<Lesson> lessons;
  final ProgressSnapshot progress;
  final List<WordItem> favoriteWords;
  final List<GrammarPageContent> grammarPages;
  final List<GrammarRecentVisit> grammarRecentVisits;
  final List<String> grammarFavoriteIds;
  final List<AlphabetLetter> alphabetLetters;
  final Map<String, LearningContentState> learningStates;

  const ReviewPlannerContext({
    required this.settings,
    required this.now,
    required this.lessons,
    required this.progress,
    required this.favoriteWords,
    required this.grammarPages,
    required this.grammarRecentVisits,
    required this.grammarFavoriteIds,
    required this.alphabetLetters,
    required this.learningStates,
  });
}

class ReviewPlanner {
  ReviewPlanner._();

  static Future<ReviewPlannerContext> loadContext(
    AppSettings settings, {
    DateTime? now,
  }) async {
    final results = await Future.wait<dynamic>([
      LessonService().loadLessons(),
      ProgressService.getSnapshot(),
      VocabService.getFavoriteWords(),
      GrammarService.loadPages(),
      GrammarStateService.getRecentVisits(),
      GrammarStateService.getFavoriteIds(),
      AlphabetService.loadAlphabetGroups(),
      LearningStateService.getAllStates(),
    ]);

    final alphabetGroups = results[6] as List<AlphabetGroup>;
    return ReviewPlannerContext(
      settings: settings,
      now: now ?? DateTime.now(),
      lessons: results[0] as List<Lesson>,
      progress: results[1] as ProgressSnapshot,
      favoriteWords: results[2] as List<WordItem>,
      grammarPages: results[3] as List<GrammarPageContent>,
      grammarRecentVisits: results[4] as List<GrammarRecentVisit>,
      grammarFavoriteIds: results[5] as List<String>,
      alphabetLetters: alphabetGroups
          .expand((group) => group.letters)
          .toList(growable: false),
      learningStates: results[7] as Map<String, LearningContentState>,
    );
  }

  static List<ReviewTask> buildTodayCandidates(ReviewPlannerContext context) {
    final tasks = _sortedCandidates(context);
    return _balancedSelection(tasks, limit: 8);
  }

  static List<ReviewTask> buildWeakCandidates(ReviewPlannerContext context) {
    final tasks = _sortedCandidates(context)
        .where((task) {
          final state = context.learningStates[task.contentId];
          return (state?.stage == LearningStage.weak) ||
              (state?.isReviewDue ?? false);
        })
        .take(6)
        .toList(growable: false);
    return tasks;
  }

  static List<ReviewTask> buildRecentCandidates(ReviewPlannerContext context) {
    final tasks = _sortedCandidates(context)
        .where((task) {
          final state = context.learningStates[task.contentId];
          final recentStudy = _isRecent(state?.lastStudiedAt, context.now);
          final recentView = _isRecent(state?.lastViewedAt, context.now);
          return recentStudy ||
              recentView ||
              task.origin == ReviewTaskOrigin.recentLesson ||
              task.origin == ReviewTaskOrigin.grammarRecent ||
              task.origin == ReviewTaskOrigin.alphabetRecent;
        })
        .take(6)
        .toList(growable: false);
    return tasks;
  }

  static Map<ReviewContentType, int> buildTypeCounts(
    ReviewPlannerContext context,
  ) {
    final counts = <ReviewContentType, int>{};
    for (final task in _sortedCandidates(context)) {
      counts[task.type] = (counts[task.type] ?? 0) + 1;
    }
    return counts;
  }

  static Map<ReviewPracticeArea, int> buildPracticeCounts(
    ReviewPlannerContext context,
  ) {
    final counts = <ReviewPracticeArea, int>{};
    for (final task in _sortedCandidates(context)) {
      final area = reviewPracticeAreaForObject(task.objectType);
      if (area == null) {
        continue;
      }
      counts[area] = (counts[area] ?? 0) + 1;
    }
    return counts;
  }

  static List<ReviewTask> buildTypeFocusTasks(
    ReviewPlannerContext context,
    ReviewContentType type,
  ) {
    return _sortedCandidates(context)
        .where((task) => task.type == type)
        .take(6)
        .toList(growable: false);
  }

  static List<ReviewTask> buildLessonBridgeTasks(
    ReviewPlannerContext context,
    Lesson lesson, {
    required bool afterCompletion,
    int limit = 3,
  }) {
    if (!afterCompletion) {
      final pendingTasks = buildTodayCandidates(context)
          .where((task) => task.lessonId != lesson.id)
          .take(limit)
          .toList(growable: false);
      if (pendingTasks.isNotEmpty) {
        return pendingTasks;
      }

      return buildWeakCandidates(context).take(limit).toList(growable: false);
    }

    final tasks = <ReviewTask>[
      ...lesson.vocabulary.take(2).map(
            (word) => _buildWordTask(
              context,
              word,
              lesson: lesson,
              origin: ReviewTaskOrigin.lessonBridge,
              score: 48,
            ),
          ),
      ...lesson.patterns.take(1).map(
            (pattern) => _buildPatternTask(
              context,
              pattern,
              lesson: lesson,
              origin: ReviewTaskOrigin.lessonBridge,
              score: 46,
            ),
          ),
    ];

    final relatedGrammar = context.grammarPages
        .where((page) => page.relatedLessons.contains(lesson.id))
        .take(1)
        .map(
          (page) => _buildGrammarTask(
            context,
            page,
            origin: ReviewTaskOrigin.lessonBridge,
            score: 44,
          ),
        );
    tasks.addAll(relatedGrammar);

    if (tasks.length < limit && lesson.letters.isNotEmpty) {
      final alphabetByArabic = <String, AlphabetLetter>{
        for (final letter in context.alphabetLetters) letter.arabic: letter,
      };
      tasks.addAll(
        lesson.letters
            .map((letter) => alphabetByArabic[removeArabicDiacritics(letter)])
            .whereType<AlphabetLetter>()
            .take(limit - tasks.length)
            .map(
              (letter) => _buildAlphabetTask(
                context,
                letter,
                origin: ReviewTaskOrigin.lessonBridge,
                score: 42,
                lessonId: lesson.id,
              ),
            ),
      );
    }

    return tasks.take(limit).toList(growable: false);
  }

  static List<ReviewTask> _sortedCandidates(ReviewPlannerContext context) {
    final merged = <String, ReviewTask>{};

    void addTask(ReviewTask task) {
      final existing = merged[task.contentId];
      if (existing == null || task.priority > existing.priority) {
        merged[task.contentId] = task;
      }
    }

    final recentLessons = _recentLessons(context);
    final favoriteWordKeys = context.favoriteWords
        .map((word) => buildWordContentId(word.text.plain))
        .toSet();
    final recentVisitIds = <String, GrammarRecentVisit>{
      for (final visit in context.grammarRecentVisits) visit.pageId: visit,
    };

    for (final lesson in recentLessons) {
      final lessonBoost = lesson.id == context.progress.lastLessonId ? 18 : 10;
      final completedBoost =
          context.progress.completedLessons.contains(lesson.id) ? 8 : 4;

      for (final word in lesson.vocabulary.take(3)) {
        final contentId = buildWordContentId(word.text.plain);
        final state = context.learningStates[contentId];
        final score = lessonBoost +
            completedBoost +
            _statePriorityBonus(state) +
            (favoriteWordKeys.contains(contentId) ? 10 : 0);
        addTask(
          _buildWordTask(
            context,
            word,
            lesson: lesson,
            origin: _originForState(
              state,
              fallback: favoriteWordKeys.contains(contentId)
                  ? ReviewTaskOrigin.favorite
                  : ReviewTaskOrigin.recentLesson,
            ),
            score: score,
          ),
        );
      }

      final sentenceSource = lesson.patterns.isNotEmpty
          ? lesson.patterns.take(2).toList(growable: false)
          : const <LessonPattern>[];
      for (final pattern in sentenceSource) {
        final contentId = buildSentenceContentId(pattern.text.plain);
        final state = context.learningStates[contentId];
        final score = lessonBoost + completedBoost + _statePriorityBonus(state);
        addTask(
          _buildPatternTask(
            context,
            pattern,
            lesson: lesson,
            origin: _originForState(
              state,
              fallback: ReviewTaskOrigin.recentLesson,
            ),
            score: score,
          ),
        );
      }
    }

    for (final word in context.favoriteWords) {
      final contentId = buildWordContentId(word.text.plain);
      final state = context.learningStates[contentId];
      final score = 22 + _statePriorityBonus(state);
      addTask(
        ReviewTask(
          contentId: contentId,
          type: ReviewContentType.word,
          objectType: ReviewObjectType.wordReading,
          actionType: ReviewActionType.repeat,
          origin: _originForState(
            state,
            fallback: ReviewTaskOrigin.favorite,
          ),
          title: LessonContentLocalizer.meaning(
            word.meaning,
            context.settings.meaningLanguage,
          ),
          subtitle: _localizedLabel(
            context.settings,
            zh: '来自单词本，顺手回看一下',
            en: 'Saved in your wordbook for quick review',
          ),
          arabicText: word.arabic,
          transliteration: word.pronunciation,
          helperText: word.metadata.patternNote == null ||
                  word.metadata.patternNote!.isEmpty
              ? null
              : LessonContentLocalizer.meaning(
                  word.metadata.patternNote!,
                  context.settings.meaningLanguage,
                ),
          lessonId: state?.lessonId,
          sourceId: word.text.plain,
          estimatedSeconds: 40,
          priority: score,
        ),
      );
    }

    for (final page in context.grammarPages) {
      final state = context.learningStates[buildGrammarContentId(page.id)];
      final recentVisit = recentVisitIds[page.id];
      final isFavorite = context.grammarFavoriteIds.contains(page.id);
      final relatedToCurrentLesson = context.progress.lastLessonId != null &&
          page.relatedLessons.contains(context.progress.lastLessonId);
      final score = _statePriorityBonus(state) +
          (recentVisit == null
              ? 0
              : 16 + _recencyBonus(recentVisit.visitedAt, context.now)) +
          (isFavorite ? 10 : 0) +
          (relatedToCurrentLesson ? 14 : 0);

      if (score <= 0) {
        continue;
      }

      addTask(
        _buildGrammarTask(
          context,
          page,
          origin: _originForState(
            state,
            fallback: recentVisit != null
                ? ReviewTaskOrigin.grammarRecent
                : relatedToCurrentLesson
                    ? ReviewTaskOrigin.grammarRelated
                    : ReviewTaskOrigin.favorite,
          ),
          score: score,
        ),
      );
    }

    final alphabetByKey = <String, AlphabetLetter>{
      for (final letter in context.alphabetLetters)
        normalizeReviewKey(letter.arabic): letter,
    };
    final alphabetKeys = <String>{
      for (final state in context.learningStates.values)
        if (state.type == ReviewContentType.alphabet) state.contentId,
      for (final lesson in recentLessons)
        ...lesson.letters.map(
            (item) => buildAlphabetContentId(removeArabicDiacritics(item))),
    };

    for (final key in alphabetKeys) {
      final arabic = reviewSourceIdFromContentId(key);
      if (arabic == null) {
        continue;
      }
      final letter = alphabetByKey[arabic];
      if (letter == null) {
        continue;
      }
      final state = context.learningStates[key];
      final score = 14 + _statePriorityBonus(state);
      addTask(
        _buildAlphabetTask(
          context,
          letter,
          origin: _originForState(
            state,
            fallback: ReviewTaskOrigin.alphabetRecent,
          ),
          score: score,
          lessonId: state?.lessonId,
        ),
      );
    }

    for (final state in context.learningStates.values) {
      if (state.type == ReviewContentType.pronunciation) {
        final arabic = reviewSourceIdFromContentId(state.contentId);
        final symbolKey = reviewVariantKeyFromContentId(state.contentId);
        if (arabic == null || symbolKey == null) {
          continue;
        }
        final letter = alphabetByKey[arabic];
        if (letter == null) {
          continue;
        }
        AlphabetPronunciationItem? pronunciation;
        for (final item in letter.pronunciations) {
          if (item.key == symbolKey) {
            pronunciation = item;
            break;
          }
        }
        if (pronunciation == null) {
          continue;
        }
        addTask(
          _buildPronunciationTask(
            context,
            letter,
            pronunciation,
            origin: _originForState(state, fallback: ReviewTaskOrigin.recentLesson),
            score: 18 + _statePriorityBonus(state),
            lessonId: state.lessonId,
          ),
        );
      }
      if (state.type == ReviewContentType.pair) {
        final pairKey = reviewSourceIdFromContentId(state.contentId);
        if (pairKey == null) {
          continue;
        }
        final parts = pairKey.split('__');
        if (parts.length != 2) {
          continue;
        }
        final left = alphabetByKey[parts[0]];
        final right = alphabetByKey[parts[1]];
        if (left == null || right == null) {
          continue;
        }
        addTask(
          _buildConfusionPairTask(
            context,
            left,
            right,
            origin: _originForState(state, fallback: ReviewTaskOrigin.recentLesson),
            score: 16 + _statePriorityBonus(state),
            lessonId: state.lessonId,
          ),
        );
      }
      if (state.type == ReviewContentType.alphabet &&
          state.objectType != ReviewObjectType.letterSound) {
        final arabic = reviewSourceIdFromContentId(state.contentId);
        if (arabic == null) {
          continue;
        }
        final letter = alphabetByKey[arabic];
        if (letter == null) {
          continue;
        }
        if (state.objectType == ReviewObjectType.letterName) {
          addTask(
            _buildLetterNameTask(
              context,
              letter,
              origin: _originForState(state, fallback: ReviewTaskOrigin.recentLesson),
              score: 14 + _statePriorityBonus(state),
              lessonId: state.lessonId,
            ),
          );
        }
        if (state.objectType == ReviewObjectType.letterForm) {
          addTask(
            _buildLetterFormTask(
              context,
              letter,
              origin: _originForState(state, fallback: ReviewTaskOrigin.recentLesson),
              score: 14 + _statePriorityBonus(state),
              lessonId: state.lessonId,
            ),
          );
        }
      }
    }

    final tasks = merged.values.toList(growable: false)
      ..sort((a, b) => b.priority.compareTo(a.priority));
    return tasks;
  }

  static List<Lesson> _recentLessons(ReviewPlannerContext context) {
    final candidates = context.lessons
        .where(
          (lesson) =>
              context.progress.startedLessons.contains(lesson.id) ||
              context.progress.completedLessons.contains(lesson.id),
        )
        .toList(growable: false);

    final sorted = List<Lesson>.from(candidates)
      ..sort((a, b) {
        if (a.id == context.progress.lastLessonId) {
          return -1;
        }
        if (b.id == context.progress.lastLessonId) {
          return 1;
        }
        return b.sequence.compareTo(a.sequence);
      });
    return sorted.take(3).toList(growable: false);
  }

  static List<ReviewTask> _balancedSelection(
    List<ReviewTask> tasks, {
    required int limit,
  }) {
    final groups = <ReviewContentType, List<ReviewTask>>{};
    for (final task in tasks) {
      groups.putIfAbsent(task.type, () => <ReviewTask>[]).add(task);
    }

    final selected = <ReviewTask>[];
    var keepPicking = true;
    while (keepPicking && selected.length < limit) {
      keepPicking = false;
      for (final type in ReviewContentType.values) {
        final pool = groups[type];
        if (pool == null || pool.isEmpty || selected.length >= limit) {
          continue;
        }
        selected.add(pool.removeAt(0));
        keepPicking = true;
      }
    }

    if (selected.length < limit) {
      final remaining = groups.values.expand((items) => items).toList()
        ..sort((a, b) => b.priority.compareTo(a.priority));
      selected.addAll(
        remaining.take(limit - selected.length),
      );
    }

    return selected.take(limit).toList(growable: false);
  }

  static ReviewTask _buildWordTask(
    ReviewPlannerContext context,
    LessonWord word, {
    required Lesson lesson,
    required ReviewTaskOrigin origin,
    required int score,
  }) {
    return ReviewTask(
      contentId: buildWordContentId(word.text.plain),
      type: ReviewContentType.word,
      objectType: ReviewObjectType.wordReading,
      actionType: ReviewActionType.repeat,
      origin: origin,
      title: LessonContentLocalizer.meaning(
        word.meaning.zh,
        context.settings.meaningLanguage,
      ),
      subtitle: _localizedLabel(
        context.settings,
        zh: '来自${LessonLocalizer.title(lesson, context.settings.appLanguage)}的核心词',
        en: 'Core word from ${LessonLocalizer.title(lesson, context.settings.appLanguage)}',
      ),
      arabicText: word.arabic,
      transliteration: word.transliteration,
      helperText: word.metadata.patternNote == null ||
              word.metadata.patternNote!.isEmpty
          ? null
          : LessonContentLocalizer.meaning(
              word.metadata.patternNote!,
              context.settings.meaningLanguage,
            ),
      lessonId: lesson.id,
      sourceId: word.text.plain,
      estimatedSeconds: 40,
      priority: score,
    );
  }

  static ReviewTask _buildPatternTask(
    ReviewPlannerContext context,
    LessonPattern pattern, {
    required Lesson lesson,
    required ReviewTaskOrigin origin,
    required int score,
  }) {
    return ReviewTask(
      contentId: buildSentenceContentId(pattern.text.plain),
      type: ReviewContentType.sentence,
      objectType: ReviewObjectType.sentencePattern,
      actionType: ReviewActionType.read,
      origin: origin,
      title: LessonContentLocalizer.meaning(
        pattern.meaning.zh,
        context.settings.meaningLanguage,
      ),
      subtitle: _localizedLabel(
        context.settings,
        zh: '课里的常用句型，回看一遍更容易开口',
        en: 'A useful lesson sentence worth one more look',
      ),
      arabicText: pattern.arabic,
      transliteration: pattern.transliteration,
      helperText: LessonLocalizer.title(lesson, context.settings.appLanguage),
      lessonId: lesson.id,
      sourceId: pattern.text.plain,
      estimatedSeconds: 55,
      priority: score,
    );
  }

  static ReviewTask _buildGrammarTask(
    ReviewPlannerContext context,
    GrammarPageContent page, {
    required ReviewTaskOrigin origin,
    required int score,
  }) {
    final lessonId =
        page.relatedLessons.isEmpty ? null : page.relatedLessons.first;
    return ReviewTask(
      contentId: buildGrammarContentId(page.id),
      type: ReviewContentType.grammar,
      objectType: ReviewObjectType.grammarReference,
      actionType: ReviewActionType.recognize,
      origin: origin,
      title: grammarUiText(page.title, context.settings.appLanguage),
      subtitle: grammarContentText(
        page.subtitle.isNotEmpty ? page.subtitle : page.summary,
        context.settings.meaningLanguage,
      ),
      helperText: lessonId == null
          ? null
          : _localizedLabel(
              context.settings,
              zh: '和最近课程相关，查完就能顺着回去学',
              en: 'Connected to your recent lesson and easy to jump back from',
            ),
      lessonId: lessonId,
      sourceId: page.id,
      estimatedSeconds: 60,
      priority: score,
    );
  }

  static ReviewTask _buildAlphabetTask(
    ReviewPlannerContext context,
    AlphabetLetter letter, {
    required ReviewTaskOrigin origin,
    required int score,
    String? lessonId,
  }) {
    final title = context.settings.appLanguage == AppLanguage.en
        ? '${letter.name} · ${letter.latinName}'
        : '${letter.arabicName} · ${letter.latinName}';

    return ReviewTask(
      contentId: buildAlphabetContentId(letter.arabic),
      type: ReviewContentType.alphabet,
      objectType: ReviewObjectType.letterSound,
      actionType: ReviewActionType.listen,
      origin: origin,
      title: title,
      subtitle: LessonContentLocalizer.meaning(
        letter.soundHint,
        context.settings.meaningLanguage,
      ),
      arabicText: letter.arabic,
      transliteration: letter.pronunciation,
      helperText: LessonContentLocalizer.meaning(
        letter.hint,
        context.settings.meaningLanguage,
      ),
      lessonId: lessonId,
      sourceId: letter.arabic,
      estimatedSeconds: 35,
      priority: score,
    );
  }

  static ReviewTask _buildLetterNameTask(
    ReviewPlannerContext context,
    AlphabetLetter letter, {
    required ReviewTaskOrigin origin,
    required int score,
    String? lessonId,
  }) {
    return ReviewTask(
      contentId: buildLetterNameContentId(letter.arabic),
      type: ReviewContentType.alphabet,
      objectType: ReviewObjectType.letterName,
      actionType: ReviewActionType.recognize,
      origin: origin,
      title: context.settings.appLanguage == AppLanguage.en
          ? 'Name this letter'
          : '认出这个字母的名字',
      subtitle: context.settings.appLanguage == AppLanguage.en
          ? '${letter.name} · ${letter.latinName}'
          : '${letter.arabicName} · ${letter.latinName}',
      arabicText: letter.arabic,
      transliteration: letter.pronunciation,
      helperText: LessonContentLocalizer.meaning(
        letter.hint,
        context.settings.meaningLanguage,
      ),
      lessonId: lessonId,
      sourceId: letter.arabic,
      estimatedSeconds: 25,
      priority: score,
    );
  }

  static ReviewTask _buildLetterFormTask(
    ReviewPlannerContext context,
    AlphabetLetter letter, {
    required ReviewTaskOrigin origin,
    required int score,
    String? lessonId,
  }) {
    return ReviewTask(
      contentId: buildLetterFormContentId(letter.arabic),
      type: ReviewContentType.alphabet,
      objectType: ReviewObjectType.letterForm,
      actionType: ReviewActionType.recognize,
      origin: origin,
      title: context.settings.appLanguage == AppLanguage.en
          ? 'Match the letter form'
          : '认出这个字母形态',
      subtitle: context.settings.appLanguage == AppLanguage.en
          ? 'Isolated ${letter.forms.isolated} · Initial ${letter.forms.initial}'
          : '独立 ${letter.forms.isolated} · 词首 ${letter.forms.initial}',
      arabicText: letter.forms.medial,
      transliteration: letter.latinName,
      helperText: context.settings.appLanguage == AppLanguage.en
          ? 'Also appears as ${letter.forms.finalForm} at the end of words.'
          : '它在词尾还会写成 ${letter.forms.finalForm}。',
      lessonId: lessonId,
      sourceId: letter.arabic,
      estimatedSeconds: 30,
      priority: score,
    );
  }

  static ReviewTask _buildPronunciationTask(
    ReviewPlannerContext context,
    AlphabetLetter letter,
    AlphabetPronunciationItem pronunciation, {
    required ReviewTaskOrigin origin,
    required int score,
    String? lessonId,
  }) {
    return ReviewTask(
      contentId: buildSymbolReadingContentId(letter.arabic, pronunciation.key),
      type: ReviewContentType.pronunciation,
      objectType: ReviewObjectType.symbolReading,
      actionType: ReviewActionType.read,
      origin: origin,
      title: pronunciation.fullTitle,
      subtitle: pronunciation.shortSubtitle.isEmpty
          ? pronunciation.detailDescription
          : pronunciation.shortSubtitle,
      arabicText: pronunciation.arabicSymbol,
      transliteration: pronunciation.transliteration,
      helperText: pronunciation.detailDescription,
      lessonId: lessonId,
      sourceId: letter.arabic,
      variantKey: pronunciation.key,
      audioQueryText: pronunciation.audioQueryText,
      estimatedSeconds: 35,
      priority: score,
    );
  }

  static ReviewTask _buildConfusionPairTask(
    ReviewPlannerContext context,
    AlphabetLetter left,
    AlphabetLetter right, {
    required ReviewTaskOrigin origin,
    required int score,
    String? lessonId,
  }) {
    return ReviewTask(
      contentId: buildConfusionPairContentId(left.arabic, right.arabic),
      type: ReviewContentType.pair,
      objectType: ReviewObjectType.confusionPair,
      actionType: ReviewActionType.distinguish,
      origin: origin,
      title: context.settings.appLanguage == AppLanguage.en
          ? 'Tell these two letters apart'
          : '区分这两个易混字母',
      subtitle: context.settings.appLanguage == AppLanguage.en
          ? '${left.latinName} vs ${right.latinName}'
          : '${left.arabicName} 和 ${right.arabicName}',
      arabicText: '${left.arabic}  ${right.arabic}',
      transliteration: '${left.pronunciation} / ${right.pronunciation}',
      helperText: context.settings.appLanguage == AppLanguage.en
          ? '${left.soundHint}; ${right.soundHint}'
          : '${left.soundHint}；${right.soundHint}',
      lessonId: lessonId,
      sourceId: '${left.arabic}|${right.arabic}',
      estimatedSeconds: 32,
      priority: score,
    );
  }

  static ReviewTaskOrigin _originForState(
    LearningContentState? state, {
    required ReviewTaskOrigin fallback,
  }) {
    if (state?.stage == LearningStage.weak || state?.isWeak == true) {
      return ReviewTaskOrigin.weak;
    }
    if (state?.isReviewDue == true || state?.needsReview == true) {
      return ReviewTaskOrigin.due;
    }
    if (state?.isFavorited ?? false) {
      return ReviewTaskOrigin.favorite;
    }
    return fallback;
  }

  static int _statePriorityBonus(LearningContentState? state) {
    if (state == null) {
      return 0;
    }
    var score = state.reviewPriority * 4;
    switch (state.stage) {
      case LearningStage.newItem:
        score += 0;
      case LearningStage.learning:
        score += 10;
      case LearningStage.weak:
        score += 28;
      case LearningStage.reviewDue:
        score += 24;
      case LearningStage.stable:
        score += 8;
      case LearningStage.mastered:
        score += 2;
    }
    if (state.isReviewDue) {
      score += 16;
    }
    if (state.isWeak) {
      score += 18;
    }
    if (state.isFavorited) {
      score += 8;
    }
    score += _recencyBonus(state.lastStudiedAt, DateTime.now());
    score += _recencyBonus(state.lastViewedAt, DateTime.now()) ~/ 2;
    score += _recencyBonus(state.lastReviewedAt, DateTime.now());
    return score;
  }

  static bool _isRecent(DateTime? value, DateTime now) {
    if (value == null) {
      return false;
    }
    return now.difference(value).inDays <= 7;
  }

  static int _recencyBonus(DateTime? value, DateTime now) {
    if (value == null) {
      return 0;
    }
    final hours = now.difference(value).inHours;
    if (hours <= 24) {
      return 8;
    }
    if (hours <= 72) {
      return 5;
    }
    if (hours <= 24 * 7) {
      return 3;
    }
    return 0;
  }

  static String _localizedLabel(
    AppSettings settings, {
    required String zh,
    required String en,
  }) {
    return settings.appLanguage == AppLanguage.en ? en : zh;
  }
}
