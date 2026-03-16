import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      contains('学完后，你能听清并点出 ث / ذ / ظ 这组三个易混字母'));
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
}
