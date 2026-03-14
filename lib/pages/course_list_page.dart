import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/app_strings.dart';
import '../l10n/lesson_localizer.dart';
import '../models/app_settings.dart';
import '../models/lesson.dart';
import '../models/review_models.dart';
import '../services/lesson_service.dart';
import '../services/progress_service.dart';
import '../services/review_service.dart';
import '../services/review_sync_service.dart';
import '../services/unlock_service.dart';
import '../theme/app_arabic_typography.dart';
import '../theme/app_theme.dart';
import '../view_models/learning_path_view_models.dart' as vm;
import '../widgets/app_widgets.dart';
import '../widgets/review/lesson_micro_review_card.dart';
import 'lesson_detail_page.dart';
import 'review_session_page.dart';
import 'unlock_page.dart';

const Duration _courseLoadTimeout = Duration(seconds: 2);

class CourseListPage extends StatefulWidget {
  final AppSettings settings;

  const CourseListPage({
    super.key,
    required this.settings,
  });

  @override
  State<CourseListPage> createState() => _CourseListPageState();
}

enum LessonFilter { all, notStarted, inProgress, completed }

enum _CoursePrimaryActionType {
  startLesson,
  continueLesson,
  unlockAll,
  reviewDone,
}

class _CurrentLearningState {
  final String badgeText;
  final String title;
  final String? arabicPreview;
  final String description;
  final String progressText;
  final String? reviewText;
  final String? stageText;
  final String primaryButtonText;
  final _CoursePrimaryActionType actionType;
  final Lesson? lesson;

  const _CurrentLearningState({
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

class _CourseListPageState extends State<CourseListPage> {
  bool _loading = true;
  bool _unlocked = false;
  List<Lesson> _lessons = const <Lesson>[];
  ProgressSnapshot _progress = const ProgressSnapshot(
    completedLessons: <String>{},
    startedLessons: <String>{},
    reviewCount: 0,
    streakDays: 0,
  );
  ReviewDashboardData? _reviewDashboard;
  LessonFilter _filter = LessonFilter.all;
  final Map<String, bool> _expanded = <String, bool>{};

  @override
  void initState() {
    super.initState();
    ReviewSyncService.changes.addListener(_handleReviewChange);
    _load();
  }

  @override
  void dispose() {
    ReviewSyncService.changes.removeListener(_handleReviewChange);
    super.dispose();
  }

  void _handleReviewChange() {
    _refreshReviewDashboard();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait<dynamic>([
        LessonService().loadLessons().timeout(
          _courseLoadTimeout,
          onTimeout: () => <Lesson>[],
        ),
        UnlockService.isUnlocked().timeout(
          _courseLoadTimeout,
          onTimeout: () => false,
        ),
        ProgressService.getSnapshot().timeout(
          _courseLoadTimeout,
          onTimeout: () => const ProgressSnapshot(
            completedLessons: <String>{},
            startedLessons: <String>{},
            reviewCount: 0,
            streakDays: 0,
          ),
        ),
        ReviewService.buildDashboard(widget.settings).timeout(
          _courseLoadTimeout,
          onTimeout: () => const ReviewDashboardData(
            summary: ReviewSummary(
              todayPlan: DailyReviewPlan(
                dateKey: '',
                tasks: <ReviewTask>[],
                completedTaskIds: <String>[],
              ),
              streakDays: 0,
              weeklyReviewCount: 0,
              typeCounts: <ReviewContentType, int>{},
            ),
            weakTasks: <ReviewTask>[],
            recentTasks: <ReviewTask>[],
          ),
        ),
      ]);
      if (!mounted) return;

      final snapshot = vm.LearningPathViewModels.buildSnapshot(
        lessons: results[0] as List<Lesson>,
        progress: results[2] as ProgressSnapshot,
        unlocked: results[1] as bool,
      );
      final currentUnitId = snapshot.currentUnitId;

      setState(() {
        _lessons = results[0] as List<Lesson>;
        _unlocked = results[1] as bool;
        _progress = results[2] as ProgressSnapshot;
        _reviewDashboard = results[3] as ReviewDashboardData;
        for (final unit in _lessons.map((lesson) => lesson.unitId).toSet()) {
          _expanded.putIfAbsent(unit, () => unit == currentUnitId);
        }
        if (currentUnitId != null) {
          _expanded[currentUnitId] = true;
        }
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _lessons = const <Lesson>[];
        _unlocked = false;
        _progress = const ProgressSnapshot(
          completedLessons: <String>{},
          startedLessons: <String>{},
          reviewCount: 0,
          streakDays: 0,
        );
        _reviewDashboard = null;
        _expanded.clear();
        _loading = false;
      });
    }
  }

  Future<void> _refreshReviewDashboard() async {
    final dashboard = await ReviewService.buildDashboard(widget.settings);
    if (!mounted) return;
    setState(() => _reviewDashboard = dashboard);
  }

  Future<void> _openLesson(Lesson lesson) async {
    final locked = lesson.isLocked && !_unlocked;
    if (locked) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const UnlockPage()),
      );
      if (result == true) {
        await _load();
      }
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LessonDetailPage(
          lesson: lesson,
          settings: widget.settings,
          isUnlocked: _unlocked,
        ),
      ),
    );
    await _load();
  }

  Future<void> _openUnlock() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UnlockPage()),
    );
    if (result == true) {
      await _load();
    }
  }

  Future<void> _handlePrimaryAction(_CurrentLearningState state) async {
    switch (state.actionType) {
      case _CoursePrimaryActionType.startLesson:
      case _CoursePrimaryActionType.continueLesson:
      case _CoursePrimaryActionType.reviewDone:
        if (state.lesson != null) {
          await _openLesson(state.lesson!);
        }
        break;
      case _CoursePrimaryActionType.unlockAll:
        await _openUnlock();
        break;
    }
  }

  Future<void> _openPreviewReview(Lesson lesson) async {
    final session = await ReviewService.createLessonPreviewSession(
      widget.settings,
      lesson,
    );
    if (!mounted || session == null) {
      return;
    }

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewSessionPage(session: session),
      ),
    );
    if (result == true) {
      await _refreshReviewDashboard();
    }
  }

  _CurrentLearningState _materializeCurrentLearningState(
    vm.CourseCurrentLearningViewModel viewModel,
  ) {
    _CoursePrimaryActionType actionType;
    switch (viewModel.actionType) {
      case vm.CoursePrimaryActionType.startLesson:
        actionType = _CoursePrimaryActionType.startLesson;
        break;
      case vm.CoursePrimaryActionType.continueLesson:
        actionType = _CoursePrimaryActionType.continueLesson;
        break;
      case vm.CoursePrimaryActionType.unlockAll:
        actionType = _CoursePrimaryActionType.unlockAll;
        break;
      case vm.CoursePrimaryActionType.reviewDone:
        actionType = _CoursePrimaryActionType.reviewDone;
        break;
    }

    return _CurrentLearningState(
      badgeText: viewModel.badgeText,
      title: viewModel.title,
      arabicPreview: viewModel.arabicPreview,
      description: viewModel.description,
      progressText: viewModel.progressText,
      reviewText: viewModel.reviewText,
      stageText: viewModel.stageText,
      primaryButtonText: viewModel.primaryButtonText,
      actionType: actionType,
      lesson: viewModel.lesson,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final strings = context.strings;
    final language = context.appSettings.appLanguage;
    final grouped = <String, List<Lesson>>{};
    for (final lesson in _lessons) {
      grouped.putIfAbsent(lesson.unitId, () => <Lesson>[]).add(lesson);
    }

    final snapshot = vm.LearningPathViewModels.buildSnapshot(
      lessons: _lessons,
      progress: _progress,
      unlocked: _unlocked,
    );
    final currentState = _materializeCurrentLearningState(
      vm.LearningPathViewModels.buildCourseCurrentLearning(
        language: widget.settings.appLanguage,
        strings: strings,
        snapshot: snapshot,
      ),
    );
    final currentUnitId = snapshot.currentUnitId ??
        (grouped.isNotEmpty ? grouped.keys.first : null);
    final orderedUnitIds = <String>[
      if (currentUnitId != null && grouped.containsKey(currentUnitId))
        currentUnitId,
      ...grouped.keys.where((unitId) => unitId != currentUnitId),
    ];
    final showUnlockBanner = !snapshot.unlocked && snapshot.isTrialComplete;
    final reviewPlan = _reviewDashboard?.summary.todayPlan;
    final previewLesson = currentState.lesson;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: AppTheme.pagePadding,
          children: [
            _CourseTopBar(title: strings.t('course.title')),
            const SizedBox(height: 10),
            _CoursePageHeader(subtitle: strings.t('course.subtitle')),
            const SizedBox(height: 18),
            _CurrentLearningCard(
              state: currentState,
              progressValue: snapshot.completionRate,
              onPrimaryTap: () => _handlePrimaryAction(currentState),
            ),
            if (previewLesson != null &&
                reviewPlan != null &&
                reviewPlan.tasks.isNotEmpty) ...[
              const SizedBox(height: 14),
              LessonMicroReviewCard(
                title: _copy(
                  language,
                  zh: '课前回顾',
                  en: 'Before This Lesson',
                ),
                subtitle: _copy(
                  language,
                  zh: '先回顾两三个最近学过的点，再进这一课会更顺手。',
                  en: 'Refresh a couple of recent points before stepping into this lesson.',
                ),
                tasks: reviewPlan.tasks
                    .where((task) => task.lessonId != previewLesson.id)
                    .take(3)
                    .toList(growable: false),
                actionLabel: _copy(
                  language,
                  zh: '先回顾一下',
                  en: 'Quick Review First',
                ),
                onActionTap: () => _openPreviewReview(previewLesson),
              ),
            ],
            if (!_unlocked) ...[
              const SizedBox(height: 14),
              _FreeTrialProgressBanner(
                completed: snapshot.freeCompletedLessonCount,
                total: snapshot.freeLessonCount,
                completedAllFreeLessons: snapshot.isTrialComplete,
                unlocked: _unlocked,
                language: language,
              ),
            ],
            const SizedBox(height: 18),
            _CourseFilterTabs(
              currentFilter: _filter,
              labelBuilder: (filter) => _labelForFilter(filter, strings),
              onChanged: (filter) => setState(() => _filter = filter),
            ),
            if (currentUnitId != null && grouped[currentUnitId] != null) ...[
              const SizedBox(height: 22),
              _SectionHeader(
                title: _copy(language, zh: '当前单元', en: 'Current Unit'),
                subtitle: _copy(
                  language,
                  zh: '先把当前最相关的这一组学完。',
                  en: 'Start with the unit that matters most right now.',
                ),
              ),
              const SizedBox(height: 10),
              _UnitSectionCard(
                unitId: currentUnitId,
                lessons: grouped[currentUnitId]!,
                language: language,
                strings: strings,
                isExpanded: _expanded[currentUnitId] ?? true,
                isCurrentUnit: true,
                isUnlocked: _unlocked,
                filter: _filter,
                progress: _progress,
                recommendedLessonId: currentState.lesson?.id,
                onToggle: () => setState(
                  () => _expanded[currentUnitId] =
                      !(_expanded[currentUnitId] ?? true),
                ),
                onLessonTap: _openLesson,
              ),
            ],
            if (showUnlockBanner) ...[
              const SizedBox(height: 16),
              _UnlockCourseBanner(
                title: _copy(
                  language,
                  zh: '解锁完整课程',
                  en: 'Unlock the Full Course',
                ),
                description: _copy(
                  language,
                  zh: '一次解锁，继续剩余 13 节课程，首页和课程页后续都会自然衔接。',
                  en:
                      'Unlock once and continue the remaining 13 lessons with no extra friction later.',
                ),
                buttonText: _copy(language, zh: '立即解锁', en: 'Unlock Now'),
                onTap: _openUnlock,
              ),
            ],
            if (orderedUnitIds.length > 1) ...[
              const SizedBox(height: 22),
              _SectionHeader(
                title: _copy(language, zh: '其他单元', en: 'Other Units'),
                subtitle: _copy(
                  language,
                  zh: '按单元查看完整结构，但默认保持轻量。',
                  en: 'See the full course structure without making it feel heavy.',
                ),
              ),
              const SizedBox(height: 10),
              ...orderedUnitIds.where((unitId) => unitId != currentUnitId).map(
                    (unitId) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _UnitSectionCard(
                        unitId: unitId,
                        lessons: grouped[unitId]!,
                        language: language,
                        strings: strings,
                        isExpanded: _expanded[unitId] ?? false,
                        isCurrentUnit: false,
                        isUnlocked: _unlocked,
                        filter: _filter,
                        progress: _progress,
                        recommendedLessonId: currentState.lesson?.id,
                        onToggle: () => setState(
                          () => _expanded[unitId] = !(_expanded[unitId] ?? false),
                        ),
                        onLessonTap: _openLesson,
                      ),
                    ),
                  ),
            ],
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  _CurrentLearningState _buildCurrentLearningState(AppStrings strings) {
    final completedCount = _completedCount(_lessons);
    final reviewText = _progress.reviewCount > 0
        ? _copy(
            widget.settings.appLanguage,
            zh: '待复习 ${_progress.reviewCount} 项',
            en: '${_progress.reviewCount} items to review',
          )
        : null;
    final progressText = strings.t(
      'course.completed_summary',
      params: <String, String>{
        'completed': '$completedCount',
        'total': '${_lessons.length}',
      },
    );
    final freeLessons = _lessons.where((lesson) => !lesson.isLocked).toList();
    final freeCompleted = freeLessons
        .where((lesson) => _progress.completedLessons.contains(lesson.id))
        .length;
    final nextLesson = _resolveContinuationLesson(
          lessons: _lessons,
          progress: _progress,
          unlocked: _unlocked,
        ) ??
        (_lessons.isNotEmpty ? _lessons.last : null);

    if (_lessons.isNotEmpty && completedCount >= _lessons.length) {
      final lesson = nextLesson;
      return _CurrentLearningState(
        badgeText: _copy(widget.settings.appLanguage, zh: '已全部完成', en: 'All Done'),
        title: _copy(
          widget.settings.appLanguage,
          zh: '全部课程已完成',
          en: 'All Lessons Completed',
        ),
        arabicPreview: lesson?.titleAr,
        description: _copy(
          widget.settings.appLanguage,
          zh: '16 节课程都已学完，现在更适合回看熟悉内容。',
          en: 'All 16 lessons are done. This is a good time to revisit what you learned.',
        ),
        progressText: progressText,
        reviewText: reviewText,
        stageText: _copy(
          widget.settings.appLanguage,
          zh: '完整课程已完成',
          en: 'Full course complete',
        ),
        primaryButtonText: _copy(widget.settings.appLanguage, zh: '回看课程', en: 'Review Lessons'),
        actionType: _CoursePrimaryActionType.reviewDone,
        lesson: lesson,
      );
    }

    if (!_unlocked &&
        freeLessons.isNotEmpty &&
        freeCompleted >= freeLessons.length) {
      return _CurrentLearningState(
        badgeText: _copy(widget.settings.appLanguage, zh: '体验已完成', en: 'Trial Complete'),
        title: _copy(
          widget.settings.appLanguage,
          zh: '继续完整课程',
          en: 'Continue the Full Course',
        ),
        description: _copy(
          widget.settings.appLanguage,
          zh: '前三节体验课已经完成，解锁后可继续剩余 13 节正式课程。',
          en: 'You finished the free trial. Unlock to continue the remaining 13 lessons.',
        ),
        progressText: progressText,
        reviewText: reviewText,
        stageText: _copy(
          widget.settings.appLanguage,
          zh: '前三节免费体验已完成',
          en: 'First 3 free lessons completed',
        ),
        primaryButtonText:
            _copy(widget.settings.appLanguage, zh: '解锁全部课程', en: 'Unlock All Lessons'),
        actionType: _CoursePrimaryActionType.unlockAll,
      );
    }

    if (nextLesson == null) {
      return _CurrentLearningState(
        badgeText: _copy(widget.settings.appLanguage, zh: '开始学习', en: 'Start Learning'),
        title: _copy(widget.settings.appLanguage, zh: '从第一课开始', en: 'Start with Lesson 1'),
        description: _copy(
          widget.settings.appLanguage,
          zh: '课程数据已准备好，先完成一个轻量的学习闭环。',
          en: 'Your lessons are ready. Start with one light and complete learning loop.',
        ),
        progressText: progressText,
        primaryButtonText:
            _copy(widget.settings.appLanguage, zh: '开始学习', en: 'Start Learning'),
        actionType: _CoursePrimaryActionType.startLesson,
      );
    }

    final hasStartedAny = _progress.startedLessons.isNotEmpty;
    return _CurrentLearningState(
      badgeText: _copy(
        widget.settings.appLanguage,
        zh: hasStartedAny ? '继续学习' : '开始学习',
        en: hasStartedAny ? 'Continue Learning' : 'Start Learning',
      ),
      title: LessonLocalizer.title(nextLesson, widget.settings.appLanguage),
      arabicPreview: nextLesson.titleAr,
      description: _copy(
        widget.settings.appLanguage,
        zh: hasStartedAny
            ? '优先把这节课学完，页面会继续沿着当前进度推进。'
            : '从这一节开始，先完成一次完整、轻量的学习体验。',
        en: hasStartedAny
            ? 'Finish this lesson next to keep your learning continuous.'
            : 'Start here for a light, complete first lesson experience.',
      ),
      progressText: progressText,
      reviewText: reviewText,
      stageText: _unlocked
          ? _copy(widget.settings.appLanguage, zh: '完整课程已开启', en: 'Full course unlocked')
          : _copy(
              widget.settings.appLanguage,
              zh: '当前处于免费体验阶段',
              en: 'You are in the free trial stage',
            ),
      primaryButtonText: _copy(
        widget.settings.appLanguage,
        zh: hasStartedAny ? '继续学习' : '开始学习',
        en: hasStartedAny ? 'Continue Learning' : 'Start Learning',
      ),
      actionType: hasStartedAny
          ? _CoursePrimaryActionType.continueLesson
          : _CoursePrimaryActionType.startLesson,
      lesson: nextLesson,
    );
  }

  // ignore: unused_element
  Lesson? _resolveContinuationLesson({
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

  // ignore: unused_element
  String? _resolveCurrentUnitId({
    required List<Lesson> lessons,
    required ProgressSnapshot progress,
    required bool unlocked,
  }) {
    final referenceLesson = _resolveContinuationLesson(
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

  // ignore: unused_element
  int _completedCount(List<Lesson> lessons) {
    final lessonIds = lessons.map((lesson) => lesson.id).toSet();
    return _progress.completedLessons.intersection(lessonIds).length;
  }

  String _labelForFilter(LessonFilter filter, AppStrings strings) {
    switch (filter) {
      case LessonFilter.all:
        return strings.t('course.filter_all');
      case LessonFilter.notStarted:
        return strings.t('course.filter_not_started');
      case LessonFilter.inProgress:
        return strings.t('course.filter_in_progress');
      case LessonFilter.completed:
        return strings.t('course.filter_completed');
    }
  }
}

class _CourseTopBar extends StatelessWidget {
  final String title;

  const _CourseTopBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ],
    );
  }
}

class _CoursePageHeader extends StatelessWidget {
  final String subtitle;

  const _CoursePageHeader({required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Text(
      subtitle,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.55),
    );
  }
}

class _CurrentLearningCard extends StatelessWidget {
  final _CurrentLearningState state;
  final double progressValue;
  final VoidCallback onPrimaryTap;

  const _CurrentLearningCard({
    required this.state,
    required this.progressValue,
    required this.onPrimaryTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppSurface(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Pill(
            label: state.badgeText,
            backgroundColor: AppTheme.softAccent,
            foregroundColor: AppTheme.accentMintDark,
          ),
          const SizedBox(height: 14),
          Text(
            state.title,
            style: textTheme.headlineMedium?.copyWith(
              fontSize: 26,
              height: 1.18,
            ),
          ),
          if (state.arabicPreview != null && state.arabicPreview!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.bgCardSoft,
                borderRadius: BorderRadius.circular(18),
              ),
              child: ArabicText.display(
                state.arabicPreview!,
                style: const TextStyle(
                  fontSize: 30,
                  height: 1.08,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.accentMintDark,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            state.description,
            style: textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _MetaPill(text: state.progressText),
              if (state.reviewText != null) _MetaPill(text: state.reviewText!),
              if (state.stageText != null) _MetaPill(text: state.stageText!),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progressValue.clamp(0, 1),
              minHeight: 8,
              backgroundColor: AppTheme.bgCardSoft,
              color: AppTheme.accentMintDark,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onPrimaryTap,
              child: Text(state.primaryButtonText),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final String text;

  const _MetaPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.bgCardSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppTheme.accentMintDark,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _FreeTrialProgressBanner extends StatelessWidget {
  final int completed;
  final int total;
  final bool completedAllFreeLessons;
  final bool unlocked;
  final AppLanguage language;

  const _FreeTrialProgressBanner({
    required this.completed,
    required this.total,
    required this.completedAllFreeLessons,
    required this.unlocked,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    if (unlocked || total == 0) return const SizedBox.shrink();

    final title = completedAllFreeLessons
        ? _copy(language, zh: '免费体验已完成', en: 'Free Trial Completed')
        : _copy(language, zh: '新手体验中', en: 'Free Trial in Progress');
    final subtitle = completedAllFreeLessons
        ? _copy(
            language,
            zh: '前三节体验课已完成，解锁后可继续剩余 13 节课程。',
            en:
                'You finished the first 3 trial lessons. Unlock to continue the remaining 13.',
          )
        : _copy(
            language,
            zh: '已完成 $completed/$total 节，再完成几节就能走完整个入门闭环。',
            en:
                'You completed $completed/$total trial lessons. Finish a few more to experience the full learning loop.',
          );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6FAF8),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.strokeLight),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppTheme.softAccent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              size: 18,
              color: AppTheme.accentMintDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$completed/$total',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppTheme.accentMintDark,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseFilterTabs extends StatelessWidget {
  final LessonFilter currentFilter;
  final String Function(LessonFilter filter) labelBuilder;
  final ValueChanged<LessonFilter> onChanged;

  const _CourseFilterTabs({
    required this.currentFilter,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: LessonFilter.values.map((filter) {
          final selected = filter == currentFilter;
          return Padding(
            padding: EdgeInsets.only(
              right: filter == LessonFilter.values.last ? 0 : 10,
            ),
            child: _LessonFilterChip(
              label: labelBuilder(filter),
              selected: selected,
              onTap: () => onChanged(filter),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(subtitle, style: textTheme.bodyMedium),
      ],
    );
  }
}

class _UnitSectionCard extends StatelessWidget {
  final String unitId;
  final List<Lesson> lessons;
  final AppLanguage language;
  final AppStrings strings;
  final bool isExpanded;
  final bool isCurrentUnit;
  final bool isUnlocked;
  final LessonFilter filter;
  final ProgressSnapshot progress;
  final String? recommendedLessonId;
  final VoidCallback onToggle;
  final ValueChanged<Lesson> onLessonTap;

  const _UnitSectionCard({
    required this.unitId,
    required this.lessons,
    required this.language,
    required this.strings,
    required this.isExpanded,
    required this.isCurrentUnit,
    required this.isUnlocked,
    required this.filter,
    required this.progress,
    required this.recommendedLessonId,
    required this.onToggle,
    required this.onLessonTap,
  });

  @override
  Widget build(BuildContext context) {
    final filteredLessons = _filterLessons(lessons, progress, filter);
    final fullyLocked = !isUnlocked && lessons.every((lesson) => lesson.isLocked);
    final completedCount = lessons
        .where((lesson) => progress.completedLessons.contains(lesson.id))
        .length;
    final totalMinutes = lessons.fold<int>(
      0,
      (sum, lesson) => sum + lesson.estimatedMinutes,
    );

    return AppSurface(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        children: [
          _UnitHeader(
            unitTitle: _unitTitle(unitId, language),
            metaText: _unitMeta(
              language: language,
              completedCount: completedCount,
              totalCount: lessons.length,
              totalMinutes: totalMinutes,
              fullyLocked: fullyLocked,
            ),
            isExpanded: isExpanded,
            isCurrentUnit: isCurrentUnit,
            onTap: onToggle,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: !isExpanded
                ? const SizedBox.shrink()
                : Column(
                    children: [
                      const SizedBox(height: 14),
                      if (fullyLocked)
                        _LockedUnitPreview(
                          language: language,
                          lessonCount: lessons.length,
                          totalMinutes: totalMinutes,
                        )
                      else if (filteredLessons.isEmpty)
                        _EmptyFilterState(language: language)
                      else
                        ...filteredLessons.map(
                          (lesson) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _LessonCard(
                              lesson: lesson,
                              language: language,
                              statusText: _lessonActionText(
                                language,
                                lesson: lesson,
                                progress: progress,
                                isUnlocked: isUnlocked,
                              ),
                              metaText: _lessonMetaText(
                                language,
                                lesson: lesson,
                                progress: progress,
                                isUnlocked: isUnlocked,
                              ),
                              isLocked: lesson.isLocked && !isUnlocked,
                              isCompleted:
                                  progress.completedLessons.contains(lesson.id),
                              isStarted:
                                  progress.startedLessons.contains(lesson.id),
                              isRecommended:
                                  recommendedLessonId != null &&
                                  recommendedLessonId == lesson.id,
                              onTap: () => onLessonTap(lesson),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  static List<Lesson> _filterLessons(
    List<Lesson> lessons,
    ProgressSnapshot progress,
    LessonFilter filter,
  ) {
    return lessons.where((lesson) {
      switch (filter) {
        case LessonFilter.all:
          return true;
        case LessonFilter.notStarted:
          return !progress.startedLessons.contains(lesson.id);
        case LessonFilter.inProgress:
          return progress.startedLessons.contains(lesson.id) &&
              !progress.completedLessons.contains(lesson.id);
        case LessonFilter.completed:
          return progress.completedLessons.contains(lesson.id);
      }
    }).toList();
  }
}

class _UnitHeader extends StatelessWidget {
  final String unitTitle;
  final String metaText;
  final bool isExpanded;
  final bool isCurrentUnit;
  final VoidCallback onTap;

  const _UnitHeader({
    required this.unitTitle,
    required this.metaText,
    required this.isExpanded,
    required this.isCurrentUnit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isCurrentUnit) ...[
                    Text(
                      _copy(
                        context.appSettings.appLanguage,
                        zh: '当前推荐单元',
                        en: 'Recommended Unit',
                      ),
                      style: textTheme.labelMedium?.copyWith(
                        color: AppTheme.accentMintDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(unitTitle, style: textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(metaText, style: textTheme.bodySmall),
                ],
              ),
            ),
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 220),
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LockedUnitPreview extends StatelessWidget {
  final AppLanguage language;
  final int lessonCount;
  final int totalMinutes;

  const _LockedUnitPreview({
    required this.language,
    required this.lessonCount,
    required this.totalMinutes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgCardSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        _copy(
          language,
          zh: '这一单元包含 $lessonCount 节课，约 $totalMinutes 分钟。解锁后可展开详细课程。',
          en:
              'This unit has $lessonCount lessons and about $totalMinutes minutes of content. Unlock to open the full lesson list.',
        ),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

class _EmptyFilterState extends StatelessWidget {
  final AppLanguage language;

  const _EmptyFilterState({required this.language});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgCardSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        _copy(
          language,
          zh: '这个筛选状态下，这个单元暂时没有可显示的课程。',
          en: 'No lessons from this unit match the current filter.',
        ),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final Lesson lesson;
  final AppLanguage language;
  final String statusText;
  final String metaText;
  final bool isLocked;
  final bool isCompleted;
  final bool isStarted;
  final bool isRecommended;
  final VoidCallback onTap;

  const _LessonCard({
    required this.lesson,
    required this.language,
    required this.statusText,
    required this.metaText,
    required this.isLocked,
    required this.isCompleted,
    required this.isStarted,
    required this.isRecommended,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final backgroundColor =
        isRecommended ? const Color(0xFFF4FBF8) : Theme.of(context).cardColor;
    final borderColor = isRecommended
        ? AppTheme.accentMintDark.withOpacity(0.18)
        : AppTheme.strokeLight;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isRecommended) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _copy(
                      language,
                      zh: isStarted ? '继续学习' : '推荐学习',
                      en: isStarted ? 'Continue Here' : 'Recommended',
                    ),
                    style: textTheme.labelMedium?.copyWith(
                      color: AppTheme.accentMintDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _lessonIndexLabel(lesson.id),
                      style: textTheme.titleSmall?.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LessonLocalizer.title(lesson, language),
                          style: textTheme.titleSmall?.copyWith(height: 1.3),
                        ),
                        const SizedBox(height: 6),
                        ArabicText.display(
                          lesson.titleAr,
                          style: const TextStyle(
                            fontSize: 24,
                            height: 1.08,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.accentMintDark,
                          ),
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(metaText, style: textTheme.bodySmall),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _LessonActionChip(
                    text: statusText,
                    locked: isLocked,
                    completed: isCompleted,
                    started: isStarted,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonActionChip extends StatelessWidget {
  final String text;
  final bool locked;
  final bool completed;
  final bool started;

  const _LessonActionChip({
    required this.text,
    required this.locked,
    required this.completed,
    required this.started,
  });

  @override
  Widget build(BuildContext context) {
    final Color foreground;
    final Color background;
    final IconData icon;

    if (locked) {
      foreground = AppTheme.textSecondary;
      background = AppTheme.bgCardSoft;
      icon = Icons.lock_outline_rounded;
    } else if (completed) {
      foreground = AppTheme.accentMintDark;
      background = AppTheme.softAccent;
      icon = Icons.check_rounded;
    } else if (started) {
      foreground = AppTheme.accentMintDark;
      background = AppTheme.softAccent;
      icon = Icons.play_arrow_rounded;
    } else {
      foreground = AppTheme.accentMintDark;
      background = AppTheme.bgCardSoft;
      icon = Icons.arrow_forward_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _UnlockCourseBanner extends StatelessWidget {
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback onTap;

  const _UnlockCourseBanner({
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onTap,
              child: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LessonFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? AppTheme.softAccent : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? AppTheme.accentMintDark.withOpacity(0.2)
                  : AppTheme.strokeLight,
            ),
          ),
          child: Text(
            label,
            style: textTheme.labelLarge?.copyWith(
              color: selected ? AppTheme.accentMintDark : AppTheme.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

String _unitTitle(String unitId, AppLanguage language) {
  switch (unitId) {
    case 'U1':
      return _copy(language, zh: 'Unit 1 · 入门表达', en: 'Unit 1 · Core Expressions');
    case 'U2':
      return _copy(language, zh: 'Unit 2 · 人物与身份', en: 'Unit 2 · People & Identity');
    case 'U3':
      return _copy(language, zh: 'Unit 3 · 时间与生活', en: 'Unit 3 · Time & Daily Life');
    case 'U4':
      return _copy(language, zh: 'Unit 4 · 场景表达', en: 'Unit 4 · Real-life Scenes');
    default:
      return unitId;
  }
}

String _unitMeta({
  required AppLanguage language,
  required int completedCount,
  required int totalCount,
  required int totalMinutes,
  required bool fullyLocked,
}) {
  if (fullyLocked) {
    return _copy(
      language,
      zh: '$totalCount 节课 · 约 $totalMinutes 分钟 · 解锁后学习',
      en: '$totalCount lessons · about $totalMinutes min · Unlock to learn',
    );
  }

  return _copy(
    language,
    zh: '已完成 $completedCount/$totalCount · 约 $totalMinutes 分钟',
    en: '$completedCount/$totalCount completed · about $totalMinutes min',
  );
}

String _lessonIndexLabel(String lessonId) {
  final marker = lessonId.indexOf('L');
  if (marker == -1 || marker == lessonId.length - 1) {
    return lessonId;
  }
  return 'L${lessonId.substring(marker + 1)}';
}

String _lessonActionText(
  AppLanguage language, {
  required Lesson lesson,
  required ProgressSnapshot progress,
  required bool isUnlocked,
}) {
  final locked = lesson.isLocked && !isUnlocked;
  final completed = progress.completedLessons.contains(lesson.id);
  final started = progress.startedLessons.contains(lesson.id);

  if (locked) {
    return _copy(language, zh: '解锁后学习', en: 'Unlock');
  }
  if (completed) {
    return _copy(language, zh: '已完成', en: 'Done');
  }
  if (started) {
    return _copy(language, zh: '继续学习', en: 'Continue');
  }
  return _copy(language, zh: '开始学习', en: 'Start');
}

String _lessonMetaText(
  AppLanguage language, {
  required Lesson lesson,
  required ProgressSnapshot progress,
  required bool isUnlocked,
}) {
  final locked = lesson.isLocked && !isUnlocked;
  final completed = progress.completedLessons.contains(lesson.id);
  final started = progress.startedLessons.contains(lesson.id);

  if (locked) {
    return _copy(
      language,
      zh: '${lesson.estimatedMinutes} 分钟 · 当前阶段先完成前面的可学课程',
      en: '${lesson.estimatedMinutes} min · Finish the currently open lessons first',
    );
  }
  if (completed) {
    return _copy(
      language,
      zh: '${lesson.estimatedMinutes} 分钟 · 已学完，可随时回看',
      en: '${lesson.estimatedMinutes} min · Completed and ready to review',
    );
  }
  if (started) {
    return _copy(
      language,
      zh: '${lesson.estimatedMinutes} 分钟 · 继续这一节最顺手',
      en: '${lesson.estimatedMinutes} min · Best lesson to continue right now',
    );
  }
  return _copy(
    language,
    zh: '${lesson.estimatedMinutes} 分钟 · 轻量一节，适合现在开始',
    en: '${lesson.estimatedMinutes} min · A light lesson to start right now',
  );
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
