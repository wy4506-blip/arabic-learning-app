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
      final dashboard = await ReviewService.buildDashboard(context.appSettings);
      if (!mounted) {
        return;
      }
      setState(() {
        _dashboard = dashboard;
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
    if (_dashboard == null) {
      return Scaffold(
        body: SafeArea(
          child: ListView(
            padding: AppTheme.pagePadding,
            children: [
              SectionTitle(
                title: localizedText(context, zh: '复习', en: 'Review'),
                subtitle: localizedText(
                  context,
                  zh: '先做今天最值得的一轮正式复习，做完就顺着回到课程。',
                  en: 'Start with the single most valuable formal review set for today, then return to lessons.',
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
                                zh: '正在整理今天适合顺手回顾的内容…',
                                en: 'Preparing a light review set for today...',
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
                              localizedText(context, zh: '重新加载', en: 'Try Again'),
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
    final summary = dashboard.summary;
    final todayPlan = summary.todayPlan;
    final typeCounts = summary.typeCounts;

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
                  zh: '正式复习优先，自由练习放后，尽量让你少做选择。',
                  en: 'Formal review first, free practice second, with fewer choices to make.',
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
              const SizedBox(height: 18),
              ReviewTodayCard(
                badge: localizedText(
                  context,
                  zh: summary.todayPlan.isCompleted ? '今天已完成' : '今日复习',
                  en: summary.todayPlan.isCompleted ? 'Done for Today' : 'Today\'s Review',
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
                                zh: '继续今天这轮正式复习',
                                en: 'Continue Today\'s Formal Review',
                              )
                            : localizedText(
                                context,
                                zh: '先完成今天最值得做的正式复习',
                                en: 'Start with the most valuable formal review set',
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
                            zh: '今天这组正式复习已经完成。你可以回到课程继续推进，也可以做一轮自由练习。',
                            en: 'Today\'s formal review is complete. You can return to lessons or do a short free-practice pass.',
                          )
                        : localizedText(
                            context,
                            zh: '内容会优先从待正式复习、薄弱项和刚学完的对象里自动整理。',
                            en: 'The set is automatically built from due review items, weak spots, and what you just learned.',
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
                        zh:
                            '${todayPlan.totalCount} 项 · 约 ${_estimatedMinutes(todayPlan)} 分钟',
                        en:
                            '${todayPlan.totalCount} items · about ${_estimatedMinutes(todayPlan)} min',
                      ),
                primaryActionLabel: todayPlan.tasks.isEmpty
                    ? localizedText(context, zh: '刷新看看', en: 'Refresh')
                    : todayPlan.isCompleted
                        ? localizedText(context, zh: '再来一轮快复习', en: 'Start a Quick Review')
                        : summary.todayPlan.hasStarted
                          ? localizedText(context, zh: '继续正式复习', en: 'Continue Formal Review')
                          : localizedText(context, zh: '开始正式复习', en: 'Start Formal Review'),
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
                  zh: '先做一小轮，或者只补最需要再看一遍的地方。',
                  en: 'Run one light pass or focus only on the items that still need another look.',
                ),
                actions: [
                  ReviewQuickActionItem(
                    title: localizedText(context, zh: '5 分钟快复习', en: '5-Minute Review'),
                    subtitle: localizedText(
                      context,
                      zh: '自由练习模式，快速清几个点，不占用正式复习配额。',
                      en: 'Free-practice mode for clearing a few items without consuming the formal review flow.',
                    ),
                    badge: todayPlan.tasks.isEmpty ? null : '${todayPlan.pendingCount}',
                    icon: Icons.bolt_rounded,
                    tintColor: const Color(0xFFFFF1E5),
                    iconColor: const Color(0xFFB56D45),
                    onTap: () => _openSession(
                      () => ReviewService.createQuickSession(context.appSettings),
                    ),
                  ),
                  ReviewQuickActionItem(
                    title: localizedText(context, zh: '薄弱项再练', en: 'Weak Spots'),
                    subtitle: localizedText(
                      context,
                      zh: '把还不稳的内容单独拎出来补一下，适合自由练习。',
                      en: 'Pull your unstable items into a separate free-practice pass.',
                    ),
                    badge: '${dashboard.weakTasks.length}',
                    icon: Icons.track_changes_rounded,
                    tintColor: const Color(0xFFE9F6EF),
                    iconColor: AppTheme.accentMintDark,
                    onTap: () => _openSession(
                      () => ReviewService.createWeakSession(context.appSettings),
                    ),
                  ),
                  ReviewQuickActionItem(
                    title: localizedText(context, zh: '按类型复习', en: 'By Type'),
                    subtitle: localizedText(
                      context,
                      zh: '按对象类型自由挑一组，适合补单点，不替代正式复习。',
                      en: 'Choose one content type for a focused free-practice pass without replacing formal review.',
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
                title: localizedText(context, zh: '需要再看一遍', en: 'Worth Another Look'),
                subtitle: localizedText(
                  context,
                  zh: '这些内容还不够稳，回顾一次会更安心。',
                  en: 'These items are not fully stable yet, so one more pass helps.',
                ),
                tasks: dashboard.weakTasks,
                emptyTitle: localizedText(context, zh: '目前没有特别薄弱的内容', en: 'No obvious weak spots right now'),
                emptySubtitle: localizedText(
                  context,
                  zh: '当你在复习里点“再看一遍”时，这里会自动留下来方便继续补。',
                  en: 'When you choose “review again”, the item will stay here for an easy follow-up.',
                ),
                onTaskTap: _openSingleTask,
              ),
              const SizedBox(height: 18),
              ReviewTaskSection(
                title: localizedText(context, zh: '最近学过，建议回看', en: 'Recently Learned'),
                subtitle: localizedText(
                  context,
                  zh: '查完或学完后能顺着回到这里，少找路，少切换。',
                  en: 'Items you recently learned or checked stay here for a quick return.',
                ),
                tasks: dashboard.recentTasks,
                emptyTitle: localizedText(context, zh: '最近还没有形成回看内容', en: 'No recent review items yet'),
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
        return localizedText(context, zh: '辨音', en: 'Contrast');
      case ReviewContentType.sentence:
        return localizedText(context, zh: '句子', en: 'Sentences');
      case ReviewContentType.grammar:
        return localizedText(context, zh: '语法', en: 'Grammar');
      case ReviewContentType.alphabet:
        return localizedText(context, zh: '字母', en: 'Letters');
    }
  }
}
