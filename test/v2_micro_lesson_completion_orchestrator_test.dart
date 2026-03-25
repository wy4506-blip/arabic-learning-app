import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arabic_learning_app/data/v2_micro_lesson_catalog.dart';
import 'package:arabic_learning_app/data/v2_micro_lessons.dart';
import 'package:arabic_learning_app/models/learning_state_models.dart';
import 'package:arabic_learning_app/models/review_models.dart';
import 'package:arabic_learning_app/models/v2_lesson_progress_models.dart';
import 'package:arabic_learning_app/models/v2_micro_lesson.dart';
import 'package:arabic_learning_app/services/learning_state_service.dart';
import 'package:arabic_learning_app/services/lesson_progress_service.dart';
import 'package:arabic_learning_app/services/v2_learning_snapshot_service.dart';
import 'package:arabic_learning_app/services/v2_micro_lesson_completion_orchestrator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const evidenceRuleLesson = V2MicroLesson(
    lessonId: 'V2-EVIDENCE-01',
    phaseId: 'phase_test',
    groupId: 'group_test',
    title: 'Evidence Rule Lesson',
    outcomeSummary: 'Collect only the minimum credible evidence.',
    estimatedMinutes: 6,
    lessonType: V2MicroLessonType.responseProduction,
    objectives: <V2MicroLessonObjective>[
      V2MicroLessonObjective(
        objectiveId: 'required_objective',
        summary: 'Required objective',
      ),
      V2MicroLessonObjective(
        objectiveId: 'supporting_objective',
        summary: 'Supporting objective',
      ),
    ],
    entryCondition: V2MicroLessonEntryCondition(),
    contentItems: <V2MicroContentItem>[],
    practiceItems: <V2MicroPracticeItem>[
      V2MicroPracticeItem(
        itemId: 'required_practice',
        type: V2MicroPracticeType.listenTap,
        prompt: 'Required practice',
        itemRefId: 'required_practice',
        reviewObjectType: ReviewObjectType.wordReading,
        reviewActionType: ReviewActionType.read,
      ),
      V2MicroPracticeItem(
        itemId: 'supporting_practice',
        type: V2MicroPracticeType.listenTap,
        prompt: 'Supporting practice',
        itemRefId: 'supporting_practice',
        reviewObjectType: ReviewObjectType.wordReading,
        reviewActionType: ReviewActionType.read,
      ),
    ],
    completionRule: V2MicroCompletionRule(
      requiredPracticeItemIds: <String>['required_practice'],
      requiredObjectiveIds: <String>['required_objective'],
      minimumPracticeCount: 1,
      passThreshold: 0.5,
    ),
    reviewSeedRules: <V2MicroReviewSeedRule>[],
    nextActionHints: <V2NextActionHint>[],
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await LessonProgressService.debugClearAll();
    await LearningStateService.saveAllStates(
      const <LearningContentState>[],
      notify: false,
    );
    await LearningStateService.saveAllPracticeStates(
      const <LearningPracticeState>[],
      notify: false,
    );
  });

  test('completion orchestrator advances recommendation after a clean pass',
      () async {
    final before = V2LearningSnapshotService.buildSnapshot(
      lessons: v2PilotMicroLessons,
      lessonRecords: const <String, V2LessonProgressRecord>{},
      learningStates: const <String, LearningContentState>{},
    );

    expect(before.recommendedLessonId, 'V2-ALPHA-CL-01');
    expect(before.recommendedAction.actionType,
        V2RecommendedActionType.startLesson);

    final result = await V2MicroLessonCompletionOrchestrator.completeLesson(
      lessonId: 'V2-ALPHA-CL-01',
      practiceOutcomes: const <V2MicroPracticeOutcome>[
        V2MicroPracticeOutcome(itemId: 'hear_tha', passed: true),
        V2MicroPracticeOutcome(itemId: 'hear_dhal', passed: true),
        V2MicroPracticeOutcome(itemId: 'say_zha', passed: true),
      ],
    );

    expect(result.lessonId, 'V2-ALPHA-CL-01');
    expect(result.previousStatus, V2CanonicalLessonStatus.notStarted);
    expect(result.currentStatus, V2CanonicalLessonStatus.completed);
    expect(result.updatedObjectives.every((item) => item.reachedThreshold),
        isTrue);
    expect(result.createdReviewSeeds, isNotEmpty);
    expect(result.dueReviewCount, 0);
    expect(result.recommendedLessonId, 'V2-BRIDGE-01');
    expect(result.recommendedAction.actionType,
        V2RecommendedActionType.startLesson);
    expect(result.completionSummary.learnedOutcome,
      contains('瀛﹀畬鍚庯紝浣犺兘鍚竻骞剁偣鍑?孬 / 匕 / 馗 杩欑粍涓変釜鏄撴贩瀛楁瘝'));
  });

  test(
      'weak completion switches recommendation to review first and back after review',
      () async {
    await LessonProgressService.saveRecord(
      const V2LessonProgressRecord(
        lessonId: 'V2-ALPHA-CL-01',
        status: V2LessonStatus.completed,
      ),
    );
    await LessonProgressService.saveRecord(
      const V2LessonProgressRecord(
        lessonId: 'V2-BRIDGE-01',
        status: V2LessonStatus.completed,
      ),
    );

    final result = await V2MicroLessonCompletionOrchestrator.completeLesson(
      lessonId: 'V2-U1-01',
      practiceOutcomes: const <V2MicroPracticeOutcome>[
        V2MicroPracticeOutcome(itemId: 'recognize_marhaban', passed: true),
        V2MicroPracticeOutcome(itemId: 'recognize_sabah', passed: false),
        V2MicroPracticeOutcome(itemId: 'recognize_salama', passed: true),
      ],
    );

    expect(result.currentStatus, V2CanonicalLessonStatus.dueForReview);
    expect(result.recommendedAction.actionType,
        V2RecommendedActionType.startReview);
    expect(result.recommendedAction.reason, 'review_due_first');
    expect(result.createdReviewSeeds, isNotEmpty);

    final weakSeed = result.createdReviewSeeds.firstWhere(
      (seed) => seed.initialStage == LearningStage.weak,
    );
    await LearningStateService.markReviewResult(
      contentId: weakSeed.reviewId,
      type: ReviewContentType.sentence,
      objectType: weakSeed.objectType,
      lessonId: 'V2-U1-01',
      remembered: true,
    );

    final afterReview = V2LearningSnapshotService.buildSnapshot(
      lessons: v2PilotMicroLessons,
      lessonRecords: await LessonProgressService.getAllRecords(),
      learningStates: await LearningStateService.getAllStates(),
    );

    expect(
      afterReview.lessonStatusFor('V2-U1-01'),
      V2CanonicalLessonStatus.coreCompleted,
    );
    expect(afterReview.recommendedLessonId, 'V2-U1-02');
    expect(afterReview.recommendedAction.actionType,
        V2RecommendedActionType.startLesson);
    expect(afterReview.recommendedAction.reason, 'next_core_lesson');
  });

  test('formal completion supports foundation catalog lessons', () async {
    final result = await V2MicroLessonCompletionOrchestrator.completeLesson(
      lessonId: 'V2-A1-01-PREVIEW',
      practiceOutcomes: const <V2MicroPracticeOutcome>[
        V2MicroPracticeOutcome(itemId: 'hear_kitab_anchor', passed: true),
        V2MicroPracticeOutcome(itemId: 'recognize_start_side_kitab', passed: true),
        V2MicroPracticeOutcome(itemId: 'recognize_kitab_meaning', passed: true),
        V2MicroPracticeOutcome(itemId: 'recall_start_side_kitab', passed: true),
        V2MicroPracticeOutcome(itemId: 'recall_kitab_meaning', passed: true),
        V2MicroPracticeOutcome(itemId: 'build_kitab_pair', passed: true),
      ],
    );

    expect(result.lessonId, 'V2-A1-01-PREVIEW');
    expect(result.currentStatus, V2CanonicalLessonStatus.completed);
    expect(result.recommendedLessonId, 'V2-A1-02-PREVIEW');

    final snapshot = V2LearningSnapshotService.buildSnapshot(
      lessons: foundationPilotMicroLessons,
      lessonRecords: await LessonProgressService.getAllRecords(),
      learningStates: await LearningStateService.getAllStates(),
    );

    expect(
      snapshot.lessonStatusFor('V2-A1-01-PREVIEW'),
      V2CanonicalLessonStatus.completed,
    );
    expect(snapshot.recommendedLessonId, 'V2-A1-02-PREVIEW');
    expect(
      snapshot.recommendedAction.actionType,
      V2RecommendedActionType.startLesson,
    );
  });

  test(
    'evidence evaluator honors completionRule subsets instead of requiring every objective',
    () {
    final evaluation = V2MicroLessonEvidenceEvaluator.evaluate(
      lesson: evidenceRuleLesson,
      practiceOutcomes: const <V2MicroPracticeOutcome>[
        V2MicroPracticeOutcome(itemId: 'required_practice', passed: true),
        V2MicroPracticeOutcome(itemId: 'supporting_practice', passed: false),
      ],
      objectiveResults: const <V2ObjectiveProgressRecord>[
        V2ObjectiveProgressRecord(
          lessonId: 'V2-EVIDENCE-01',
          objectiveId: 'required_objective',
          status: V2ObjectiveStatus.reached,
          accuracy: 1.0,
          evidenceCount: 1,
          threshold: 0.8,
        ),
        V2ObjectiveProgressRecord(
          lessonId: 'V2-EVIDENCE-01',
          objectiveId: 'supporting_objective',
          status: V2ObjectiveStatus.weak,
          accuracy: 0.0,
          evidenceCount: 1,
          threshold: 0.8,
        ),
      ],
      confirmationPassed: true,
    );

    expect(evaluation.attemptedPracticeCount, 2);
    expect(evaluation.averageScore, 0.5);
    expect(evaluation.meetsMinimumPracticeCount, isTrue);
    expect(evaluation.meetsPassThreshold, isTrue);
    expect(evaluation.unmetRequiredPracticeItemIds, isEmpty);
    expect(evaluation.unmetRequiredObjectiveIds, isEmpty);
    expect(evaluation.targetReached, isTrue);
  });

  test(
    'evidence evaluator blocks completion when required practice evidence is missing',
    () {
    final evaluation = V2MicroLessonEvidenceEvaluator.evaluate(
      lesson: evidenceRuleLesson,
      practiceOutcomes: const <V2MicroPracticeOutcome>[
        V2MicroPracticeOutcome(itemId: 'supporting_practice', passed: true),
      ],
      objectiveResults: const <V2ObjectiveProgressRecord>[
        V2ObjectiveProgressRecord(
          lessonId: 'V2-EVIDENCE-01',
          objectiveId: 'required_objective',
          status: V2ObjectiveStatus.reached,
          accuracy: 1.0,
          evidenceCount: 1,
          threshold: 0.8,
        ),
      ],
      confirmationPassed: true,
    );

    expect(evaluation.meetsMinimumPracticeCount, isTrue);
    expect(evaluation.meetsPassThreshold, isTrue);
    expect(
      evaluation.unmetRequiredPracticeItemIds,
      <String>['required_practice'],
    );
    expect(evaluation.targetReached, isFalse);
  });
}

