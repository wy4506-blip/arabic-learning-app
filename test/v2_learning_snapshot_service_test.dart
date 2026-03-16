import 'package:flutter_test/flutter_test.dart';

import 'package:arabic_learning_app/data/v2_micro_lessons.dart';
import 'package:arabic_learning_app/models/learning_state_models.dart';
import 'package:arabic_learning_app/models/review_models.dart';
import 'package:arabic_learning_app/models/v2_lesson_progress_models.dart';
import 'package:arabic_learning_app/models/v2_micro_lesson.dart';
import 'package:arabic_learning_app/services/v2_learning_snapshot_service.dart';

void main() {
  test('snapshot recommends the first lesson for a fresh user', () {
    final snapshot = V2LearningSnapshotService.buildSnapshot(
      lessons: v2PilotMicroLessons,
      lessonRecords: const <String, V2LessonProgressRecord>{},
      learningStates: const <String, LearningContentState>{},
    );

    expect(
      snapshot.lessonStatusFor('V2-ALPHA-CL-01'),
      V2CanonicalLessonStatus.notStarted,
    );
    expect(snapshot.recommendedLessonId, 'V2-ALPHA-CL-01');
    expect(
      snapshot.recommendedAction.actionType,
      V2RecommendedActionType.startLesson,
    );
    expect(snapshot.recommendedAction.reason, 'next_core_lesson');
  });

  test('snapshot prioritizes due review before new lesson', () {
    final snapshot = V2LearningSnapshotService.buildSnapshot(
      lessons: v2PilotMicroLessons,
      lessonRecords: <String, V2LessonProgressRecord>{
        'V2-U1-01': const V2LessonProgressRecord(
          lessonId: 'V2-U1-01',
          status: V2LessonStatus.completed,
        ),
      },
      learningStates: <String, LearningContentState>{
        'sentence:marhaban': LearningContentState(
          contentId: 'sentence:marhaban',
          type: ReviewContentType.sentence,
          objectType: ReviewObjectType.sentencePattern,
          lessonId: 'V2-U1-01',
          isStarted: true,
          isCompleted: true,
          needsReview: true,
          isWeak: false,
          isFavorited: false,
          reviewPriority: 2,
          stage: LearningStage.reviewDue,
        ),
      },
    );

    expect(
      snapshot.lessonStatusFor('V2-U1-01'),
      V2CanonicalLessonStatus.dueForReview,
    );
    expect(snapshot.dueReviewItems, isNotEmpty);
    expect(
      snapshot.recommendedAction.actionType,
      V2RecommendedActionType.startReview,
    );
    expect(snapshot.recommendedAction.reason, 'review_due_first');
  });

  test('snapshot continues an in-progress lesson before starting a new one',
      () {
    final snapshot = V2LearningSnapshotService.buildSnapshot(
      lessons: v2PilotMicroLessons,
      lessonRecords: <String, V2LessonProgressRecord>{
        'V2-ALPHA-CL-01': const V2LessonProgressRecord(
          lessonId: 'V2-ALPHA-CL-01',
          status: V2LessonStatus.completed,
        ),
        'V2-BRIDGE-01': const V2LessonProgressRecord(
          lessonId: 'V2-BRIDGE-01',
          status: V2LessonStatus.inProgress,
          objectiveResults: <V2ObjectiveProgressRecord>[
            V2ObjectiveProgressRecord(
              lessonId: 'V2-BRIDGE-01',
              objectiveId: 'bridge_short_vowels_hear',
              status: V2ObjectiveStatus.attempted,
              accuracy: 0.5,
              evidenceCount: 1,
              threshold: 0.8,
            ),
          ],
        ),
      },
      learningStates: const <String, LearningContentState>{},
    );

    expect(snapshot.recommendedLessonId, 'V2-BRIDGE-01');
    expect(
      snapshot.recommendedAction.actionType,
      V2RecommendedActionType.continueLesson,
    );
    expect(snapshot.recommendedAction.reason, 'continue_in_progress_lesson');
    expect(
        snapshot.objectiveProgress.keys, contains('bridge_short_vowels_hear'));
  });
}
