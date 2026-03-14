import '../l10n/app_strings.dart';
import '../l10n/lesson_localizer.dart';
import '../models/app_settings.dart';
import '../models/lesson.dart';
import '../services/progress_service.dart';

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
  final Lesson? recommendedLesson;
  final String? currentUnitId;

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
    required this.recommendedLesson,
    required this.currentUnitId,
  });

  double get completionRate {
    return totalLessonCount == 0 ? 0 : completedLessonCount / totalLessonCount;
  }

  bool get nextLessonLocked {
    return recommendedLesson?.isLocked == true && !unlocked;
  }
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

class LearningOverviewViewModel {
  final String title;
  final String suggestion;
  final List<String> stats;

  const LearningOverviewViewModel({
    required this.title,
    required this.suggestion,
    required this.stats,
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
  }) {
    final lessonIds = lessons.map((lesson) => lesson.id).toSet();
    final completedLessonIds = progress.completedLessons.intersection(lessonIds);
    final startedLessonIds = progress.startedLessons.intersection(lessonIds);
    final freeLessons = lessons.where((lesson) => !lesson.isLocked).toList();
    final freeCompletedLessonCount = freeLessons
        .where((lesson) => completedLessonIds.contains(lesson.id))
        .length;

    final recommendedLesson = _resolveRecommendedLesson(
          lessons: lessons,
          progress: progress,
          unlocked: unlocked,
        ) ??
        (lessons.isNotEmpty ? lessons.last : null);
    final currentUnitId = _resolveCurrentUnitId(
      lessons: lessons,
      progress: progress,
      unlocked: unlocked,
    );

    final completedLessonCount = completedLessonIds.length;
    final startedLessonCount = startedLessonIds.length;
    final totalLessonCount = lessons.length;
    final pendingReviewCount =
        (startedLessonCount - completedLessonCount).clamp(0, totalLessonCount);

    return LearningPathSnapshot(
      lessons: lessons,
      unlocked: unlocked,
      completedLessonIds: completedLessonIds,
      startedLessonIds: startedLessonIds,
      reviewHistoryCount: progress.reviewCount,
      streakDays: progress.streakDays,
      totalLessonCount: totalLessonCount,
      completedLessonCount: completedLessonCount,
      startedLessonCount: startedLessonCount,
      pendingReviewCount: pendingReviewCount,
      freeLessonCount: freeLessons.length,
      freeCompletedLessonCount: freeCompletedLessonCount,
      hasLockedLessons: lessons.any((lesson) => lesson.isLocked),
      hasStartedAny: startedLessonCount > 0,
      hasCompletedAllLessons:
          totalLessonCount > 0 && completedLessonCount >= totalLessonCount,
      isTrialComplete:
          freeLessons.isNotEmpty && freeCompletedLessonCount >= freeLessons.length,
      remainingLessonCount:
          (totalLessonCount - completedLessonCount).clamp(0, totalLessonCount),
      recommendedLesson: recommendedLesson,
      currentUnitId: currentUnitId,
    );
  }

  static HomeMainLearningViewModel buildHomeMainCard({
    required AppLanguage language,
    required LearningPathSnapshot snapshot,
    required bool onboardingCompleted,
  }) {
    if (snapshot.pendingReviewCount > 0 && snapshot.completedLessonCount > 0) {
      return HomeMainLearningViewModel(
        badgeText: _copy(language, zh: '今日建议', en: 'Today\'s Tip'),
        title: _copy(language, zh: '先复习一下', en: 'Review First'),
        arabicPreview: 'راجع الآن',
        description: _copy(
          language,
          zh: '花 2 分钟，回顾刚学过的重点。',
          en: 'Take two minutes to refresh the most recent points.',
        ),
        progressText:
            'Completed ${snapshot.completedLessonCount}/${snapshot.totalLessonCount} lessons',
        reviewText: _copy(
          language,
          zh: '待回顾 ${snapshot.pendingReviewCount} 项',
          en: '${snapshot.pendingReviewCount} items to review',
        ),
        primaryButtonText: _copy(language, zh: '开始复习', en: 'Start Review'),
        actionType: HomePrimaryActionType.startReview,
      );
    }

    if (onboardingCompleted && !snapshot.hasStartedAny) {
      return HomeMainLearningViewModel(
        badgeText: _copy(language, zh: '今日主线', en: 'Today\'s Focus'),
        title: _copy(language, zh: '继续字母学习', en: 'Continue Alphabet Learning'),
        arabicPreview: 'تابع الحروف',
        description: _copy(
          language,
          zh: '再学 1 个字母，继续打好基础。',
          en: 'Learn one more letter and keep strengthening the base.',
        ),
        progressText:
            _copy(language, zh: '已完成首学体验', en: 'First experience completed'),
        reviewText: _copy(language, zh: '下一步：分组字母', en: 'Next: grouped letters'),
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
          zh: '你已完成免费部分，继续后续内容。',
          en: 'You finished the free part. Continue the rest of the path.',
        ),
        progressText: _copy(language, zh: '已完成前 3 课', en: 'First 3 lessons completed'),
        reviewText: snapshot.pendingReviewCount > 0
            ? _copy(
                language,
                zh: '待回顾 ${snapshot.pendingReviewCount} 项',
                en: '${snapshot.pendingReviewCount} items to review',
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
          zh: '继续${LessonLocalizer.title(lesson, language)}',
          en: 'Continue ${LessonLocalizer.title(lesson, language)}',
        ),
        arabicPreview: lesson.titleAr,
        description: _copy(
          language,
          zh: '今天建议先完成这一小节。',
          en: 'This is the most useful next step for today.',
        ),
        progressText: _copy(
          language,
          zh: '进度 ${snapshot.completedLessonCount}/${snapshot.totalLessonCount}',
          en:
              'Progress ${snapshot.completedLessonCount}/${snapshot.totalLessonCount}',
        ),
        reviewText: snapshot.pendingReviewCount > 0
            ? _copy(
                language,
                zh: '待复习 ${snapshot.pendingReviewCount} 项',
                en: '${snapshot.pendingReviewCount} items to review',
              )
            : null,
        progressValue: snapshot.completionRate,
        primaryButtonText:
            _copy(language, zh: '继续学习', en: 'Continue Learning'),
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
        zh: '先建立字母识别和发音基础，再进入课程。',
        en: 'Build letter recognition and sound first, then move into lessons.',
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
    final reviewText = snapshot.pendingReviewCount > 0
        ? _copy(
            language,
            zh: '待复习 ${snapshot.pendingReviewCount} 项',
            en: '${snapshot.pendingReviewCount} items to review',
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
          zh: '16 节课程都已学完，现在更适合回看熟悉内容。',
          en: 'All 16 lessons are done. This is a good time to revisit what you learned.',
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
          zh: '前三节体验课已经完成，解锁后可继续剩余 13 节正式课程。',
          en: 'You finished the free trial. Unlock to continue the remaining 13 lessons.',
        ),
        progressText: progressText,
        reviewText: reviewText,
        stageText:
            _copy(language, zh: '前三节免费体验已完成', en: 'First 3 free lessons completed'),
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
          zh: '课程数据已准备好，先完成一个轻量的学习闭环。',
          en: 'Your lessons are ready. Start with one light and complete learning loop.',
        ),
        progressText: progressText,
        primaryButtonText:
            _copy(language, zh: '开始学习', en: 'Start Learning'),
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
        zh: snapshot.hasStartedAny
            ? '优先把这节课学完，页面会继续沿着当前进度推进。'
            : '从这一节开始，先完成一次完整、轻量的学习体验。',
        en: snapshot.hasStartedAny
            ? 'Finish this lesson next to keep your learning continuous.'
            : 'Start here for a light, complete first lesson experience.',
      ),
      progressText: progressText,
      reviewText: reviewText,
      stageText: snapshot.unlocked
          ? _copy(language, zh: '完整课程已开启', en: 'Full course unlocked')
          : _copy(language, zh: '当前处于免费体验阶段', en: 'You are in the free trial stage'),
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

  static LearningOverviewViewModel buildProfileOverview({
    required AppLanguage language,
    required AppStrings strings,
    required LearningPathSnapshot snapshot,
  }) {
    final title = snapshot.completedLessonCount == 0
        ? strings.t('profile.overview_title_new')
        : snapshot.hasCompletedAllLessons
            ? strings.t('profile.overview_title_completed')
            : strings.t(
                'profile.overview_title_unit',
                params: <String, String>{
                  'unit': unitTitle(snapshot.currentUnitId, strings),
                },
              );

    String suggestion;
    if (!snapshot.unlocked && snapshot.isTrialComplete) {
      suggestion = strings.t('profile.overview_suggestion_unlock');
    } else if (snapshot.pendingReviewCount > 0) {
      suggestion = strings.t(
        'profile.overview_suggestion_review',
        params: <String, String>{'count': '${snapshot.pendingReviewCount}'},
      );
    } else if (snapshot.recommendedLesson != null) {
      suggestion = strings.t(
        snapshot.completedLessonCount == 0
            ? 'profile.overview_suggestion_first_lesson'
            : 'profile.overview_suggestion_continue',
        params: <String, String>{
          'lesson':
              LessonLocalizer.title(snapshot.recommendedLesson!, language),
        },
      );
    } else {
      suggestion = strings.t('profile.overview_suggestion_keep_going');
    }

    final streakText = snapshot.streakDays == 0
        ? strings.t('profile.overview_streak_start')
        : strings.t(
            'profile.overview_streak_days',
            params: <String, String>{'days': '${snapshot.streakDays}'},
          );

    final stageText = !snapshot.unlocked
        ? (snapshot.isTrialComplete
            ? strings.t('profile.overview_stage_trial_done')
            : strings.t('profile.overview_stage_trial'))
        : snapshot.currentUnitId != null
            ? strings.t(
                'profile.overview_stage_unit',
                params: <String, String>{
                  'unit': unitTitle(snapshot.currentUnitId, strings),
                },
              )
            : strings.t('profile.overview_stage_full');

    return LearningOverviewViewModel(
      title: title,
      suggestion: suggestion,
      stats: <String>[
        strings.t(
          'profile.overview_completed',
          params: <String, String>{
            'completed': '${snapshot.completedLessonCount}',
            'total': '${snapshot.totalLessonCount}',
          },
        ),
        stageText,
        streakText,
        if (snapshot.pendingReviewCount > 0)
          strings.t(
            'profile.overview_review',
            params: <String, String>{'count': '${snapshot.pendingReviewCount}'},
          ),
      ],
    );
  }

  static CurrentPlanViewModel buildCurrentPlan({
    required AppStrings strings,
    required LearningPathSnapshot snapshot,
  }) {
    if (snapshot.unlocked || !snapshot.hasLockedLessons) {
      return CurrentPlanViewModel(
        badge: strings.t('profile.plan_full_badge'),
        title: strings.t('profile.plan_full_title'),
        description: strings.t('profile.plan_full_description'),
        footnote: strings.t(
          'profile.plan_full_footnote',
          params: <String, String>{
            'remaining': '${snapshot.remainingLessonCount}',
          },
        ),
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

  static Lesson? _resolveRecommendedLesson({
    required List<Lesson> lessons,
    required ProgressSnapshot progress,
    required bool unlocked,
  }) {
    if (lessons.isEmpty) return null;

    Lesson? byLastLesson;
    if (progress.lastLessonId != null) {
      byLastLesson = _firstWhereOrNull(
        lessons,
        (lesson) =>
            lesson.id == progress.lastLessonId &&
            progress.startedLessons.contains(lesson.id) &&
            !progress.completedLessons.contains(lesson.id),
      );
    }

    final startedInProgress = _firstWhereOrNull(
      lessons,
      (lesson) =>
          progress.startedLessons.contains(lesson.id) &&
          !progress.completedLessons.contains(lesson.id),
    );

    final nextAccessibleUnfinished = _firstWhereOrNull(
      lessons,
      (lesson) =>
          !progress.completedLessons.contains(lesson.id) &&
          (!lesson.isLocked || unlocked),
    );

    return byLastLesson ?? startedInProgress ?? nextAccessibleUnfinished;
  }

  static String? _resolveCurrentUnitId({
    required List<Lesson> lessons,
    required ProgressSnapshot progress,
    required bool unlocked,
  }) {
    final referenceLesson = _resolveRecommendedLesson(
          lessons: lessons,
          progress: progress,
          unlocked: unlocked,
        ) ??
        _firstWhereOrNull(
          lessons,
          (lesson) => !progress.completedLessons.contains(lesson.id),
        ) ??
        (lessons.isNotEmpty ? lessons.first : null);
    return referenceLesson?.unitId;
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
