import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/localized_text.dart';
import '../models/review_models.dart';
import '../services/review_service.dart';
import '../services/review_sync_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/review/review_item_sections.dart';
import '../widgets/review/review_quick_actions.dart';
import '../widgets/review/review_status_strip.dart';
import '../widgets/review/review_today_card.dart';
import 'course_list_page.dart';
import 'review_session_page.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  ReviewDashboardData? _dashboard;
  ReviewEntrySnapshot? _entrySnapshot;
  bool _loading = true;
  bool _didLoadInitialDashboard = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    ReviewSyncService.changes.addListener(_handleReviewChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadInitialDashboard) {
      return;
    }
    _didLoadInitialDashboard = true;
    _loadDashboard();
  }

  @override
  void dispose() {
    ReviewSyncService.changes.removeListener(_handleReviewChanged);
    super.dispose();
  }

  void _handleReviewChanged() {
    _loadDashboard(showSpinner: false);
  }

  Future<void> _loadDashboard({bool showSpinner = true}) async {
    if (showSpinner && mounted) {
      setState(() {
        _loading = true;
        _loadError = null;
      });
    }

    try {
      final results = await Future.wait<dynamic>([
        ReviewService.buildDashboard(context.appSettings),
        ReviewService.getEntrySnapshot(context.appSettings),
      ]);

      if (!mounted) {
        return;
      }
      setState(() {
        _dashboard = results[0] as ReviewDashboardData;
        _entrySnapshot = results[1] as ReviewEntrySnapshot;
        _loading = false;
        _loadError = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _loadError = error.toString();
      });
    }
  }

  Future<void> _openSession(Future<ReviewSession?> Function() factory) async {
    final session = await factory();
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
      await _loadDashboard(showSpinner: false);
    }
  }

  Future<void> _showTypePicker(Map<ReviewContentType, int> counts) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              Text(
                localizedText(
                  context,
                  zh: '按类型复习',
                  en: 'Review by Type',
                ),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                localizedText(
                  context,
                  zh: '按你当下最想补的那一类来，不需要一次看很多。',
                  en: 'Choose just the type you want to reinforce right now.',
                ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ...ReviewContentType.values.map(
                (type) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(_typeLabel(type)),
                  subtitle: Text(
                    localizedText(
                      context,
                      zh: '可回顾 ${counts[type] ?? 0} 项',
                      en: '${counts[type] ?? 0} items available',
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: (counts[type] ?? 0) == 0
                      ? null
                      : () async {
                          Navigator.of(context).pop();
                          await _openSession(
                            () => ReviewService.createTypeSession(
                              context.appSettings,
                              type,
                            ),
                          );
                        },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openSingleTask(ReviewTask task) async {
    final session = ReviewService.createSingleTaskSession(
      context.appSettings,
      task,
    );
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewSessionPage(session: session),
      ),
    );
    if (result == true) {
      await _loadDashboard(showSpinner: false);
    }
  }

  Future<void> _openLessons() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CourseListPage(settings: context.appSettings),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_dashboard == null || _entrySnapshot == null) {
      return Scaffold(
        body: SafeArea(
          child: ListView(
            padding: AppTheme.pagePadding,
            children: [
              SectionTitle(
                title: localizedText(context, zh: '复习', en: 'Review'),
                subtitle: localizedText(
                  context,
                  zh: '复习引擎 - 优先完成最需要的复习任务。',
                  en: 'Review Engine - prioritize the reviews that matter most.',
                ),
              ),
              const SizedBox(height: 18),
              AppSurface(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                child: _loading
                    ? Row(
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.4),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              localizedText(
                                context,
                                zh: '正在整理复习优先级…',
                                en: 'Preparing review priorities...',
                              ),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizedText(
                              context,
                              zh: '这次没有顺利取到复习内容',
                              en: 'The review set could not be loaded this time',
                            ),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _loadError ??
                                localizedText(
                                  context,
                                  zh: '可以再试一次，或先继续主线学习。',
                                  en: 'Try again, or continue with lessons for now.',
                                ),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 14),
                          FilledButton(
                            onPressed: _loadDashboard,
                            child: Text(
                              localizedText(context,
                                  zh: '重新加载', en: 'Try Again'),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      );
    }

    final dashboard = _dashboard!;
    final snapshot = _entrySnapshot!;
    final summary = dashboard.summary;
    final todayPlan = summary.todayPlan;
    final typeCounts = summary.typeCounts;

    // Priority signals from review engine entry
    final hasFormalReview = snapshot.formalTasks.isNotEmpty;
    final hasLightReview = snapshot.lightTasks.isNotEmpty;
    final hasOverdueReview = snapshot.overdueTasks.isNotEmpty;
    final hasStageReinforcement = snapshot.stageReinforcementTasks.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboard,
          child: ListView(
            padding: AppTheme.pagePadding,
            children: [
              SectionTitle(
                title: localizedText(context, zh: '复习', en: 'Review'),
                subtitle: localizedText(
                  context,
                  zh: '先做今天的主复习，再按需补充短练习。',
                  en: 'Start with today\'s main review, then add shorter practice only if needed.',
                ),
              ),
              const SizedBox(height: 18),
              ReviewStatusStrip(
                title: localizedText(
                  context,
                  zh: '今天的状态',
                  en: 'Today\'s Snapshot',
                ),
                metrics: [
                  ReviewStatusMetric(
                    label: localizedText(context, zh: '待复习', en: 'Pending'),
                    value: '${todayPlan.pendingCount}',
                    icon: Icons.refresh_rounded,
                  ),
                  ReviewStatusMetric(
                    label: localizedText(context, zh: '已完成', en: 'Done'),
                    value: '${todayPlan.completedCount}',
                    icon: Icons.check_circle_outline_rounded,
                  ),
                  ReviewStatusMetric(
                    label: localizedText(context, zh: '连续天数', en: 'Streak'),
                    value: localizedText(
                      context,
                      zh: '${summary.streakDays} 天',
                      en: '${summary.streakDays} days',
                    ),
                    icon: Icons.local_fire_department_outlined,
                  ),
                  ReviewStatusMetric(
                    label: localizedText(context, zh: '本周次数', en: 'This Week'),
                    value: '${summary.weeklyReviewCount}',
                    icon: Icons.calendar_today_outlined,
                  ),
                ],
              ),
              if (hasStageReinforcement || hasOverdueReview || hasFormalReview)
                Column(
                  children: [
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      decoration: BoxDecoration(
                        color: hasStageReinforcement
                            ? const Color(0xFFFFF3E0)
                            : hasOverdueReview
                                ? const Color(0xFFFFE0E0)
                                : const Color(0xFFF0F7FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            hasStageReinforcement
                                ? Icons.pending_actions_rounded
                                : hasOverdueReview
                                    ? Icons.warning_rounded
                                    : Icons.trending_up_rounded,
                            size: 20,
                            color: hasStageReinforcement
                                ? const Color(0xFFE65100)
                                : hasOverdueReview
                                    ? const Color(0xFFD32F2F)
                                    : const Color(0xFF1976D2),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              hasStageReinforcement
                                  ? localizedText(
                                      context,
                                      zh: '有${snapshot.stageReinforcementTasks.length}项需要补强',
                                      en: '${snapshot.stageReinforcementTasks.length} items need extra reinforcement',
                                    )
                                  : hasOverdueReview
                                      ? localizedText(
                                          context,
                                          zh: '有${snapshot.overdueTasks.length}项已超期，建议优先处理',
                                          en: '${snapshot.overdueTasks.length} overdue items need attention',
                                        )
                                      : localizedText(
                                          context,
                                          zh: '${snapshot.formalTasks.length}项待复习内容已就绪，建议先处理',
                                          en: '${snapshot.formalTasks.length} review items are ready',
                                        ),
                              style: Theme.of(context).textTheme.labelMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 18),
              ReviewTodayCard(
                badge: localizedText(
                  context,
                  zh: summary.todayPlan.isCompleted ? '今天已完成' : '今日复习',
                  en: summary.todayPlan.isCompleted
                      ? 'Done for Today'
                      : 'Today\'s Review',
                ),
                title: todayPlan.tasks.isEmpty
                    ? localizedText(
                        context,
                        zh: '今天先轻松往前学就好',
                        en: 'You Can Keep Learning Lightly Today',
                      )
                    : todayPlan.isCompleted
                        ? localizedText(
                            context,
                            zh: '这轮内容已经顺手回顾完了',
                            en: 'This Review Set Is Already Done',
                          )
                        : summary.todayPlan.hasStarted
                            ? localizedText(
                                context,
                                zh: '继续今日复习',
                                en: 'Continue Today\'s Review',
                              )
                            : localizedText(
                                context,
                                zh: '先完成今天最值得做的一组复习',
                                en: 'Start with today\'s main review set',
                              ),
                subtitle: todayPlan.tasks.isEmpty
                    ? localizedText(
                        context,
                        zh: '如果刚学完新内容，回头这里会自动出现今天适合顺手复习的内容。',
                        en: 'Once you learn something new, suitable review items will show up here automatically.',
                      )
                    : todayPlan.isCompleted
                        ? localizedText(
                            context,
                            zh: '今天这组主复习已经完成。你可以回到课程继续学习，也可以做一轮短练习。',
                            en: 'Today\'s main review is complete. You can return to lessons or do a short practice pass.',
                          )
                        : localizedText(
                            context,
                            zh: '系统会优先整理到期内容、薄弱项和刚学完的对象。',
                            en: 'This set is built from due items, weak spots, and what you just learned.',
                          ),
                composition: _compositionLabels(typeCounts, todayPlan.tasks),
                metaText: todayPlan.tasks.isEmpty
                    ? localizedText(
                        context,
                        zh: '当前没有待复习任务',
                        en: 'No review task is waiting right now',
                      )
                    : localizedText(
                        context,
                        zh: '${todayPlan.totalCount} 项 · 约 ${_estimatedMinutes(todayPlan)} 分钟',
                        en: '${todayPlan.totalCount} items · about ${_estimatedMinutes(todayPlan)} min',
                      ),
                primaryActionLabel: todayPlan.tasks.isEmpty
                    ? localizedText(context, zh: '刷新看看', en: 'Refresh')
                    : todayPlan.isCompleted
                        ? localizedText(context,
                            zh: '开始快速复习', en: 'Start a Quick Review')
                        : summary.todayPlan.hasStarted
                            ? localizedText(context,
                                zh: '继续今日复习', en: 'Continue Today\'s Review')
                            : localizedText(context,
                                zh: '开始今日复习', en: 'Start Today\'s Review'),
                onPrimaryTap: todayPlan.tasks.isEmpty
                    ? () => _loadDashboard()
                    : todayPlan.isCompleted
                        ? () => _openSession(
                              () => ReviewService.createQuickSession(
                                context.appSettings,
                              ),
                            )
                        : () => _openSession(
                              () => ReviewService.createTodaySession(
                                context.appSettings,
                              ),
                            ),
                secondaryActionLabel: todayPlan.tasks.isEmpty
                    ? localizedText(
                        context,
                        zh: '去看课程',
                        en: 'Go to Lessons',
                      )
                    : localizedText(
                        context,
                        zh: '按类型复习',
                        en: 'Review by Type',
                      ),
                onSecondaryTap: todayPlan.tasks.isEmpty
                    ? _openLessons
                    : () => _showTypePicker(typeCounts),
              ),
              const SizedBox(height: 18),
              ReviewQuickActions(
                title: localizedText(context, zh: '快捷入口', en: 'Quick Actions'),
                subtitle: localizedText(
                  context,
                  zh: hasFormalReview || hasLightReview
                      ? '今天的主复习在前，下面这些入口留给补漏和短练习。'
                      : '先做一小轮，或者只补最需要再看一遍的地方。',
                  en: hasFormalReview || hasLightReview
                      ? 'Today\'s main review comes first. Use these entries for targeted catch-up and short practice.'
                      : 'Run one short pass or focus on the items that still need another look.',
                ),
                actions: [
                  ReviewQuickActionItem(
                    title:
                        localizedText(context, zh: '快速复习', en: 'Quick Review'),
                    subtitle: localizedText(
                      context,
                      zh: '快速过一遍几个关键点，不影响今天的主复习。',
                      en: 'Clear a few key items without affecting today\'s main review.',
                    ),
                    badge: todayPlan.tasks.isEmpty
                        ? null
                        : '${todayPlan.pendingCount}',
                    icon: Icons.bolt_rounded,
                    tintColor: const Color(0xFFFFF1E5),
                    iconColor: const Color(0xFFB56D45),
                    onTap: () => _openSession(
                      () =>
                          ReviewService.createQuickSession(context.appSettings),
                    ),
                  ),
                  ReviewQuickActionItem(
                    title:
                        localizedText(context, zh: '薄弱项加练', en: 'Weak Spots'),
                    subtitle: localizedText(
                      context,
                      zh: '把还不稳的内容单独补一下。',
                      en: 'Pull unstable items into a separate short pass.',
                    ),
                    badge: '${dashboard.weakTasks.length}',
                    icon: Icons.track_changes_rounded,
                    tintColor: const Color(0xFFE9F6EF),
                    iconColor: AppTheme.accentMintDark,
                    onTap: () => _openSession(
                      () =>
                          ReviewService.createWeakSession(context.appSettings),
                    ),
                  ),
                  ReviewQuickActionItem(
                    title: localizedText(context,
                        zh: '按类型复习', en: 'Review by Type'),
                    subtitle: localizedText(
                      context,
                      zh: '按对象类型挑一组，适合补单点。',
                      en: 'Choose one content type for a focused short pass.',
                    ),
                    icon: Icons.tune_rounded,
                    tintColor: const Color(0xFFEAF1FB),
                    iconColor: const Color(0xFF5B7FA8),
                    onTap: () => _showTypePicker(typeCounts),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ReviewTaskSection(
                title: localizedText(context,
                    zh: '需要再看一遍', en: 'Worth Another Look'),
                subtitle: localizedText(
                  context,
                  zh: '这些内容还不够稳，回顾一次会更安心。',
                  en: 'These items are not fully stable yet, so one more pass helps.',
                ),
                tasks: dashboard.weakTasks,
                emptyTitle: localizedText(context,
                    zh: '目前没有特别薄弱的内容', en: 'No obvious weak spots right now'),
                emptySubtitle: localizedText(
                  context,
                  zh: '当你在复习里点“再看一遍”时，这里会自动留下来方便继续补。',
                  en: 'When you choose “review again”, the item will stay here for an easy follow-up.',
                ),
                onTaskTap: _openSingleTask,
              ),
              const SizedBox(height: 18),
              ReviewTaskSection(
                title: localizedText(context,
                    zh: '最近学过，建议回看', en: 'Recently Learned'),
                subtitle: localizedText(
                  context,
                  zh: '查完或学完后能顺着回到这里，少找路，少切换。',
                  en: 'Items you recently learned or checked stay here for a quick return.',
                ),
                tasks: dashboard.recentTasks,
                emptyTitle: localizedText(context,
                    zh: '最近还没有形成回看内容', en: 'No recent review items yet'),
                emptySubtitle: localizedText(
                  context,
                  zh: '学完一节课、看过语法或打开过字母页后，这里会慢慢长出来。',
                  en: 'After lessons, grammar lookups, or letter pages, this area will start filling in naturally.',
                ),
                onTaskTap: _openSingleTask,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _compositionLabels(
    Map<ReviewContentType, int> counts,
    List<ReviewTask> tasks,
  ) {
    if (tasks.isEmpty) {
      return const <String>[];
    }

    final labels = <String>[];
    for (final type in ReviewContentType.values) {
      final count = counts[type] ?? 0;
      if (count == 0) {
        continue;
      }
      labels.add('${_typeLabel(type)} $count');
    }
    return labels.take(4).toList(growable: false);
  }

  int _estimatedMinutes(DailyReviewPlan plan) {
    final seconds = plan.estimatedSeconds;
    return (seconds / 60).ceil().clamp(1, 99);
  }

  String _typeLabel(ReviewContentType type) {
    switch (type) {
      case ReviewContentType.word:
        return localizedText(context, zh: '单词', en: 'Words');
      case ReviewContentType.pronunciation:
        return localizedText(context, zh: '发音', en: 'Pronunciation');
      case ReviewContentType.pair:
        return localizedText(context, zh: '辨音', en: 'Sound Contrast');
      case ReviewContentType.sentence:
        return localizedText(context, zh: '句子', en: 'Sentences');
      case ReviewContentType.grammar:
        return localizedText(context, zh: '语法', en: 'Grammar');
      case ReviewContentType.alphabet:
        return localizedText(context, zh: '字母', en: 'Letters');
    }
  }
}
