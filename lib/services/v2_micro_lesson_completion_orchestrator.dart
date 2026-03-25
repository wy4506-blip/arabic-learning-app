import '../data/v2_micro_lesson_catalog.dart';
import '../models/learning_state_models.dart';
import '../models/review_models.dart';
import '../models/v2_lesson_progress_models.dart';
import '../models/v2_micro_lesson.dart';
import 'learning_state_service.dart';
import 'lesson_progress_service.dart';
import 'v2_learning_snapshot_service.dart';

class V2MicroPracticeOutcome {
  final String itemId;
  final bool passed;
  final double score;

  const V2MicroPracticeOutcome({
    required this.itemId,
    required this.passed,
    this.score = 1.0,
  });
}

class V2MicroLessonCompletionSummary {
  final String learnedOutcome;
  final List<String> achievedObjectives;
  final List<String> unstableObjectives;
  final String reviewSummary;
  final String nextStepSummary;

  const V2MicroLessonCompletionSummary({
    required this.learnedOutcome,
    required this.achievedObjectives,
    required this.unstableObjectives,
    required this.reviewSummary,
    required this.nextStepSummary,
  });
}

class V2MicroLessonCompletionResult {
  final String lessonId;
  final V2CanonicalLessonStatus previousStatus;
  final V2CanonicalLessonStatus currentStatus;
  final List<V2ObjectiveProgressRecord> updatedObjectives;
  final List<V2ReviewSeedRecord> createdReviewSeeds;
  final int dueReviewCount;
  final V2RecommendedAction recommendedAction;
  final String? recommendedLessonId;
  final V2MicroLessonCompletionSummary completionSummary;

  const V2MicroLessonCompletionResult({
    required this.lessonId,
    required this.previousStatus,
    required this.currentStatus,
    required this.updatedObjectives,
    required this.createdReviewSeeds,
    required this.dueReviewCount,
    required this.recommendedAction,
    required this.recommendedLessonId,
    required this.completionSummary,
  });
}

class V2MicroLessonEvidenceEvaluation {
  final bool targetReached;
  final int attemptedPracticeCount;
  final double? averageScore;
  final bool meetsMinimumPracticeCount;
  final bool meetsPassThreshold;
  final List<String> unmetRequiredPracticeItemIds;
  final List<String> unmetRequiredObjectiveIds;

  const V2MicroLessonEvidenceEvaluation({
    required this.targetReached,
    required this.attemptedPracticeCount,
    required this.averageScore,
    required this.meetsMinimumPracticeCount,
    required this.meetsPassThreshold,
    required this.unmetRequiredPracticeItemIds,
    required this.unmetRequiredObjectiveIds,
  });
}

class V2MicroLessonEvidenceEvaluator {
  const V2MicroLessonEvidenceEvaluator._();

  static V2MicroLessonEvidenceEvaluation evaluate({
    required V2MicroLesson lesson,
    required List<V2MicroPracticeOutcome> practiceOutcomes,
    required List<V2ObjectiveProgressRecord> objectiveResults,
    required bool confirmationPassed,
  }) {
    final completionRule = lesson.completionRule;
    final resolvedRequiredPracticeItemIds =
        completionRule.requiredPracticeItemIds.isEmpty
            ? lesson.practiceItems
                .map((item) => item.itemId)
                .toList(growable: false)
            : completionRule.requiredPracticeItemIds;
    final resolvedRequiredObjectiveIds =
        completionRule.requiredObjectiveIds.isEmpty
            ? lesson.objectives
                .map((objective) => objective.objectiveId)
                .toList(growable: false)
            : completionRule.requiredObjectiveIds;
    final passedPracticeIds = practiceOutcomes
        .where((outcome) => outcome.passed)
        .map((outcome) => outcome.itemId)
        .toSet();
    final objectiveResultsById = <String, V2ObjectiveProgressRecord>{
      for (final result in objectiveResults) result.objectiveId: result,
    };
    final unmetRequiredPracticeItemIds = resolvedRequiredPracticeItemIds
        .where((itemId) => !passedPracticeIds.contains(itemId))
        .toList(growable: false);
    final unmetRequiredObjectiveIds = resolvedRequiredObjectiveIds
        .where(
          (objectiveId) =>
              objectiveResultsById[objectiveId]?.reachedThreshold != true,
        )
        .toList(growable: false);
    final attemptedPracticeCount = practiceOutcomes.length;
    final averageScore = _averageScore(practiceOutcomes);
    final meetsMinimumPracticeCount =
        attemptedPracticeCount >= completionRule.minimumPracticeCount;
    final meetsPassThreshold = averageScore != null &&
        averageScore >= completionRule.passThreshold;

    return V2MicroLessonEvidenceEvaluation(
      targetReached: confirmationPassed &&
          meetsMinimumPracticeCount &&
          meetsPassThreshold &&
          unmetRequiredPracticeItemIds.isEmpty &&
          unmetRequiredObjectiveIds.isEmpty,
      attemptedPracticeCount: attemptedPracticeCount,
      averageScore: averageScore,
      meetsMinimumPracticeCount: meetsMinimumPracticeCount,
      meetsPassThreshold: meetsPassThreshold,
      unmetRequiredPracticeItemIds: unmetRequiredPracticeItemIds,
      unmetRequiredObjectiveIds: unmetRequiredObjectiveIds,
    );
  }

  static double? _averageScore(List<V2MicroPracticeOutcome> practiceOutcomes) {
    if (practiceOutcomes.isEmpty) {
      return null;
    }
    final total = practiceOutcomes.fold<double>(
      0,
      (sum, outcome) => sum + outcome.score,
    );
    return total / practiceOutcomes.length;
  }
}

class V2MicroLessonCompletionOrchestrator {
  const V2MicroLessonCompletionOrchestrator._();

  static Future<V2MicroLessonCompletionResult> completeLesson({
    required String lessonId,
    required List<V2MicroPracticeOutcome> practiceOutcomes,
    bool confirmationPassed = true,
    DateTime? now,
  }) async {
    final moment = now ?? DateTime.now();
    final lesson = _lessonById(lessonId);
    final lessonTrack = _lessonTrackFor(lessonId);
    final previousRecords = await LessonProgressService.getAllRecords();
    final previousStates = await LearningStateService.getAllStates();
    final previousSnapshot = V2LearningSnapshotService.buildSnapshot(
      lessons: lessonTrack,
      lessonRecords: previousRecords,
      learningStates: previousStates,
    );
    final previousStatus = previousSnapshot.lessonStatusFor(lessonId);

    if (previousStatus == V2CanonicalLessonStatus.locked) {
      throw StateError('Micro lesson is locked: $lessonId');
    }

    if (!previousStatus.isStartedLike) {
      await LessonProgressService.markLessonStarted(
        lessonId: lessonId,
        sourceLessonIds: lesson.sourceLessonIds,
      );
    }

    final objectiveResults = _buildObjectiveResults(
      lesson: lesson,
      practiceOutcomes: practiceOutcomes,
      confirmationPassed: confirmationPassed,
      evaluatedAt: moment,
    );
    final evidenceEvaluation = V2MicroLessonEvidenceEvaluator.evaluate(
      lesson: lesson,
      practiceOutcomes: practiceOutcomes,
      objectiveResults: objectiveResults,
      confirmationPassed: confirmationPassed,
    );
    final nextSuggestedLessonId = _firstNextLessonIdHint(lesson);

    await LessonProgressService.applyEvaluation(
      lessonId: lessonId,
      evaluation: LessonCompletionEvaluation(
        completedBlockIds: practiceOutcomes
            .map((outcome) => outcome.itemId)
            .toList(growable: false),
        currentScore: evidenceEvaluation.averageScore,
        confirmationPassed: confirmationPassed,
        targetReached: evidenceEvaluation.targetReached,
        nextRecommendedLessonId: nextSuggestedLessonId,
        objectiveResults: objectiveResults,
      ),
    );

    final generatedSeeds = _buildGeneratedSeeds(
      lesson: lesson,
      objectiveResults: objectiveResults,
      practiceOutcomes: practiceOutcomes,
      now: moment,
    );

    for (final generatedSeed in generatedSeeds) {
      await LearningStateService.upsertLearningState(
        contentId: generatedSeed.record.reviewId,
        type: _contentTypeFor(generatedSeed.record.objectType),
        objectType: generatedSeed.record.objectType,
        stage: generatedSeed.record.initialStage,
        lessonId: lesson.lessonId,
        lastViewedAt: moment,
        lastStudiedAt: moment,
        nextReviewAt: generatedSeed.record.dueAt,
        isStarted: true,
        isCompleted: true,
        needsReview: generatedSeed.record.initialStage == LearningStage.weak ||
            !generatedSeed.record.dueAt.isAfter(moment),
        isWeak: generatedSeed.record.initialStage == LearningStage.weak,
        reviewPriority: _priorityForSeedKind(generatedSeed.rule.seedKind),
        lapseCount:
            generatedSeed.record.initialStage == LearningStage.weak ? 1 : 0,
      );
    }

    if (generatedSeeds.isNotEmpty) {
      await LessonProgressService.attachReviewSeeds(
        lessonId: lessonId,
        seeds: generatedSeeds
            .map((generatedSeed) => generatedSeed.record)
            .toList(growable: false),
      );
    }

    final currentRecords = await LessonProgressService.getAllRecords();
    final currentStates = await LearningStateService.getAllStates();
    final currentSnapshot = V2LearningSnapshotService.buildSnapshot(
      lessons: lessonTrack,
      lessonRecords: currentRecords,
      learningStates: currentStates,
    );
    final currentStatus = currentSnapshot.lessonStatusFor(lessonId);
    final createdReviewSeeds = generatedSeeds
        .map((generatedSeed) => generatedSeed.record)
        .toList(growable: false);

    return V2MicroLessonCompletionResult(
      lessonId: lessonId,
      previousStatus: previousStatus,
      currentStatus: currentStatus,
      updatedObjectives: objectiveResults,
      createdReviewSeeds: createdReviewSeeds,
      dueReviewCount: currentSnapshot.dueReviewItems.length,
      recommendedAction: currentSnapshot.recommendedAction,
      recommendedLessonId: currentSnapshot.recommendedLessonId,
      completionSummary: _buildCompletionSummary(
        lesson: lesson,
        objectiveResults: objectiveResults,
        createdReviewSeeds: createdReviewSeeds,
        recommendedAction: currentSnapshot.recommendedAction,
      ),
    );
  }

  static Future<V2MicroLessonCompletionResult> completePreviewLesson({
    required V2MicroLesson lesson,
    required List<V2MicroPracticeOutcome> practiceOutcomes,
    bool confirmationPassed = true,
    DateTime? now,
  }) async {
    final moment = now ?? DateTime.now();
    final objectiveResults = _buildObjectiveResults(
      lesson: lesson,
      practiceOutcomes: practiceOutcomes,
      confirmationPassed: confirmationPassed,
      evaluatedAt: moment,
    );
    final evidenceEvaluation = V2MicroLessonEvidenceEvaluator.evaluate(
      lesson: lesson,
      practiceOutcomes: practiceOutcomes,
      objectiveResults: objectiveResults,
      confirmationPassed: confirmationPassed,
    );
    final generatedSeeds = _buildGeneratedSeeds(
      lesson: lesson,
      objectiveResults: objectiveResults,
      practiceOutcomes: practiceOutcomes,
      now: moment,
    );
    final recommendedAction = _previewRecommendedAction(
      lesson: lesson,
      evidenceEvaluation: evidenceEvaluation,
    );
    final createdReviewSeeds = generatedSeeds
        .map((generatedSeed) => generatedSeed.record)
        .toList(growable: false);

    return V2MicroLessonCompletionResult(
      lessonId: lesson.lessonId,
      previousStatus: V2CanonicalLessonStatus.notStarted,
      currentStatus: _previewStatusFor(evidenceEvaluation),
      updatedObjectives: objectiveResults,
      createdReviewSeeds: createdReviewSeeds,
      dueReviewCount: createdReviewSeeds
          .where((seed) => !seed.dueAt.isAfter(moment))
          .length,
      recommendedAction: recommendedAction,
      recommendedLessonId: recommendedAction.targetLessonId,
      completionSummary: _buildCompletionSummary(
        lesson: lesson,
        objectiveResults: objectiveResults,
        createdReviewSeeds: createdReviewSeeds,
        recommendedAction: recommendedAction,
      ),
    );
  }

  static V2MicroLesson _lessonById(String lessonId) {
    return v2MicroLessonById(lessonId);
  }

  static List<V2MicroLesson> _lessonTrackFor(String lessonId) {
    return v2MicroLessonTrackForLessonId(lessonId);
  }

  static List<V2ObjectiveProgressRecord> _buildObjectiveResults({
    required V2MicroLesson lesson,
    required List<V2MicroPracticeOutcome> practiceOutcomes,
    required bool confirmationPassed,
    required DateTime evaluatedAt,
  }) {
    final outcomesByItemId = <String, V2MicroPracticeOutcome>{
      for (final outcome in practiceOutcomes) outcome.itemId: outcome,
    };
    final results = <V2ObjectiveProgressRecord>[];

    for (final objective in lesson.objectives) {
      final relatedItems = lesson.practiceItems
          .where((item) => item.objectiveIds.contains(objective.objectiveId))
          .toList(growable: false);
      final attemptedOutcomes = relatedItems
          .map((item) => outcomesByItemId[item.itemId])
          .whereType<V2MicroPracticeOutcome>()
          .toList(growable: false);
      final passedCount =
          attemptedOutcomes.where((outcome) => outcome.passed).length;
      final accuracy =
          relatedItems.isEmpty ? 0.0 : passedCount / relatedItems.length;

      final V2ObjectiveStatus status;
      if (attemptedOutcomes.isEmpty) {
        status = V2ObjectiveStatus.notStarted;
      } else if (accuracy >= objective.masteryThreshold && confirmationPassed) {
        status = V2ObjectiveStatus.reached;
      } else {
        status = V2ObjectiveStatus.weak;
      }

      results.add(
        V2ObjectiveProgressRecord(
          lessonId: lesson.lessonId,
          objectiveId: objective.objectiveId,
          status: status,
          accuracy: accuracy,
          evidenceCount: attemptedOutcomes.length,
          threshold: objective.masteryThreshold,
          lastEvaluatedAt: evaluatedAt,
        ),
      );
    }

    return results;
  }

  static List<_GeneratedReviewSeed> _buildGeneratedSeeds({
    required V2MicroLesson lesson,
    required List<V2ObjectiveProgressRecord> objectiveResults,
    required List<V2MicroPracticeOutcome> practiceOutcomes,
    required DateTime now,
  }) {
    final weakObjectiveIds = objectiveResults
        .where((result) => !result.reachedThreshold)
        .map((result) => result.objectiveId)
        .toSet();
    final failedItemRefs = <String>{};
    final outcomeByItemId = <String, V2MicroPracticeOutcome>{
      for (final outcome in practiceOutcomes) outcome.itemId: outcome,
    };

    for (final item in lesson.practiceItems) {
      final outcome = outcomeByItemId[item.itemId];
      if (outcome != null && !outcome.passed) {
        failedItemRefs.add(item.itemRefId);
      }
    }

    final generated = <_GeneratedReviewSeed>[];
    for (final rule in lesson.reviewSeedRules) {
      final weakMatch = _ruleMatchesWeak(
        rule: rule,
        weakObjectiveIds: weakObjectiveIds,
        failedItemRefs: failedItemRefs,
      );
      if (!_shouldCreateSeed(rule: rule, weakMatch: weakMatch)) {
        continue;
      }

      final initialStage =
          weakMatch ? LearningStage.weak : LearningStage.learning;
      final dueAt = weakMatch ? now : now.add(rule.dueAfter);
      generated.add(
        _GeneratedReviewSeed(
          rule: rule,
          record: V2ReviewSeedRecord(
            reviewId: _buildContentId(
              objectType: rule.reviewObjectType,
              sourceItemRefId: rule.sourceItemRefId,
            ),
            lessonId: lesson.lessonId,
            objectType: rule.reviewObjectType,
            actionType: rule.reviewActionType,
            itemRefId: rule.sourceItemRefId,
            initialStage: initialStage,
            dueAt: dueAt,
          ),
        ),
      );
    }

    return generated;
  }

  static bool _ruleMatchesWeak({
    required V2MicroReviewSeedRule rule,
    required Set<String> weakObjectiveIds,
    required Set<String> failedItemRefs,
  }) {
    if (rule.objectiveIds.any(weakObjectiveIds.contains)) {
      return true;
    }
    if (failedItemRefs.contains(rule.sourceItemRefId)) {
      return true;
    }
    if (rule.sourceItemRefId.contains('|')) {
      final parts = rule.sourceItemRefId.split('|');
      return parts.any(failedItemRefs.contains);
    }
    return false;
  }

  static bool _shouldCreateSeed({
    required V2MicroReviewSeedRule rule,
    required bool weakMatch,
  }) {
    if (rule.onlyIfWeak) {
      return weakMatch;
    }
    if (rule.seedKind == V2ReviewSeedKind.weakPoint ||
        rule.seedKind == V2ReviewSeedKind.mistake) {
      return weakMatch;
    }
    return true;
  }

  static String? _firstNextLessonIdHint(V2MicroLesson lesson) {
    for (final hint in lesson.nextActionHints) {
      if (hint.targetLessonId != null &&
          hint.targetLessonId!.trim().isNotEmpty) {
        return hint.targetLessonId;
      }
    }
    return null;
  }

  static V2CanonicalLessonStatus _previewStatusFor(
    V2MicroLessonEvidenceEvaluation evidenceEvaluation,
  ) {
    if (evidenceEvaluation.targetReached) {
      return V2CanonicalLessonStatus.completed;
    }
    if (evidenceEvaluation.meetsMinimumPracticeCount) {
      return V2CanonicalLessonStatus.coreCompleted;
    }
    return V2CanonicalLessonStatus.inProgress;
  }

  static V2RecommendedAction _previewRecommendedAction({
    required V2MicroLesson lesson,
    required V2MicroLessonEvidenceEvaluation evidenceEvaluation,
  }) {
    if (evidenceEvaluation.targetReached) {
      final successfulHint = lesson.nextActionHints.isNotEmpty
          ? lesson.nextActionHints.first
          : null;
      if (successfulHint != null) {
        return V2RecommendedAction(
          actionType: successfulHint.actionType,
          reason: successfulHint.reason,
          targetLessonId: successfulHint.targetLessonId,
        );
      }
      return const V2RecommendedAction(
        actionType: V2RecommendedActionType.noAction,
        reason: 'Preview completed without a live next lesson target.',
      );
    }

    if (evidenceEvaluation.meetsMinimumPracticeCount) {
      return const V2RecommendedAction(
        actionType: V2RecommendedActionType.startReview,
        reason: 'Preview result suggests reviewing the weak point before moving on.',
      );
    }

    return const V2RecommendedAction(
      actionType: V2RecommendedActionType.continueLesson,
      reason: 'Preview result suggests continuing the lesson until the recall-bearing step is stable.',
    );
  }

  static V2MicroLessonCompletionSummary _buildCompletionSummary({
    required V2MicroLesson lesson,
    required List<V2ObjectiveProgressRecord> objectiveResults,
    required List<V2ReviewSeedRecord> createdReviewSeeds,
    required V2RecommendedAction recommendedAction,
  }) {
    final achievedObjectives = lesson.objectives
        .where(
          (objective) => objectiveResults.any(
            (result) =>
                result.objectiveId == objective.objectiveId &&
                result.reachedThreshold,
          ),
        )
        .map((objective) => objective.summary)
        .toList(growable: false);
    final unstableObjectives = lesson.objectives
        .where(
          (objective) => objectiveResults.any(
            (result) =>
                result.objectiveId == objective.objectiveId &&
                !result.reachedThreshold,
          ),
        )
        .map((objective) => objective.summary)
        .toList(growable: false);
    final reviewSummary = createdReviewSeeds.isEmpty
        ? 'No new review items were created from this lesson.'
        : 'This lesson created ${createdReviewSeeds.length} review seeds.';

    return V2MicroLessonCompletionSummary(
      learnedOutcome: lesson.outcomeSummary,
      achievedObjectives: achievedObjectives,
      unstableObjectives: unstableObjectives,
      reviewSummary: reviewSummary,
      nextStepSummary: _nextStepSummary(recommendedAction),
    );
  }

  static String _nextStepSummary(V2RecommendedAction action) {
    switch (action.actionType) {
      case V2RecommendedActionType.startLesson:
        return 'Next, continue into the next lesson.';
      case V2RecommendedActionType.continueLesson:
        return 'Next, continue the lesson already in progress.';
      case V2RecommendedActionType.startReview:
        return 'Next, clear the due or weak review item first.';
      case V2RecommendedActionType.startConsolidation:
        return 'Next, move into a short consolidation step.';
      case V2RecommendedActionType.startNextPhase:
        return 'Next, move into the next phase.';
      case V2RecommendedActionType.noAction:
        return 'There is no new action to take right now.';
    }
  }

  static ReviewContentType _contentTypeFor(ReviewObjectType objectType) {
    switch (objectType) {
      case ReviewObjectType.letterName:
      case ReviewObjectType.letterSound:
      case ReviewObjectType.letterForm:
        return ReviewContentType.alphabet;
      case ReviewObjectType.symbolReading:
        return ReviewContentType.pronunciation;
      case ReviewObjectType.wordReading:
        return ReviewContentType.word;
      case ReviewObjectType.confusionPair:
        return ReviewContentType.pair;
      case ReviewObjectType.sentencePattern:
        return ReviewContentType.sentence;
      case ReviewObjectType.grammarReference:
        return ReviewContentType.grammar;
    }
  }

  static int _priorityForSeedKind(V2ReviewSeedKind seedKind) {
    switch (seedKind) {
      case V2ReviewSeedKind.newVocabulary:
        return 1;
      case V2ReviewSeedKind.coreExpression:
        return 2;
      case V2ReviewSeedKind.weakPoint:
        return 4;
      case V2ReviewSeedKind.mistake:
        return 4;
      case V2ReviewSeedKind.confusionPair:
        return 3;
    }
  }

  static String _buildContentId({
    required ReviewObjectType objectType,
    required String sourceItemRefId,
  }) {
    switch (objectType) {
      case ReviewObjectType.letterName:
        return buildLetterNameContentId(sourceItemRefId);
      case ReviewObjectType.letterSound:
        return buildLetterSoundContentId(sourceItemRefId);
      case ReviewObjectType.letterForm:
        return buildLetterFormContentId(sourceItemRefId);
      case ReviewObjectType.symbolReading:
        final parts = sourceItemRefId.split('|');
        if (parts.length >= 2) {
          return buildSymbolReadingContentId(parts.first, parts.last);
        }
        return buildSymbolReadingContentId(sourceItemRefId, sourceItemRefId);
      case ReviewObjectType.wordReading:
        return buildWordContentId(sourceItemRefId);
      case ReviewObjectType.confusionPair:
        final parts = sourceItemRefId.split('|');
        if (parts.length >= 2) {
          return buildConfusionPairContentId(parts.first, parts.last);
        }
        return buildConfusionPairContentId(sourceItemRefId, sourceItemRefId);
      case ReviewObjectType.sentencePattern:
        return buildSentenceContentId(sourceItemRefId);
      case ReviewObjectType.grammarReference:
        return buildGrammarContentId(sourceItemRefId);
    }
  }
}

class _GeneratedReviewSeed {
  final V2MicroReviewSeedRule rule;
  final V2ReviewSeedRecord record;

  const _GeneratedReviewSeed({
    required this.rule,
    required this.record,
  });
}




