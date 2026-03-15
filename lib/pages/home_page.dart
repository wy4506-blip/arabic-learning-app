import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../features/onboarding/models/onboarding_state.dart';
import '../l10n/lesson_localizer.dart';
import '../l10n/localized_text.dart';
import '../models/app_settings.dart';
import '../models/lesson.dart';
import '../models/review_models.dart';
import '../services/alphabet_progress_service.dart';
import '../services/lesson_service.dart';
import '../services/progress_service.dart';
import '../services/review_service.dart';
import '../services/review_sync_service.dart';
import '../services/unlock_service.dart';
import '../theme/app_arabic_typography.dart';
import '../theme/app_theme.dart';
import '../view_models/learning_path_view_models.dart' as vm;
import '../widgets/app_widgets.dart';
import 'alphabet_hub_page.dart';
import 'alphabet_page.dart';
import 'lesson_detail_page.dart';
import 'review_session_page.dart';
import 'unlock_page.dart';

const Color _homeApricot = Color(0xFFFFF0E3);
const Color _homeMint = Color(0xFFE3F5ED);
const Color _homeTerracotta = Color(0xFFB56D45);
const Color _homeBlue = Color(0xFF5B7FA8);
const Duration _homeLoadTimeout = Duration(seconds: 5);

class HomeMainCardState {
  final String badgeText;
  final String title;
  final String? arabicPreview;
  final String nextStepDescription;
  final String? progressText;
  final String? reviewText;
  final double? progressValue;
  final String primaryButtonText;
  final String? secondaryText;
  final vm.HomePrimaryActionType actionType;
  final VoidCallback onPrimaryTap;
  final VoidCallback? onSecondaryTap;

  const HomeMainCardState({
    required this.badgeText,
    required this.title,
    required this.nextStepDescription,
    required this.primaryButtonText,
    required this.actionType,
    required this.onPrimaryTap,
    this.arabicPreview,
    this.progressText,
    this.reviewText,
    this.progressValue,
    this.secondaryText,
    this.onSecondaryTap,
  });
}

class HomePage extends StatefulWidget {
  final AppSettings settings;
  final OnboardingState onboardingState;
  final ValueChanged<int> onOpenTab;

  const HomePage({
    super.key,
    required this.settings,
    required this.onboardingState,
    required this.onOpenTab,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _unlocked = false;
  bool _loading = true;
  List<Lesson> _lessons = const [];
  AlphabetLearningSnapshot _alphabetProgress = AlphabetLearningSnapshot.empty;
  ProgressSnapshot _progress = const ProgressSnapshot(
    completedLessons: <String>{},
    startedLessons: <String>{},
    reviewCount: 0,
    streakDays: 0,
  );
  ReviewDashboardData? _reviewDashboard;

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
        UnlockService.isUnlocked().timeout(
          _homeLoadTimeout,
          onTimeout: () => false,
        ),
        LessonService().loadLessons().timeout(
              _homeLoadTimeout,
              onTimeout: () => <Lesson>[],
            ),
        ProgressService.getSnapshot().timeout(
          _homeLoadTimeout,
          onTimeout: () => const ProgressSnapshot(
            completedLessons: <String>{},
            startedLessons: <String>{},
            reviewCount: 0,
            streakDays: 0,
          ),
        ),
        ReviewService.buildDashboard(widget.settings).timeout(
          _homeLoadTimeout,
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
        AlphabetProgressService.getSnapshot().timeout(
          _homeLoadTimeout,
          onTimeout: () => AlphabetLearningSnapshot.empty,
        ),
      ]);
      if (!mounted) return;
      setState(() {
        _unlocked = results[0] as bool;
        _lessons = results[1] as List<Lesson>;
        _progress = results[2] as ProgressSnapshot;
        _reviewDashboard = results[3] as ReviewDashboardData;
        _alphabetProgress = results[4] as AlphabetLearningSnapshot;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _unlocked = false;
        _lessons = const <Lesson>[];
        _progress = const ProgressSnapshot(
          completedLessons: <String>{},
          startedLessons: <String>{},
          reviewCount: 0,
          streakDays: 0,
        );
        _reviewDashboard = null;
        _alphabetProgress = AlphabetLearningSnapshot.empty;
        _loading = false;
      });
    }
  }

  Future<void> _refreshReviewDashboard() async {
    final dashboard = await ReviewService.buildDashboard(widget.settings);
    if (!mounted) return;
    setState(() => _reviewDashboard = dashboard);
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

  Future<void> _openAlphabetHub() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AlphabetHubPage()),
    );
    await _load();
  }

  Future<void> _openAlphabetLearning() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AlphabetPage()),
    );
    await _load();
  }

  Future<void> _openNextTask(
    Lesson? lesson, {
    bool fromHomeTodayPlan = false,
  }) async {
    final nextLesson = lesson;
    if (nextLesson == null) {
      await _openAlphabetHub();
      return;
    }

    final locked = nextLesson.isLocked && !_unlocked;
    if (locked) {
      final didUnlock = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const UnlockPage()),
      );
      if (didUnlock != true) {
        return;
      }
      await _load();
      if (!mounted) return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LessonDetailPage(
          lesson: nextLesson,
          settings: widget.settings,
          isUnlocked: _unlocked,
          fromHomeTodayPlan: fromHomeTodayPlan,
        ),
      ),
    );
    await _load();
  }

  void _openLessonsTab() => widget.onOpenTab(1);

  void _openReviewTab() => widget.onOpenTab(2);

  Future<void> _openHomeTodayReviewFlow(Lesson? nextLesson) async {
    final session = await ReviewService.createHomeTodayFlowSession(
      widget.settings,
      nextLessonId: nextLesson?.id,
    );
    if (!mounted) {
      return;
    }
    if (session == null) {
      if (nextLesson != null) {
        await _openNextTask(nextLesson, fromHomeTodayPlan: true);
      } else {
        _openReviewTab();
      }
      return;
    }

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewSessionPage(session: session),
      ),
    );
    if (result == true) {
      await _load();
    }
  }

  Future<void> _openStandaloneReviewFlow() async {
    final plan = await ReviewService.getTodayPlan(widget.settings);
    if (!mounted) {
      return;
    }
    if (plan.pendingCount == 0) {
      _openReviewTab();
      return;
    }

    final session = await ReviewService.createTodaySession(widget.settings);
    if (!mounted) {
      return;
    }
    if (session == null) {
      _openReviewTab();
      return;
    }

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewSessionPage(session: session),
      ),
    );
    if (result == true) {
      await _load();
    }
  }

  HomeMainCardState _buildPrimaryCardState({
    required vm.LearningPathSnapshot snapshot,
    required DailyReviewPlan? reviewPlan,
  }) {
    final nextLesson = snapshot.recommendedLesson;
    final alphabetStarted = _alphabetProgress.hasStarted;
    final alphabetComplete = _alphabetProgress.isStageComplete;

    if (!widget.onboardingState.hasCompletedFirstExperience ||
        !alphabetComplete) {
      return HomeMainCardState(
        badgeText: localizedText(
          context,
          zh: alphabetStarted ? '字母阶段' : '学习起点',
          en: alphabetStarted ? 'Alphabet Stage' : 'Starting Point',
        ),
        title: localizedText(
          context,
          zh: alphabetStarted ? '继续字母学习' : '先完成字母阶段',
          en: alphabetStarted
              ? 'Continue Alphabet Learning'
              : 'Start with the Alphabet',
        ),
        arabicPreview: 'ابدأ من الحروف',
        nextStepDescription: localizedText(
          context,
          zh: '先把字母分组、听读和书写走通，再进入正式复习或课程。',
          en: 'Finish the alphabet groups, listening, and writing first, then move into formal review or lessons.',
        ),
        progressText: _alphabetProgress.totalGroupCount == 0
            ? null
            : localizedText(
                context,
                zh: '已完成 ${_alphabetProgress.completedGroupCount}/${_alphabetProgress.totalGroupCount} 组',
                en: '${_alphabetProgress.completedGroupCount}/${_alphabetProgress.totalGroupCount} groups completed',
              ),
        reviewText: _alphabetProgress.totalLetterCount == 0
            ? null
            : localizedText(
                context,
                zh: '浏览 ${_alphabetProgress.viewedLetterCount} · 听读 ${_alphabetProgress.listenCompletedCount} · 书写 ${_alphabetProgress.writeCompletedCount}',
                en: 'Browse ${_alphabetProgress.viewedLetterCount} · Listen ${_alphabetProgress.listenCompletedCount} · Write ${_alphabetProgress.writeCompletedCount}',
              ),
        progressValue: _alphabetProgress.totalGroupCount == 0
            ? null
            : _alphabetProgress.completedGroupCount /
                _alphabetProgress.totalGroupCount,
        primaryButtonText: localizedText(
          context,
          zh: alphabetStarted ? '继续字母学习' : '开始字母学习',
          en: alphabetStarted
              ? 'Continue Alphabet Learning'
              : 'Start Alphabet Learning',
        ),
        secondaryText: localizedText(
          context,
          zh: '查看字母分组',
          en: 'Open Alphabet Groups',
        ),
        actionType: vm.HomePrimaryActionType.continueAlphabet,
        onPrimaryTap: _openAlphabetHub,
        onSecondaryTap: _openAlphabetLearning,
      );
    }

    final pendingFormalReview = (reviewPlan?.pendingCount ?? 0) > 0;
    if (pendingFormalReview) {
      final hasStartedFormalReview = reviewPlan?.hasStarted ?? false;
      final nextLessonTitle = nextLesson == null
          ? null
          : LessonLocalizer.title(nextLesson, context.appSettings.appLanguage);

      return HomeMainCardState(
        badgeText: localizedText(
          context,
          zh: '今日正式复习',
          en: 'Today\'s Formal Review',
        ),
        title: localizedText(
          context,
          zh: hasStartedFormalReview ? '继续正式复习' : '先完成正式复习',
          en: hasStartedFormalReview
              ? 'Continue Formal Review'
              : 'Start Formal Review',
        ),
        arabicPreview: nextLesson?.titleAr,
        nextStepDescription: nextLessonTitle == null
            ? localizedText(
                context,
                zh: '先把今天这轮正式复习完成，再继续后面的学习。',
                en: 'Finish today\'s formal review first, then continue learning.',
              )
            : localizedText(
                context,
                zh: '先完成今天这轮正式复习，再顺着进入 $nextLessonTitle。',
                en: 'Finish today\'s formal review first, then continue into $nextLessonTitle.',
              ),
        progressText: localizedText(
          context,
          zh: '已完成 ${reviewPlan?.completedCount ?? 0}/${reviewPlan?.totalCount ?? 0} 项',
          en: '${reviewPlan?.completedCount ?? 0}/${reviewPlan?.totalCount ?? 0} items completed',
        ),
        reviewText: nextLessonTitle == null
            ? null
            : localizedText(
                context,
                zh: '下一节：$nextLessonTitle',
                en: 'Next lesson: $nextLessonTitle',
              ),
        primaryButtonText: localizedText(
          context,
          zh: hasStartedFormalReview ? '继续正式复习' : '开始正式复习',
          en: hasStartedFormalReview
              ? 'Continue Formal Review'
              : 'Start Formal Review',
        ),
        secondaryText: localizedText(
          context,
          zh: '去看复习页',
          en: 'Open Review Page',
        ),
        actionType: vm.HomePrimaryActionType.startReview,
        onPrimaryTap: nextLesson == null
            ? _openStandaloneReviewFlow
            : () => _openHomeTodayReviewFlow(nextLesson),
        onSecondaryTap: _openReviewTab,
      );
    }

    if (!_unlocked &&
        snapshot.nextLessonLocked &&
        snapshot.completedLessonCount >= 3) {
      return HomeMainCardState(
        badgeText: localizedText(context, zh: '当前阶段', en: 'Current Stage'),
        title: localizedText(
          context,
          zh: '先巩固已学内容',
          en: 'Reinforce What You Learned First',
        ),
        arabicPreview: 'أكمل المسار',
        nextStepDescription: localizedText(
          context,
          zh: '起步阶段已经完成。先完成复习与回看，会员说明可在需要时再查看。',
          en: 'The starter stage is complete. Review and revisit first, then check membership info only if you need it.',
        ),
        progressText: localizedText(
          context,
          zh: '已完成前 3 课',
          en: 'First 3 lessons completed',
        ),
        primaryButtonText: localizedText(
          context,
          zh: '去复习',
          en: 'Go Review',
        ),
        secondaryText: localizedText(
          context,
          zh: '查看会员说明',
          en: 'View Membership Info',
        ),
        actionType: vm.HomePrimaryActionType.startReview,
        onPrimaryTap: _openReviewTab,
        onSecondaryTap: _openUnlock,
      );
    }

    if (nextLesson != null) {
      final lessonTitle = LessonLocalizer.title(
        nextLesson,
        context.appSettings.appLanguage,
      );
      return HomeMainCardState(
        badgeText: localizedText(context, zh: '今日主线', en: 'Today\'s Focus'),
        title: localizedText(
          context,
          zh: '继续 $lessonTitle',
          en: 'Continue $lessonTitle',
        ),
        arabicPreview: nextLesson.titleAr,
        nextStepDescription: localizedText(
          context,
          zh: '字母阶段已完成，现在继续这节课最顺。',
          en: 'The alphabet stage is complete. This lesson is the best next step now.',
        ),
        progressText: localizedText(
          context,
          zh: '进度 ${snapshot.completedLessonCount}/${snapshot.totalLessonCount}',
          en: 'Progress ${snapshot.completedLessonCount}/${snapshot.totalLessonCount}',
        ),
        reviewText: null,
        progressValue: snapshot.completionRate,
        primaryButtonText: localizedText(
          context,
          zh: snapshot.hasStartedAny ? '继续学习' : '开始第一课',
          en: snapshot.hasStartedAny ? 'Continue Learning' : 'Start Lesson 1',
        ),
        secondaryText: localizedText(
          context,
          zh: '查看课程',
          en: 'View Lessons',
        ),
        actionType: vm.HomePrimaryActionType.continueLesson,
        onPrimaryTap: () => _openNextTask(
          nextLesson,
          fromHomeTodayPlan: true,
        ),
        onSecondaryTap: _openLessonsTab,
      );
    }

    return HomeMainCardState(
      badgeText: localizedText(context, zh: '今日主线', en: 'Today\'s Focus'),
      title: localizedText(context, zh: '从字母开始', en: 'Start with the Alphabet'),
      arabicPreview: 'ابدأ من الحروف',
      nextStepDescription: localizedText(
        context,
        zh: '先建立字母识别和发音基础，再进入课程。',
        en: 'Build letter recognition and sound first, then move into lessons.',
      ),
      primaryButtonText: localizedText(context, zh: '开始', en: 'Start'),
      secondaryText: localizedText(context, zh: '查看字母分组', en: 'Open Alphabet Groups'),
      actionType: vm.HomePrimaryActionType.continueAlphabet,
      onPrimaryTap: _openAlphabetHub,
      onSecondaryTap: _openAlphabetLearning,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final snapshot = vm.LearningPathViewModels.buildSnapshot(
      lessons: _lessons,
      progress: _progress,
      unlocked: _unlocked,
    );

    final mainCardState = _buildPrimaryCardState(
      snapshot: snapshot,
      reviewPlan: _reviewDashboard?.summary.todayPlan,
    );

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: AppTheme.pagePadding,
            children: [
              _HomeTopGreetingSection(
                title: localizedText(
                  context,
                  zh: '今天从这里开始',
                  en: 'Start Here Today',
                ),
                subtitle: localizedText(
                  context,
                  zh: '你的下一步，从这里开始。',
                  en: 'Your next useful step starts here.',
                ),
              ),
              const SizedBox(height: 20),
              _HomeMainLearningCard(state: mainCardState),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeTopGreetingSection extends StatelessWidget {
  final String title;
  final String subtitle;

  const _HomeTopGreetingSection({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: <Color>[_homeApricot, _homeMint],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppTheme.softShadow,
          ),
          child: const Icon(
            Icons.auto_stories_rounded,
            color: AppTheme.accentMintDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: text.titleLarge),
              const SizedBox(height: 4),
              Text(subtitle, style: text.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _HomeMainLearningCard extends StatelessWidget {
  final HomeMainCardState state;

  const _HomeMainLearningCard({
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[
            Color(0xFFF7EAD8),
            Color(0xFFE2F4EC),
            Color(0xFFE8F1FA),
          ],
          stops: <double>[0.0, 0.58, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 26,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HomeStatusBadge(text: state.badgeText),
          const SizedBox(height: 14),
          _HomeMainCardHeader(
            title: state.title,
            arabicPreview: state.arabicPreview,
          ),
          const SizedBox(height: 10),
          Text(
            state.nextStepDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _homeBlue,
                ),
          ),
          if (state.progressText != null || state.reviewText != null) ...[
            const SizedBox(height: 14),
            _HomeMainCardMeta(
              progressText: state.progressText,
              reviewText: state.reviewText,
            ),
          ],
          if (state.progressValue != null) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: state.progressValue,
                minHeight: 8,
                backgroundColor: Colors.white.withOpacity(0.48),
                color: AppTheme.accentMintDark,
              ),
            ),
          ],
          const SizedBox(height: 18),
          _HomeMainCardActionArea(
            primaryButtonText: state.primaryButtonText,
            onPrimaryTap: state.onPrimaryTap,
            secondaryText: state.secondaryText,
            onSecondaryTap: state.onSecondaryTap,
          ),
        ],
      ),
    );
  }
}


class _HomeStatusBadge extends StatelessWidget {
  final String text;

  const _HomeStatusBadge({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Pill(
      label: text,
      backgroundColor: Colors.white.withOpacity(0.74),
      foregroundColor: _homeTerracotta,
    );
  }
}

class _HomeMainCardHeader extends StatelessWidget {
  final String title;
  final String? arabicPreview;

  const _HomeMainCardHeader({
    required this.title,
    this.arabicPreview,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final showInline = MediaQuery.of(context).size.width >= 390;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.44),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.28)),
      ),
      child: showInline
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 7,
                  child: Text(
                    title,
                    style: text.headlineMedium?.copyWith(
                      color: const Color(0xFF24313A),
                      height: 1.08,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (arabicPreview != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 5,
                    child: ArabicText.display(
                      arabicPreview!,
                      style: const TextStyle(
                        fontSize: 24,
                        height: 1.06,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF5B6B65),
                      ),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: text.headlineMedium?.copyWith(
                    color: const Color(0xFF24313A),
                    height: 1.08,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (arabicPreview != null) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ArabicText.display(
                      arabicPreview!,
                      style: const TextStyle(
                        fontSize: 24,
                        height: 1.06,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF5B6B65),
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

class _HomeMainCardMeta extends StatelessWidget {
  final String? progressText;
  final String? reviewText;

  const _HomeMainCardMeta({
    this.progressText,
    this.reviewText,
  });

  @override
  Widget build(BuildContext context) {
    final parts = <String>[
      if (progressText != null && progressText!.isNotEmpty) progressText!,
      if (reviewText != null && reviewText!.isNotEmpty) reviewText!,
    ];

    return Text(
      parts.join('  ·  '),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: const Color(0xFF56656E),
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _HomeMainCardActionArea extends StatelessWidget {
  final String primaryButtonText;
  final VoidCallback onPrimaryTap;
  final String? secondaryText;
  final VoidCallback? onSecondaryTap;

  const _HomeMainCardActionArea({
    required this.primaryButtonText,
    required this.onPrimaryTap,
    this.secondaryText,
    this.onSecondaryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onPrimaryTap,
            child: Text(primaryButtonText),
          ),
        ),
        if (secondaryText != null && onSecondaryTap != null) ...[
          const SizedBox(height: 10),
          TextButton(
            onPressed: onSecondaryTap,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(secondaryText!),
          ),
        ],
      ],
    );
  }
}
