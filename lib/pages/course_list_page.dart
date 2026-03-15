import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../models/app_settings.dart';
import '../models/lesson.dart';
import '../models/review_models.dart';
import '../services/lesson_service.dart';
import '../services/learning_state_service.dart';
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
  ReviewEntrySnapshot? _reviewEntry;
  LearningStateSummary? _learningStateSummary;

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
        ReviewService.getEntrySnapshot(widget.settings).timeout(
          _courseLoadTimeout,
          onTimeout: () => const ReviewEntrySnapshot(
            formalTasks: <ReviewTask>[],
            lightTasks: <ReviewTask>[],
            overdueTasks: <ReviewTask>[],
            stageReinforcementTasks: <ReviewTask>[],
          ),
        ),
        LearningStateService.getSummary().timeout(
          _courseLoadTimeout,
          onTimeout: () => const LearningStateSummary(
            trackedObjectCount: 0,
            introducedCount: 0,
            practicingCount: 0,
            weakCount: 0,
            stableCount: 0,
            masteredCount: 0,
            dueCount: 0,
            overdueCount: 0,
          ),
        ),
      ]);
      if (!mounted) return;

      setState(() {
        _lessons = results[0] as List<Lesson>;
        _unlocked = results[1] as bool;
        _progress = results[2] as ProgressSnapshot;
        _reviewDashboard = results[3] as ReviewDashboardData;
        _reviewEntry = results[4] as ReviewEntrySnapshot;
        _learningStateSummary = results[5] as LearningStateSummary;
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
        _reviewEntry = const ReviewEntrySnapshot(
          formalTasks: <ReviewTask>[],
          lightTasks: <ReviewTask>[],
          overdueTasks: <ReviewTask>[],
          stageReinforcementTasks: <ReviewTask>[],
        );
        _learningStateSummary = const LearningStateSummary(
          trackedObjectCount: 0,
          introducedCount: 0,
          practicingCount: 0,
          weakCount: 0,
          stableCount: 0,
          masteredCount: 0,
          dueCount: 0,
          overdueCount: 0,
        );
        _loading = false;
      });
    }
  }

  Future<void> _refreshReviewDashboard() async {
    final results = await Future.wait<dynamic>([
      ReviewService.buildDashboard(widget.settings),
      ReviewService.getEntrySnapshot(widget.settings),
      LearningStateService.getSummary(),
    ]);
    if (!mounted) return;
    setState(() {
      _reviewDashboard = results[0] as ReviewDashboardData;
      _reviewEntry = results[1] as ReviewEntrySnapshot;
      _learningStateSummary = results[2] as LearningStateSummary;
    });
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

  Future<void> _handlePrimaryAction(
    vm.CourseCurrentLearningViewModel state,
  ) async {
    switch (state.actionType) {
      case vm.CoursePrimaryActionType.startLesson:
      case vm.CoursePrimaryActionType.continueLesson:
      case vm.CoursePrimaryActionType.reviewDone:
        if (state.lesson != null) {
          await _openLesson(state.lesson!);
        }
        break;
      case vm.CoursePrimaryActionType.unlockAll:
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final strings = context.strings;
    final language = context.appSettings.appLanguage;

    final snapshot = vm.LearningPathViewModels.buildSnapshot(
      lessons: _lessons,
      progress: _progress,
      unlocked: _unlocked,
      reviewEntry: _reviewEntry,
      learningStateSummary: _learningStateSummary,
    );
    final learningMap = vm.LearningPathViewModels.buildCourseLearningMap(
      language: language,
      snapshot: snapshot,
    );

    final currentState = vm.LearningPathViewModels.buildCourseCurrentLearning(
      language: widget.settings.appLanguage,
      strings: strings,
      snapshot: snapshot,
    );
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
            _SectionHeader(
              title: _copy(language, zh: '学习地图', en: 'Learning Map'),
              subtitle: _copy(
                language,
                zh: learningMap.hasPrimaryEntryTarget
                    ? '学习地图当前会优先标出主线所在单元。'
                    : '学习地图会按统一课程状态展示当前可继续的位置。',
                en: learningMap.hasPrimaryEntryTarget
                    ? 'The learning map highlights the unit that currently anchors the main path.'
                    : 'The learning map shows the current continuation point from unified course semantics.',
              ),
            ),
            const SizedBox(height: 12),
            ...learningMap.phases.map((phase) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _LearningPhaseCard(
                    phase: phase,
                    language: language,
                    onTap:
                        phase.canEnter ? () => _showPhaseDetails(phase) : null,
                  ),
                )),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Future<void> _showPhaseDetails(
    vm.CoursePhaseViewModel phase,
  ) async {
    if (!phase.canEnter || phase.lesson == null) {
      return;
    }
    await _openLesson(phase.lesson!);
    if (mounted) {
      await _load();
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
  final vm.CourseCurrentLearningViewModel state;
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
          if (state.arabicPreview != null &&
              state.arabicPreview!.isNotEmpty) ...[
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
            zh: '体验内容已经完成，解锁后可继续后面的课程。',
            en: 'The trial content is done. Unlock to continue the remaining lessons.',
          )
        : _copy(
            language,
            zh: '已完成 $completed/$total 节，继续把入门内容学完。',
            en: 'You completed $completed/$total trial lessons. Keep going and finish the beginner content.',
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

String _copy(
  AppLanguage language, {
  required String zh,
  required String en,
}) {
  return language == AppLanguage.en ? en : zh;
}

class _LearningPhaseCard extends StatelessWidget {
  final vm.CoursePhaseViewModel phase;
  final AppLanguage language;
  final VoidCallback? onTap;

  const _LearningPhaseCard({
    required this.phase,
    required this.language,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _phaseStatusColor(phase.status);
    final statusIcon = _phaseStatusIcon(phase.status);
    final borderColor = phase.isPrimaryEntryTarget
        ? AppTheme.accentMintDark.withValues(alpha: 0.28)
        : AppTheme.strokeLight;

    return GestureDetector(
      onTap: phase.canEnter ? onTap : null,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(16),
          color: phase.canEnter
              ? Theme.of(context).cardColor
              : const Color(0xFFFAFAFA),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (phase.isPrimaryEntryTarget) ...[
                        Text(
                          _copy(
                            language,
                            zh: '当前主入口',
                            en: 'Primary Entry',
                          ),
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: AppTheme.accentMintDark,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 6),
                      ],
                      Text(
                        phase.title,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        phase.description,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: const Color(0xFF666666)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  children: [
                    Icon(statusIcon, size: 28, color: statusColor),
                    const SizedBox(height: 6),
                    Text(
                      phase.statusText,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: statusColor),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              phase.recommendedActionText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              phase.accessText,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (phase.progressValue != null && phase.progressText != null) ...[
              const SizedBox(height: 12),
              Text(
                phase.progressText!,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: phase.progressValue ?? 0,
                        minHeight: 6,
                        backgroundColor: const Color(0xFFEEEEEE),
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${((phase.progressValue ?? 0) * 100).toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ],
            if (phase.footnote != null) ...[
              const SizedBox(height: 10),
              Text(
                phase.footnote!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
            if (phase.canEnter) ...[
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.tonal(
                  onPressed: onTap,
                  child: Text(phase.recommendedActionText),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Color _phaseStatusColor(vm.CoursePhaseStatus status) {
  switch (status) {
    case vm.CoursePhaseStatus.current:
      return AppTheme.accentMintDark;
    case vm.CoursePhaseStatus.available:
      return const Color(0xFF1976D2);
    case vm.CoursePhaseStatus.locked:
      return AppTheme.textSecondary;
    case vm.CoursePhaseStatus.planned:
      return const Color(0xFF8C6E4A);
    case vm.CoursePhaseStatus.completed:
      return const Color(0xFF2E7D32);
  }
}

IconData _phaseStatusIcon(vm.CoursePhaseStatus status) {
  switch (status) {
    case vm.CoursePhaseStatus.current:
      return Icons.play_circle_fill_rounded;
    case vm.CoursePhaseStatus.available:
      return Icons.radio_button_checked_rounded;
    case vm.CoursePhaseStatus.locked:
      return Icons.lock_rounded;
    case vm.CoursePhaseStatus.planned:
      return Icons.schedule_rounded;
    case vm.CoursePhaseStatus.completed:
      return Icons.check_circle_rounded;
  }
}
