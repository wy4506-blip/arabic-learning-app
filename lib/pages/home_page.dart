import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../features/onboarding/models/onboarding_state.dart';
import '../l10n/lesson_localizer.dart';
import '../l10n/localized_text.dart';
import '../models/app_settings.dart';
import '../models/lesson.dart';
import '../models/review_models.dart';
import '../pages/grammar_home_page.dart';
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
import 'alphabet_hub_page.dart';
import 'alphabet_page.dart';
import 'lesson_detail_page.dart';
import 'review_session_page.dart';
import 'unlock_page.dart';
import 'vocab_book_page.dart';

const Color _homeSand = Color(0xFFF7E8D6);
const Color _homeApricot = Color(0xFFFFF0E3);
const Color _homeSky = Color(0xFFE7F1FA);
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

class HomeQuickActionState {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color tintColor;
  final Color accentColor;
  final int? badgeCount;
  final bool isVisible;
  final VoidCallback onTap;

  const HomeQuickActionState({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tintColor,
    required this.accentColor,
    required this.onTap,
    this.badgeCount,
    this.isVisible = true,
  });
}

class HomeTodayLearningCardState {
  final String badgeText;
  final String title;
  final String subtitle;
  final String lessonLabel;
  final String lessonTitle;
  final String lessonMeta;
  final String totalTimeText;
  final String primaryButtonText;
  final String secondaryButtonText;
  final String tertiaryButtonText;
  final VoidCallback onPrimaryTap;
  final VoidCallback onSecondaryTap;
  final VoidCallback onTertiaryTap;

  const HomeTodayLearningCardState({
    required this.badgeText,
    required this.title,
    required this.subtitle,
    required this.lessonLabel,
    required this.lessonTitle,
    required this.lessonMeta,
    required this.totalTimeText,
    required this.primaryButtonText,
    required this.secondaryButtonText,
    required this.tertiaryButtonText,
    required this.onPrimaryTap,
    required this.onSecondaryTap,
    required this.onTertiaryTap,
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
      ]);
      if (!mounted) return;
      setState(() {
        _unlocked = results[0] as bool;
        _lessons = results[1] as List<Lesson>;
        _progress = results[2] as ProgressSnapshot;
        _reviewDashboard = results[3] as ReviewDashboardData;
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
  }

  Future<void> _openAlphabetLearning() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AlphabetPage()),
    );
  }

  Future<void> _openWordbook() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VocabBookPage()),
    );
  }

  Future<void> _openGrammar() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GrammarHomePage(settings: widget.settings),
      ),
    );
  }

  Future<void> _openNextTask(Lesson? lesson) async {
    final nextLesson = lesson;
    if (nextLesson == null) {
      await _openAlphabetLearning();
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
        await _openNextTask(nextLesson);
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
      await _refreshReviewDashboard();
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
      await _refreshReviewDashboard();
    }
  }

  HomeTodayLearningCardState? _buildTodayLearningCardState({
    required vm.LearningPathSnapshot snapshot,
    required DailyReviewPlan? reviewPlan,
  }) {
    if (!widget.onboardingState.hasCompletedFirstExperience) {
      return null;
    }

    final nextLesson = snapshot.recommendedLesson;
    if (nextLesson == null) {
      return null;
    }
    if (snapshot.nextLessonLocked && !_unlocked) {
      return null;
    }

    final hasWarmUp = (reviewPlan?.pendingCount ?? 0) > 0;
    final lessonTitle = LessonLocalizer.title(
      nextLesson,
      context.appSettings.appLanguage,
    );

    return HomeTodayLearningCardState(
      badgeText: localizedText(
        context,
        zh: '今日学习',
        en: 'Today\'s Learning',
      ),
      title: localizedText(
        context,
        zh: '开始今天学习',
        en: 'Start Today\'s Learning',
      ),
      subtitle: hasWarmUp
          ? localizedText(
              context,
              zh: '建议先复习 2 分钟，再进入下一节课',
              en: 'A short two-minute warm-up first, then move into the next lesson.',
            )
          : localizedText(
              context,
              zh: '当前没有待复习内容，将直接进入下一节课',
              en: 'No warm-up is waiting, so you will go straight into the next lesson.',
            ),
      lessonLabel: localizedText(
        context,
        zh: '下一节课',
        en: 'Next Lesson',
      ),
      lessonTitle: lessonTitle.isEmpty ? nextLesson.id : lessonTitle,
      lessonMeta: localizedText(
        context,
        zh: '${nextLesson.id} · 课程约 ${nextLesson.estimatedMinutes} 分钟',
        en: '${nextLesson.id} · lesson about ${nextLesson.estimatedMinutes} min',
      ),
      totalTimeText: _todayLearningTotalTimeText(
        lesson: nextLesson,
        hasWarmUp: hasWarmUp,
      ),
      primaryButtonText: localizedText(
        context,
        zh: '开始学习',
        en: 'Start Learning',
      ),
      secondaryButtonText: localizedText(
        context,
        zh: '只复习',
        en: 'Review Only',
      ),
      tertiaryButtonText: localizedText(
        context,
        zh: '跳过复习，直接学习',
        en: 'Skip Review and Learn',
      ),
      onPrimaryTap: () => _openHomeTodayReviewFlow(nextLesson),
      onSecondaryTap: _openStandaloneReviewFlow,
      onTertiaryTap: () => _openNextTask(nextLesson),
    );
  }

  String _todayLearningTotalTimeText({
    required Lesson lesson,
    required bool hasWarmUp,
  }) {
    final lessonMinutes =
        lesson.estimatedMinutes <= 0 ? 8 : lesson.estimatedMinutes;
    final minTotal = hasWarmUp ? lessonMinutes + 1 : lessonMinutes;
    final maxTotal = hasWarmUp ? lessonMinutes + 2 : lessonMinutes + 1;
    if (minTotal >= maxTotal) {
      return localizedText(
        context,
        zh: '预计约 $maxTotal 分钟',
        en: 'About $maxTotal min total',
      );
    }
    return localizedText(
      context,
      zh: '预计总耗时 $minTotal~$maxTotal 分钟',
      en: 'About $minTotal-$maxTotal min total',
    );
  }

  // ignore: unused_element
  HomeMainCardState _buildMainCardState({
    required Lesson? nextLesson,
    required int learned,
    required int totalLessons,
    required int toReview,
    required double completionRate,
    required bool nextLessonLocked,
  }) {
    final language = context.appSettings.appLanguage;

    if (toReview > 0 && learned > 0) {
      return HomeMainCardState(
        badgeText: localizedText(context, zh: '今日建议', en: 'Today\'s Tip'),
        title: localizedText(context, zh: '先复习一下', en: 'Review First'),
        arabicPreview: 'راجع الآن',
        nextStepDescription: localizedText(
          context,
          zh: '花 2 分钟，回顾刚学过的重点。',
          en: 'Take two minutes to refresh the most recent points.',
        ),
        progressText: localizedText(
          context,
          zh: '已完成 $learned/$totalLessons 课',
          en: 'Completed $learned/$totalLessons lessons',
        ),
        reviewText: localizedText(
          context,
          zh: '待回顾 $toReview 项',
          en: '$toReview items to review',
        ),
        primaryButtonText:
            localizedText(context, zh: '开始复习', en: 'Start Review'),
        actionType: vm.HomePrimaryActionType.startReview,
        onPrimaryTap: _openReviewTab,
      );
    }

    if (widget.onboardingState.hasCompletedFirstExperience &&
        _progress.startedLessons.isEmpty) {
      return HomeMainCardState(
        badgeText: localizedText(context, zh: '今日主线', en: 'Today\'s Focus'),
        title: localizedText(
          context,
          zh: '继续字母学习',
          en: 'Continue Alphabet Learning',
        ),
        arabicPreview: 'تابع الحروف',
        nextStepDescription: localizedText(
          context,
          zh: '再学 1 个字母，继续打好基础。',
          en: 'Learn one more letter and keep strengthening the base.',
        ),
        progressText: localizedText(
          context,
          zh: '已完成首学体验',
          en: 'First experience completed',
        ),
        reviewText: localizedText(
          context,
          zh: '下一步：分组字母',
          en: 'Next: grouped letters',
        ),
        primaryButtonText: localizedText(context, zh: '继续', en: 'Continue'),
        secondaryText:
            localizedText(context, zh: '查看字母表', en: 'Browse Alphabet'),
        actionType: vm.HomePrimaryActionType.continueAlphabet,
        onPrimaryTap: _openAlphabetLearning,
        onSecondaryTap: _openAlphabetHub,
      );
    }

    if (!_unlocked && nextLessonLocked && learned >= 3) {
      return HomeMainCardState(
        badgeText: localizedText(context, zh: '下一步', en: 'Next Step'),
        title: localizedText(
          context,
          zh: '继续完整课程',
          en: 'Continue the Full Course',
        ),
        arabicPreview: 'أكمل المسار',
        nextStepDescription: localizedText(
          context,
          zh: '你已完成免费部分，继续后续内容。',
          en: 'You finished the free part. Continue the rest of the path.',
        ),
        progressText: localizedText(
          context,
          zh: '已完成前 3 课',
          en: 'First 3 lessons completed',
        ),
        reviewText: toReview > 0
            ? localizedText(
                context,
                zh: '待回顾 $toReview 项',
                en: '$toReview items to review',
              )
            : null,
        primaryButtonText:
            localizedText(context, zh: '查看完整内容', en: 'View Full Access'),
        secondaryText:
            localizedText(context, zh: '回顾已学内容', en: 'Review What You Learned'),
        actionType: vm.HomePrimaryActionType.continuePremiumTrack,
        onPrimaryTap: _openUnlock,
        onSecondaryTap: _openReviewTab,
      );
    }

    if (nextLesson != null) {
      return HomeMainCardState(
        badgeText: localizedText(context, zh: '今日主线', en: 'Today\'s Focus'),
        title: localizedText(
          context,
          zh: '继续${LessonLocalizer.title(nextLesson, language)}',
          en: 'Continue ${LessonLocalizer.title(nextLesson, language)}',
        ),
        arabicPreview: nextLesson.titleAr,
        nextStepDescription: localizedText(
          context,
          zh: '今天建议先完成这一小节。',
          en: 'This is the most useful next step for today.',
        ),
        progressText: localizedText(
          context,
          zh: '进度 $learned/$totalLessons',
          en: 'Progress $learned/$totalLessons',
        ),
        reviewText: toReview > 0
            ? localizedText(
                context,
                zh: '待复习 $toReview 项',
                en: '$toReview items to review',
              )
            : null,
        progressValue: completionRate,
        primaryButtonText:
            localizedText(context, zh: '继续学习', en: 'Continue Learning'),
        secondaryText: localizedText(context, zh: '查看课程', en: 'View Lessons'),
        actionType: vm.HomePrimaryActionType.continueLesson,
        onPrimaryTap: () => _openNextTask(nextLesson),
        onSecondaryTap: _openLessonsTab,
      );
    }

    return HomeMainCardState(
      badgeText: localizedText(context, zh: '今日主线', en: 'Today\'s Focus'),
      title: localizedText(
        context,
        zh: '从字母开始',
        en: 'Start with the Alphabet',
      ),
      arabicPreview: 'ابدأ من الحروف',
      nextStepDescription: localizedText(
        context,
        zh: '先建立字母识别和发音基础，再进入课程。',
        en: 'Build letter recognition and sound first, then move into lessons.',
      ),
      primaryButtonText: localizedText(context, zh: '开始', en: 'Start'),
      secondaryText: localizedText(context, zh: '查看字母表', en: 'Browse Alphabet'),
      actionType: vm.HomePrimaryActionType.continueAlphabet,
      onPrimaryTap: _openAlphabetLearning,
      onSecondaryTap: _openAlphabetHub,
    );
  }

  HomeMainCardState _materializeMainCardState(
    vm.HomeMainLearningViewModel viewModel,
  ) {
    VoidCallback onPrimaryTap;
    VoidCallback? onSecondaryTap;

    switch (viewModel.actionType) {
      case vm.HomePrimaryActionType.continueAlphabet:
        onPrimaryTap = _openAlphabetLearning;
        onSecondaryTap = _openAlphabetHub;
        break;
      case vm.HomePrimaryActionType.continueLesson:
        onPrimaryTap = () => _openNextTask(viewModel.lesson);
        onSecondaryTap = _openLessonsTab;
        break;
      case vm.HomePrimaryActionType.startReview:
        onPrimaryTap = _openReviewTab;
        break;
      case vm.HomePrimaryActionType.continuePremiumTrack:
        onPrimaryTap = _openUnlock;
        onSecondaryTap = _openReviewTab;
        break;
    }

    return HomeMainCardState(
      badgeText: viewModel.badgeText,
      title: viewModel.title,
      arabicPreview: viewModel.arabicPreview,
      nextStepDescription: viewModel.description,
      progressText: viewModel.progressText,
      reviewText: viewModel.reviewText,
      progressValue: viewModel.progressValue,
      primaryButtonText: viewModel.primaryButtonText,
      secondaryText: viewModel.secondaryText,
      actionType: viewModel.actionType,
      onPrimaryTap: onPrimaryTap,
      onSecondaryTap: onSecondaryTap,
    );
  }

  List<HomeQuickActionState> _buildQuickActions(int toReview) {
    return [
      HomeQuickActionState(
        id: 'review',
        title: localizedText(context, zh: '复习', en: 'Review'),
        subtitle: localizedText(
          context,
          zh: '回顾刚学过的内容',
          en: 'Refresh what you just learned',
        ),
        icon: Icons.refresh_rounded,
        tintColor: _homeMint,
        accentColor: AppTheme.accentMintDark,
        badgeCount: toReview > 0 ? toReview : null,
        onTap: _openReviewTab,
      ),
      HomeQuickActionState(
        id: 'alphabet',
        title: localizedText(context, zh: '字母', en: 'Alphabet'),
        subtitle: localizedText(
          context,
          zh: '听读、书写、练习闭环',
          en: 'Listen, write, and drill letters',
        ),
        icon: Icons.sort_by_alpha_rounded,
        tintColor: _homeSky,
        accentColor: _homeBlue,
        onTap: _openAlphabetHub,
      ),
      HomeQuickActionState(
        id: 'wordbook',
        title: localizedText(context, zh: '单词本', en: 'Wordbook'),
        subtitle: localizedText(
          context,
          zh: '随学随收，随时检索',
          en: 'Save while learning and search anytime',
        ),
        icon: Icons.bookmark_outline_rounded,
        tintColor: _homeSand,
        accentColor: _homeTerracotta,
        onTap: _openWordbook,
      ),
      HomeQuickActionState(
        id: 'grammar',
        title: localizedText(context, zh: '语法速查', en: 'Grammar'),
        subtitle: localizedText(
          context,
          zh: '规则总表，随时查看',
          en: 'Quick tables and rules on demand',
        ),
        icon: Icons.rule_folder_outlined,
        tintColor: _homeApricot,
        accentColor: _homeTerracotta,
        onTap: _openGrammar,
      ),
    ];
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
    final mainCardViewModel = vm.LearningPathViewModels.buildHomeMainCard(
      language: context.appSettings.appLanguage,
      snapshot: snapshot,
      onboardingCompleted: widget.onboardingState.hasCompletedFirstExperience,
    );
    final hasLockedLessons = snapshot.hasLockedLessons;
    final mainCardState = _materializeMainCardState(mainCardViewModel);
    final quickActions = _buildQuickActions(snapshot.pendingReviewCount)
        .map(
          (action) => action.id == 'review'
              ? HomeQuickActionState(
                  id: action.id,
                  title: action.title,
                  subtitle: action.subtitle,
                  icon: action.icon,
                  tintColor: action.tintColor,
                  accentColor: action.accentColor,
                  badgeCount:
                      _reviewDashboard?.summary.todayPlan.pendingCount ??
                          action.badgeCount,
                  onTap: action.onTap,
                )
              : action,
        )
        .where((action) => action.isVisible)
        .toList();
    final reviewPlan = _reviewDashboard?.summary.todayPlan;
    final todayLearningCard = _buildTodayLearningCardState(
      snapshot: snapshot,
      reviewPlan: reviewPlan,
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
                  zh: '少入口、低干扰、强反馈的阿语入门首页',
                  en: 'A focused Arabic home that points to the next best step.',
                ),
              ),
              const SizedBox(height: 20),
              if (todayLearningCard != null)
                _HomeTodayLearningCard(state: todayLearningCard)
              else
                _HomeMainLearningCard(state: mainCardState),
              if (todayLearningCard == null &&
                  reviewPlan != null &&
                  reviewPlan.tasks.isNotEmpty) ...[
                const SizedBox(height: 18),
                LessonMicroReviewCard(
                  title: localizedText(
                    context,
                    zh: reviewPlan.hasStarted ? '继续今天的回顾' : '今天顺手回顾一下',
                    en: reviewPlan.hasStarted
                        ? 'Continue Today\'s Review'
                        : 'A Light Review for Today',
                  ),
                  subtitle: localizedText(
                    context,
                    zh: reviewPlan.hasStarted
                        ? '还有 ${reviewPlan.pendingCount} 项没看完，接着过一遍就好。'
                        : '自动整理了 ${reviewPlan.totalCount} 项最近值得先回看的内容。',
                    en: reviewPlan.hasStarted
                        ? '${reviewPlan.pendingCount} items are still waiting. Pick it back up from where you left.'
                        : '${reviewPlan.totalCount} recent items are ready for a gentle review pass.',
                  ),
                  tasks: reviewPlan.tasks.take(3).toList(growable: false),
                  actionLabel: localizedText(
                    context,
                    zh: reviewPlan.hasStarted ? '继续回顾' : '开始回顾',
                    en: reviewPlan.hasStarted
                        ? 'Continue Review'
                        : 'Start Review',
                  ),
                  onActionTap: () =>
                      _openHomeTodayReviewFlow(snapshot.recommendedLesson),
                ),
              ],
              const SizedBox(height: 22),
              _HomeQuickActionsSection(
                title: localizedText(
                  context,
                  zh: '常用操作',
                  en: 'Study Tools',
                ),
                subtitle: localizedText(
                  context,
                  zh: '回顾、查找、补充学习都在这里',
                  en: 'Review, lookup, and support actions all live here.',
                ),
                actions: quickActions,
              ),
              if (!_unlocked && hasLockedLessons) ...[
                const SizedBox(height: 18),
                _HomeFreeTrackBanner(
                  title: localizedText(
                    context,
                    zh: '前 3 课免费体验',
                    en: 'First 3 Lessons Free',
                  ),
                  subtitle: localizedText(
                    context,
                    zh: '先完成核心入门内容，再决定是否继续完整课程。',
                    en: 'Finish the core free lessons first, then decide whether to continue.',
                  ),
                  onTap: _openUnlock,
                ),
              ],
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

class _HomeTodayLearningCard extends StatelessWidget {
  final HomeTodayLearningCardState state;

  const _HomeTodayLearningCard({
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

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
          Text(
            state.title,
            style: text.headlineMedium?.copyWith(
              color: const Color(0xFF24313A),
              height: 1.08,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            state.subtitle,
            style: text.bodyMedium?.copyWith(
              color: _homeBlue,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.44),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withOpacity(0.28)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Pill(
                      label: state.lessonLabel,
                      backgroundColor: Colors.white.withOpacity(0.8),
                      foregroundColor: _homeTerracotta,
                    ),
                    const Spacer(),
                    Text(
                      state.totalTimeText,
                      style: text.bodySmall?.copyWith(
                        color: const Color(0xFF56656E),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  state.lessonTitle,
                  style: text.titleLarge?.copyWith(
                    color: const Color(0xFF24313A),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  state.lessonMeta,
                  style: text.bodySmall?.copyWith(
                    color: const Color(0xFF56656E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: state.onPrimaryTap,
              child: Text(state.primaryButtonText),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: state.onSecondaryTap,
              child: Text(state.secondaryButtonText),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: state.onTertiaryTap,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(state.tertiaryButtonText),
            ),
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

class _HomeQuickActionsSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<HomeQuickActionState> actions;

  const _HomeQuickActionsSection({
    required this.title,
    required this.subtitle,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HomeSectionHeader(title: title, subtitle: subtitle),
        const SizedBox(height: 12),
        GridView.builder(
          itemCount: actions.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.05,
          ),
          itemBuilder: (context, index) {
            final action = actions[index];
            return _QuickActionCard(state: action);
          },
        ),
      ],
    );
  }
}

class _HomeSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _HomeSectionHeader({
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: text.titleMedium),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!, style: text.bodySmall),
        ],
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final HomeQuickActionState state;

  const _QuickActionCard({
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return AppSurface(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      onTap: state.onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: state.tintColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(state.icon, color: state.accentColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.title, style: text.titleSmall),
                const SizedBox(height: 3),
                Text(
                  state.subtitle,
                  style: text.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (state.badgeCount != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: state.tintColor,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${state.badgeCount}',
                style: text.labelSmall?.copyWith(
                  color: state.accentColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HomeFreeTrackBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HomeFreeTrackBanner({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return AppSurface(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4EA),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.lock_open_rounded,
              color: _homeTerracotta,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text.titleSmall),
                const SizedBox(height: 3),
                Text(subtitle, style: text.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF98A2B3),
          ),
        ],
      ),
    );
  }
}
