import 'package:flutter/material.dart';

import '../data/generated_stage_a_preview_lessons.dart';
import '../data/generated_stage_b_preview_lessons.dart';
import '../data/generated_stage_c_preview_lessons.dart';
import '../data/v2_micro_lesson_catalog.dart';
import '../l10n/localized_text.dart';
import '../l10n/v2_micro_lesson_localizer.dart';
import '../models/app_settings.dart';
import '../models/v2_micro_lesson.dart';
import '../services/audio_service.dart';
import '../services/v2_micro_lesson_completion_orchestrator.dart';
import '../theme/app_theme.dart';
import '../widgets/arabic_text_with_audio.dart';
import '../widgets/app_widgets.dart';
import 'v2_micro_lesson_completion_page.dart';

class V2MicroLessonPage extends StatefulWidget {
  final String? lessonId;
  final V2MicroLesson? lesson;
  final AppSettings settings;

  const V2MicroLessonPage({
    super.key,
    required this.settings,
    this.lessonId,
    this.lesson,
  }) : assert(
          lessonId != null || lesson != null,
          'Provide either lessonId or lesson.',
        ),
        assert(
          lessonId == null || lesson == null,
          'Provide only one of lessonId or lesson.',
        );

  @override
  State<V2MicroLessonPage> createState() => _V2MicroLessonPageState();
}

class _V2MicroLessonPageState extends State<V2MicroLessonPage> {
  late final V2MicroLesson _lesson;
  final Map<String, V2MicroPracticeOutcome> _outcomes =
      <String, V2MicroPracticeOutcome>{};
  final TextEditingController _typedAnswerController = TextEditingController();
  int _currentPracticeIndex = 0;
  bool _submitting = false;
  String? _selectedChoice;
  bool? _autoPracticePassed;
  bool? _guidedPracticePassed;
  List<String> _arrangedResponseTokens = <String>[];

  @override
  void initState() {
    super.initState();
    _lesson = widget.lesson ?? v2MicroLessonById(widget.lessonId!);
  }

  @override
  void dispose() {
    _typedAnswerController.dispose();
    super.dispose();
  }

  V2MicroPracticeItem get _currentPractice =>
      _lesson.practiceItems[_currentPracticeIndex];

  bool get _isPreviewLesson => widget.lesson != null;

  int get _stageAPreviewIndex {
    return stageAFoundationPreviewLessons.indexWhere(
      (lesson) => lesson.lessonId == _lesson.lessonId,
    );
  }

  bool get _isStageAPreviewLesson => _stageAPreviewIndex >= 0;

  int get _stageBPreviewIndex {
    return stageBPreviewLessons.indexWhere(
      (lesson) => lesson.lessonId == _lesson.lessonId,
    );
  }

  bool get _isStageBPreviewLesson => _stageBPreviewIndex >= 0;

  int get _stageCPreviewIndex {
    return stageCPreviewLessons.indexWhere(
      (lesson) => lesson.lessonId == _lesson.lessonId,
    );
  }

  bool get _isStageCPreviewLesson => _stageCPreviewIndex >= 0;

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

  bool get _isCurrentPracticeTypedResponse =>
      _currentPractice.type == V2MicroPracticeType.speakResponse ||
      _currentPractice.type == V2MicroPracticeType.recallPrompt;

  String get _continueLabel => localizedText(
        context,
        zh: '\u7ee7\u7eed',
        en: 'Continue',
      );

  String get _retryLabel => localizedText(
        context,
        zh: '\u518d\u8bd5\u4e00\u6b21',
        en: 'Try Again',
      );

  String get _continueWithReviewLabel => localizedText(
        context,
        zh: '\u6807\u8bb0\u56de\u770b\u5e76\u7ee7\u7eed',
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
        _resetPracticeState();
      });
      return;
    }

    setState(() => _submitting = true);
    final practiceOutcomes = _lesson.practiceItems
        .map((item) => _outcomes[item.itemId]!)
        .toList(growable: false);
    final result = _isPreviewLesson
        ? await V2MicroLessonCompletionOrchestrator.completePreviewLesson(
            lesson: _lesson,
            practiceOutcomes: practiceOutcomes,
          )
        : await V2MicroLessonCompletionOrchestrator.completeLesson(
            lessonId: _lesson.lessonId,
            practiceOutcomes: practiceOutcomes,
          );
    if (!mounted) {
      return;
    }
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => V2MicroLessonCompletionPage(
          settings: widget.settings,
          result: result,
          lessonOverride: _isPreviewLesson ? _lesson : null,
          previewMode: _isPreviewLesson,
        ),
      ),
    );
    if (!mounted) {
      return;
    }
    Navigator.pop(context, true);
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

  void _resetPracticeState() {
    _selectedChoice = null;
    _autoPracticePassed = null;
    _guidedPracticePassed = null;
    _arrangedResponseTokens = <String>[];
    _typedAnswerController.clear();
  }

  String _expectedPracticeAnswer(V2MicroPracticeItem practice) {
    final explicitAnswer = (practice.expectedAnswer ?? practice.arabicText ?? '')
        .trim();
    if (explicitAnswer.isNotEmpty) {
      return explicitAnswer;
    }

    bool sharesObjectiveIds(Iterable<String> candidateObjectiveIds) {
      return practice.objectiveIds.any(candidateObjectiveIds.contains);
    }

    final practiceIndex = _lesson.practiceItems.indexOf(practice);
    if (practiceIndex > 0) {
      for (final candidate in _lesson.practiceItems
          .take(practiceIndex)
          .toList(growable: false)
          .reversed) {
        final candidateAnswer =
            (candidate.expectedAnswer ?? candidate.arabicText ?? '').trim();
        if (candidateAnswer.isNotEmpty &&
            sharesObjectiveIds(candidate.objectiveIds)) {
          return candidateAnswer;
        }
      }
    }

    for (final item in _lesson.contentItems.reversed) {
      final candidateAnswer = (item.arabicText ?? '').trim();
      if (candidateAnswer.isNotEmpty &&
          sharesObjectiveIds(item.objectiveIds)) {
        return candidateAnswer;
      }
    }

    return '';
  }

  String _normalizePracticeAnswer(String value) {
    return removeArabicDiacritics(value)
        .replaceAll(RegExp(r'[.,!?;:]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .toLowerCase();
  }

  bool _matchesExpectedAnswer(
    V2MicroPracticeItem practice,
    String candidate,
  ) {
    final normalizedCandidate = _normalizePracticeAnswer(candidate);
    final normalizedExpected = _normalizePracticeAnswer(
      _expectedPracticeAnswer(practice),
    );
    return normalizedCandidate.isNotEmpty &&
        normalizedExpected.isNotEmpty &&
        normalizedCandidate == normalizedExpected;
  }

  List<String> _arrangeResponseOptions(V2MicroPracticeItem practice) {
    final expectedAnswer = _expectedPracticeAnswer(practice);
    if (expectedAnswer.isEmpty) {
      return <String>[];
    }
    final tokens = expectedAnswer
        .split(RegExp(r'\s+'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
    if (tokens.length <= 1) {
      return tokens;
    }
    return tokens.reversed.toList(growable: false);
  }

  void _submitTypedPractice(V2MicroPracticeItem practice) {
    final passed = _matchesExpectedAnswer(
      practice,
      _typedAnswerController.text,
    );
    setState(() => _guidedPracticePassed = passed);
  }

  void _submitArrangePractice(V2MicroPracticeItem practice) {
    final candidate = _arrangedResponseTokens.join(' ');
    final passed = _matchesExpectedAnswer(practice, candidate);
    setState(() => _guidedPracticePassed = passed);
  }

  void _addArrangeToken(String token) {
    if (_guidedPracticePassed != null) {
      return;
    }
    setState(() => _arrangedResponseTokens = <String>[
          ..._arrangedResponseTokens,
          token,
        ]);
  }

  void _removeArrangeTokenAt(int index) {
    if (_guidedPracticePassed != null) {
      return;
    }
    setState(() {
      _arrangedResponseTokens = <String>[
        ..._arrangedResponseTokens.take(index),
        ..._arrangedResponseTokens.skip(index + 1),
      ];
    });
  }

  void _resetGuidedAttempt() {
    setState(_resetPracticeState);
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

    if (practice.choiceOptions.isNotEmpty) {
      for (final option in practice.choiceOptions) {
        addOption(option);
      }
      addOption(practice.arabicText);
      return options;
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

  ContentLanguage get _surfaceMeaningLanguage {
    if (widget.settings.appLanguage == AppLanguage.en) {
      return ContentLanguage.en;
    }
    return widget.settings.meaningLanguage;
  }

  String _practiceMeaning(V2MicroPracticeItem practice) {
    return V2MicroLessonLocalizer.practiceMeaning(
          practice.itemId,
          _surfaceMeaningLanguage,
          fallback: practice.meaning,
        ) ??
        '';
  }

  String _contentMeaning(V2MicroContentItem item) {
    return V2MicroLessonLocalizer.practiceMeaning(
          item.itemId,
          _surfaceMeaningLanguage,
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

  String _previewSupportText() {
    return localizedText(
      context,
      zh: 'This is a local preview lesson for checking the lesson experience. It does not change the live home progression.',
      en: 'This is a local preview lesson for checking the lesson experience. It does not change the live home progression.',
    );
  }

  Future<void> _openStageAPreviewLessonAt(int index) async {
    if (!_isStageAPreviewLesson ||
        index < 0 ||
        index >= stageAFoundationPreviewLessons.length ||
        index == _stageAPreviewIndex) {
      return;
    }

    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => V2MicroLessonPage(
          settings: widget.settings,
          lesson: stageAFoundationPreviewLessons[index],
        ),
      ),
    );
  }

  void _returnToStageAPreviewHub() {
    if (_isStageAPreviewLesson) {
      Navigator.pop(context);
    }
  }

  Widget _buildStageAPreviewNavigator(BuildContext context, ThemeData theme) {
    if (!_isStageAPreviewLesson) {
      return const SizedBox.shrink();
    }

    final currentIndex = _stageAPreviewIndex;
    final currentNumber = currentIndex + 1;
    final descriptor = stageAPreviewDescriptorForLessonId(_lesson.lessonId);

    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Pill(
            label: localizedText(
              context,
              zh: 'STAGE A PREVIEW',
              en: 'STAGE A PREVIEW',
            ),
            backgroundColor: AppTheme.softAccent,
            foregroundColor: AppTheme.accentMintDark,
          ),
          const SizedBox(height: 10),
          Text(
            localizedText(
              context,
              zh: 'Lesson $currentNumber of ${stageAFoundationPreviewLessons.length}',
              en: 'Lesson $currentNumber of ${stageAFoundationPreviewLessons.length}',
            ),
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            localizedText(
              context,
              zh: 'Now previewing: ${_lesson.title}',
              en: 'Now previewing: ${_lesson.title}',
            ),
            style: theme.textTheme.bodyMedium,
          ),
          if (descriptor != null) ...[
            const SizedBox(height: 8),
            Text(
              descriptor.chapterRole,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.accentMintDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              localizedText(
                context,
                zh: 'Next unlock: ${descriptor.nextUnlock}',
                en: 'Next unlock: ${descriptor.nextUnlock}',
              ),
              style: theme.textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List<Widget>.generate(
              stageAFoundationPreviewLessons.length,
              (index) {
                final lesson = stageAFoundationPreviewLessons[index];
                return ChoiceChip(
                  key: ValueKey<String>(
                    'stage_a_preview_lesson_chip_${lesson.lessonId}',
                  ),
                  label: Text('${index + 1}'),
                  selected: index == currentIndex,
                  onSelected: index == currentIndex
                      ? null
                      : (_) => _openStageAPreviewLessonAt(index),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton(
                onPressed: currentIndex > 0
                    ? () => _openStageAPreviewLessonAt(currentIndex - 1)
                    : null,
                child: Text(
                  localizedText(
                    context,
                    zh: 'Previous Lesson',
                    en: 'Previous Lesson',
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: _returnToStageAPreviewHub,
                child: Text(
                  localizedText(
                    context,
                    zh: 'Back to Chapter',
                    en: 'Back to Chapter',
                  ),
                ),
              ),
              OutlinedButton(
                onPressed:
                    currentIndex < stageAFoundationPreviewLessons.length - 1
                        ? () => _openStageAPreviewLessonAt(currentIndex + 1)
                        : null,
                child: Text(
                  localizedText(
                    context,
                    zh: 'Next Lesson',
                    en: 'Next Lesson',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openStageBPreviewLessonAt(int index) async {
    if (!_isStageBPreviewLesson ||
        index < 0 ||
        index >= stageBPreviewLessons.length ||
        index == _stageBPreviewIndex) {
      return;
    }

    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => V2MicroLessonPage(
          settings: widget.settings,
          lesson: stageBPreviewLessons[index],
        ),
      ),
    );
  }

  void _returnToStageBPreviewHub() {
    if (_isStageBPreviewLesson) {
      Navigator.pop(context);
    }
  }

  Widget _buildStageBPreviewNavigator(BuildContext context, ThemeData theme) {
    if (!_isStageBPreviewLesson) {
      return const SizedBox.shrink();
    }

    final currentIndex = _stageBPreviewIndex;
    final descriptor = stageBPreviewDescriptorForLessonId(_lesson.lessonId);
    final currentNumber = descriptor?.order ?? (currentIndex + 5);

    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Pill(
            label: localizedText(
              context,
              zh: 'STAGE B PREVIEW',
              en: 'STAGE B PREVIEW',
            ),
            backgroundColor: AppTheme.softAccent,
            foregroundColor: AppTheme.accentMintDark,
          ),
          const SizedBox(height: 10),
          Text(
            localizedText(
              context,
              zh: 'Lesson $currentNumber of 8',
              en: 'Lesson $currentNumber of 8',
            ),
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            localizedText(
              context,
              zh: 'Now previewing: ${_lesson.title}',
              en: 'Now previewing: ${_lesson.title}',
            ),
            style: theme.textTheme.bodyMedium,
          ),
          if (descriptor != null) ...[
            const SizedBox(height: 8),
            Text(
              descriptor.chapterRole,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.accentMintDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              localizedText(
                context,
                zh: 'Next unlock: ${descriptor.nextUnlock}',
                en: 'Next unlock: ${descriptor.nextUnlock}',
              ),
              style: theme.textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List<Widget>.generate(
              stageBPreviewLessons.length,
              (index) {
                final lesson = stageBPreviewLessons[index];
                final lessonDescriptor =
                    stageBPreviewDescriptorForLessonId(lesson.lessonId);
                final chipLabel = lessonDescriptor == null
                    ? '${index + 5}'
                    : '${lessonDescriptor.order}';
                return ChoiceChip(
                  key: ValueKey<String>(
                    'stage_b_preview_lesson_chip_${lesson.lessonId}',
                  ),
                  label: Text(chipLabel),
                  selected: index == currentIndex,
                  onSelected: index == currentIndex
                      ? null
                      : (_) => _openStageBPreviewLessonAt(index),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton(
                onPressed: currentIndex > 0
                    ? () => _openStageBPreviewLessonAt(currentIndex - 1)
                    : null,
                child: Text(
                  localizedText(
                    context,
                    zh: 'Previous Lesson',
                    en: 'Previous Lesson',
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: _returnToStageBPreviewHub,
                child: Text(
                  localizedText(
                    context,
                    zh: 'Back to Chapter',
                    en: 'Back to Chapter',
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: currentIndex < stageBPreviewLessons.length - 1
                    ? () => _openStageBPreviewLessonAt(currentIndex + 1)
                    : null,
                child: Text(
                  localizedText(
                    context,
                    zh: 'Next Lesson',
                    en: 'Next Lesson',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openStageCPreviewLessonAt(int index) async {
    if (!_isStageCPreviewLesson ||
        index < 0 ||
        index >= stageCPreviewLessons.length ||
        index == _stageCPreviewIndex) {
      return;
    }

    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => V2MicroLessonPage(
          settings: widget.settings,
          lesson: stageCPreviewLessons[index],
        ),
      ),
    );
  }

  void _returnToStageCPreviewHub() {
    if (_isStageCPreviewLesson) {
      Navigator.pop(context);
    }
  }

  Widget _buildStageCPreviewNavigator(BuildContext context, ThemeData theme) {
    if (!_isStageCPreviewLesson) {
      return const SizedBox.shrink();
    }

    final currentIndex = _stageCPreviewIndex;
    final descriptor = stageCPreviewDescriptorForLessonId(_lesson.lessonId);
    final currentNumber = descriptor?.order ?? (currentIndex + 9);

    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Pill(
            label: localizedText(
              context,
              zh: 'STAGE C PREVIEW',
              en: 'STAGE C PREVIEW',
            ),
            backgroundColor: AppTheme.softAccent,
            foregroundColor: AppTheme.accentMintDark,
          ),
          const SizedBox(height: 10),
          Text(
            localizedText(
              context,
              zh: 'Lesson $currentNumber of 12',
              en: 'Lesson $currentNumber of 12',
            ),
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            localizedText(
              context,
              zh: 'Now previewing: ${_lesson.title}',
              en: 'Now previewing: ${_lesson.title}',
            ),
            style: theme.textTheme.bodyMedium,
          ),
          if (descriptor != null) ...[
            const SizedBox(height: 8),
            Text(
              descriptor.chapterRole,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.accentMintDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              localizedText(
                context,
                zh: 'Next unlock: ${descriptor.nextUnlock}',
                en: 'Next unlock: ${descriptor.nextUnlock}',
              ),
              style: theme.textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List<Widget>.generate(
              stageCPreviewLessons.length,
              (index) {
                final lesson = stageCPreviewLessons[index];
                final lessonDescriptor =
                    stageCPreviewDescriptorForLessonId(lesson.lessonId);
                final chipLabel = lessonDescriptor == null
                    ? '${index + 9}'
                    : '${lessonDescriptor.order}';
                return ChoiceChip(
                  key: ValueKey<String>(
                    'stage_c_preview_lesson_chip_${lesson.lessonId}',
                  ),
                  label: Text(chipLabel),
                  selected: index == currentIndex,
                  onSelected: index == currentIndex
                      ? null
                      : (_) => _openStageCPreviewLessonAt(index),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton(
                onPressed: currentIndex > 0
                    ? () => _openStageCPreviewLessonAt(currentIndex - 1)
                    : null,
                child: Text(
                  localizedText(
                    context,
                    zh: 'Previous Lesson',
                    en: 'Previous Lesson',
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: _returnToStageCPreviewHub,
                child: Text(
                  localizedText(
                    context,
                    zh: 'Back to Chapter',
                    en: 'Back to Chapter',
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: currentIndex < stageCPreviewLessons.length - 1
                    ? () => _openStageCPreviewLessonAt(currentIndex + 1)
                    : null,
                child: Text(
                  localizedText(
                    context,
                    zh: 'Next Lesson',
                    en: 'Next Lesson',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _autoFeedbackTitle(bool passed) {
    return passed
        ? localizedText(
            context,
            zh: '\u5224\u65ad\u6b63\u786e',
            en: 'Correct',
          )
        : localizedText(
            context,
            zh: '\u8fd9\u9898\u5148\u56de\u770b',
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
          zh: '\u4f60\u9009\u4e2d\u4e86\u6b63\u786e\u53e5\u5b50\uff1a$answer\u3002\u5b83\u5bf9\u5e94\u7684\u662f\u201c$meaning\u201d\u3002',
          en: 'You picked the correct line: $answer. It means "$meaning".',
        );
      }
      return localizedText(
        context,
        zh: '\u4f60\u9009\u4e2d\u4e86\u6b63\u786e\u53e5\u5b50\uff1a$answer\u3002\u7ee7\u7eed\u4e0b\u4e00\u6b65\u3002',
        en: 'You picked the correct line: $answer. Continue to the next step.',
      );
    }

    if (meaning.isNotEmpty) {
      return localizedText(
        context,
        zh: '\u6b63\u786e\u53e5\u5b50\u662f $answer\uff0c\u5bf9\u5e94\u201c$meaning\u201d\u3002\u8fd9\u4e00\u9898\u4f1a\u8bb0\u5165\u56de\u770b\u3002',
        en: 'The correct line is $answer, which means "$meaning". This item will be marked for review.',
      );
    }
    return localizedText(
      context,
      zh: '\u6b63\u786e\u53e5\u5b50\u662f $answer\u3002\u8fd9\u4e00\u9898\u4f1a\u8bb0\u5165\u56de\u770b\u3002',
      en: 'The correct line is $answer. This item will be marked for review.',
    );
  }

  String _guidedFeedbackTitle(bool passed) {
    return passed
        ? localizedText(
            context,
            zh: '\u56de\u7b54\u5339\u914d',
            en: 'Answer Matches',
          )
        : localizedText(
            context,
            zh: '\u5148\u8bb0\u5165\u56de\u770b',
            en: 'Mark This For Review',
          );
  }

  String _guidedFeedbackBody(V2MicroPracticeItem practice, bool passed) {
    final expectedAnswer = _expectedPracticeAnswer(practice);
    final practiceMeaning = _practiceMeaning(practice);

    if (passed) {
      if (practiceMeaning.isNotEmpty) {
        return localizedText(
          context,
          zh: '\u8fd9\u4e00\u6b65\u7684\u7b54\u6848\u5df2\u5339\u914d\u3002\u610f\u601d\u662f\u201c$practiceMeaning\u201d\u3002',
          en: 'This step matched the expected answer. It means "$practiceMeaning".',
        );
      }
      return localizedText(
        context,
        zh: '\u8fd9\u4e00\u6b65\u7684\u7b54\u6848\u5df2\u5339\u914d\uff0c\u53ef\u4ee5\u7ee7\u7eed\u3002',
        en: 'This step matched the expected answer. Continue to the next step.',
      );
    }

    if (expectedAnswer.isEmpty) {
      return localizedText(
        context,
        zh: '\u8fd9\u4e00\u6b65\u4f1a\u8bb0\u5165\u56de\u770b\uff0c\u7136\u540e\u7ee7\u7eed\u4e0b\u4e00\u6b65\u3002',
        en: 'This step will be marked for review before you continue.',
      );
    }

    if (practiceMeaning.isNotEmpty) {
      return localizedText(
        context,
        zh: '\u6b63\u786e\u7b54\u6848\u662f\uff1a$expectedAnswer\u3002\u5b83\u7684\u610f\u601d\u662f\u201c$practiceMeaning\u201d\u3002\u8fd9\u4e00\u6b65\u4f1a\u8bb0\u5165\u56de\u770b\u3002',
        en: 'The expected answer is $expectedAnswer. It means "$practiceMeaning". This step will be marked for review.',
      );
    }

    return localizedText(
      context,
      zh: '\u6b63\u786e\u7b54\u6848\u662f\uff1a$expectedAnswer\u3002\u8fd9\u4e00\u6b65\u4f1a\u8bb0\u5165\u56de\u770b\u3002',
      en: 'The expected answer is $expectedAnswer. This step will be marked for review.',
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
    final stageAPreviewDescriptor = stageAPreviewDescriptorForLessonId(
      _lesson.lessonId,
    );
    final stageBPreviewDescriptor = stageBPreviewDescriptorForLessonId(
      _lesson.lessonId,
    );
    final stageCPreviewDescriptor = stageCPreviewDescriptorForLessonId(
      _lesson.lessonId,
    );
    final completionEvidence =
        stageAPreviewDescriptor?.completionEvidence ??
        stageBPreviewDescriptor?.completionEvidence ??
        stageCPreviewDescriptor?.completionEvidence;

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
              zh: '\u672c\u8bfe\u76ee\u6807',
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
          if (completionEvidence != null) ...[
            const SizedBox(height: 8),
            Text(
              localizedText(
                context,
                zh: 'Completion evidence: $completionEvidence',
                en: 'Completion evidence: $completionEvidence',
              ),
              style: theme.textTheme.bodySmall,
            ),
          ],
          if (_isPreviewLesson) ...[
            const SizedBox(height: 8),
            Text(_previewSupportText(), style: theme.textTheme.bodySmall),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (_isPreviewLesson)
                Chip(
                  label: Text(
                    localizedText(
                      context,
                      zh: 'Preview Lesson',
                      en: 'Preview Lesson',
                    ),
                  ),
                ),
              Chip(
                label: Text(
                  localizedText(
                    context,
                    zh: '${_lesson.estimatedMinutes} \u5206\u949f\u6837\u677f\u8bfe',
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
            zh: '\u5f00\u59cb\u7ec3\u8fd9\u4e00\u5c0f\u6b65',
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
                '\u7b2c ${_currentPracticeIndex + 1} / ${_lesson.practiceItems.length} \u6b65',
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
          else if (_isCurrentPracticeTypedResponse)
            _buildTypedResponseSection(context, theme, practice, practiceMeaning)
          else if (practice.type == V2MicroPracticeType.arrangeResponse)
            _buildArrangeResponseSection(context, theme, practice, practiceMeaning)
          else
            _buildGuidedPracticeSection(context, theme, practice, practiceMeaning),
        ],
      ),
    );
  }

  Widget _buildGuidedFeedback(
    BuildContext context,
    ThemeData theme,
    V2MicroPracticeItem practice,
  ) {
    if (_guidedPracticePassed == null) {
      return const SizedBox.shrink();
    }

    final passed = _guidedPracticePassed!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: passed ? const Color(0xFFEAF7EF) : const Color(0xFFFDF0E7),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _guidedFeedbackTitle(passed),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                _guidedFeedbackBody(practice, passed),
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (passed)
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
              onPressed: _resetGuidedAttempt,
              child: Text(_retryLabel),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTypedResponseSection(
    BuildContext context,
    ThemeData theme,
    V2MicroPracticeItem practice,
    String practiceMeaning,
  ) {
    final arabicText = practice.type == V2MicroPracticeType.recallPrompt
        ? ''
        : (practice.arabicText?.trim() ?? '');
    final expectedAnswer = _expectedPracticeAnswer(practice);
    final showTransliteration =
        widget.settings.showTransliteration &&
        practice.type != V2MicroPracticeType.recallPrompt &&
        (practice.transliteration?.trim().isNotEmpty ?? false);

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
        if (showTransliteration) ...[
          Text(practice.transliteration!, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: _typedAnswerController,
          enabled: _guidedPracticePassed == null,
          decoration: InputDecoration(
            labelText: localizedText(
              context,
              zh: '\u8f93\u5165\u7b54\u6848',
              en: 'Type Your Answer',
            ),
            hintText: expectedAnswer.isEmpty
                ? null
                : localizedText(
                    context,
                    zh: '\u7528\u963f\u62c9\u4f2f\u8bed\u8f93\u5165',
                    en: 'Answer in Arabic',
                  ),
            border: const OutlineInputBorder(),
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            if (_guidedPracticePassed == null) {
              _submitTypedPractice(practice);
            }
          },
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _guidedPracticePassed == null
                ? () => _submitTypedPractice(practice)
                : null,
            child: Text(
              localizedText(
                context,
                zh: '\u68c0\u67e5\u7b54\u6848',
                en: 'Check Answer',
              ),
            ),
          ),
        ),
        _buildGuidedFeedback(context, theme, practice),
      ],
    );
  }

  Widget _buildArrangeResponseSection(
    BuildContext context,
    ThemeData theme,
    V2MicroPracticeItem practice,
    String practiceMeaning,
  ) {
    final options = _arrangeResponseOptions(practice);
    final selectedCounts = <String, int>{};
    for (final token in _arrangedResponseTokens) {
      selectedCounts[token] = (selectedCounts[token] ?? 0) + 1;
    }
    final availableTokens = <String>[];
    final usedCounts = <String, int>{};
    for (final token in options) {
      final count = usedCounts[token] ?? 0;
      final selectedCount = selectedCounts[token] ?? 0;
      if (count < selectedCount) {
        usedCounts[token] = count + 1;
        continue;
      }
      availableTokens.add(token);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (practiceMeaning.isNotEmpty) ...[
          Text(practiceMeaning, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 12),
        ],
        Text(
          localizedText(
            context,
            zh: '\u6309\u987a\u5e8f\u70b9\u8bcd\uff0c\u62fc\u6210\u5b8c\u6574\u56de\u7b54\u3002',
            en: 'Tap the words in order to build the full response.',
          ),
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD6CCB9)),
          ),
          child: _arrangedResponseTokens.isEmpty
              ? Text(
                  localizedText(
                    context,
                    zh: '\u4f60\u7684\u7b54\u6848\u4f1a\u663e\u793a\u5728\u8fd9\u91cc',
                    en: 'Your answer will appear here',
                  ),
                  style: theme.textTheme.bodyMedium,
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List<Widget>.generate(
                    _arrangedResponseTokens.length,
                    (index) {
                      final token = _arrangedResponseTokens[index];
                      return InputChip(
                        label: Text(token),
                        onPressed: _guidedPracticePassed == null
                            ? () => _removeArrangeTokenAt(index)
                            : null,
                      );
                    },
                  ),
                ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableTokens
              .map(
                (token) => ActionChip(
                  label: Text(token),
                  onPressed: _guidedPracticePassed == null
                      ? () => _addArrangeToken(token)
                      : null,
                ),
              )
              .toList(growable: false),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _guidedPracticePassed == null &&
                    _arrangedResponseTokens.isNotEmpty
                ? () => _submitArrangePractice(practice)
                : null,
            child: Text(
              localizedText(
                context,
                zh: '\u68c0\u67e5\u7b54\u6848',
                en: 'Check Answer',
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _guidedPracticePassed == null &&
                    _arrangedResponseTokens.isNotEmpty
                ? () => setState(() => _arrangedResponseTokens = <String>[])
                : null,
            child: Text(
              localizedText(
                context,
                zh: '\u6e05\u7a7a\u987a\u5e8f',
                en: 'Reset Order',
              ),
            ),
          ),
        ),
        _buildGuidedFeedback(context, theme, practice),
      ],
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
                  zh: '\u5148\u542c\uff0c\u518d\u9009',
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
                  zh: '\u64ad\u653e\u8fd9\u4e00\u9898\u97f3\u9891',
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
                      zh: '\u56de\u5230\u4e0a\u65b9\u518d\u542c\u4e00\u6b21\u4f1a\u66f4\u7a33\u3002',
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
            zh: '\u8fd9\u4e00\u9898\u5148\u4fdd\u7559\u8f7b\u91cf\u81ea\u8bc4\uff1a\u505a\u5230\u4e86\u5c31\u7ee7\u7eed\uff0c\u4e0d\u7a33\u5c31\u8bb0\u5165\u56de\u770b\u3002',
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
                zh: '\u6211\u505a\u5230\u4e86',
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
                zh: '\u8fd9\u91cc\u8fd8\u4e0d\u7a33',
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
                    if (_isStageAPreviewLesson) ...[
                      _buildStageAPreviewNavigator(context, theme),
                      const SizedBox(height: 16),
                    ],
                    if (_isStageBPreviewLesson) ...[
                      _buildStageBPreviewNavigator(context, theme),
                      const SizedBox(height: 16),
                    ],
                    if (_isStageCPreviewLesson) ...[
                      _buildStageCPreviewNavigator(context, theme),
                      const SizedBox(height: 16),
                    ],
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










