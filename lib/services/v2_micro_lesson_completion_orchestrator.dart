import '../data/v2_micro_lessons.dart';
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
    final previousRecords = await LessonProgressService.getAllRecords();
    final previousStates = await LearningStateService.getAllStates();
    final previousSnapshot = V2LearningSnapshotService.buildSnapshot(
      lessons: v2PilotMicroLessons,
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
    final nextSuggestedLessonId = _firstNextLessonIdHint(lesson);

    await LessonProgressService.applyEvaluation(
      lessonId: lessonId,
      evaluation: LessonCompletionEvaluation(
        completedBlockIds: practiceOutcomes
            .map((outcome) => outcome.itemId)
            .toList(growable: false),
        currentScore: _averageScore(practiceOutcomes),
        confirmationPassed: confirmationPassed,
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
      lessons: v2PilotMicroLessons,
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

  static V2MicroLesson _lessonById(String lessonId) {
    for (final lesson in v2PilotMicroLessons) {
      if (lesson.lessonId == lessonId) {
        return lesson;
      }
    }
    throw StateError('Unknown V2 micro lesson: $lessonId');
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
        ? '本课暂未生成新的复习项。'
        : '本课已生成 ${createdReviewSeeds.length} 个复习种子。';

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
        return '下一步建议继续进入新课。';
      case V2RecommendedActionType.continueLesson:
        return '下一步建议先继续当前进行中的课程。';
      case V2RecommendedActionType.startReview:
        return '下一步建议先处理到期或薄弱复习。';
      case V2RecommendedActionType.startConsolidation:
        return '下一步建议先做阶段巩固。';
      case V2RecommendedActionType.startNextPhase:
        return '下一步建议进入下一阶段。';
      case V2RecommendedActionType.noAction:
        return '当前没有新的主动作可执行。';
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
