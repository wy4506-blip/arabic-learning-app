import 'dart:async';

import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/localized_text.dart';
import '../models/alphabet_group.dart';
import '../models/lesson.dart';
import '../models/review_models.dart';
import '../services/alphabet_service.dart';
import '../services/audio_service.dart';
import '../services/lesson_service.dart';
import '../services/review_service.dart';
import '../services/unlock_service.dart';
import '../theme/app_arabic_typography.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../widgets/arabic_text_with_audio.dart';
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
  bool _playingPromptAudio = false;
  bool _showCompletionState = false;
  bool _completedTodayPlan = false;
  bool _navigatingToLesson = false;
  Timer? _autoContinueTimer;

  bool get _isHomeTodayPlan =>
      widget.session.config.source == ReviewEntrySource.homeTodayPlan;

  bool get _isFormalReview =>
      widget.session.config.mode == ReviewSessionMode.formal;

  bool get _hasNextLesson =>
      widget.session.config.nextLessonId?.trim().isNotEmpty ?? false;

  bool get _canAutoContinue =>
      widget.session.config.autoContinueToLesson && _hasNextLesson;

  bool get _canContinueToNextLesson =>
      !_canAutoContinue && _isFormalReview && _hasNextLesson;

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
    AudioService.stop();
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
    final shouldRecordStandaloneCompletion =
        widget.session.countTowardActivity &&
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

  Future<void> _playPromptAudio(ReviewTask task) async {
    if (_playingPromptAudio) {
      return;
    }
    setState(() => _playingPromptAudio = true);
    try {
      switch (task.actionType) {
        case ReviewActionType.listen:
          await _playListenPrompt(task);
        case ReviewActionType.repeat:
          await _playRepeatPrompt(task);
        case ReviewActionType.read:
          await _playReadPrompt(task);
        case ReviewActionType.recognize:
        case ReviewActionType.distinguish:
          await _playComparePrompt(task);
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizedText(
              context,
              zh: '当前没有可用音频，已跳过播放。',
              en: 'Audio is not available for this item right now.',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _playingPromptAudio = false);
      }
    }
  }

  Future<void> _playListenPrompt(ReviewTask task) async {
    switch (task.type) {
      case ReviewContentType.alphabet:
        await AudioService.playLearningText(
          LearningAudioRequest.alphabet(
            type: 'letter',
            textAr: task.sourceId ?? task.arabicText ?? task.title,
            textPlain: task.arabicText ?? task.title,
            debugLabel: 'review_listen_alphabet',
          ),
        );
        return;
      case ReviewContentType.pronunciation:
        await AudioService.playLearningText(
          LearningAudioRequest.alphabet(
            type: 'pronunciation',
            textAr: task.audioQueryText ??
                task.arabicText ??
                task.transliteration ??
                task.title,
            textPlain: task.arabicText ?? task.title,
            debugLabel: 'review_listen_pronunciation',
          ),
        );
        return;
      case ReviewContentType.word:
      case ReviewContentType.sentence:
      case ReviewContentType.pair:
      case ReviewContentType.grammar:
        await AudioService.playLearningText(
          LearningAudioRequest.general(
            scope: 'review',
            type: task.type == ReviewContentType.word ? 'word' : 'sentence',
            textAr: task.arabicText ??
                task.audioQueryText ??
                task.transliteration ??
                task.title,
            textPlain: task.audioQueryText ?? task.title,
            debugLabel: 'review_listen_text',
          ),
        );
        return;
    }
  }

  Future<void> _playRepeatPrompt(ReviewTask task) async {
    await AudioService.playLearningText(
      LearningAudioRequest.general(
        scope: 'review',
        type: task.type == ReviewContentType.word ? 'word' : 'sentence',
        textAr: task.arabicText ??
            task.audioQueryText ??
            task.transliteration ??
            task.title,
        textPlain: task.audioQueryText ?? task.title,
        debugLabel: 'review_repeat_text',
      ),
    );
  }

  Future<void> _playReadPrompt(ReviewTask task) async {
    if (task.type == ReviewContentType.pronunciation) {
      await AudioService.playLearningText(
        LearningAudioRequest.alphabet(
          type: 'pronunciation',
          textAr: task.audioQueryText ??
              task.arabicText ??
              task.transliteration ??
              task.title,
          textPlain: task.arabicText ?? task.title,
          debugLabel: 'review_read_pronunciation',
        ),
      );
      return;
    }
    await AudioService.playLearningText(
      LearningAudioRequest.general(
        scope: 'review',
        type: task.type == ReviewContentType.word ? 'word' : 'sentence',
        textAr: task.arabicText ??
            task.audioQueryText ??
            task.transliteration ??
            task.title,
        textPlain: task.audioQueryText ?? task.title,
        debugLabel: 'review_read_text',
      ),
    );
  }

  Future<void> _playComparePrompt(ReviewTask task) async {
    if (task.type == ReviewContentType.pair) {
      final pairItems = _pairItems(task);
      await AudioService.playLearningText(
        LearningAudioRequest.general(
          scope: 'review',
          type: 'sentence',
          textAr: pairItems.join(' '),
          textPlain: pairItems.join(' '),
          debugLabel: 'review_compare_pair',
        ),
      );
      return;
    }
    await AudioService.playLearningText(
      LearningAudioRequest.general(
        scope: 'review',
        type: task.type == ReviewContentType.word ? 'word' : 'sentence',
        textAr: task.arabicText ??
            task.audioQueryText ??
            task.transliteration ??
            task.title,
        textPlain: task.audioQueryText ?? task.title,
        debugLabel: 'review_compare_text',
      ),
    );
  }

  Future<void> _openSource(ReviewTask task) async {
    switch (task.type) {
      case ReviewContentType.pronunciation:
      case ReviewContentType.pair:
      case ReviewContentType.grammar:
        final pageId = task.sourceId?.trim();
        if (task.type == ReviewContentType.grammar) {
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
          return;
        }
        final sourceArabic = task.sourceId?.split('|').first.trim();
        if (sourceArabic == null || sourceArabic.isEmpty) {
          return;
        }
        final groups = await AlphabetService.loadAlphabetGroups();
        AlphabetLetter? target;
        for (final group in groups) {
          for (final letter in group.letters) {
            if (letter.arabic == sourceArabic) {
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
            zh: '课前热身',
            en: 'Lesson Warm-Up',
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
            en: 'Review a few key points first, then move into the next lesson.',
          );
    }
    return widget.session.subtitle;
  }

  String _completionTitle(BuildContext context) {
    if (_isHomeTodayPlan && _canAutoContinue) {
      return localizedText(
        context,
        zh: '热身完成，即将进入下一课',
        en: 'Warm-Up Complete, Opening the Next Lesson',
      );
    }
    if (_isFormalReview) {
      return (_isHomeTodayPlan && _completedTodayPlan)
          ? localizedText(
              context,
              zh: '今日复习已完成',
              en: 'Today\'s Review Is Complete',
            )
          : localizedText(
              context,
              zh: '这轮复习已完成',
              en: 'This Review Pass Is Complete',
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
        en: 'You will move into the next lesson in a moment, or you can jump in right away.',
      );
    }
    if (_isHomeTodayPlan && _completedTodayPlan) {
      return localizedText(
        context,
        zh: '今天建议先看的内容已经完成，可以回到课程继续学习。',
        en: 'Today\'s suggested review is done. You can return to lessons now.',
      );
    }
    if (_canContinueToNextLesson) {
      return localizedText(
        context,
        zh: '这轮复习已经完成，现在可以进入下一课。',
        en: 'This review pass is done. You can continue into the next lesson now.',
      );
    }
    if (!_isFormalReview) {
      return localizedText(
        context,
        zh: '这轮练习已经完成，可以继续课程，也可以再挑一组内容。',
        en: 'This practice pass is done. You can return to lessons or pick another set.',
      );
    }
    return localizedText(
      context,
      zh: '这组内容已经回顾完成，可以回到原本的学习路径。',
      en: 'This set has been reviewed. You can return to your learning path now.',
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
    if (_canContinueToNextLesson) {
      return localizedText(
        context,
        zh: '进入下一课',
        en: 'Continue to Next Lesson',
      );
    }
    if (_isFormalReview) {
      return localizedText(
        context,
        zh: '回到学习',
        en: 'Return to Learning',
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
          _showCompletionState
              ? _completionTitle(context)
              : _headerTitle(context),
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
                zh: '第 ${completed + 1} / $total 项',
                en: 'Item ${completed + 1} / $total',
              ),
            ),
            const SizedBox(width: 8),
            Pill(label: _typeLabel(context, task.type)),
            const SizedBox(width: 8),
            Pill(label: _actionLabel(context, task.actionType)),
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
              if (task.arabicText != null &&
                  task.arabicText!.trim().isNotEmpty) ...[
                Center(
                  child: _buildTaskPromptText(context, task),
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
              if (task.helperText != null &&
                  task.helperText!.trim().isNotEmpty) ...[
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
              const SizedBox(height: 16),
              _buildActionGuide(context, task),
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
                  _retryLabel(context, task.actionType),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _submitting ? null : () => _submit(true),
                child: Text(
                  _confirmLabel(context, task.actionType),
                ),
              ),
            ),
          ],
        ),
        if ((task.sourceId?.isNotEmpty ?? false) ||
            (task.lessonId?.isNotEmpty ?? false)) ...[
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

  Widget _buildActionGuide(BuildContext context, ReviewTask task) {
    switch (task.actionType) {
      case ReviewActionType.listen:
        return _ActionGuideCard(
          title: localizedText(
            context,
            zh: '先听，再判断自己是不是真的听出来了',
            en: 'Listen first, then decide whether you truly caught it.',
          ),
          body: localizedText(
            context,
            zh: '先播放一遍音频。你不需要做选择题，只需要确认这个声音现在是否已经稳了。',
            en: 'Play the prompt once. There is no multiple-choice step here. Just decide whether the sound already feels stable.',
          ),
          buttonLabel: localizedText(context, zh: '播放音频', en: 'Play Audio'),
          onPressed: () => _playPromptAudio(task),
          busy: _playingPromptAudio,
        );
      case ReviewActionType.repeat:
        return _ActionGuideCard(
          title: localizedText(
            context,
            zh: '先听一遍，再自己跟读',
            en: 'Listen once, then repeat it aloud yourself.',
          ),
          body: localizedText(
            context,
            zh: '如果你能自然跟出来，就点“会读了”；如果还会卡住，就点“还不稳”。',
            en: 'If you can repeat it naturally, confirm it. If it still feels sticky, mark it for another pass.',
          ),
          buttonLabel:
              localizedText(context, zh: '播放示范', en: 'Play Model Audio'),
          onPressed: () => _playPromptAudio(task),
          busy: _playingPromptAudio,
        );
      case ReviewActionType.read:
        return _ActionGuideCard(
          title: localizedText(
            context,
            zh: '先看，再完整读一遍',
            en: 'Look first, then read it through once.',
          ),
          body: localizedText(
            context,
            zh: '重点不是速度，而是读得顺。需要时可以先听一遍参考音。',
            en: 'Speed is not the goal. Smooth reading is. Play the reference audio first if you need it.',
          ),
          buttonLabel:
              localizedText(context, zh: '播放参考音', en: 'Play Reference Audio'),
          onPressed: () => _playPromptAudio(task),
          busy: _playingPromptAudio,
        );
      case ReviewActionType.distinguish:
        final pairItems = _pairItems(task);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ActionGuideCard(
              title: localizedText(
                context,
                zh: '把这两个点分清就够了',
                en: 'You only need to separate these two clearly.',
              ),
              body: localizedText(
                context,
                zh: '先看差异，再读一遍或听一遍。确认自己不会再把它们混在一起。',
                en: 'Look at the contrast first, then read or listen once. Confirm that you no longer mix them up.',
              ),
              buttonLabel: localizedText(context,
                  zh: '播放对比音', en: 'Play Contrast Audio'),
              onPressed: () => _playPromptAudio(task),
              busy: _playingPromptAudio,
            ),
            if (pairItems.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final item in pairItems.take(2)) ...[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.bgCardSoft,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: ArabicText.word(
                            item,
                            style: const TextStyle(
                              fontSize: 28,
                              height: 1.4,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (item != pairItems.take(2).last)
                      const SizedBox(width: 10),
                  ],
                ],
              ),
            ],
          ],
        );
      case ReviewActionType.recognize:
        return _ActionGuideCard(
          title: localizedText(
            context,
            zh: '先看一眼，再确认能不能马上认出来',
            en: 'Take one look and check whether you can recognize it immediately.',
          ),
          body: localizedText(
            context,
            zh: '如果你还需要停下来想一会儿，就把它留在下一轮。',
            en: 'If you still need to pause and think, leave it for another pass.',
          ),
        );
    }
  }

  Widget _buildTaskPromptText(BuildContext context, ReviewTask task) {
    final usesGuideAudio = switch (task.actionType) {
      ReviewActionType.listen => true,
      ReviewActionType.repeat => true,
      ReviewActionType.read => true,
      ReviewActionType.distinguish => true,
      ReviewActionType.recognize => false,
    };

    const promptStyle = TextStyle(
      fontSize: 38,
      height: 1.55,
      fontWeight: FontWeight.w600,
    );

    if (usesGuideAudio) {
      return ArabicText.sentence(
        task.arabicText!,
        style: promptStyle,
        textAlign: TextAlign.center,
      );
    }

    return ArabicTextWithAudio(
      textAr: task.arabicText!,
      request: LearningAudioRequest.general(
        scope: 'review',
        type: task.type == ReviewContentType.word ? 'word' : 'sentence',
        textAr: task.arabicText!,
        textPlain: task.audioQueryText ?? task.arabicText!,
        debugLabel: 'review_task_prompt',
      ),
      variant: ArabicAudioTextVariant.sentence,
      style: promptStyle,
      textAlign: TextAlign.center,
    );
  }

  List<String> _pairItems(ReviewTask task) {
    if ((task.sourceId?.contains('|') ?? false)) {
      return task.sourceId!
          .split('|')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
    }
    if ((task.arabicText?.trim().isNotEmpty ?? false)) {
      return task.arabicText!
          .split(RegExp(r'\s+'))
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
    }
    return const <String>[];
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
                      zh: _navigatingToLesson
                          ? '正在打开下一课…'
                          : '如果不想等待，可以现在直接进入下一课。',
                      en: _navigatingToLesson
                          ? 'Opening the next lesson now...'
                          : 'If you do not want to wait, you can enter the lesson right away.',
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 18),
              ],
              if (_canContinueToNextLesson &&
                  (widget.session.config.nextLessonLabel?.trim().isNotEmpty ??
                      false)) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCardSoft,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizedText(
                          context,
                          zh: '下一步',
                          en: 'Next Step',
                        ),
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.session.config.nextLessonLabel!,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
              ],
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _navigatingToLesson
                      ? null
                      : (_canAutoContinue || _canContinueToNextLesson)
                          ? _openNextLesson
                          : _returnToPrevious,
                  child: Text(_primaryCompletionActionLabel(context)),
                ),
              ),
              if (_isHomeTodayPlan || _canContinueToNextLesson) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: _navigatingToLesson ? null : _returnToPrevious,
                    child: Text(
                      _isHomeTodayPlan
                          ? _secondaryCompletionActionLabel(context)
                          : localizedText(
                              context,
                              zh: '留在当前课程',
                              en: 'Stay on Current Lesson',
                            ),
                    ),
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
    final showSkipAction = widget.session.config.allowSkip &&
        !_showCompletionState &&
        _hasNextLesson;

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
      case ReviewContentType.pronunciation:
        return localizedText(context, zh: '发音', en: 'Pronunciation');
      case ReviewContentType.pair:
        return localizedText(context, zh: '辨音', en: 'Sound Contrast');
      case ReviewContentType.sentence:
        return localizedText(context, zh: '句子', en: 'Sentence');
      case ReviewContentType.grammar:
        return localizedText(context, zh: '语法', en: 'Grammar');
      case ReviewContentType.alphabet:
        return localizedText(context, zh: '字母', en: 'Letter');
    }
  }

  String _actionLabel(BuildContext context, ReviewActionType actionType) {
    switch (actionType) {
      case ReviewActionType.recognize:
        return localizedText(context, zh: '认一认', en: 'Recognize');
      case ReviewActionType.listen:
        return localizedText(context, zh: '听一听', en: 'Listen');
      case ReviewActionType.read:
        return localizedText(context, zh: '读一读', en: 'Read');
      case ReviewActionType.distinguish:
        return localizedText(context, zh: '辨一辨', en: 'Distinguish');
      case ReviewActionType.repeat:
        return localizedText(context, zh: '跟读', en: 'Repeat');
    }
  }

  String _retryLabel(BuildContext context, ReviewActionType actionType) {
    switch (actionType) {
      case ReviewActionType.recognize:
      case ReviewActionType.listen:
      case ReviewActionType.read:
      case ReviewActionType.distinguish:
      case ReviewActionType.repeat:
        return localizedText(context, zh: '还不稳', en: 'Needs Another Pass');
    }
  }

  String _confirmLabel(BuildContext context, ReviewActionType actionType) {
    switch (actionType) {
      case ReviewActionType.recognize:
        return localizedText(context, zh: '认出来了', en: 'I Recognized It');
      case ReviewActionType.listen:
        return localizedText(context, zh: '听出来了', en: 'I Heard It');
      case ReviewActionType.read:
        return localizedText(context, zh: '读顺了', en: 'I Read It');
      case ReviewActionType.distinguish:
        return localizedText(context, zh: '分清了', en: 'I Can Tell Them Apart');
      case ReviewActionType.repeat:
        return localizedText(context, zh: '会读了', en: 'I Can Say It');
    }
  }
}

class _ActionGuideCard extends StatelessWidget {
  final String title;
  final String body;
  final String? buttonLabel;
  final VoidCallback? onPressed;
  final bool busy;

  const _ActionGuideCard({
    required this.title,
    required this.body,
    this.buttonLabel,
    this.onPressed,
    this.busy = false,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (buttonLabel != null && onPressed != null) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: busy ? null : onPressed,
              icon: busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.volume_up_rounded),
              label: Text(buttonLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
