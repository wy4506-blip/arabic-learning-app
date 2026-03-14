import 'dart:async';

import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/localized_text.dart';
import '../models/alphabet_group.dart';
import '../models/lesson.dart';
import '../models/review_models.dart';
import '../services/alphabet_service.dart';
import '../services/lesson_service.dart';
import '../services/review_service.dart';
import '../services/unlock_service.dart';
import '../theme/app_arabic_typography.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'alphabet_letter_home_page.dart';
import 'grammar_detail_page.dart';
import 'lesson_detail_page.dart';

class ReviewSessionPage extends StatefulWidget {
  final ReviewSession session;

  const ReviewSessionPage({
    super.key,
    required this.session,
  });

  @override
  State<ReviewSessionPage> createState() => _ReviewSessionPageState();
}

class _ReviewSessionPageState extends State<ReviewSessionPage> {
  late final Set<String> _completedTaskIds;
  bool _submitting = false;
  bool _showCompletionState = false;
  bool _completedTodayPlan = false;
  bool _navigatingToLesson = false;
  Timer? _autoContinueTimer;

  bool get _isHomeTodayPlan =>
      widget.session.config.source == ReviewEntrySource.homeTodayPlan;

  bool get _hasNextLesson =>
      widget.session.config.nextLessonId?.trim().isNotEmpty ?? false;

  bool get _canAutoContinue =>
      widget.session.config.autoContinueToLesson && _hasNextLesson;

  List<ReviewTask> get _pendingTasks => widget.session.tasks
      .where((task) => !_completedTaskIds.contains(task.contentId))
      .toList(growable: false);

  ReviewTask? get _currentTask {
    final pendingTasks = _pendingTasks;
    if (pendingTasks.isEmpty) {
      return null;
    }
    return pendingTasks.first;
  }

  @override
  void initState() {
    super.initState();
    _completedTaskIds = widget.session.completedTaskIds.toSet();
    _showCompletionState =
        widget.session.tasks.isNotEmpty && _pendingTasks.isEmpty;
    if (_showCompletionState) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scheduleAutoContinueIfNeeded();
      });
    }
  }

  @override
  void dispose() {
    _autoContinueTimer?.cancel();
    super.dispose();
  }

  Future<void> _submit(bool remembered) async {
    final task = _currentTask;
    if (task == null || _submitting) {
      return;
    }

    setState(() => _submitting = true);
    final completedTodayPlan = await ReviewService.recordTaskResult(
      task,
      remembered: remembered,
      syncWithTodayPlan: widget.session.syncWithTodayPlan,
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _completedTaskIds.add(task.contentId);
      _submitting = false;
    });

    if (_pendingTasks.isEmpty) {
      await _completeSession(completedTodayPlan: completedTodayPlan);
    }
  }

  Future<void> _completeSession({
    required bool completedTodayPlan,
  }) async {
    final shouldRecordStandaloneCompletion = widget.session.countTowardActivity &&
        (!widget.session.syncWithTodayPlan || !completedTodayPlan);
    if (shouldRecordStandaloneCompletion) {
      await ReviewService.finishSession(widget.session);
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _showCompletionState = true;
      _completedTodayPlan = completedTodayPlan;
    });
    _scheduleAutoContinueIfNeeded();
  }

  void _scheduleAutoContinueIfNeeded() {
    _autoContinueTimer?.cancel();
    if (!_showCompletionState || !_canAutoContinue || _navigatingToLesson) {
      return;
    }
    _autoContinueTimer = Timer(
      const Duration(milliseconds: 1200),
      () {
        if (!mounted || _navigatingToLesson) {
          return;
        }
        _openNextLesson();
      },
    );
  }

  Future<void> _openNextLesson() async {
    if (_navigatingToLesson || !_hasNextLesson) {
      return;
    }

    _autoContinueTimer?.cancel();
    setState(() => _navigatingToLesson = true);

    final lessons = await LessonService().loadLessons();
    Lesson? lesson;
    for (final item in lessons) {
      if (item.id == widget.session.config.nextLessonId) {
        lesson = item;
        break;
      }
    }
    if (!mounted) {
      return;
    }
    if (lesson == null) {
      Navigator.of(context).pop(true);
      return;
    }

    final unlocked = await UnlockService.isUnlocked();
    if (!mounted) {
      return;
    }

    await Navigator.of(context).pushReplacement<bool, bool>(
      MaterialPageRoute(
        builder: (_) => LessonDetailPage(
          lesson: lesson!,
          settings: context.appSettings,
          isUnlocked: unlocked,
        ),
      ),
      result: true,
    );
  }

  Future<void> _skipToLesson() async {
    await _openNextLesson();
  }

  void _returnToPrevious() {
    _autoContinueTimer?.cancel();
    Navigator.of(context).pop(true);
  }

  Future<void> _openSource(ReviewTask task) async {
    switch (task.type) {
      case ReviewContentType.grammar:
        final pageId = task.sourceId?.trim();
        if (pageId == null || pageId.isEmpty) {
          return;
        }
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GrammarDetailPage(
              pageId: pageId,
              settings: context.appSettings,
            ),
          ),
        );
        break;
      case ReviewContentType.word:
      case ReviewContentType.sentence:
        final lessonId = task.lessonId?.trim();
        if (lessonId == null || lessonId.isEmpty) {
          return;
        }
        final lessons = await LessonService().loadLessons();
        Lesson? lesson;
        for (final item in lessons) {
          if (item.id == lessonId) {
            lesson = item;
            break;
          }
        }
        if (!mounted || lesson == null) {
          return;
        }
        final unlocked = await UnlockService.isUnlocked();
        if (!mounted) {
          return;
        }
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LessonDetailPage(
              lesson: lesson!,
              settings: context.appSettings,
              isUnlocked: unlocked,
            ),
          ),
        );
        break;
      case ReviewContentType.alphabet:
        final sourceId = task.sourceId?.trim();
        if (sourceId == null || sourceId.isEmpty) {
          return;
        }
        final groups = await AlphabetService.loadAlphabetGroups();
        AlphabetLetter? target;
        for (final group in groups) {
          for (final letter in group.letters) {
            if (letter.arabic == sourceId) {
              target = letter;
              break;
            }
          }
          if (target != null) {
            break;
          }
        }
        if (!mounted || target == null) {
          return;
        }
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AlphabetLetterHomePage(letter: target!),
          ),
        );
        break;
    }
  }

  String _appBarTitle(BuildContext context) {
    if (_isHomeTodayPlan) {
      return localizedText(
        context,
        zh: '今日学习',
        en: 'Today\'s Learning',
      );
    }
    return widget.session.title;
  }

  String _headerTitle(BuildContext context) {
    if (_isHomeTodayPlan) {
      return widget.session.config.headerTitle ??
          localizedText(
            context,
            zh: '热身复习',
            en: 'Quick Warm-Up',
          );
    }
    return widget.session.title;
  }

  String _headerSubtitle(BuildContext context) {
    if (_isHomeTodayPlan) {
      return widget.session.config.headerSubtitle ??
          localizedText(
            context,
            zh: '先快速回顾，再进入下一课。',
            en: 'Review quickly first, then move into the next lesson.',
          );
    }
    return widget.session.subtitle;
  }

  String _completionTitle(BuildContext context) {
    if (_isHomeTodayPlan && _canAutoContinue) {
      return localizedText(
        context,
        zh: '热身完成，即将进入下一课',
        en: 'Warm-Up Done, Opening the Next Lesson',
      );
    }
    return _completedTodayPlan
        ? localizedText(
            context,
            zh: '今日复习已完成',
            en: 'Today\'s Review Is Complete',
          )
        : localizedText(
            context,
            zh: '本轮复习已完成',
            en: 'This Review Pass Is Complete',
          );
  }

  String _completionSubtitle(BuildContext context) {
    if (_isHomeTodayPlan && _canAutoContinue) {
      return localizedText(
        context,
        zh: '页面会短暂停留后自动跳转，你也可以现在直接进入。',
        en:
            'You will move into the next lesson in a moment, or you can jump in right away.',
      );
    }
    if (_completedTodayPlan) {
      return localizedText(
        context,
        zh: '今天建议先看的内容已经完成，可以回到课程继续学习。',
        en:
            'The suggested review for today is done. You can head back into learning with a clearer head.',
      );
    }
    return localizedText(
      context,
      zh: '这组内容已经回顾完成，可以先回到原本的学习路径。',
      en:
          'This set has been reviewed once more. You can return to your normal learning path now.',
    );
  }

  String _primaryCompletionActionLabel(BuildContext context) {
    if (_isHomeTodayPlan && _canAutoContinue) {
      return localizedText(
        context,
        zh: '立即进入',
        en: 'Enter Now',
      );
    }
    return localizedText(
      context,
      zh: '返回',
      en: 'Back',
    );
  }

  String _secondaryCompletionActionLabel(BuildContext context) {
    return localizedText(
      context,
      zh: '返回首页',
      en: 'Back Home',
    );
  }

  Widget _buildFlowHeader(BuildContext context) {
    final stepLabel = localizedText(
      context,
      zh: _showCompletionState ? '今日学习 · 第 2 步 / 2' : '今日学习 · 第 1 步 / 2',
      en: _showCompletionState
          ? 'Today\'s Learning · Step 2 / 2'
          : 'Today\'s Learning · Step 1 / 2',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Pill(
          label: stepLabel,
          backgroundColor: AppTheme.softAccent,
          foregroundColor: AppTheme.accentMintDark,
        ),
        const SizedBox(height: 14),
        Text(
          _showCompletionState ? _completionTitle(context) : _headerTitle(context),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          _showCompletionState
              ? _completionSubtitle(context)
              : _headerSubtitle(context),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildTaskView(BuildContext context, ReviewTask task) {
    final total = widget.session.tasks.length;
    final completed = _completedTaskIds.length.clamp(0, total);

    return ListView(
      padding: AppTheme.pagePadding,
      children: [
        if (_isHomeTodayPlan)
          _buildFlowHeader(context)
        else
          SectionTitle(
            title: widget.session.title,
            subtitle: widget.session.subtitle,
          ),
        const SizedBox(height: 14),
        Row(
          children: [
            Pill(
              label: localizedText(
                context,
                zh: '第 ${completed + 1} / $total 题',
                en: 'Item ${completed + 1} / $total',
              ),
            ),
            const SizedBox(width: 8),
            Pill(label: _typeLabel(context, task.type)),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: total == 0 ? 0 : completed / total,
            minHeight: 8,
            backgroundColor: AppTheme.bgCardSoft,
            color: AppTheme.accentMintDark,
          ),
        ),
        const SizedBox(height: 18),
        AppSurface(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.arabicText != null && task.arabicText!.trim().isNotEmpty) ...[
                Center(
                  child: ArabicText.sentence(
                    task.arabicText!,
                    style: const TextStyle(
                      fontSize: 38,
                      height: 1.55,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                task.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (task.transliteration != null &&
                  task.transliteration!.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  task.transliteration!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              if (task.subtitle.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  task.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              if (task.helperText != null && task.helperText!.trim().isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCardSoft,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    task.helperText!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _submitting ? null : () => _submit(false),
                child: Text(
                  localizedText(
                    context,
                    zh: '再看一遍',
                    en: 'Review Again',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _submitting ? null : () => _submit(true),
                child: Text(
                  localizedText(
                    context,
                    zh: '记住了',
                    en: 'Got It',
                  ),
                ),
              ),
            ),
          ],
        ),
        if ((task.sourceId?.isNotEmpty ?? false) || (task.lessonId?.isNotEmpty ?? false)) ...[
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: _submitting ? null : () => _openSource(task),
              child: Text(
                localizedText(
                  context,
                  zh: '打开相关内容',
                  en: 'Open Source Content',
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCompletionView(BuildContext context) {
    final showFlowHeader = _isHomeTodayPlan;

    return ListView(
      padding: AppTheme.pagePadding,
      children: [
        if (showFlowHeader)
          _buildFlowHeader(context)
        else
          SectionTitle(
            title: _completionTitle(context),
            subtitle: _completionSubtitle(context),
          ),
        const SizedBox(height: 18),
        AppSurface(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.softAccent,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: _navigatingToLesson
                      ? const Padding(
                          padding: EdgeInsets.all(18),
                          child: CircularProgressIndicator(strokeWidth: 2.8),
                        )
                      : const Icon(
                          Icons.check_rounded,
                          color: AppTheme.accentMintDark,
                          size: 34,
                        ),
                ),
              ),
              const SizedBox(height: 16),
              if (_canAutoContinue) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCardSoft,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    localizedText(
                      context,
                      zh: _navigatingToLesson ? '正在打开下一课…' : '如果不想等待，可以现在直接进入下一课。',
                      en: _navigatingToLesson
                          ? 'Opening the next lesson now...'
                          : 'If you do not want to wait, you can enter the lesson right away.',
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 18),
              ],
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _navigatingToLesson
                      ? null
                      : _canAutoContinue
                          ? _openNextLesson
                          : _returnToPrevious,
                  child: Text(_primaryCompletionActionLabel(context)),
                ),
              ),
              if (_isHomeTodayPlan) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: _navigatingToLesson ? null : _returnToPrevious,
                    child: Text(_secondaryCompletionActionLabel(context)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final task = _currentTask;
    final showSkipAction =
        widget.session.config.allowSkip && !_showCompletionState && _hasNextLesson;

    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle(context)),
        actions: [
          if (showSkipAction)
            TextButton(
              onPressed: _navigatingToLesson ? null : _skipToLesson,
              child: Text(
                localizedText(
                  context,
                  zh: '跳过复习',
                  en: 'Skip Review',
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: _showCompletionState || task == null
            ? _buildCompletionView(context)
            : _buildTaskView(context, task),
      ),
    );
  }

  String _typeLabel(BuildContext context, ReviewContentType type) {
    switch (type) {
      case ReviewContentType.word:
        return localizedText(context, zh: '单词', en: 'Word');
      case ReviewContentType.sentence:
        return localizedText(context, zh: '句子', en: 'Sentence');
      case ReviewContentType.grammar:
        return localizedText(context, zh: '语法', en: 'Grammar');
      case ReviewContentType.alphabet:
        return localizedText(context, zh: '字母', en: 'Letter');
    }
  }
}
