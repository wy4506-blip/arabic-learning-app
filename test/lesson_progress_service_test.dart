import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arabic_learning_app/data/sample_lessons.dart';
import 'package:arabic_learning_app/models/learning_state_models.dart';
import 'package:arabic_learning_app/models/review_models.dart';
import 'package:arabic_learning_app/models/v2_lesson_progress_models.dart';
import 'package:arabic_learning_app/services/lesson_progress_service.dart';
import 'package:arabic_learning_app/services/progress_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await LessonProgressService.debugClearAll();
  });

  test('markLessonStarted creates a sidecar record and syncs base progress',
      () async {
    final record = await LessonProgressService.markLessonStarted(
      lessonId: 'V2-U1-01',
      sourceLessonIds: const <String>['U1L1'],
    );

    expect(record.lessonId, 'V2-U1-01');
    expect(record.status, V2LessonStatus.inProgress);
    expect(record.attemptCount, 1);
    expect(record.sourceLessonIds, const <String>['U1L1']);

    final snapshot = await ProgressService.getSnapshot();
    expect(snapshot.startedLessons.contains('V2-U1-01'), isTrue);
  });

  test('applyEvaluation stores objective results and marks lesson completed',
      () async {
    await LessonProgressService.markLessonStarted(lessonId: 'V2-U1-05');

    final updated = await LessonProgressService.applyEvaluation(
      lessonId: 'V2-U1-05',
      evaluation: LessonCompletionEvaluation(
        completedBlockIds: const <String>['intro', 'input', 'practice'],
        currentScore: 0.92,
        nextRecommendedLessonId: 'V2-U1-06',
        objectiveResults: const <V2ObjectiveProgressRecord>[
          V2ObjectiveProgressRecord(
            lessonId: 'V2-U1-05',
            objectiveId: 'g1_identity_sentence',
            status: V2ObjectiveStatus.reached,
            accuracy: 1.0,
            evidenceCount: 3,
            threshold: 0.75,
          ),
          V2ObjectiveProgressRecord(
            lessonId: 'V2-U1-05',
            objectiveId: 'g2_gender_pair_intro',
            status: V2ObjectiveStatus.reached,
            accuracy: 1.0,
            evidenceCount: 2,
            threshold: 1.0,
          ),
        ],
      ),
    );

    expect(updated.status, V2LessonStatus.completed);
    expect(updated.targetReached, isTrue);
    expect(updated.currentScore, 0.92);
    expect(updated.nextRecommendedLessonId, 'V2-U1-06');
    expect(updated.weakObjectiveIds, isEmpty);

    final snapshot = await ProgressService.getSnapshot();
    expect(snapshot.completedLessons.contains('V2-U1-05'), isTrue);
  });

  test('seedRecordsForLesson builds stable ids from lesson content', () {
    final lesson = sampleLessons.first;
    final seeds = LessonReviewSeeder.seedRecordsForLesson(
      lesson,
      now: DateTime(2026, 3, 15, 9),
    );

    expect(seeds, isNotEmpty);
    expect(
      seeds.any(
        (seed) =>
            seed.reviewId ==
            buildWordContentId(lesson.vocabulary.first.text.plain),
      ),
      isTrue,
    );
    expect(
      seeds.any(
        (seed) =>
            seed.reviewId ==
            buildSentenceContentId(lesson.patterns.first.text.plain),
      ),
      isTrue,
    );
  });

  test(
      'attachReviewSeeds keeps completed lessons completed for future-due seeds',
      () async {
    final futureDueAt = DateTime.now().add(const Duration(days: 1));

    await LessonProgressService.applyEvaluation(
      lessonId: 'V2-U1-09',
      evaluation: LessonCompletionEvaluation(
        completedBlockIds: const <String>['intro', 'practice'],
        objectiveResults: const <V2ObjectiveProgressRecord>[
          V2ObjectiveProgressRecord(
            lessonId: 'V2-U1-09',
            objectiveId: 'g1_demonstrative_pair',
            status: V2ObjectiveStatus.reached,
            accuracy: 1.0,
            evidenceCount: 2,
            threshold: 0.8,
          ),
        ],
      ),
    );

    final updated = await LessonProgressService.attachReviewSeeds(
      lessonId: 'V2-U1-09',
      seeds: <V2ReviewSeedRecord>[
        V2ReviewSeedRecord(
          reviewId: 'rv_demonstrative_pair',
          lessonId: 'V2-U1-09',
          objectType: ReviewObjectType.sentencePattern,
          actionType: ReviewActionType.distinguish,
          itemRefId: 'demonstrative_pair',
          initialStage: LearningStage.reviewDue,
          dueAt: futureDueAt,
        ),
      ],
    );

    expect(updated.status, V2LessonStatus.completed);
    expect(updated.seededReviewIds, contains('rv_demonstrative_pair'));
  });

  test(
      'attachReviewSeeds upgrades completed lessons to due_for_review when due now',
      () async {
    await LessonProgressService.applyEvaluation(
      lessonId: 'V2-U1-10',
      evaluation: LessonCompletionEvaluation(
        completedBlockIds: const <String>['intro', 'practice'],
        objectiveResults: const <V2ObjectiveProgressRecord>[
          V2ObjectiveProgressRecord(
            lessonId: 'V2-U1-10',
            objectiveId: 'g1_bridge_review',
            status: V2ObjectiveStatus.reached,
            accuracy: 1.0,
            evidenceCount: 2,
            threshold: 0.8,
          ),
        ],
      ),
    );

    final updated = await LessonProgressService.attachReviewSeeds(
      lessonId: 'V2-U1-10',
      seeds: <V2ReviewSeedRecord>[
        V2ReviewSeedRecord(
          reviewId: 'rv_bridge_due_now',
          lessonId: 'V2-U1-10',
          objectType: ReviewObjectType.sentencePattern,
          actionType: ReviewActionType.repeat,
          itemRefId: 'bridge_pattern',
          initialStage: LearningStage.reviewDue,
          dueAt: DateTime.now().subtract(const Duration(minutes: 1)),
        ),
      ],
    );

    expect(updated.status, V2LessonStatus.dueForReview);
  });

  test('buildPhaseProgress summarizes completion and review state', () async {
    await LessonProgressService.markLessonStarted(lessonId: 'V2-U1-01');
    await LessonProgressService.applyEvaluation(
      lessonId: 'V2-U1-01',
      evaluation: LessonCompletionEvaluation(
        completedBlockIds: const <String>['intro', 'practice'],
        objectiveResults: const <V2ObjectiveProgressRecord>[
          V2ObjectiveProgressRecord(
            lessonId: 'V2-U1-01',
            objectiveId: 'g1_greeting_opening',
            status: V2ObjectiveStatus.reached,
            accuracy: 0.9,
            evidenceCount: 3,
            threshold: 0.8,
          ),
        ],
      ),
    );
    await LessonProgressService.markLessonStarted(lessonId: 'V2-U1-02');

    final phase = await LessonProgressService.buildPhaseProgress(
      phaseId: 'phase_3_basic_expression',
      lessonIds: const <String>['V2-U1-01', 'V2-U1-02'],
    );

    expect(phase.phaseId, 'phase_3_basic_expression');
    expect(phase.status, V2PhaseStatus.active);
    expect(phase.completedLessonCount, 1);
    expect(phase.unlockedLessonIds,
        containsAll(const <String>['V2-U1-01', 'V2-U1-02']));
  });
}
