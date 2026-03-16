import 'package:flutter/material.dart';

import '../data/v2_micro_lessons.dart';
import '../l10n/localized_text.dart';
import '../l10n/v2_micro_lesson_localizer.dart';
import '../models/app_settings.dart';
import '../models/v2_micro_lesson.dart';
import '../services/audio_service.dart';
import '../services/v2_micro_lesson_completion_orchestrator.dart';
import '../widgets/arabic_text_with_audio.dart';
import 'v2_micro_lesson_completion_page.dart';

class V2MicroLessonPage extends StatefulWidget {
  final String lessonId;
  final AppSettings settings;

  const V2MicroLessonPage({
    super.key,
    required this.lessonId,
    required this.settings,
  });

  @override
  State<V2MicroLessonPage> createState() => _V2MicroLessonPageState();
}

class _V2MicroLessonPageState extends State<V2MicroLessonPage> {
  late final V2MicroLesson _lesson;
  final Map<String, V2MicroPracticeOutcome> _outcomes =
      <String, V2MicroPracticeOutcome>{};
  int _currentPracticeIndex = 0;
  bool _submitting = false;
  String? _selectedChoice;
  bool? _autoPracticePassed;

  @override
  void initState() {
    super.initState();
    _lesson = v2PilotMicroLessons.firstWhere(
      (lesson) => lesson.lessonId == widget.lessonId,
    );
  }

  V2MicroPracticeItem get _currentPractice =>
      _lesson.practiceItems[_currentPracticeIndex];

  V2MicroContentItem? get _goalContent {
    for (final item in _lesson.contentItems) {
      if (item.kind == V2MicroContentKind.goal) {
        return item;
      }
    }
    return null;
  }

  List<V2MicroContentItem> get _supportedContentItems => _lesson.contentItems
      .where(
        (item) =>
            item.kind != V2MicroContentKind.goal &&
            <V2MicroContentKind>{
              V2MicroContentKind.input,
              V2MicroContentKind.modeling,
              V2MicroContentKind.explanation,
              V2MicroContentKind.contrast,
            }.contains(item.kind),
      )
      .toList(growable: false);

  bool get _isCurrentPracticeAutoGraded =>
      _currentPractice.type == V2MicroPracticeType.listenTap ||
      _currentPractice.type == V2MicroPracticeType.comprehensionCheck;

  String get _continueLabel => localizedText(
        context,
        zh: '继续',
        en: 'Continue',
      );

  String get _retryLabel => localizedText(
        context,
        zh: '再试一次',
        en: 'Try Again',
      );

  String get _continueWithReviewLabel => localizedText(
        context,
        zh: '标记回看并继续',
        en: 'Continue With Review',
      );

  Future<void> _recordOutcome(
    bool passed, {
    double? score,
  }) async {
    if (_submitting) {
      return;
    }

    final current = _currentPractice;
    _outcomes[current.itemId] = V2MicroPracticeOutcome(
      itemId: current.itemId,
      passed: passed,
      score: score ?? (passed ? 1.0 : 0.0),
    );

    if (_currentPracticeIndex < _lesson.practiceItems.length - 1) {
      setState(() {
        _currentPracticeIndex += 1;
        _selectedChoice = null;
        _autoPracticePassed = null;
      });
      return;
    }

    setState(() => _submitting = true);
    final result = await V2MicroLessonCompletionOrchestrator.completeLesson(
      lessonId: _lesson.lessonId,
      practiceOutcomes: _lesson.practiceItems
          .map((item) => _outcomes[item.itemId]!)
          .toList(growable: false),
    );
    if (!mounted) {
      return;
    }
    await Navigator.pushReplacement<bool, bool>(
      context,
      MaterialPageRoute(
        builder: (_) => V2MicroLessonCompletionPage(
          settings: widget.settings,
          result: result,
        ),
      ),
    );
  }

  void _evaluateAutoPractice(String choice) {
    final normalizedChoice = choice.trim();
    final normalizedAnswer = (_currentPractice.arabicText ?? '').trim();
    setState(() {
      _selectedChoice = normalizedChoice;
      _autoPracticePassed =
          normalizedChoice.isNotEmpty && normalizedChoice == normalizedAnswer;
    });
  }

  void _resetAutoAttempt() {
    setState(() {
      _selectedChoice = null;
      _autoPracticePassed = null;
    });
  }

  List<String> _buildChoiceOptions(V2MicroPracticeItem practice) {
    final options = <String>[];
    final seen = <String>{};

    void addOption(String? value) {
      final normalized = value?.trim() ?? '';
      if (normalized.isEmpty || !seen.add(normalized)) {
        return;
      }
      options.add(normalized);
    }

    void addSplitOptions(String? value) {
      final normalized = value?.trim() ?? '';
      if (normalized.isEmpty) {
        return;
      }
      final segments = normalized
          .split(RegExp(r'\s*/\s*'))
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty);
      for (final segment in segments) {
        addOption(segment);
      }
    }

    for (final item in _lesson.practiceItems) {
      addOption(item.arabicText);
    }

    for (final item in _lesson.contentItems) {
      addSplitOptions(item.arabicText);
    }

    addOption(practice.arabicText);
    return options;
  }

  LearningAudioRequest _buildAudioRequest({
    required String textAr,
    required String debugLabel,
  }) {
    return LearningAudioRequest.general(
      scope: 'v2_micro_lesson',
      type: 'sentence',
      textAr: textAr,
      debugLabel: debugLabel,
    );
  }

  String _practiceMeaning(V2MicroPracticeItem practice) {
    return V2MicroLessonLocalizer.practiceMeaning(
          practice.itemId,
          widget.settings.meaningLanguage,
          fallback: practice.meaning,
        ) ??
        '';
  }

  String _contentMeaning(V2MicroContentItem item) {
    return V2MicroLessonLocalizer.practiceMeaning(
          item.itemId,
          widget.settings.meaningLanguage,
          fallback: item.meaning,
        ) ??
        '';
  }

  String _contentTitle(V2MicroContentItem item) {
    if (widget.settings.appLanguage != AppLanguage.en) {
      return item.title;
    }

    switch (item.kind) {
      case V2MicroContentKind.input:
        return 'Listen First';
      case V2MicroContentKind.modeling:
        return 'Use This Pattern';
      case V2MicroContentKind.explanation:
        return 'Quick Cue';
      case V2MicroContentKind.contrast:
        return 'Watch The Contrast';
      case V2MicroContentKind.goal:
        return 'Lesson Goal';
      case V2MicroContentKind.recall:
        return 'Recall';
      case V2MicroContentKind.feedback:
        return 'Completion Cue';
    }
  }

  String _contentBody(V2MicroContentItem item) {
    if (widget.settings.appLanguage != AppLanguage.en) {
      return item.body;
    }

    switch (item.kind) {
      case V2MicroContentKind.input:
        return 'Hear the core line first before you try to react to it.';
      case V2MicroContentKind.modeling:
        return 'Keep the whole pattern together first instead of breaking it apart.';
      case V2MicroContentKind.explanation:
        return 'Focus only on the one cue that matters for this step.';
      case V2MicroContentKind.contrast:
        return 'Look at the contrast that separates nearby sounds or forms.';
      case V2MicroContentKind.goal:
        return 'Stay with the one reaction this lesson is trying to make automatic.';
      case V2MicroContentKind.recall:
        return 'Pull the meaning back up before you move on.';
      case V2MicroContentKind.feedback:
        return 'Aim to react right away when this pattern shows up again.';
    }
  }

  String _goalBodyText() {
    final goalBody = _goalContent?.body.trim() ?? '';
    if (widget.settings.appLanguage != AppLanguage.en) {
      return goalBody;
    }
    return 'Stay with one usable response, then move straight into practice.';
  }

  String _autoFeedbackTitle(bool passed) {
    return passed
        ? localizedText(
            context,
            zh: '判断正确',
            en: 'Correct',
          )
        : localizedText(
            context,
            zh: '这题先回看',
            en: 'Mark This For Review',
          );
  }

  String _autoFeedbackBody(V2MicroPracticeItem practice, bool passed) {
    final answer = practice.arabicText?.trim() ?? '';
    final meaning = _practiceMeaning(practice);

    if (passed) {
      if (meaning.isNotEmpty) {
        return localizedText(
          context,
          zh: '你选中了正确句子：$answer。它对应的是“$meaning”。',
          en: 'You picked the correct line: $answer. It means "$meaning".',
        );
      }
      return localizedText(
        context,
        zh: '你选中了正确句子：$answer。继续下一步。',
        en: 'You picked the correct line: $answer. Continue to the next step.',
      );
    }

    if (meaning.isNotEmpty) {
      return localizedText(
        context,
        zh: '正确句子是 $answer，对应“$meaning”。这一题会记入回看。',
        en: 'The correct line is $answer, which means "$meaning". This item will be marked for review.',
      );
    }
    return localizedText(
      context,
      zh: '正确句子是 $answer。这一题会记入回看。',
      en: 'The correct line is $answer. This item will be marked for review.',
    );
  }

  Widget _buildLessonBrief(BuildContext context, ThemeData theme) {
    final lessonTitle = V2MicroLessonLocalizer.lessonTitle(
      _lesson,
      widget.settings.appLanguage,
    );
    final lessonOutcome = V2MicroLessonLocalizer.outcomeSummary(
      _lesson,
      widget.settings.appLanguage,
    );
    final goalBody = _goalBodyText();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F1E8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizedText(
              context,
              zh: '本课目标',
              en: 'Lesson Goal',
            ),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            lessonOutcome,
            style: theme.textTheme.titleLarge,
          ),
          if (goalBody.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(goalBody, style: theme.textTheme.bodyMedium),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                label: Text(
                  localizedText(
                    context,
                    zh: '${_lesson.estimatedMinutes} 分钟样板课',
                    en: '${_lesson.estimatedMinutes}-minute pilot lesson',
                  ),
                ),
              ),
              Chip(label: Text(lessonTitle)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentItemCard(
    BuildContext context,
    ThemeData theme,
    V2MicroContentItem item,
  ) {
    final meaning = _contentMeaning(item);
    final supportsAudio =
        item.kind == V2MicroContentKind.input ||
        item.kind == V2MicroContentKind.modeling;
    final arabicText = item.arabicText?.trim() ?? '';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4DED2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_contentTitle(item), style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(_contentBody(item), style: theme.textTheme.bodyMedium),
          if (arabicText.isNotEmpty) ...[
            const SizedBox(height: 12),
            if (supportsAudio)
              ArabicTextWithAudio(
                textAr: arabicText,
                variant: ArabicAudioTextVariant.sentence,
                request: _buildAudioRequest(
                  textAr: (item.audioQueryText ?? arabicText).trim(),
                  debugLabel: item.itemId,
                ),
              )
            else
              Text(
                arabicText,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.right,
              ),
          ],
          if (meaning.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(meaning, style: theme.textTheme.bodyMedium),
          ],
          if (widget.settings.showTransliteration &&
              (item.transliteration?.trim().isNotEmpty ?? false)) ...[
            const SizedBox(height: 6),
            Text(item.transliteration!, style: theme.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }

  Widget _buildPracticeHeader(BuildContext context, ThemeData theme) {
    final progress = (_currentPracticeIndex + 1) / _lesson.practiceItems.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizedText(
            context,
            zh: '开始练这一小步',
            en: 'Practice This Step',
          ),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: progress, minHeight: 8),
        const SizedBox(height: 8),
        Text(
          localizedText(
            context,
            zh:
                '第 ${_currentPracticeIndex + 1} / ${_lesson.practiceItems.length} 步',
            en:
                'Step ${_currentPracticeIndex + 1} of ${_lesson.practiceItems.length}',
          ),
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildPracticeCard(BuildContext context, ThemeData theme) {
    final practice = _currentPractice;
    final practicePrompt = V2MicroLessonLocalizer.practicePrompt(
      practice.itemId,
      widget.settings.appLanguage,
      fallback: practice.prompt,
    );
    final practiceMeaning = _practiceMeaning(practice);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8DFCF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(practicePrompt, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 14),
          if (_isCurrentPracticeAutoGraded)
            _buildAutoPracticeSection(context, theme, practice, practiceMeaning)
          else
            _buildGuidedPracticeSection(context, theme, practice, practiceMeaning),
        ],
      ),
    );
  }

  Widget _buildAutoPracticeSection(
    BuildContext context,
    ThemeData theme,
    V2MicroPracticeItem practice,
    String practiceMeaning,
  ) {
    final choiceOptions = _buildChoiceOptions(practice);
    final bool showAudioButton = practice.type == V2MicroPracticeType.listenTap;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showAudioButton) ...[
          Row(
            children: [
              Text(
                localizedText(
                  context,
                  zh: '先听，再选',
                  en: 'Listen first, then choose',
                ),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(width: 10),
              LearningAudioIconButton(
                request: _buildAudioRequest(
                  textAr: (practice.arabicText ?? '').trim(),
                  debugLabel: practice.itemId,
                ),
                tooltip: localizedText(
                  context,
                  zh: '播放这一题音频',
                  en: 'Play this prompt audio',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
        ],
        ...choiceOptions.map(
          (option) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _autoPracticePassed == null
                    ? () => _evaluateAutoPractice(option)
                    : null,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  alignment: Alignment.centerLeft,
                  side: BorderSide(
                    color: option == _selectedChoice
                        ? const Color(0xFF0D6B4D)
                        : const Color(0xFFD6CCB9),
                    width: option == _selectedChoice ? 2 : 1,
                  ),
                ),
                child: Text(
                  option,
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.right,
                ),
              ),
            ),
          ),
        ),
        if (_autoPracticePassed != null) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _autoPracticePassed!
                  ? const Color(0xFFEAF7EF)
                  : const Color(0xFFFDF0E7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _autoFeedbackTitle(_autoPracticePassed!),
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  _autoFeedbackBody(practice, _autoPracticePassed!),
                  style: theme.textTheme.bodyMedium,
                ),
                if (practiceMeaning.isNotEmpty &&
                    !_autoPracticePassed! &&
                    practice.type == V2MicroPracticeType.listenTap) ...[
                  const SizedBox(height: 6),
                  Text(
                    localizedText(
                      context,
                      zh: '回到上方再听一次会更稳。',
                      en: 'One more listen above will make this more stable.',
                    ),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (_autoPracticePassed!)
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => _recordOutcome(true),
                child: Text(_continueLabel),
              ),
            )
          else ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => _recordOutcome(false),
                child: Text(_continueWithReviewLabel),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _resetAutoAttempt,
                child: Text(_retryLabel),
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildGuidedPracticeSection(
    BuildContext context,
    ThemeData theme,
    V2MicroPracticeItem practice,
    String practiceMeaning,
  ) {
    final arabicText = practice.arabicText?.trim() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (arabicText.isNotEmpty) ...[
          Text(
            arabicText,
            style: theme.textTheme.displaySmall,
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 12),
        ],
        if (practiceMeaning.isNotEmpty) ...[
          Text(practiceMeaning, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 8),
        ],
        if (widget.settings.showTransliteration &&
            (practice.transliteration?.trim().isNotEmpty ?? false)) ...[
          Text(practice.transliteration!, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
        ],
        Text(
          localizedText(
            context,
            zh: '这一题先保留轻量自评：做到了就继续，不稳就记入回看。',
            en: 'This step stays as lightweight self-check for now: continue if stable, or mark it for review if not.',
          ),
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => _recordOutcome(true),
            child: Text(
              localizedText(
                context,
                zh: '我做到了',
                en: 'I Got It',
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _recordOutcome(false),
            child: Text(
              localizedText(
                context,
                zh: '这里还不稳',
                en: 'Need Review',
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lessonTitle = V2MicroLessonLocalizer.lessonTitle(
      _lesson,
      widget.settings.appLanguage,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EC),
      appBar: AppBar(
        title: Text(lessonTitle),
      ),
      body: SafeArea(
        child: _submitting
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLessonBrief(context, theme),
                    if (_supportedContentItems.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      ..._supportedContentItems.map(
                        (item) => _buildContentItemCard(context, theme, item),
                      ),
                    ],
                    const SizedBox(height: 8),
                    _buildPracticeHeader(context, theme),
                    const SizedBox(height: 14),
                    _buildPracticeCard(context, theme),
                  ],
                ),
              ),
      ),
    );
  }
}
