import '../l10n/app_strings.dart';
import '../l10n/lesson_localizer.dart';
import '../models/app_settings.dart';
import '../models/lesson.dart';
import '../models/v2_lesson_progress_models.dart';
import '../services/learning_state_service.dart';
import '../services/progress_service.dart';
import '../services/review_service.dart';

enum HomePrimaryActionType {
  continueAlphabet,
  continueLesson,
  startReview,
  continuePremiumTrack,
}

enum CoursePrimaryActionType {
  startLesson,
  continueLesson,
  unlockAll,
  reviewDone,
}

enum ProfileLearningActionType {
  startLearning,
  continueLearning,
  startReview,
  reviewLessons,
}

class LearningPathSnapshot {
  final List<Lesson> lessons;
  final bool unlocked;
  final Set<String> completedLessonIds;
  final Set<String> startedLessonIds;
  final int reviewHistoryCount;
  final int streakDays;
  final int totalLessonCount;
  final int completedLessonCount;
  final int startedLessonCount;
  final int pendingReviewCount;
  final int freeLessonCount;
  final int freeCompletedLessonCount;
  final bool hasLockedLessons;
  final bool hasStartedAny;
  final bool hasCompletedAllLessons;
  final bool isTrialComplete;
  final int remainingLessonCount;
  final String? recommendedLessonId;
  final Lesson? recommendedLesson;
  final String? currentGroupId;
  final String? currentPhaseId;
  final String? currentLessonId;
  final List<ProgressStageSummary> stageSummaries;
  final Map<String, V2LessonStatus> lessonStatuses;
  final int coreCompletedLessonCount;
  final int reviewDueLessonCount;
  final int formalReviewCount;
  final int lightReviewCount;
  final int overdueReviewCount;
  final int stageReinforcementCount;
  final int trackedObjectCount;
  final int weakObjectCount;

  const LearningPathSnapshot({
    required this.lessons,
    required this.unlocked,
    required this.completedLessonIds,
    required this.startedLessonIds,
    required this.reviewHistoryCount,
    required this.streakDays,
    required this.totalLessonCount,
    required this.completedLessonCount,
    required this.startedLessonCount,
    required this.pendingReviewCount,
    required this.freeLessonCount,
    required this.freeCompletedLessonCount,
    required this.hasLockedLessons,
    required this.hasStartedAny,
    required this.hasCompletedAllLessons,
    required this.isTrialComplete,
    required this.remainingLessonCount,
    required this.recommendedLessonId,
    required this.recommendedLesson,
    required this.currentGroupId,
    required this.currentPhaseId,
    required this.currentLessonId,
    required this.stageSummaries,
    required this.lessonStatuses,
    required this.coreCompletedLessonCount,
    required this.reviewDueLessonCount,
    required this.formalReviewCount,
    required this.lightReviewCount,
    required this.overdueReviewCount,
    required this.stageReinforcementCount,
    required this.trackedObjectCount,
    required this.weakObjectCount,
  });

  String? get currentUnitId => currentGroupId;

  double get completionRate {
    return totalLessonCount == 0 ? 0 : completedLessonCount / totalLessonCount;
  }

  bool get nextLessonLocked {
    return recommendedLesson?.isLocked == true && !unlocked;
  }

  V2LessonStatus lessonStatusFor(String lessonId) {
    return lessonStatuses[lessonId] ?? V2LessonStatus.available;
  }

  bool get shouldPrioritizeReview =>
      formalReviewCount > 0 || overdueReviewCount > 0;

  int get actionableReviewCount =>
      formalReviewCount > 0 ? formalReviewCount : pendingReviewCount;
}

class HomeMainLearningViewModel {
  final String badgeText;
  final String title;
  final String? arabicPreview;
  final String description;
  final String? progressText;
  final String? reviewText;
  final double? progressValue;
  final String primaryButtonText;
  final String? secondaryText;
  final HomePrimaryActionType actionType;
  final Lesson? lesson;

  const HomeMainLearningViewModel({
    required this.badgeText,
    required this.title,
    required this.description,
    required this.primaryButtonText,
    required this.actionType,
    this.arabicPreview,
    this.progressText,
    this.reviewText,
    this.progressValue,
    this.secondaryText,
    this.lesson,
  });
}

class CourseCurrentLearningViewModel {
  final String badgeText;
  final String title;
  final String? arabicPreview;
  final String description;
  final String progressText;
  final String? reviewText;
  final String? stageText;
  final String primaryButtonText;
  final CoursePrimaryActionType actionType;
  final Lesson? lesson;

  const CourseCurrentLearningViewModel({
    required this.badgeText,
    required this.title,
    required this.description,
    required this.progressText,
    required this.primaryButtonText,
    required this.actionType,
    this.arabicPreview,
    this.reviewText,
    this.stageText,
    this.lesson,
  });
}

enum CoursePhaseStatus {
  current,
  available,
  locked,
  planned,
  completed,
}

class CoursePhaseViewModel {
  final String phaseId;
  final String title;
  final String description;
  final CoursePhaseStatus status;
  final String statusText;
  final String recommendedActionText;
  final String accessText;
  final bool canEnter;
  final bool isPlaceholder;
  final bool isPrimaryEntryTarget;
  final Lesson? lesson;
  final double? progressValue;
  final String? progressText;
  final String? footnote;

  const CoursePhaseViewModel({
    required this.phaseId,
    required this.title,
    required this.description,
    required this.status,
    required this.statusText,
    required this.recommendedActionText,
    required this.accessText,
    required this.canEnter,
    required this.isPlaceholder,
    required this.isPrimaryEntryTarget,
    this.lesson,
    this.progressValue,
    this.progressText,
    this.footnote,
  });
}

class CourseLearningMapViewModel {
  final List<CoursePhaseViewModel> phases;
  final bool hasPrimaryEntryTarget;

  const CourseLearningMapViewModel({
    required this.phases,
    required this.hasPrimaryEntryTarget,
  });
}

class LearningOverviewViewModel {
  final String title;
  final String suggestion;
  final List<String> stats;
  final String actionText;
  final ProfileLearningActionType actionType;
  final Lesson? lesson;

  const LearningOverviewViewModel({
    required this.title,
    required this.suggestion,
    required this.stats,
    required this.actionText,
    required this.actionType,
    this.lesson,
  });
}

class CurrentPlanViewModel {
  final String badge;
  final String title;
  final String description;
  final String footnote;
  final String? actionText;
  final bool unlocked;

  const CurrentPlanViewModel({
    required this.badge,
    required this.title,
    required this.description,
    required this.footnote,
    required this.unlocked,
    this.actionText,
  });
}

class UnlockPageViewModel {
  final String title;
  final String subtitle;
  final String priceText;
  final String priceTag;
  final List<String> trustTags;
  final List<String> benefitItems;
  final List<String> purchaseNotes;
  final String primaryActionText;
  final String secondaryActionText;
  final String footerHint;
  final bool unlocked;

  const UnlockPageViewModel({
    required this.title,
    required this.subtitle,
    required this.priceText,
    required this.priceTag,
    required this.trustTags,
    required this.benefitItems,
    required this.purchaseNotes,
    required this.primaryActionText,
    required this.secondaryActionText,
    required this.footerHint,
    required this.unlocked,
  });
}

class LearningPathViewModels {
  LearningPathViewModels._();

  static LearningPathSnapshot buildSnapshot({
    required List<Lesson> lessons,
    required ProgressSnapshot progress,
    required bool unlocked,
    ProgressOverview? progressOverview,
    ReviewEntrySnapshot? reviewEntry,
    LearningStateSummary? learningStateSummary,
  }) {
    final resolvedProgressOverview = progressOverview ??
        ProgressService.buildOverview(
            lessons: lessons, snapshot: progress, unlocked: unlocked);
    final lessonStatuses = resolvedProgressOverview.lessonStatuses;
    final completedLessonIds = lessonStatuses.entries
        .where((entry) => entry.value.isCompletedLike)
        .map((entry) => entry.key)
        .toSet();
    final startedLessonIds = lessonStatuses.entries
        .where((entry) => entry.value.isStartedLike)
        .map((entry) => entry.key)
        .toSet();
    final freeLessons = lessons.where((lesson) => !lesson.isLocked).toList();
    final freeCompletedLessonCount = freeLessons
        .where((lesson) => completedLessonIds.contains(lesson.id))
        .length;

    final recommendedLessonId = resolvedProgressOverview.recommendedLessonId;
    final recommendedLesson = recommendedLessonId == null
        ? null
        : _firstWhereOrNull(
            lessons,
            (lesson) => lesson.id == recommendedLessonId,
          );

    final completedLessonCount = resolvedProgressOverview.completedLessonCount;
    final startedLessonCount = resolvedProgressOverview.startedLessonCount;
    final totalLessonCount = resolvedProgressOverview.totalLessonCount;
    final fallbackReviewCount =
        (startedLessonCount - completedLessonCount).clamp(0, totalLessonCount);
    final pendingReviewCount =
        reviewEntry?.primaryReviewCount ?? fallbackReviewCount;

    return LearningPathSnapshot(
      lessons: lessons,
      unlocked: unlocked,
      completedLessonIds: completedLessonIds,
      startedLessonIds: startedLessonIds,
      reviewHistoryCount: resolvedProgressOverview.reviewCount,
      streakDays: resolvedProgressOverview.streakDays,
      totalLessonCount: totalLessonCount,
      completedLessonCount: completedLessonCount,
      startedLessonCount: startedLessonCount,
      pendingReviewCount: pendingReviewCount,
      freeLessonCount: freeLessons.length,
      freeCompletedLessonCount: freeCompletedLessonCount,
      hasLockedLessons: lessons.any((lesson) => lesson.isLocked),
      hasStartedAny: resolvedProgressOverview.startedLessonCount > 0,
      hasCompletedAllLessons:
          totalLessonCount > 0 && completedLessonCount >= totalLessonCount,
      isTrialComplete: freeLessons.isNotEmpty &&
          freeCompletedLessonCount >= freeLessons.length,
      remainingLessonCount: resolvedProgressOverview.remainingLessonCount,
      recommendedLessonId: recommendedLessonId,
      recommendedLesson: recommendedLesson,
      currentGroupId: resolvedProgressOverview.currentGroupId,
      currentPhaseId: resolvedProgressOverview.currentPhaseId,
      currentLessonId: resolvedProgressOverview.currentLessonId,
      stageSummaries: resolvedProgressOverview.stageSummaries,
      lessonStatuses: lessonStatuses,
      coreCompletedLessonCount:
          resolvedProgressOverview.coreCompletedLessonCount,
      reviewDueLessonCount: resolvedProgressOverview.reviewDueLessonCount,
      formalReviewCount: reviewEntry?.formalReviewCount ?? fallbackReviewCount,
      lightReviewCount: reviewEntry?.lightReviewCount ?? 0,
      overdueReviewCount: reviewEntry?.overdueReviewCount ?? 0,
      stageReinforcementCount: reviewEntry?.stageReinforcementCount ?? 0,
      trackedObjectCount: learningStateSummary?.trackedObjectCount ?? 0,
      weakObjectCount: learningStateSummary?.weakCount ?? 0,
    );
  }

  static HomeMainLearningViewModel buildHomeMainCard({
    required AppLanguage language,
    required LearningPathSnapshot snapshot,
    required bool onboardingCompleted,
  }) {
    if (snapshot.shouldPrioritizeReview && snapshot.completedLessonCount > 0) {
      return HomeMainLearningViewModel(
        badgeText: _copy(language, zh: '今日建议', en: 'Today\'s Tip'),
        title:
            _copy(language, zh: '先完成今天的复习', en: 'Finish Today\'s Review First'),
        arabicPreview: 'راجع الآن',
        description: _copy(
          language,
          zh: '复习之后再学新内容，记得会更稳。',
          en: 'Review first, then new learning will stay with you more steadily.',
        ),
        progressText:
            'Completed ${snapshot.completedLessonCount}/${snapshot.totalLessonCount} lessons',
        reviewText: _copy(
          language,
          zh: '待回顾 ${snapshot.actionableReviewCount} 项',
          en: '${snapshot.actionableReviewCount} items to review',
        ),
        primaryButtonText: _copy(language, zh: '开始复习', en: 'Start Review'),
        actionType: HomePrimaryActionType.startReview,
      );
    }

    if (onboardingCompleted && !snapshot.hasStartedAny) {
      return HomeMainLearningViewModel(
        badgeText: _copy(language, zh: '今日主线', en: 'Today\'s Focus'),
        title:
            _copy(language, zh: '开始你的阿语学习', en: 'Start Your Arabic Learning'),
        arabicPreview: 'تابع الحروف',
        description: _copy(
          language,
          zh: '从字母与发音开始，先完成第一步内容。',
          en: 'Start with letters and sounds, then finish the first small step.',
        ),
        progressText:
            _copy(language, zh: '已完成首学体验', en: 'First experience completed'),
        reviewText:
            _copy(language, zh: '下一步：分组字母', en: 'Next: grouped letters'),
        primaryButtonText: _copy(language, zh: '继续', en: 'Continue'),
        secondaryText: _copy(language, zh: '查看字母表', en: 'Browse Alphabet'),
        actionType: HomePrimaryActionType.continueAlphabet,
      );
    }

    if (!snapshot.unlocked &&
        snapshot.nextLessonLocked &&
        snapshot.completedLessonCount >= 3) {
      return HomeMainLearningViewModel(
        badgeText: _copy(language, zh: '下一步', en: 'Next Step'),
        title: _copy(language, zh: '继续完整课程', en: 'Continue the Full Course'),
        arabicPreview: 'أكمل المسار',
        description: _copy(
          language,
          zh: '解锁后可继续学习后面的课程内容。',
          en: 'Unlock to continue the remaining course content.',
        ),
        progressText:
            _copy(language, zh: '已完成前 3 课', en: 'First 3 lessons completed'),
        reviewText: snapshot.actionableReviewCount > 0
            ? _copy(
                language,
                zh: '待回顾 ${snapshot.actionableReviewCount} 项',
                en: '${snapshot.actionableReviewCount} items to review',
              )
            : null,
        primaryButtonText:
            _copy(language, zh: '查看完整内容', en: 'View Full Access'),
        secondaryText:
            _copy(language, zh: '回顾已学内容', en: 'Review What You Learned'),
        actionType: HomePrimaryActionType.continuePremiumTrack,
      );
    }

    if (snapshot.recommendedLesson != null) {
      final lesson = snapshot.recommendedLesson!;
      return HomeMainLearningViewModel(
        badgeText: _copy(language, zh: '今日主线', en: 'Today\'s Focus'),
        title: _copy(
          language,
          zh: '继续你的学习',
          en: 'Continue Your Learning',
        ),
        arabicPreview: lesson.titleAr,
        description: _copy(
          language,
          zh: '保持节奏，比学得快更重要。',
          en: 'Keeping a rhythm matters more than moving fast.',
        ),
        progressText: _copy(
          language,
          zh: '进度 ${snapshot.completedLessonCount}/${snapshot.totalLessonCount}',
          en: 'Progress ${snapshot.completedLessonCount}/${snapshot.totalLessonCount}',
        ),
        reviewText: snapshot.actionableReviewCount > 0
            ? _copy(
                language,
                zh: '待复习 ${snapshot.actionableReviewCount} 项',
                en: '${snapshot.actionableReviewCount} items to review',
              )
            : null,
        progressValue: snapshot.completionRate,
        primaryButtonText: _copy(language, zh: '继续学习', en: 'Continue Learning'),
        secondaryText: _copy(language, zh: '查看课程', en: 'View Lessons'),
        actionType: HomePrimaryActionType.continueLesson,
        lesson: lesson,
      );
    }

    return HomeMainLearningViewModel(
      badgeText: _copy(language, zh: '今日主线', en: 'Today\'s Focus'),
      title: _copy(language, zh: '从字母开始', en: 'Start with the Alphabet'),
      arabicPreview: 'ابدأ من الحروف',
      description: _copy(
        language,
        zh: '从字母与发音开始，先完成第一步内容。',
        en: 'Start with letters and sounds, then finish the first small step.',
      ),
      primaryButtonText: _copy(language, zh: '开始', en: 'Start'),
      secondaryText: _copy(language, zh: '查看字母表', en: 'Browse Alphabet'),
      actionType: HomePrimaryActionType.continueAlphabet,
    );
  }

  static CourseCurrentLearningViewModel buildCourseCurrentLearning({
    required AppLanguage language,
    required AppStrings strings,
    required LearningPathSnapshot snapshot,
  }) {
    final reviewText = snapshot.actionableReviewCount > 0
        ? _copy(
            language,
            zh: '待复习 ${snapshot.actionableReviewCount} 项',
            en: '${snapshot.actionableReviewCount} items to review',
          )
        : null;
    final progressText = strings.t(
      'course.completed_summary',
      params: <String, String>{
        'completed': '${snapshot.completedLessonCount}',
        'total': '${snapshot.totalLessonCount}',
      },
    );

    if (snapshot.hasCompletedAllLessons) {
      return CourseCurrentLearningViewModel(
        badgeText: _copy(language, zh: '已全部完成', en: 'All Done'),
        title: _copy(language, zh: '全部课程已完成', en: 'All Lessons Completed'),
        arabicPreview: snapshot.recommendedLesson?.titleAr,
        description: _copy(
          language,
          zh: '主线课程已经完成，现在更适合按需回看和复习。',
          en: 'The main course is complete. Now it makes more sense to revisit and review as needed.',
        ),
        progressText: progressText,
        reviewText: reviewText,
        stageText: _copy(language, zh: '完整课程已完成', en: 'Full course complete'),
        primaryButtonText: _copy(language, zh: '回看课程', en: 'Review Lessons'),
        actionType: CoursePrimaryActionType.reviewDone,
        lesson: snapshot.recommendedLesson,
      );
    }

    if (!snapshot.unlocked && snapshot.isTrialComplete) {
      return CourseCurrentLearningViewModel(
        badgeText: _copy(language, zh: '体验已完成', en: 'Trial Complete'),
        title: _copy(language, zh: '继续完整课程', en: 'Continue the Full Course'),
        description: _copy(
          language,
          zh: '体验内容已经完成，解锁后可继续后面的课程。',
          en: 'The trial content is done. Unlock to continue the remaining lessons.',
        ),
        progressText: progressText,
        reviewText: reviewText,
        stageText: _copy(language,
            zh: '前三节免费体验已完成', en: 'First 3 free lessons completed'),
        primaryButtonText:
            _copy(language, zh: '解锁全部课程', en: 'Unlock All Lessons'),
        actionType: CoursePrimaryActionType.unlockAll,
      );
    }

    if (snapshot.recommendedLesson == null) {
      return CourseCurrentLearningViewModel(
        badgeText: _copy(language, zh: '开始学习', en: 'Start Learning'),
        title: _copy(language, zh: '从第一课开始', en: 'Start with Lesson 1'),
        description: _copy(
          language,
          zh: '从第一节开始，先完成今天这一课。',
          en: 'Start with lesson 1 and finish today\'s first lesson.',
        ),
        progressText: progressText,
        primaryButtonText: _copy(language, zh: '开始学习', en: 'Start Learning'),
        actionType: CoursePrimaryActionType.startLesson,
      );
    }

    final lesson = snapshot.recommendedLesson!;
    return CourseCurrentLearningViewModel(
      badgeText: _copy(
        language,
        zh: snapshot.hasStartedAny ? '继续学习' : '开始学习',
        en: snapshot.hasStartedAny ? 'Continue Learning' : 'Start Learning',
      ),
      title: LessonLocalizer.title(lesson, language),
      arabicPreview: lesson.titleAr,
      description: _copy(
        language,
        zh: snapshot.hasStartedAny ? '保持节奏，把这一课继续学完。' : '从这一课开始，先完成第一节内容。',
        en: snapshot.hasStartedAny
            ? 'Keep your rhythm and finish this lesson next.'
            : 'Start here and finish the first lesson.',
      ),
      progressText: progressText,
      reviewText: reviewText,
      stageText: snapshot.unlocked
          ? _copy(language, zh: '完整课程已开启', en: 'Full course unlocked')
          : _copy(language,
              zh: '当前处于免费体验阶段', en: 'You are in the free trial stage'),
      primaryButtonText: _copy(
        language,
        zh: snapshot.hasStartedAny ? '继续学习' : '开始学习',
        en: snapshot.hasStartedAny ? 'Continue Learning' : 'Start Learning',
      ),
      actionType: snapshot.hasStartedAny
          ? CoursePrimaryActionType.continueLesson
          : CoursePrimaryActionType.startLesson,
      lesson: lesson,
    );
  }

  static CourseLearningMapViewModel buildCourseLearningMap({
    required AppLanguage language,
    required LearningPathSnapshot snapshot,
  }) {
    final phases = snapshot.stageSummaries.map((summary) {
      final phaseLessons = snapshot.lessons
          .where(
              (lesson) => _phaseIdForUnitId(lesson.unitId) == summary.stageId)
          .toList(growable: false);
      final stageLesson = _resolveStageLesson(
        lessons: phaseLessons,
        snapshot: snapshot,
      );
      final allLocked = phaseLessons.isNotEmpty &&
          phaseLessons.every((lesson) => lesson.isLocked && !snapshot.unlocked);
      final status = _mapCoursePhaseStatus(
        phaseStatus: summary.status,
        allLocked: allLocked,
      );
      final unitLabel = phaseLessons.isNotEmpty
          ? phaseLessons.first.unitId
          : summary.stageId.toUpperCase();

      return CoursePhaseViewModel(
        phaseId: summary.stageId,
        title: _copy(
          language,
          zh: '学习单元 $unitLabel',
          en: 'Unit $unitLabel',
        ),
        description: _phaseDescription(
          language,
          status: summary.status,
          lessonCount: summary.totalLessonCount,
        ),
        status: status,
        statusText: _phaseStatusText(language, status),
        recommendedActionText: _phaseActionText(
          language,
          status: status,
          canEnter: stageLesson != null,
        ),
        accessText: _phaseAccessText(
          language,
          status: status,
          canEnter: stageLesson != null,
        ),
        canEnter: stageLesson != null,
        isPlaceholder: false,
        isPrimaryEntryTarget: summary.stageId == snapshot.currentPhaseId,
        lesson: stageLesson,
        progressValue: summary.totalLessonCount == 0
            ? null
            : summary.completedLessonCount / summary.totalLessonCount,
        progressText: _copy(
          language,
          zh: '已完成 ${summary.completedLessonCount}/${summary.totalLessonCount} 节',
          en: '${summary.completedLessonCount}/${summary.totalLessonCount} lessons completed',
        ),
        footnote: summary.reviewDueCount > 0
            ? _copy(
                language,
                zh: '待回顾 ${summary.reviewDueCount} 节',
                en: '${summary.reviewDueCount} lessons need review',
              )
            : null,
      );
    }).toList(growable: false);

    return CourseLearningMapViewModel(
      phases: phases,
      hasPrimaryEntryTarget: phases.any((phase) => phase.isPrimaryEntryTarget),
    );
  }

  static LearningOverviewViewModel buildProfileOverview({
    required AppLanguage language,
    required AppStrings strings,
    required LearningPathSnapshot snapshot,
  }) {
    final lesson = snapshot.recommendedLesson;

    if (snapshot.shouldPrioritizeReview) {
      return LearningOverviewViewModel(
        title: strings.t('profile.overview_title_review_first'),
        suggestion: strings.t('profile.overview_suggestion_review_first'),
        stats: <String>[
          strings.t(
            'profile.overview_review',
            params: <String, String>{
              'count': '${snapshot.actionableReviewCount}'
            },
          ),
          strings.t('profile.overview_lesson_not_finished'),
        ],
        actionText: strings.t('profile.overview_action_review'),
        actionType: ProfileLearningActionType.startReview,
        lesson: lesson,
      );
    }

    if (!snapshot.hasStartedAny ||
        (snapshot.completedLessonCount == 0 &&
            snapshot.startedLessonCount == 0)) {
      return LearningOverviewViewModel(
        title: strings.t('profile.overview_title_start_learning'),
        suggestion: strings.t('profile.overview_suggestion_start_learning'),
        stats: <String>[
          strings.t('profile.overview_stage_beginner'),
          strings.t('profile.overview_first_step_progress'),
        ],
        actionText: strings.t('profile.overview_action_start_learning'),
        actionType: ProfileLearningActionType.startLearning,
        lesson: lesson,
      );
    }

    if (snapshot.hasCompletedAllLessons) {
      return LearningOverviewViewModel(
        title: strings.t('profile.overview_title_completed'),
        suggestion: strings.t('profile.overview_suggestion_completed'),
        stats: <String>[
          strings.t(
            'profile.overview_completed',
            params: <String, String>{
              'completed': '${snapshot.completedLessonCount}',
              'total': '${snapshot.totalLessonCount}',
            },
          ),
          strings.t('profile.overview_stage_full'),
          if (snapshot.streakDays > 0)
            strings.t(
              'profile.overview_streak_days',
              params: <String, String>{'days': '${snapshot.streakDays}'},
            ),
        ],
        actionText: strings.t('profile.overview_action_review_lessons'),
        actionType: ProfileLearningActionType.reviewLessons,
        lesson: lesson,
      );
    }

    return LearningOverviewViewModel(
      title: strings.t('profile.overview_title_continue_learning'),
      suggestion: strings.t('profile.overview_suggestion_continue_learning'),
      stats: <String>[
        if (lesson != null)
          strings.t(
            'profile.overview_lesson_in_progress',
            params: <String, String>{'lesson': '${lesson.sequence}'},
          ),
        strings.t(
          'profile.overview_completed',
          params: <String, String>{
            'completed': '${snapshot.completedLessonCount}',
            'total': '${snapshot.totalLessonCount}',
          },
        ),
        if (snapshot.streakDays > 0)
          strings.t(
            'profile.overview_streak_days',
            params: <String, String>{'days': '${snapshot.streakDays}'},
          ),
      ],
      actionText: strings.t('profile.overview_action_continue_learning'),
      actionType: ProfileLearningActionType.continueLearning,
      lesson: lesson,
    );
  }

  static CurrentPlanViewModel buildCurrentPlan({
    required AppStrings strings,
    required LearningPathSnapshot snapshot,
  }) {
    if (snapshot.unlocked || !snapshot.hasLockedLessons) {
      return CurrentPlanViewModel(
        badge: '',
        title: strings.t('profile.plan_full_title'),
        description: strings.t('profile.plan_full_description'),
        footnote: '',
        unlocked: true,
      );
    }

    return CurrentPlanViewModel(
      badge: strings.t('profile.plan_trial_badge'),
      title: strings.t('profile.plan_trial_title'),
      description: strings.t(
        'profile.plan_trial_description',
        params: <String, String>{'free': '${snapshot.freeLessonCount}'},
      ),
      footnote: strings.t(
        'profile.plan_trial_footnote',
        params: <String, String>{
          'completed': '${snapshot.freeCompletedLessonCount}',
          'total': '${snapshot.freeLessonCount}',
        },
      ),
      unlocked: false,
      actionText: strings.t('profile.plan_unlock_action'),
    );
  }

  static UnlockPageViewModel buildUnlockPage({
    required AppStrings strings,
    required LearningPathSnapshot snapshot,
  }) {
    final remainingLessons =
        (snapshot.totalLessonCount - snapshot.freeLessonCount).clamp(
      0,
      snapshot.totalLessonCount,
    );

    final subtitle = snapshot.unlocked
        ? strings.t('unlock.hero_subtitle_unlocked')
        : snapshot.isTrialComplete
            ? strings.t(
                'unlock.hero_subtitle_completed',
                params: <String, String>{
                  'free': '${snapshot.freeLessonCount}',
                  'remaining': '$remainingLessons',
                },
              )
            : strings.t(
                'unlock.hero_subtitle_trial',
                params: <String, String>{
                  'free': '${snapshot.freeLessonCount}',
                  'remaining': '$remainingLessons',
                },
              );

    return UnlockPageViewModel(
      title: strings.t('unlock.hero_title'),
      subtitle: subtitle,
      priceText: strings.t('unlock.price'),
      priceTag: strings.t('unlock.price_tag'),
      trustTags: <String>[
        strings.t('unlock.trust_subscription'),
        strings.t('unlock.trust_ads'),
        strings.t('unlock.trust_lifetime'),
      ],
      benefitItems: <String>[
        strings.t(
          'unlock.benefit_all_lessons',
          params: <String, String>{'count': '${snapshot.totalLessonCount}'},
        ),
        strings.t('unlock.benefit_learning_flow'),
        strings.t('unlock.benefit_content_full'),
        strings.t('unlock.benefit_review_full'),
      ],
      purchaseNotes: <String>[
        strings.t('unlock.note_one_time'),
        strings.t('unlock.note_restore'),
        strings.t(
          'unlock.note_current_release',
          params: <String, String>{'remaining': '$remainingLessons'},
        ),
        strings.t('unlock.note_future'),
      ],
      primaryActionText: snapshot.unlocked
          ? strings.t('unlock.action_unlocked')
          : strings.t('unlock.primary_action'),
      secondaryActionText: strings.t('unlock.secondary_action'),
      footerHint: strings.t('unlock.footer'),
      unlocked: snapshot.unlocked,
    );
  }

  static String unitTitle(String? unitId, AppStrings strings) {
    switch (unitId) {
      case 'U1':
        return strings.t('profile.unit_1');
      case 'U2':
        return strings.t('profile.unit_2');
      case 'U3':
        return strings.t('profile.unit_3');
      case 'U4':
        return strings.t('profile.unit_4');
      default:
        return strings.t('profile.unit_default');
    }
  }
}

Lesson? _resolveStageLesson({
  required List<Lesson> lessons,
  required LearningPathSnapshot snapshot,
}) {
  if (lessons.isEmpty) {
    return null;
  }

  final current = _firstWhereOrNull(
    lessons,
    (lesson) => snapshot.lessonStatusFor(lesson.id).isCurrentLike,
  );
  if (current != null) {
    return current;
  }

  final next = _firstWhereOrNull(
    lessons,
    (lesson) {
      final status = snapshot.lessonStatusFor(lesson.id);
      return status == V2LessonStatus.available ||
          status == V2LessonStatus.coreCompleted;
    },
  );
  if (next != null) {
    return next;
  }

  return _firstWhereOrNull(
        lessons,
        (lesson) => snapshot.lessonStatusFor(lesson.id).isCompletedLike,
      ) ??
      lessons.first;
}

String _phaseIdForUnitId(String? unitId) {
  if (unitId == null || unitId.isEmpty) {
    return 'phase_unknown';
  }
  return 'phase_${unitId.toLowerCase()}';
}

CoursePhaseStatus _mapCoursePhaseStatus({
  required V2PhaseStatus phaseStatus,
  required bool allLocked,
}) {
  if (allLocked) {
    return CoursePhaseStatus.locked;
  }
  switch (phaseStatus) {
    case V2PhaseStatus.notStarted:
      return CoursePhaseStatus.available;
    case V2PhaseStatus.active:
    case V2PhaseStatus.consolidation:
      return CoursePhaseStatus.current;
    case V2PhaseStatus.completed:
      return CoursePhaseStatus.completed;
  }
}

String _phaseDescription(
  AppLanguage language, {
  required V2PhaseStatus status,
  required int lessonCount,
}) {
  switch (status) {
    case V2PhaseStatus.notStarted:
      return _copy(
        language,
        zh: '这一单元还没开始，共 $lessonCount 节课。',
        en: 'This unit has not started yet and contains $lessonCount lessons.',
      );
    case V2PhaseStatus.active:
      return _copy(
        language,
        zh: '这一单元正在进行中，继续沿当前主线推进。',
        en: 'This unit is active. Continue along the current learning path.',
      );
    case V2PhaseStatus.consolidation:
      return _copy(
        language,
        zh: '这一单元已学完主线，但还有回顾巩固信号。',
        en: 'The main path is finished here, but some review signals remain.',
      );
    case V2PhaseStatus.completed:
      return _copy(
        language,
        zh: '这一单元已稳定完成，可按需回看。',
        en: 'This unit is completed and can be revisited as needed.',
      );
  }
}

String _phaseActionText(
  AppLanguage language, {
  required CoursePhaseStatus status,
  required bool canEnter,
}) {
  if (!canEnter) {
    return _copy(language, zh: '当前不可进入', en: 'Not available to enter');
  }
  switch (status) {
    case CoursePhaseStatus.current:
      return _copy(language, zh: '继续这个单元', en: 'Continue This Unit');
    case CoursePhaseStatus.available:
      return _copy(language, zh: '开始这个单元', en: 'Start This Unit');
    case CoursePhaseStatus.locked:
      return _copy(language, zh: '当前未开放', en: 'Currently Locked');
    case CoursePhaseStatus.planned:
      return _copy(language, zh: '等待内容接入', en: 'Waiting for Content');
    case CoursePhaseStatus.completed:
      return _copy(language, zh: '回看这个单元', en: 'Review This Unit');
  }
}

String _phaseAccessText(
  AppLanguage language, {
  required CoursePhaseStatus status,
  required bool canEnter,
}) {
  if (!canEnter) {
    return _copy(language,
        zh: '当前没有可进入的课程入口。',
        en: 'There is no available lesson entry in this unit right now.');
  }
  switch (status) {
    case CoursePhaseStatus.current:
      return _copy(language,
          zh: '这是当前课程主线所在单元。',
          en: 'This is the unit currently driving the main learning path.');
    case CoursePhaseStatus.available:
      return _copy(language,
          zh: '这一单元可以直接进入。', en: 'This unit is ready to enter.');
    case CoursePhaseStatus.locked:
      return _copy(language,
          zh: '这一单元当前锁定。', en: 'This unit is currently locked.');
    case CoursePhaseStatus.planned:
      return _copy(language,
          zh: '这一单元仍在规划中。', en: 'This unit is still planned only.');
    case CoursePhaseStatus.completed:
      return _copy(language,
          zh: '这一单元已经完成，可回看复盘。',
          en: 'This unit is finished and available for review.');
  }
}

String _phaseStatusText(
  AppLanguage language,
  CoursePhaseStatus status,
) {
  switch (status) {
    case CoursePhaseStatus.current:
      return _copy(language, zh: '当前阶段', en: 'Current');
    case CoursePhaseStatus.available:
      return _copy(language, zh: '可开始', en: 'Available');
    case CoursePhaseStatus.locked:
      return _copy(language, zh: '未开放', en: 'Locked');
    case CoursePhaseStatus.planned:
      return _copy(language, zh: '规划中', en: 'Planned');
    case CoursePhaseStatus.completed:
      return _copy(language, zh: '已完成', en: 'Completed');
  }
}

String _copy(
  AppLanguage language, {
  required String zh,
  required String en,
}) {
  return language == AppLanguage.en ? en : zh;
}

T? _firstWhereOrNull<T>(
  Iterable<T> items,
  bool Function(T item) test,
) {
  for (final item in items) {
    if (test(item)) {
      return item;
    }
  }
  return null;
}
