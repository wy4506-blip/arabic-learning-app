import '../data/v2_micro_lessons.dart';
import '../models/app_settings.dart';
import '../models/learning_state_models.dart';
import '../models/review_models.dart';
import '../models/v2_lesson_progress_models.dart';
import '../models/v2_micro_lesson.dart';
import 'learning_state_service.dart';
import 'lesson_progress_service.dart';
import 'progress_service.dart';
import 'review_service.dart';

class V2DueReviewItem {
  final String contentId;
  final String lessonId;
  final ReviewObjectType objectType;
  final ReviewActionType actionType;
  final int priority;
  final bool isWeak;
  final DateTime? dueAt;

  const V2DueReviewItem({
    required this.contentId,
    required this.lessonId,
    required this.objectType,
    required this.actionType,
    required this.priority,
    required this.isWeak,
    required this.dueAt,
  });
}

class V2RecommendedAction {
  final V2RecommendedActionType actionType;
  final String reason;
  final String? targetLessonId;
  final String? targetPhaseId;

  const V2RecommendedAction({
    required this.actionType,
    required this.reason,
    this.targetLessonId,
    this.targetPhaseId,
  });
}

enum V2HomeEntryState {
  reviewFirst,
  continueMainline,
  completedForToday,
}

class V2LearningSnapshot {
  final Map<String, V2CanonicalLessonStatus> lessonStatuses;
  final Map<String, V2PhaseStatus> phaseStatuses;
  final List<ProgressStageSummary> stageSummaries;
  final Map<String, V2ObjectiveProgressRecord> objectiveProgress;
  final String? recommendedLessonId;
  final V2RecommendedAction recommendedAction;
  final V2HomeEntryState homeEntryState;
  final String? currentPhaseId;
  final List<V2DueReviewItem> dueReviewItems;

  const V2LearningSnapshot({
    required this.lessonStatuses,
    required this.phaseStatuses,
    required this.stageSummaries,
    required this.objectiveProgress,
    required this.recommendedLessonId,
    required this.recommendedAction,
    required this.homeEntryState,
    required this.currentPhaseId,
    required this.dueReviewItems,
  });

  V2CanonicalLessonStatus lessonStatusFor(String lessonId) {
    return lessonStatuses[lessonId] ?? V2CanonicalLessonStatus.notStarted;
  }
}

class V2LearningSnapshotService {
  const V2LearningSnapshotService._();

  static Future<V2LearningSnapshot> getSnapshot({
    List<V2MicroLesson> lessons = v2PilotMicroLessons,
  }) async {
    final records = await LessonProgressService.getAllRecords();
    final learningStates = await LearningStateService.getAllStates();
    final reviewEntry = await ReviewService.getEntrySnapshot(
      const AppSettings(
        appLanguage: AppLanguage.en,
        meaningLanguage: ContentLanguage.en,
        showTransliteration: true,
      ),
    );
    return buildSnapshot(
      lessons: lessons,
      lessonRecords: records,
      learningStates: learningStates,
      reviewEntry: reviewEntry,
    );
  }

  static V2LearningSnapshot buildSnapshot({
    required List<V2MicroLesson> lessons,
    required Map<String, V2LessonProgressRecord> lessonRecords,
    required Map<String, LearningContentState> learningStates,
    ReviewEntrySnapshot? reviewEntry,
  }) {
    final lessonStatuses = <String, V2CanonicalLessonStatus>{};
    final objectiveProgress = <String, V2ObjectiveProgressRecord>{};
    final allowedLessonIds =
        lessons.map((lesson) => lesson.lessonId).toSet();
    final dueReviewItems = _collectDueReviewItems(
      learningStates,
      allowedLessonIds: allowedLessonIds,
    );

    for (final record in lessonRecords.values) {
      for (final objective in record.objectiveResults) {
        objectiveProgress[objective.objectiveId] = objective;
      }
    }

    for (final lesson in lessons) {
      final record = lessonRecords[lesson.lessonId];
      final hasPendingReview = dueReviewItems.any(
        (item) => item.lessonId == lesson.lessonId,
      );
      final isEntryLocked = !_entryConditionMet(
        lesson: lesson,
        lessonStatuses: lessonStatuses,
        objectiveProgress: objectiveProgress,
        hasDueReview: (reviewEntry?.formalReviewCount ?? 0) > 0,
      );
      var status = canonicalLessonStatusFromProgress(record?.status);
      if (record == null && isEntryLocked) {
        status = V2CanonicalLessonStatus.locked;
      }
      if (record == null && !isEntryLocked) {
        status = V2CanonicalLessonStatus.notStarted;
      }
      if (hasPendingReview &&
          (status == V2CanonicalLessonStatus.completed ||
              status == V2CanonicalLessonStatus.coreCompleted ||
              status == V2CanonicalLessonStatus.mastered)) {
        status = V2CanonicalLessonStatus.dueForReview;
      }
      lessonStatuses[lesson.lessonId] = status;
    }

    final phaseBuckets = <String, List<V2CanonicalLessonStatus>>{};
    for (final lesson in lessons) {
      final bucket = phaseBuckets.putIfAbsent(
        lesson.phaseId,
        () => <V2CanonicalLessonStatus>[],
      );
      bucket.add(
        lessonStatuses[lesson.lessonId] ?? V2CanonicalLessonStatus.notStarted,
      );
    }

    final phaseStatuses = <String, V2PhaseStatus>{
      for (final entry in phaseBuckets.entries)
        entry.key: ProgressService.resolvePhaseStatus(
          entry.value.map(_toProgressStatus).toList(growable: false),
        ),
    };

    final currentPhaseId = _resolveCurrentPhaseId(
      lessons: lessons,
      lessonStatuses: lessonStatuses,
      phaseStatuses: phaseStatuses,
    );
    final stageSummaries = _buildStageSummaries(
      lessons: lessons,
      lessonStatuses: lessonStatuses,
      phaseStatuses: phaseStatuses,
      currentPhaseId: currentPhaseId,
    );
    final recommendedLessonId = _resolveRecommendedLessonId(
      lessons: lessons,
      lessonStatuses: lessonStatuses,
      currentPhaseId: currentPhaseId,
    );
    final recommendedAction = _resolveRecommendedAction(
      lessons: lessons,
      lessonStatuses: lessonStatuses,
      phaseStatuses: phaseStatuses,
      currentPhaseId: currentPhaseId,
      recommendedLessonId: recommendedLessonId,
      dueReviewItems: dueReviewItems,
    );
    final homeEntryState = _resolveHomeEntryState(
      recommendedAction: recommendedAction,
    );

    return V2LearningSnapshot(
      lessonStatuses: lessonStatuses,
      phaseStatuses: phaseStatuses,
      stageSummaries: stageSummaries,
      objectiveProgress: objectiveProgress,
      recommendedLessonId: recommendedLessonId,
      recommendedAction: recommendedAction,
      homeEntryState: homeEntryState,
      currentPhaseId: currentPhaseId,
      dueReviewItems: dueReviewItems,
    );
  }

  static List<V2DueReviewItem> _collectDueReviewItems(
    Map<String, LearningContentState> learningStates, {
    required Set<String> allowedLessonIds,
  }) {
    final now = DateTime.now();
    final items = learningStates.values
        .where(
          (state) =>
              state.lessonId != null &&
              allowedLessonIds.contains(state.lessonId) &&
              state.isStarted &&
              (state.isWeak ||
                  state.isReviewDue ||
                  (state.needsReview &&
                      state.nextReviewAt != null &&
                      !state.nextReviewAt!.isAfter(now))),
        )
        .map(
          (state) => V2DueReviewItem(
            contentId: state.contentId,
            lessonId: state.lessonId!,
            objectType: state.objectType,
            actionType: _defaultReviewActionFor(state.objectType),
            priority: state.reviewPriority,
            isWeak: state.isWeak,
            dueAt: state.nextReviewAt,
          ),
        )
        .toList(growable: false)
      ..sort((left, right) => right.priority.compareTo(left.priority));
    return items;
  }

  static bool _entryConditionMet({
    required V2MicroLesson lesson,
    required Map<String, V2CanonicalLessonStatus> lessonStatuses,
    required Map<String, V2ObjectiveProgressRecord> objectiveProgress,
    required bool hasDueReview,
  }) {
    if (lesson.entryCondition.requiresDueReviewClear && hasDueReview) {
      return false;
    }
    for (final requiredLessonId in lesson.entryCondition.requiredLessonIds) {
      final status = lessonStatuses[requiredLessonId];
      if (status == null || !status.canAdvanceMainline) {
        return false;
      }
    }
    for (final requiredObjectiveId
        in lesson.entryCondition.requiredObjectiveIds) {
      final record = objectiveProgress[requiredObjectiveId];
      if (record == null || !record.reachedThreshold) {
        return false;
      }
    }
    return true;
  }

  static String? _resolveCurrentPhaseId({
    required List<V2MicroLesson> lessons,
    required Map<String, V2CanonicalLessonStatus> lessonStatuses,
    required Map<String, V2PhaseStatus> phaseStatuses,
  }) {
    for (final lesson in lessons) {
      final status = lessonStatuses[lesson.lessonId];
      if (status == V2CanonicalLessonStatus.inProgress ||
          status == V2CanonicalLessonStatus.coreCompleted) {
        return lesson.phaseId;
      }
    }
    for (final lesson in lessons) {
      final status = lessonStatuses[lesson.lessonId];
      if (status == V2CanonicalLessonStatus.notStarted) {
        return lesson.phaseId;
      }
    }
    for (final entry in phaseStatuses.entries) {
      if (entry.value == V2PhaseStatus.consolidation) {
        return entry.key;
      }
    }
    return lessons.isEmpty ? null : lessons.last.phaseId;
  }

  static List<ProgressStageSummary> _buildStageSummaries({
    required List<V2MicroLesson> lessons,
    required Map<String, V2CanonicalLessonStatus> lessonStatuses,
    required Map<String, V2PhaseStatus> phaseStatuses,
    required String? currentPhaseId,
  }) {
    final grouped = <String, List<V2MicroLesson>>{};
    for (final lesson in lessons) {
      grouped.putIfAbsent(lesson.phaseId, () => <V2MicroLesson>[]).add(lesson);
    }
    return grouped.entries.map((entry) {
      final statuses = entry.value
          .map((lesson) =>
              lessonStatuses[lesson.lessonId] ??
              V2CanonicalLessonStatus.notStarted)
          .toList(growable: false);
      return ProgressStageSummary(
        stageId: entry.key,
        totalLessonCount: entry.value.length,
        startedLessonCount:
            statuses.where((status) => status.isStartedLike).length,
        completedLessonCount:
            statuses.where((status) => status.isCompletedLike).length,
        isCurrent: entry.key == currentPhaseId,
        status: phaseStatuses[entry.key] ?? V2PhaseStatus.notStarted,
        reviewDueCount: statuses.where((status) => status.needsReview).length,
      );
    }).toList(growable: false);
  }

  static String? _resolveRecommendedLessonId({
    required List<V2MicroLesson> lessons,
    required Map<String, V2CanonicalLessonStatus> lessonStatuses,
    required String? currentPhaseId,
  }) {
    for (final lesson in lessons) {
      final status =
          lessonStatuses[lesson.lessonId] ?? V2CanonicalLessonStatus.notStarted;
      if (status == V2CanonicalLessonStatus.inProgress) {
        return lesson.lessonId;
      }
    }
    for (final lesson in lessons) {
      final status =
          lessonStatuses[lesson.lessonId] ?? V2CanonicalLessonStatus.notStarted;
      if (lesson.phaseId == currentPhaseId &&
          status == V2CanonicalLessonStatus.notStarted) {
        return lesson.lessonId;
      }
    }
    for (final lesson in lessons) {
      final status =
          lessonStatuses[lesson.lessonId] ?? V2CanonicalLessonStatus.notStarted;
      if (status == V2CanonicalLessonStatus.notStarted) {
        return lesson.lessonId;
      }
    }
    return null;
  }

  static V2RecommendedAction _resolveRecommendedAction({
    required List<V2MicroLesson> lessons,
    required Map<String, V2CanonicalLessonStatus> lessonStatuses,
    required Map<String, V2PhaseStatus> phaseStatuses,
    required String? currentPhaseId,
    required String? recommendedLessonId,
    required List<V2DueReviewItem> dueReviewItems,
  }) {
    if (dueReviewItems.isNotEmpty) {
      return V2RecommendedAction(
        actionType: V2RecommendedActionType.startReview,
        reason: 'review_due_first',
        targetLessonId: dueReviewItems.first.lessonId,
        targetPhaseId: currentPhaseId,
      );
    }

    for (final lesson in lessons) {
      final status =
          lessonStatuses[lesson.lessonId] ?? V2CanonicalLessonStatus.notStarted;
      if (status == V2CanonicalLessonStatus.inProgress) {
        return V2RecommendedAction(
          actionType: V2RecommendedActionType.continueLesson,
          reason: 'continue_in_progress_lesson',
          targetLessonId: lesson.lessonId,
          targetPhaseId: lesson.phaseId,
        );
      }
    }

    if (recommendedLessonId != null) {
      final lesson = lessons.firstWhere(
        (item) => item.lessonId == recommendedLessonId,
      );
      return V2RecommendedAction(
        actionType: V2RecommendedActionType.startLesson,
        reason: 'next_core_lesson',
        targetLessonId: recommendedLessonId,
        targetPhaseId: lesson.phaseId,
      );
    }

    if (currentPhaseId != null &&
        phaseStatuses[currentPhaseId] == V2PhaseStatus.consolidation) {
      return V2RecommendedAction(
        actionType: V2RecommendedActionType.startConsolidation,
        reason: 'phase_needs_consolidation',
        targetPhaseId: currentPhaseId,
      );
    }

    final nextPhase = phaseStatuses.entries
        .where((entry) => entry.value != V2PhaseStatus.completed);
    if (nextPhase.isNotEmpty) {
      return V2RecommendedAction(
        actionType: V2RecommendedActionType.startNextPhase,
        reason: 'advance_to_next_phase',
        targetPhaseId: nextPhase.first.key,
      );
    }

    return const V2RecommendedAction(
      actionType: V2RecommendedActionType.noAction,
      reason: 'no_action_available',
    );
  }

  static V2HomeEntryState _resolveHomeEntryState({
    required V2RecommendedAction recommendedAction,
  }) {
    switch (recommendedAction.actionType) {
      case V2RecommendedActionType.startReview:
        return V2HomeEntryState.reviewFirst;
      case V2RecommendedActionType.startLesson:
      case V2RecommendedActionType.continueLesson:
        return V2HomeEntryState.continueMainline;
      case V2RecommendedActionType.startConsolidation:
      case V2RecommendedActionType.startNextPhase:
      case V2RecommendedActionType.noAction:
        return V2HomeEntryState.completedForToday;
    }
  }

  static V2LessonStatus _toProgressStatus(V2CanonicalLessonStatus value) {
    switch (value) {
      case V2CanonicalLessonStatus.locked:
        return V2LessonStatus.locked;
      case V2CanonicalLessonStatus.notStarted:
        return V2LessonStatus.available;
      case V2CanonicalLessonStatus.inProgress:
        return V2LessonStatus.inProgress;
      case V2CanonicalLessonStatus.coreCompleted:
        return V2LessonStatus.coreCompleted;
      case V2CanonicalLessonStatus.completed:
        return V2LessonStatus.completed;
      case V2CanonicalLessonStatus.dueForReview:
        return V2LessonStatus.dueForReview;
      case V2CanonicalLessonStatus.mastered:
        return V2LessonStatus.mastered;
    }
  }

  static ReviewActionType _defaultReviewActionFor(ReviewObjectType objectType) {
    switch (objectType) {
      case ReviewObjectType.letterName:
        return ReviewActionType.read;
      case ReviewObjectType.letterSound:
        return ReviewActionType.listen;
      case ReviewObjectType.letterForm:
        return ReviewActionType.recognize;
      case ReviewObjectType.symbolReading:
        return ReviewActionType.listen;
      case ReviewObjectType.wordReading:
        return ReviewActionType.read;
      case ReviewObjectType.confusionPair:
        return ReviewActionType.distinguish;
      case ReviewObjectType.sentencePattern:
        return ReviewActionType.repeat;
      case ReviewObjectType.grammarReference:
        return ReviewActionType.read;
    }
  }
}

