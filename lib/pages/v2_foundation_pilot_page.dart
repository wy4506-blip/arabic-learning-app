import 'package:flutter/material.dart';

import '../data/generated_stage_a_preview_lessons.dart';
import '../data/generated_stage_b_preview_lessons.dart';
import '../data/generated_stage_c_preview_lessons.dart';
import '../data/v2_micro_lesson_catalog.dart';
import '../l10n/localized_text.dart';
import '../l10n/v2_micro_lesson_localizer.dart';
import '../models/app_settings.dart';
import '../models/v2_micro_lesson.dart';
import '../services/v2_learning_snapshot_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'v2_micro_lesson_page.dart';
import 'v2_review_entry_page.dart';

class V2FoundationPilotPage extends StatefulWidget {
  final AppSettings settings;

  const V2FoundationPilotPage({
    super.key,
    required this.settings,
  });

  @override
  State<V2FoundationPilotPage> createState() => _V2FoundationPilotPageState();
}

class _V2FoundationPilotPageState extends State<V2FoundationPilotPage> {
  static const List<_FoundationStageConfig> _stageConfigs =
      <_FoundationStageConfig>[
    _FoundationStageConfig(
      stageLabel: 'Stage A',
      lessonsLabel: 'Lessons 1-4',
      title: 'Arabic Entry',
      summary:
          'Enter Arabic through real words, build the first owned words, and finish with supported reading.',
      lessons: stageAFoundationPreviewLessons,
    ),
    _FoundationStageConfig(
      stageLabel: 'Stage B',
      lessonsLabel: 'Lessons 5-8',
      title: 'Usable Arabic',
      summary:
          'Grow the pack into a first usable line, hear known content more directly, and finish with a small working set.',
      lessons: stageBPreviewLessons,
    ),
    _FoundationStageConfig(
      stageLabel: 'Stage C',
      lessonsLabel: 'Lessons 9-12',
      title: 'Pattern Growth',
      summary:
          'Add one more real word, notice two small clues, and finish with one tiny Arabic card.',
      lessons: stageCPreviewLessons,
    ),
  ];

  bool _loading = true;
  V2LearningSnapshot? _snapshot;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _loadSnapshot();
  }

  Future<void> _loadSnapshot() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });

    try {
      final snapshot = await V2LearningSnapshotService.getSnapshot(
        lessons: foundationPilotMicroLessons,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _snapshot = snapshot;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadError = error;
        _loading = false;
      });
    }
  }

  Future<void> _openLesson(String lessonId) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => V2MicroLessonPage(
          settings: widget.settings,
          lessonId: lessonId,
        ),
      ),
    );
    if (!mounted) {
      return;
    }
    await _loadSnapshot();
  }

  Future<void> _openReview(List<V2DueReviewItem> dueReviewItems) async {
    if (dueReviewItems.isEmpty) {
      return;
    }

    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => V2ReviewEntryPage(
          settings: widget.settings,
          dueReviewItems: dueReviewItems,
        ),
      ),
    );
    if (!mounted) {
      return;
    }
    await _loadSnapshot();
  }

  Future<void> _runPrimaryAction() async {
    final snapshot = _snapshot;
    if (snapshot == null) {
      return;
    }

    switch (snapshot.recommendedAction.actionType) {
      case V2RecommendedActionType.startReview:
        await _openReview(snapshot.dueReviewItems);
        return;
      case V2RecommendedActionType.startLesson:
      case V2RecommendedActionType.continueLesson:
        final lessonId = snapshot.recommendedAction.targetLessonId ??
            snapshot.recommendedLessonId;
        if (lessonId != null) {
          await _openLesson(lessonId);
        }
        return;
      case V2RecommendedActionType.startConsolidation:
      case V2RecommendedActionType.startNextPhase:
      case V2RecommendedActionType.noAction:
        await _loadSnapshot();
        return;
    }
  }

  String _primaryActionTitle(V2LearningSnapshot snapshot) {
    final recommendedLessonId = snapshot.recommendedAction.targetLessonId ??
        snapshot.recommendedLessonId;
    final recommendedLesson = recommendedLessonId == null
        ? null
        : maybeV2MicroLessonById(recommendedLessonId);
    final recommendedLessonTitle = recommendedLesson == null
        ? null
        : V2MicroLessonLocalizer.lessonTitle(
            recommendedLesson,
            widget.settings.appLanguage,
          );

    switch (snapshot.recommendedAction.actionType) {
      case V2RecommendedActionType.startReview:
        return 'Clear Foundation Review First';
      case V2RecommendedActionType.startLesson:
        return recommendedLessonTitle == null
            ? 'Start Foundation Lesson'
            : 'Next Lesson: $recommendedLessonTitle';
      case V2RecommendedActionType.continueLesson:
        return recommendedLessonTitle == null
            ? 'Continue Foundation Lesson'
            : 'Continue: $recommendedLessonTitle';
      case V2RecommendedActionType.startConsolidation:
      case V2RecommendedActionType.startNextPhase:
      case V2RecommendedActionType.noAction:
        return 'Foundation Is Complete For Now';
    }
  }

  String _primaryActionBody(V2LearningSnapshot snapshot) {
    switch (snapshot.recommendedAction.actionType) {
      case V2RecommendedActionType.startReview:
        final dueCount = snapshot.dueReviewItems.length;
        final itemLabel = dueCount == 1 ? 'item' : 'items';
        return '$dueCount due or weak $itemLabel should be cleared before continuing the mainline.';
      case V2RecommendedActionType.startLesson:
        return 'This path writes real lesson progress and review seeds while the live Home recommendation stays unchanged.';
      case V2RecommendedActionType.continueLesson:
        return 'Continue the current Foundation lesson. This page refreshes when you return.';
      case V2RecommendedActionType.startConsolidation:
      case V2RecommendedActionType.startNextPhase:
      case V2RecommendedActionType.noAction:
        return 'Stage A through Stage C do not have a blocking next action right now. Promotion to Home can stay separate.';
    }
  }

  String _primaryActionButtonLabel(V2LearningSnapshot snapshot) {
    switch (snapshot.recommendedAction.actionType) {
      case V2RecommendedActionType.startReview:
        return 'Start Review';
      case V2RecommendedActionType.startLesson:
        return 'Start Lesson';
      case V2RecommendedActionType.continueLesson:
        return 'Continue Lesson';
      case V2RecommendedActionType.startConsolidation:
      case V2RecommendedActionType.startNextPhase:
      case V2RecommendedActionType.noAction:
        return 'Refresh Status';
    }
  }

  String _statusLabel(V2CanonicalLessonStatus status) {
    switch (status) {
      case V2CanonicalLessonStatus.locked:
        return 'Locked';
      case V2CanonicalLessonStatus.notStarted:
        return 'Not Started';
      case V2CanonicalLessonStatus.inProgress:
        return 'In Progress';
      case V2CanonicalLessonStatus.coreCompleted:
        return 'Core Complete';
      case V2CanonicalLessonStatus.completed:
        return 'Completed';
      case V2CanonicalLessonStatus.dueForReview:
        return 'Review Due';
      case V2CanonicalLessonStatus.mastered:
        return 'Mastered';
    }
  }

  String _lessonActionLabel(V2CanonicalLessonStatus status) {
    switch (status) {
      case V2CanonicalLessonStatus.locked:
        return 'Locked';
      case V2CanonicalLessonStatus.notStarted:
        return 'Start Lesson';
      case V2CanonicalLessonStatus.inProgress:
      case V2CanonicalLessonStatus.coreCompleted:
      case V2CanonicalLessonStatus.completed:
      case V2CanonicalLessonStatus.dueForReview:
      case V2CanonicalLessonStatus.mastered:
        return 'Open Lesson';
    }
  }

  int _lessonNumber(String lessonId) {
    final index = foundationPilotMicroLessons.indexWhere(
      (lesson) => lesson.lessonId == lessonId,
    );
    return index < 0 ? 0 : index + 1;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EC),
      appBar: AppBar(
        title: Text(
          localizedText(
            context,
            zh: 'Foundation Pilot',
            en: 'Foundation Pilot',
          ),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _loadError != null
                ? Center(
                    child: Padding(
                      padding: AppTheme.pagePadding,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            localizedText(
                              context,
                              zh: 'Foundation pilot state could not be loaded.',
                              en: 'Foundation pilot state could not be loaded.',
                            ),
                            style: theme.textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: _loadSnapshot,
                            child: Text(
                              localizedText(
                                context,
                                zh: 'Retry',
                                en: 'Retry',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView(
                    padding: AppTheme.pagePadding,
                    children: [
                      SectionTitle(
                        title: localizedText(
                          context,
                          zh: 'Foundation Pilot Candidate',
                          en: 'Foundation Pilot Candidate',
                        ),
                        subtitle: localizedText(
                          context,
                          zh:
                              'Run the accepted 12-lesson foundation path with real lesson progress and review evidence while the live Home mainline stays unchanged.',
                          en:
                              'Run the accepted 12-lesson foundation path with real lesson progress and review evidence while the live Home mainline stays unchanged.',
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildPrimaryActionCard(theme, _snapshot!),
                      const SizedBox(height: 16),
                      AppSurface(
                        child: Text(
                          localizedText(
                            context,
                            zh:
                                'This is the controlled pilot entry. It writes real Foundation progress, but it does not replace the current Home recommendation loop.',
                            en:
                                'This is the controlled pilot entry. It writes real Foundation progress, but it does not replace the current Home recommendation loop.',
                          ),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._stageConfigs.map(
                        (stage) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildStageSection(theme, _snapshot!, stage),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildPrimaryActionCard(
    ThemeData theme,
    V2LearningSnapshot snapshot,
  ) {
    final completedCount = foundationPilotMicroLessons
        .where(
          (lesson) => snapshot.lessonStatusFor(lesson.lessonId).isCompletedLike,
        )
        .length;

    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Pill(
            label: localizedText(
              context,
              zh: 'CONTROLLED PILOT',
              en: 'CONTROLLED PILOT',
            ),
            backgroundColor: AppTheme.softAccent,
            foregroundColor: AppTheme.accentMintDark,
          ),
          const SizedBox(height: 10),
          Text(
            _primaryActionTitle(snapshot),
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            _primaryActionBody(snapshot),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                label: Text(
                  'Completed $completedCount / ${foundationPilotMicroLessons.length}',
                ),
              ),
              Chip(
                label: Text(
                  'Review Due ${snapshot.dueReviewItems.length}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: const ValueKey<String>('foundation_pilot_primary_action'),
              onPressed: _runPrimaryAction,
              child: Text(_primaryActionButtonLabel(snapshot)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageSection(
    ThemeData theme,
    V2LearningSnapshot snapshot,
    _FoundationStageConfig stage,
  ) {
    final completedCount = stage.lessons
        .where(
          (lesson) => snapshot.lessonStatusFor(lesson.lessonId).isCompletedLike,
        )
        .length;

    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${stage.stageLabel} - ${stage.lessonsLabel}',
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppTheme.accentMintDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(stage.title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(stage.summary, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 10),
          Text(
            'Stage progress: $completedCount / ${stage.lessons.length}',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 14),
          ...stage.lessons.map(
            (lesson) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildLessonCard(theme, snapshot, lesson),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonCard(
    ThemeData theme,
    V2LearningSnapshot snapshot,
    V2MicroLesson lesson,
  ) {
    final status = snapshot.lessonStatusFor(lesson.lessonId);
    final lessonNumber = _lessonNumber(lesson.lessonId);
    final isRecommended = snapshot.recommendedAction.actionType !=
            V2RecommendedActionType.startReview &&
        (snapshot.recommendedAction.targetLessonId == lesson.lessonId ||
            snapshot.recommendedLessonId == lesson.lessonId);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Pill(label: 'Lesson $lessonNumber'),
              Pill(
                label: _statusLabel(status),
                backgroundColor: AppTheme.softAccent,
                foregroundColor: AppTheme.accentMintDark,
              ),
              if (isRecommended)
                const Pill(
                  label: 'NEXT',
                  backgroundColor: Color(0xFFE9F4FF),
                  foregroundColor: Color(0xFF2E5D88),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            V2MicroLessonLocalizer.lessonTitle(
              lesson,
              widget.settings.appLanguage,
            ),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            V2MicroLessonLocalizer.outcomeSummary(
              lesson,
              widget.settings.appLanguage,
            ),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: status == V2CanonicalLessonStatus.locked
                ? OutlinedButton(
                    onPressed: null,
                    child: Text(_lessonActionLabel(status)),
                  )
                : FilledButton(
                    key: ValueKey<String>(
                      'open_foundation_pilot_${lesson.lessonId}',
                    ),
                    onPressed: () => _openLesson(lesson.lessonId),
                    child: Text(_lessonActionLabel(status)),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FoundationStageConfig {
  final String stageLabel;
  final String lessonsLabel;
  final String title;
  final String summary;
  final List<V2MicroLesson> lessons;

  const _FoundationStageConfig({
    required this.stageLabel,
    required this.lessonsLabel,
    required this.title,
    required this.summary,
    required this.lessons,
  });
}
