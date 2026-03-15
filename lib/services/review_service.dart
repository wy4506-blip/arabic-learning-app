import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/lesson_localizer.dart';
import '../models/alphabet_group.dart';
import '../models/app_settings.dart';
import '../models/learning_state_models.dart';
import '../models/lesson.dart';
import '../models/review_models.dart';
import '../models/word_item.dart';
import 'alphabet_service.dart';
import 'learning_state_service.dart';
import 'progress_service.dart';
import 'review_planner.dart';
import 'review_sync_service.dart';
import '../widgets/app_widgets.dart';

class ReviewEntrySnapshot {
  final List<ReviewTask> formalTasks;
  final List<ReviewTask> lightTasks;
  final List<ReviewTask> overdueTasks;
  final List<ReviewTask> stageReinforcementTasks;

  const ReviewEntrySnapshot({
    required this.formalTasks,
    required this.lightTasks,
    required this.overdueTasks,
    required this.stageReinforcementTasks,
  });

  bool get hasFormalReview => formalTasks.isNotEmpty;
  bool get hasLightReview => lightTasks.isNotEmpty;
  bool get hasOverdueReview => overdueTasks.isNotEmpty;
  bool get hasStageReinforcement => stageReinforcementTasks.isNotEmpty;
  int get formalReviewCount => formalTasks.length;
  int get lightReviewCount => lightTasks.length;
  int get overdueReviewCount => overdueTasks.length;
  int get stageReinforcementCount => stageReinforcementTasks.length;
  int get primaryReviewCount => hasFormalReview ? formalReviewCount : lightReviewCount;
}

class ReviewService {
  ReviewService._();

  static const String _todayPlanKey = 'review_today_plan_v1';
  static const String _sessionLogsKey = 'review_session_logs_v1';

  static Future<ReviewDashboardData> buildDashboard(
    AppSettings settings, {
    DateTime? now,
  }) async {
    final moment = now ?? DateTime.now();
    final context = await ReviewPlanner.loadContext(settings, now: moment);
    final todayPlan = await getTodayPlan(settings, now: moment);
    final logs = await _getSessionLogs();
    return ReviewDashboardData(
      summary: ReviewSummary(
        todayPlan: todayPlan,
        streakDays: _calculateStreak(logs, moment),
        weeklyReviewCount: _countWeeklyReviews(logs, moment),
        typeCounts: ReviewPlanner.buildTypeCounts(context),
        practiceCounts: ReviewPlanner.buildPracticeCounts(context),
        recommendedLessonId: context.progress.lastLessonId,
      ),
      weakTasks: ReviewPlanner.buildWeakCandidates(context),
      recentTasks: ReviewPlanner.buildRecentCandidates(context),
    );
  }

  static Future<DailyReviewPlan> getTodayPlan(
    AppSettings settings, {
    DateTime? now,
  }) async {
    final moment = now ?? DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_todayPlanKey);
    final context = await ReviewPlanner.loadContext(settings, now: moment);
    final reviewSignals = ReviewPlanner.buildSignals(context);
    final freshTasks = reviewSignals.hasFormalReview
      ? reviewSignals.formalReviewTasks
      : ReviewPlanner.buildTodayCandidates(context);
    final todayKey = reviewDateKey(moment);

    if (raw == null || raw.isEmpty) {
      final plan = DailyReviewPlan(
        dateKey: todayKey,
        tasks: freshTasks,
        completedTaskIds: const <String>[],
      );
      await _saveTodayPlan(plan, notify: false);
      return plan;
    }

    DailyReviewPlan storedPlan;
    try {
      storedPlan = DailyReviewPlan.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      final plan = DailyReviewPlan(
        dateKey: todayKey,
        tasks: freshTasks,
        completedTaskIds: const <String>[],
      );
      await _saveTodayPlan(plan, notify: false);
      return plan;
    }

    if (storedPlan.dateKey != todayKey) {
      final plan = DailyReviewPlan(
        dateKey: todayKey,
        tasks: freshTasks,
        completedTaskIds: const <String>[],
      );
      await _saveTodayPlan(plan, notify: false);
      return plan;
    }

    if (storedPlan.hasStarted || storedPlan.isCompleted) {
      return storedPlan;
    }

    final plan = storedPlan.copyWith(
      tasks: freshTasks,
      completedTaskIds: storedPlan.completedTaskIds
          .where(
            (id) => freshTasks.any((task) => task.contentId == id),
          )
          .toList(growable: false),
    );
    await _saveTodayPlan(plan, notify: false);
    return plan;
  }

  static Future<ReviewEntrySnapshot> getEntrySnapshot(
    AppSettings settings, {
    DateTime? now,
  }) async {
    final moment = now ?? DateTime.now();
    final context = await ReviewPlanner.loadContext(settings, now: moment);
    final signals = ReviewPlanner.buildSignals(context);
    final todayPlan = await getTodayPlan(settings, now: moment);
    final formalTasks = todayPlan.tasks
        .where((task) => !todayPlan.completedTaskIds.contains(task.contentId))
        .toList(growable: false);

    return ReviewEntrySnapshot(
      formalTasks: formalTasks.isNotEmpty
          ? formalTasks
          : signals.formalReviewTasks,
      lightTasks: signals.lightReviewTasks,
      overdueTasks: signals.overdueReviewTasks,
      stageReinforcementTasks: signals.stageReinforcementTasks,
    );
  }

  static Future<ReviewSession?> createTodaySession(
    AppSettings settings,
  ) async {
    final now = DateTime.now();
    final plan = await getTodayPlan(settings, now: now);
    final context = await ReviewPlanner.loadContext(settings, now: now);
    if (plan.tasks.isEmpty) {
      return null;
    }

    final nextLesson =
        _findNextLesson(context.lessons, context.progress.lastLessonId);

    final activePlan = plan.hasStarted ? plan : plan.copyWith(startedAt: now);
    if (!plan.hasStarted) {
      await _saveTodayPlan(activePlan);
    }

    return ReviewSession(
      id: 'today:${activePlan.dateKey}',
      kind: ReviewSessionKind.today,
      title: settings.appLanguage == AppLanguage.en
          ? (activePlan.completedCount > 0
              ? 'Continue Review'
              : 'Today\'s Review')
          : (activePlan.completedCount > 0 ? '继续回顾' : '今日复习'),
      subtitle: settings.appLanguage == AppLanguage.en
          ? 'A light set based on recent lessons and items worth revisiting.'
          : '基于最近学习和需要回看的内容，轻量过一遍。',
      tasks: activePlan.tasks,
      completedTaskIds: activePlan.completedTaskIds,
      countTowardActivity: true,
      syncWithTodayPlan: true,
      config: ReviewSessionConfig.reviewTab(
        mode: ReviewSessionMode.formal,
        nextLessonId: nextLesson?.id,
        nextLessonLabel: nextLesson == null
            ? null
            : LessonLocalizer.title(nextLesson, settings.appLanguage),
      ),
    );
  }

  static Future<ReviewSession?> createHomeTodayFlowSession(
    AppSettings settings, {
    String? nextLessonId,
  }) async {
    final now = DateTime.now();
    final context = await ReviewPlanner.loadContext(settings, now: now);
    final plan = await getTodayPlan(settings, now: now);
    final pendingTasks = plan.tasks
        .where((task) => !plan.completedTaskIds.contains(task.contentId))
        .toList(growable: false);
    if (pendingTasks.isEmpty) {
      return null;
    }

    final tasks = _selectHomeWarmUpTasks(
      pendingTasks: pendingTasks,
      weakTasks: ReviewPlanner.buildWeakCandidates(context),
      recentTasks: ReviewPlanner.buildRecentCandidates(context),
    );
    if (tasks.isEmpty) {
      return null;
    }

    return ReviewSession(
      id: 'home-today:${now.millisecondsSinceEpoch}',
      kind: ReviewSessionKind.today,
      title:
          settings.appLanguage == AppLanguage.en ? 'Today\'s Warm-Up' : '今日热身',
      subtitle: settings.appLanguage == AppLanguage.en
          ? 'Review a few key points first, then continue straight into the next lesson.'
          : '先快速回顾几个关键点，再直接进入下一课。',
      tasks: tasks,
      completedTaskIds: plan.completedTaskIds
          .where((id) => tasks.any((task) => task.contentId == id))
          .toList(growable: false),
      countTowardActivity: true,
      syncWithTodayPlan: true,
      config: ReviewSessionConfig(
        source: ReviewEntrySource.homeTodayPlan,
        mode: ReviewSessionMode.formal,
        autoContinueToLesson: nextLessonId?.trim().isNotEmpty ?? false,
        nextLessonId: nextLessonId,
        allowSkip: true,
        headerTitle:
            settings.appLanguage == AppLanguage.en ? 'Quick Warm-Up' : '热身复习',
        headerSubtitle: settings.appLanguage == AppLanguage.en
            ? 'Review quickly first, then move into the next lesson.'
            : '先快速回顾，再进入下一课',
      ),
    );
  }

  static Future<ReviewSession?> createQuickSession(
    AppSettings settings,
  ) async {
    final context = await ReviewPlanner.loadContext(settings);
    final signals = ReviewPlanner.buildSignals(context);
    final todayPlan = await getTodayPlan(settings);
    final pool = todayPlan.tasks
        .where((task) => !todayPlan.completedTaskIds.contains(task.contentId))
        .toList(growable: false);
    final candidatePool = pool.isNotEmpty
        ? pool
        : (signals.lightReviewTasks.isNotEmpty
            ? signals.lightReviewTasks
            : ReviewPlanner.buildRecentCandidates(context));
    final tasks = candidatePool.take(4).toList(growable: false);
    if (tasks.isEmpty) {
      return null;
    }

    return ReviewSession(
      id: 'quick:${DateTime.now().millisecondsSinceEpoch}',
      kind: ReviewSessionKind.quick,
      title: settings.appLanguage == AppLanguage.en
          ? '5-Minute Review'
          : '5 分钟快复习',
      subtitle: settings.appLanguage == AppLanguage.en
          ? 'Quickly clear a few high-value items without changing your rhythm.'
          : '不打断节奏，顺手过几个高价值内容就够了。',
      tasks: tasks,
      countTowardActivity: true,
      syncWithTodayPlan: false,
      config: const ReviewSessionConfig.reviewTab(
        mode: ReviewSessionMode.freePractice,
      ),
    );
  }

  static Future<ReviewSession?> createWeakSession(
    AppSettings settings,
  ) async {
    final context = await ReviewPlanner.loadContext(settings);
    final signals = ReviewPlanner.buildSignals(context);
    final tasks = signals.formalReviewTasks.where((task) {
      final state = context.learningStates[task.contentId];
      return state?.stage == LearningStage.weak || state?.isWeak == true;
    }).take(6).toList(growable: false);
    if (tasks.isEmpty) {
      return null;
    }

    return ReviewSession(
      id: 'weak:${DateTime.now().millisecondsSinceEpoch}',
      kind: ReviewSessionKind.weak,
      title: settings.appLanguage == AppLanguage.en ? 'Weak Spots' : '薄弱项再练',
      subtitle: settings.appLanguage == AppLanguage.en
          ? 'Give the items that still feel shaky one gentle extra pass.'
          : '把还不稳的点温和地再过一遍，更容易留下来。',
      tasks: tasks,
      countTowardActivity: true,
      syncWithTodayPlan: false,
      config: const ReviewSessionConfig.reviewTab(
        mode: ReviewSessionMode.freePractice,
      ),
    );
  }

  static Future<ReviewSession?> createTypeSession(
    AppSettings settings,
    ReviewContentType type,
  ) async {
    final context = await ReviewPlanner.loadContext(settings);
    final tasks = ReviewPlanner.buildTypeFocusTasks(context, type);
    if (tasks.isEmpty) {
      return null;
    }

    return ReviewSession(
      id: 'type:${reviewContentTypeKey(type)}:${DateTime.now().millisecondsSinceEpoch}',
      kind: ReviewSessionKind.typeFocus,
      title: _typeSessionTitle(settings, type),
      subtitle: settings.appLanguage == AppLanguage.en
          ? 'Stay in one content type and keep the decision cost low.'
          : '只看一种内容类型，少切换，脑子更轻松。',
      tasks: tasks,
      countTowardActivity: true,
      syncWithTodayPlan: false,
      config: const ReviewSessionConfig.reviewTab(
        mode: ReviewSessionMode.freePractice,
      ),
    );
  }

  static Future<ReviewSession?> createLessonPreviewSession(
    AppSettings settings,
    Lesson lesson,
  ) async {
    final context = await ReviewPlanner.loadContext(settings);
    final tasks = ReviewPlanner.buildLessonBridgeTasks(
      context,
      lesson,
      afterCompletion: false,
    );
    if (tasks.isEmpty) {
      return null;
    }

    return ReviewSession(
      id: 'lesson-preview:${lesson.id}:${DateTime.now().millisecondsSinceEpoch}',
      kind: ReviewSessionKind.lessonPreview,
      title: settings.appLanguage == AppLanguage.en
          ? 'Before This Lesson'
          : '课前回顾',
      subtitle: settings.appLanguage == AppLanguage.en
          ? 'Review a couple of recent points first, then move into the lesson.'
          : '先回顾两三个刚学过的点，再进入这节会更顺。',
      tasks: tasks,
      countTowardActivity: false,
      syncWithTodayPlan: true,
      config: const ReviewSessionConfig(
        source: ReviewEntrySource.lessonFollowUp,
        mode: ReviewSessionMode.formal,
      ),
    );
  }

  static Future<ReviewSession?> createLessonWrapUpSession(
    AppSettings settings,
    Lesson lesson,
  ) async {
    final context = await ReviewPlanner.loadContext(settings);
    final nextLesson = _findNextLesson(context.lessons, lesson.id);
    final tasks = ReviewPlanner.buildLessonBridgeTasks(
      context,
      lesson,
      afterCompletion: true,
    );
    if (tasks.isEmpty) {
      return null;
    }

    return ReviewSession(
      id: 'lesson-wrap:${lesson.id}:${DateTime.now().millisecondsSinceEpoch}',
      kind: ReviewSessionKind.lessonWrapUp,
      title: settings.appLanguage == AppLanguage.en ? 'Lesson Wrap-Up' : '课后巩固',
      subtitle: settings.appLanguage == AppLanguage.en
          ? 'A short reinforcement loop while this lesson is still fresh.'
          : '趁这节内容还热，顺手再巩固一下会更容易记住。',
      tasks: tasks,
      countTowardActivity: true,
      syncWithTodayPlan: true,
      config: ReviewSessionConfig(
        source: ReviewEntrySource.lessonFollowUp,
        mode: ReviewSessionMode.formal,
        nextLessonId: nextLesson?.id,
        nextLessonLabel: nextLesson == null
            ? null
            : LessonLocalizer.title(nextLesson, settings.appLanguage),
      ),
    );
  }

  static ReviewSession createSingleTaskSession(
    AppSettings settings,
    ReviewTask task,
  ) {
    return ReviewSession(
      id: 'single:${task.contentId}:${DateTime.now().millisecondsSinceEpoch}',
      kind: ReviewSessionKind.single,
      title: settings.appLanguage == AppLanguage.en ? 'Quick Review' : '快速回顾',
      subtitle: settings.appLanguage == AppLanguage.en
          ? 'Revisit just this one item and head back when you are ready.'
          : '只看这一条，回顾完就能继续刚才的学习。',
      tasks: <ReviewTask>[task],
      countTowardActivity: false,
      syncWithTodayPlan: true,
      config: const ReviewSessionConfig.reviewTab(
        mode: ReviewSessionMode.freePractice,
      ),
    );
  }

  static Future<bool> recordTaskResult(
    ReviewTask task, {
    required bool remembered,
    required bool syncWithTodayPlan,
  }) async {
    await LearningStateService.markReviewResult(
      contentId: task.contentId,
      type: task.type,
      objectType: task.objectType,
      lessonId: task.lessonId,
      remembered: remembered,
    );

    if (!syncWithTodayPlan) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_todayPlanKey);
    if (raw == null || raw.isEmpty) {
      return false;
    }

    DailyReviewPlan plan;
    try {
      plan = DailyReviewPlan.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return false;
    }

    if (!plan.tasks.any((item) => item.contentId == task.contentId) ||
        plan.completedTaskIds.contains(task.contentId)) {
      return false;
    }

    final wasCompleted = plan.isCompleted;
    final updated = plan.copyWith(
      startedAt: plan.startedAt ?? DateTime.now(),
      completedTaskIds: <String>[
        ...plan.completedTaskIds,
        task.contentId,
      ],
      completedAt: plan.pendingCount == 1 ? DateTime.now() : plan.completedAt,
    );
    await _saveTodayPlan(updated);

    if (!wasCompleted && updated.isCompleted) {
      await _appendSessionLog('today:${updated.dateKey}');
      await ProgressService.incrementReviewCount();
      return true;
    }

    return false;
  }

  static Future<void> finishSession(ReviewSession session) async {
    if (!session.countTowardActivity) {
      return;
    }

    await _appendSessionLog(session.id);
    await ProgressService.incrementReviewCount();
  }

  static Future<void> recordLessonStarted(Lesson lesson) async {
    final now = DateTime.now();

    for (final word in lesson.vocabulary) {
      await LearningStateService.upsertLearningState(
        contentId: buildWordContentId(word.text.plain),
        type: ReviewContentType.word,
        objectType: ReviewObjectType.wordReading,
        lessonId: lesson.id,
        lastViewedAt: now,
        isStarted: true,
        stage: LearningStage.learning,
      );
    }

    for (final pattern in lesson.patterns) {
      await LearningStateService.upsertLearningState(
        contentId: buildSentenceContentId(pattern.text.plain),
        type: ReviewContentType.sentence,
        objectType: ReviewObjectType.sentencePattern,
        lessonId: lesson.id,
        lastViewedAt: now,
        isStarted: true,
        stage: LearningStage.learning,
      );
    }
  }

  static Future<void> recordLessonCompleted(Lesson lesson) async {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1, 7);

    for (final word in lesson.vocabulary) {
      await LearningStateService.upsertLearningState(
        contentId: buildWordContentId(word.text.plain),
        type: ReviewContentType.word,
        objectType: ReviewObjectType.wordReading,
        lessonId: lesson.id,
        lastStudiedAt: now,
        lastViewedAt: now,
        isStarted: true,
        isCompleted: true,
        stage: LearningStage.reviewDue,
        needsReview: true,
        reviewPriority: 1,
        nextReviewAt: tomorrow,
      );
    }

    for (final pattern in lesson.patterns) {
      await LearningStateService.upsertLearningState(
        contentId: buildSentenceContentId(pattern.text.plain),
        type: ReviewContentType.sentence,
        objectType: ReviewObjectType.sentencePattern,
        lessonId: lesson.id,
        lastStudiedAt: now,
        lastViewedAt: now,
        isStarted: true,
        isCompleted: true,
        stage: LearningStage.reviewDue,
        needsReview: true,
        reviewPriority: 1,
        nextReviewAt: tomorrow,
      );
    }

    final groups = await AlphabetService.loadAlphabetGroups();
    final alphabetByArabic = <String, AlphabetLetter>{
      for (final group in groups)
        for (final letter in group.letters)
          removeArabicDiacritics(letter.arabic): letter,
    };
    final lessonLetters = lesson.letters
        .map((item) => alphabetByArabic[removeArabicDiacritics(item)])
        .whereType<AlphabetLetter>()
        .toList(growable: false);

    for (final letter in lessonLetters) {
      await LearningStateService.upsertLearningState(
        contentId: buildLetterNameContentId(letter.arabic),
        type: ReviewContentType.alphabet,
        objectType: ReviewObjectType.letterName,
        lessonId: lesson.id,
        lastStudiedAt: now,
        lastViewedAt: now,
        isStarted: true,
        isCompleted: true,
        stage: LearningStage.learning,
        reviewPriority: 1,
        nextReviewAt: now.add(const Duration(hours: 6)),
      );
      await LearningStateService.upsertLearningState(
        contentId: buildLetterSoundContentId(letter.arabic),
        type: ReviewContentType.alphabet,
        objectType: ReviewObjectType.letterSound,
        lessonId: lesson.id,
        lastStudiedAt: now,
        lastViewedAt: now,
        isStarted: true,
        isCompleted: true,
        stage: LearningStage.reviewDue,
        needsReview: true,
        reviewPriority: 2,
        nextReviewAt: tomorrow,
      );
      await LearningStateService.upsertLearningState(
        contentId: buildLetterFormContentId(letter.arabic),
        type: ReviewContentType.alphabet,
        objectType: ReviewObjectType.letterForm,
        lessonId: lesson.id,
        lastStudiedAt: now,
        lastViewedAt: now,
        isStarted: true,
        isCompleted: true,
        stage: LearningStage.learning,
        reviewPriority: 1,
        nextReviewAt: now.add(const Duration(hours: 12)),
      );
      for (final pronunciation in letter.pronunciations.take(2)) {
        await LearningStateService.upsertLearningState(
          contentId:
              buildSymbolReadingContentId(letter.arabic, pronunciation.key),
          type: ReviewContentType.pronunciation,
          objectType: ReviewObjectType.symbolReading,
          lessonId: lesson.id,
          lastStudiedAt: now,
          lastViewedAt: now,
          isStarted: true,
          isCompleted: true,
          stage: LearningStage.reviewDue,
          needsReview: true,
          reviewPriority: 1,
          nextReviewAt: tomorrow,
        );
      }
    }

    for (var index = 0; index + 1 < lessonLetters.length; index += 2) {
      final left = lessonLetters[index];
      final right = lessonLetters[index + 1];
      await LearningStateService.upsertLearningState(
        contentId: buildConfusionPairContentId(left.arabic, right.arabic),
        type: ReviewContentType.pair,
        objectType: ReviewObjectType.confusionPair,
        lessonId: lesson.id,
        lastStudiedAt: now,
        lastViewedAt: now,
        isStarted: true,
        isCompleted: true,
        stage: LearningStage.learning,
        reviewPriority: 1,
        nextReviewAt: now.add(const Duration(hours: 18)),
      );
    }
  }

  static Future<void> markWordFavorited(
    WordItem word, {
    String? lessonId,
    required bool isFavorited,
  }) async {
    await LearningStateService.setFavorited(
      contentId: buildWordContentId(word.text.plain),
      type: ReviewContentType.word,
      objectType: ReviewObjectType.wordReading,
      lessonId: lessonId,
      isFavorited: isFavorited,
    );
  }

  static Future<void> markGrammarViewed(
    String pageId, {
    String? lessonId,
  }) async {
    await LearningStateService.markViewed(
      contentId: buildGrammarContentId(pageId),
      type: ReviewContentType.grammar,
      objectType: ReviewObjectType.grammarReference,
      lessonId: lessonId,
    );
  }

  static Future<void> setGrammarFavorited(
    String pageId, {
    String? lessonId,
    required bool isFavorited,
  }) async {
    await LearningStateService.setFavorited(
      contentId: buildGrammarContentId(pageId),
      type: ReviewContentType.grammar,
      objectType: ReviewObjectType.grammarReference,
      lessonId: lessonId,
      isFavorited: isFavorited,
    );
  }

  static Future<void> markAlphabetViewed(
    AlphabetLetter letter, {
    String? lessonId,
  }) async {
    await LearningStateService.markViewed(
      contentId: buildAlphabetContentId(letter.arabic),
      type: ReviewContentType.alphabet,
      objectType: ReviewObjectType.letterSound,
      lessonId: lessonId,
    );
  }

  static Future<void> markAlphabetListenReadCompleted(
    AlphabetLetter letter, {
    String? lessonId,
  }) async {
    final now = DateTime.now();

    await LearningStateService.upsertLearningState(
      contentId: buildLetterSoundContentId(letter.arabic),
      type: ReviewContentType.alphabet,
      objectType: ReviewObjectType.letterSound,
      lessonId: lessonId,
      lastStudiedAt: now,
      lastViewedAt: now,
      isStarted: true,
      isCompleted: true,
      stage: LearningStage.reviewDue,
      needsReview: true,
      reviewPriority: 2,
      nextReviewAt: now,
    );

    await LearningStateService.upsertLearningState(
      contentId: buildLetterNameContentId(letter.arabic),
      type: ReviewContentType.alphabet,
      objectType: ReviewObjectType.letterName,
      lessonId: lessonId,
      lastStudiedAt: now,
      lastViewedAt: now,
      isStarted: true,
      isCompleted: true,
      stage: LearningStage.reviewDue,
      needsReview: true,
      reviewPriority: 1,
      nextReviewAt: now,
    );
  }

  static Future<void> markAlphabetWriteCompleted(
    AlphabetLetter letter, {
    String? lessonId,
  }) async {
    final now = DateTime.now();

    await LearningStateService.upsertLearningState(
      contentId: buildLetterFormContentId(letter.arabic),
      type: ReviewContentType.alphabet,
      objectType: ReviewObjectType.letterForm,
      lessonId: lessonId,
      lastStudiedAt: now,
      lastViewedAt: now,
      isStarted: true,
      isCompleted: true,
      stage: LearningStage.reviewDue,
      needsReview: true,
      reviewPriority: 1,
      nextReviewAt: now,
    );
  }

  static Future<void> setTaskWeak(
    ReviewTask task, {
    required bool isWeak,
  }) async {
    await LearningStateService.setWeak(
      contentId: task.contentId,
      type: task.type,
      objectType: task.objectType,
      lessonId: task.lessonId,
      isWeak: isWeak,
    );
  }

  static List<ReviewTask> _selectHomeWarmUpTasks({
    required List<ReviewTask> pendingTasks,
    required List<ReviewTask> weakTasks,
    required List<ReviewTask> recentTasks,
  }) {
    final selected = <ReviewTask>[];
    final seenIds = <String>{};

    void addFrom(List<ReviewTask> tasks) {
      for (final task in tasks) {
        if (selected.length >= 5) {
          return;
        }
        if (seenIds.add(task.contentId)) {
          selected.add(task);
        }
      }
    }

    addFrom(pendingTasks);
    if (selected.length < 2) {
      addFrom(weakTasks);
    }
    if (selected.length < 2) {
      addFrom(recentTasks);
    }

    return selected.take(5).toList(growable: false);
  }

  static Future<List<DateTime>> _getSessionLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final values = prefs.getStringList(_sessionLogsKey) ?? const <String>[];
    return values
        .map((value) => value.split('|'))
        .map(
          (parts) => parts.length < 2 ? null : DateTime.tryParse(parts.last),
        )
        .whereType<DateTime>()
        .toList(growable: false);
  }

  static Future<void> _appendSessionLog(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    final logs = prefs.getStringList(_sessionLogsKey) ?? const <String>[];
    final marker = '$sessionId|${DateTime.now().toIso8601String()}';
    final updated = <String>[marker, ...logs].take(60).toList(growable: false);
    await prefs.setStringList(_sessionLogsKey, updated);
    ReviewSyncService.markSessionLogged();
  }

  static int _calculateStreak(List<DateTime> logs, DateTime now) {
    if (logs.isEmpty) {
      return 0;
    }
    final uniqueDays = logs.map(reviewDateKey).toSet().toList(growable: false)
      ..sort();
    var streak = 0;
    var pointer = DateTime(now.year, now.month, now.day);
    while (uniqueDays.contains(reviewDateKey(pointer))) {
      streak++;
      pointer = pointer.subtract(const Duration(days: 1));
    }
    return streak;
  }

  static int _countWeeklyReviews(List<DateTime> logs, DateTime now) {
    return logs.where((log) => now.difference(log).inDays < 7).length;
  }

  static Future<void> _saveTodayPlan(
    DailyReviewPlan plan, {
    bool notify = true,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_todayPlanKey, jsonEncode(plan.toJson()));
    if (notify) {
      ReviewSyncService.markPlanChanged();
    }
  }

  static String _typeSessionTitle(
    AppSettings settings,
    ReviewContentType type,
  ) {
    final english = settings.appLanguage == AppLanguage.en;
    switch (type) {
      case ReviewContentType.word:
        return english ? 'Word Review' : '按单词复习';
      case ReviewContentType.pronunciation:
        return english ? 'Pronunciation Review' : '按发音复习';
      case ReviewContentType.pair:
        return english ? 'Distinction Review' : '按易混对复习';
      case ReviewContentType.sentence:
        return english ? 'Sentence Review' : '按句子复习';
      case ReviewContentType.grammar:
        return english ? 'Grammar Review' : '按语法复习';
      case ReviewContentType.alphabet:
        return english ? 'Alphabet Review' : '按字母复习';
    }
  }

  static Lesson? _findNextLesson(
    List<Lesson> lessons,
    String? currentLessonId,
  ) {
    if (lessons.isEmpty) {
      return null;
    }
    final sorted = List<Lesson>.from(lessons)
      ..sort((a, b) => a.sequence.compareTo(b.sequence));
    if (currentLessonId == null || currentLessonId.isEmpty) {
      return sorted.isEmpty ? null : sorted.first;
    }
    Lesson? current;
    for (final lesson in sorted) {
      if (lesson.id == currentLessonId) {
        current = lesson;
        break;
      }
    }
    if (current == null) {
      return sorted.isEmpty ? null : sorted.first;
    }
    for (final lesson in sorted) {
      if (lesson.sequence > current.sequence) {
        return lesson;
      }
    }
    return null;
  }
}
