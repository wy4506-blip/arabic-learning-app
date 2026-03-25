import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arabic_learning_app/data/v2_micro_lesson_catalog.dart';
import 'package:arabic_learning_app/data/v2_micro_lessons.dart';
import 'package:arabic_learning_app/models/learning_state_models.dart';
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

  test(
      'formal foundation completion advances the foundation track without changing the live pilot recommendation',
      () async {
    final result = await V2MicroLessonCompletionOrchestrator.completeLesson(
      lessonId: 'V2-A1-01-PREVIEW',
      practiceOutcomes: const <V2MicroPracticeOutcome>[
        V2MicroPracticeOutcome(itemId: 'hear_kitab_anchor', passed: true),
        V2MicroPracticeOutcome(
          itemId: 'recognize_start_side_kitab',
          passed: true,
        ),
        V2MicroPracticeOutcome(
          itemId: 'recognize_kitab_meaning',
          passed: true,
        ),
        V2MicroPracticeOutcome(
          itemId: 'recall_start_side_kitab',
          passed: true,
        ),
        V2MicroPracticeOutcome(
          itemId: 'recall_kitab_meaning',
          passed: true,
        ),
        V2MicroPracticeOutcome(itemId: 'build_kitab_pair', passed: true),
      ],
    );

    expect(result.lessonId, 'V2-A1-01-PREVIEW');
    expect(result.currentStatus, V2CanonicalLessonStatus.completed);
    expect(result.createdReviewSeeds, isNotEmpty);
    expect(result.recommendedLessonId, 'V2-A1-02-PREVIEW');

    final lessonRecords = await LessonProgressService.getAllRecords();
    final learningStates = await LearningStateService.getAllStates();

    final foundationSnapshot = V2LearningSnapshotService.buildSnapshot(
      lessons: foundationPilotMicroLessons,
      lessonRecords: lessonRecords,
      learningStates: learningStates,
    );
    final liveSnapshot = V2LearningSnapshotService.buildSnapshot(
      lessons: v2PilotMicroLessons,
      lessonRecords: lessonRecords,
      learningStates: learningStates,
    );

    expect(
      foundationSnapshot.lessonStatusFor('V2-A1-01-PREVIEW'),
      V2CanonicalLessonStatus.completed,
    );
    expect(foundationSnapshot.recommendedLessonId, 'V2-A1-02-PREVIEW');
    expect(
      foundationSnapshot.recommendedAction.actionType,
      V2RecommendedActionType.startLesson,
    );

    expect(
      liveSnapshot.lessonStatusFor('V2-ALPHA-CL-01'),
      V2CanonicalLessonStatus.notStarted,
    );
    expect(liveSnapshot.recommendedLessonId, 'V2-ALPHA-CL-01');
    expect(
      liveSnapshot.recommendedAction.actionType,
      V2RecommendedActionType.startLesson,
    );

    expect(
      learningStates.values
          .where((state) => state.lessonId == 'V2-A1-01-PREVIEW')
          .isNotEmpty,
      isTrue,
    );
  });

  test(
      'foundation review seeds can drive review-first inside the foundation track while leaving the live pilot track untouched',
      () async {
    await V2MicroLessonCompletionOrchestrator.completeLesson(
      lessonId: 'V2-A1-01-PREVIEW',
      practiceOutcomes: const <V2MicroPracticeOutcome>[
        V2MicroPracticeOutcome(itemId: 'hear_kitab_anchor', passed: true),
        V2MicroPracticeOutcome(
          itemId: 'recognize_start_side_kitab',
          passed: false,
        ),
        V2MicroPracticeOutcome(
          itemId: 'recognize_kitab_meaning',
          passed: true,
        ),
        V2MicroPracticeOutcome(
          itemId: 'recall_start_side_kitab',
          passed: false,
        ),
        V2MicroPracticeOutcome(
          itemId: 'recall_kitab_meaning',
          passed: true,
        ),
        V2MicroPracticeOutcome(itemId: 'build_kitab_pair', passed: false),
      ],
    );

    final lessonRecords = await LessonProgressService.getAllRecords();
    final learningStates = await LearningStateService.getAllStates();

    final foundationSnapshot = V2LearningSnapshotService.buildSnapshot(
      lessons: foundationPilotMicroLessons,
      lessonRecords: lessonRecords,
      learningStates: learningStates,
    );
    final liveSnapshot = V2LearningSnapshotService.buildSnapshot(
      lessons: v2PilotMicroLessons,
      lessonRecords: lessonRecords,
      learningStates: learningStates,
    );

    expect(
      foundationSnapshot.lessonStatusFor('V2-A1-01-PREVIEW'),
      V2CanonicalLessonStatus.dueForReview,
    );
    expect(foundationSnapshot.dueReviewItems, isNotEmpty);
    expect(
      foundationSnapshot.recommendedAction.actionType,
      V2RecommendedActionType.startReview,
    );
    expect(
      foundationSnapshot.recommendedAction.targetLessonId,
      'V2-A1-01-PREVIEW',
    );

    expect(liveSnapshot.dueReviewItems, isEmpty);
    expect(liveSnapshot.recommendedLessonId, 'V2-ALPHA-CL-01');
    expect(
      liveSnapshot.recommendedAction.actionType,
      V2RecommendedActionType.startLesson,
    );
  });
}
