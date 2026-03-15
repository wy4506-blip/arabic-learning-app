import 'package:flutter_test/flutter_test.dart';

import 'package:arabic_learning_app/data/sample_lessons.dart';
import 'package:arabic_learning_app/models/app_settings.dart';
import 'package:arabic_learning_app/models/v2_lesson_progress_models.dart';
import 'package:arabic_learning_app/services/progress_service.dart';
import 'package:arabic_learning_app/view_models/learning_path_view_models.dart';

void main() {
  final lessons = sampleLessons.take(5).toList(growable: false);
  final lesson1 = lessons[0];
  final lesson2 = lessons[1];
  final lesson3 = lessons[2];
  final lesson5 = lessons[4];

  ProgressSnapshot buildSnapshot({
    Map<String, V2LessonProgressRecord> lessonProgressRecords =
        const <String, V2LessonProgressRecord>{},
    Set<String> completedLessons = const <String>{},
    Set<String> startedLessons = const <String>{},
    String? currentLessonId,
    String? currentGroupId,
    String? currentPhaseId,
  }) {
    return ProgressSnapshot(
      completedLessons: completedLessons,
      startedLessons: startedLessons,
      reviewCount: 0,
      streakDays: 0,
      currentLessonId: currentLessonId,
      currentGroupId: currentGroupId,
      currentPhaseId: currentPhaseId,
      lessonProgressRecords: lessonProgressRecords,
    );
  }

  test('buildOverview uses V2 lesson statuses as the runtime source of truth', () {
    final snapshot = buildSnapshot(
      completedLessons: <String>{lesson1.id, lesson2.id},
      startedLessons: <String>{lesson2.id},
      currentLessonId: lesson2.id,
      currentGroupId: lesson2.unitId,
      currentPhaseId: 'phase_u1',
      lessonProgressRecords: <String, V2LessonProgressRecord>{
        lesson1.id: V2LessonProgressRecord(
          lessonId: lesson1.id,
          status: V2LessonStatus.completed,
        ),
        lesson2.id: V2LessonProgressRecord(
          lessonId: lesson2.id,
          status: V2LessonStatus.inProgress,
        ),
        lesson3.id: V2LessonProgressRecord(
          lessonId: lesson3.id,
          status: V2LessonStatus.coreCompleted,
        ),
      },
    );

    final overview = ProgressService.buildOverview(
      lessons: lessons,
      snapshot: snapshot,
      unlocked: true,
    );

    expect(overview.currentLessonId, lesson2.id);
    expect(overview.recommendedLessonId, lesson2.id);
    expect(overview.lessonStatusFor(lesson2.id), V2LessonStatus.inProgress);
    expect(overview.lessonStatusFor(lesson3.id), V2LessonStatus.coreCompleted);
    expect(overview.completedLessonCount, 1);
    expect(overview.coreCompletedLessonCount, 1);
    expect(
      overview.stageSummaries.firstWhere((summary) => summary.stageId == 'phase_u1').status,
      V2PhaseStatus.active,
    );
  });

  test('buildSnapshot keeps completed-like and review-due semantics aligned', () {
    final snapshot = buildSnapshot(
      currentLessonId: lesson2.id,
      currentGroupId: lesson2.unitId,
      currentPhaseId: 'phase_u1',
      lessonProgressRecords: <String, V2LessonProgressRecord>{
        lesson1.id: V2LessonProgressRecord(
          lessonId: lesson1.id,
          status: V2LessonStatus.completed,
        ),
        lesson2.id: V2LessonProgressRecord(
          lessonId: lesson2.id,
          status: V2LessonStatus.dueForReview,
        ),
      },
    );

    final learningSnapshot = LearningPathViewModels.buildSnapshot(
      lessons: lessons,
      progress: snapshot,
      unlocked: true,
    );

    expect(learningSnapshot.completedLessonIds, containsAll(<String>[lesson1.id, lesson2.id]));
    expect(learningSnapshot.startedLessonIds, contains(lesson2.id));
    expect(learningSnapshot.reviewDueLessonCount, 1);
    expect(learningSnapshot.lessonStatusFor(lesson2.id), V2LessonStatus.dueForReview);
    expect(learningSnapshot.recommendedLesson?.id, lesson3.id);
  });

  test('buildCourseLearningMap emits real unit phases and lesson entry targets', () {
    final snapshot = buildSnapshot(
      currentLessonId: lesson2.id,
      currentGroupId: lesson2.unitId,
      currentPhaseId: 'phase_u1',
      lessonProgressRecords: <String, V2LessonProgressRecord>{
        lesson1.id: V2LessonProgressRecord(
          lessonId: lesson1.id,
          status: V2LessonStatus.completed,
        ),
        lesson2.id: V2LessonProgressRecord(
          lessonId: lesson2.id,
          status: V2LessonStatus.inProgress,
        ),
      },
    );

    final learningSnapshot = LearningPathViewModels.buildSnapshot(
      lessons: lessons,
      progress: snapshot,
      unlocked: true,
    );
    final learningMap = LearningPathViewModels.buildCourseLearningMap(
      language: AppLanguage.zh,
      snapshot: learningSnapshot,
    );

    expect(learningMap.hasPrimaryEntryTarget, isTrue);
    expect(learningMap.phases.map((phase) => phase.phaseId), containsAll(<String>['phase_u1', 'phase_u2']));

    final currentPhase =
        learningMap.phases.firstWhere((phase) => phase.phaseId == 'phase_u1');
    final nextPhase =
        learningMap.phases.firstWhere((phase) => phase.phaseId == 'phase_u2');

    expect(currentPhase.isPrimaryEntryTarget, isTrue);
    expect(currentPhase.lesson?.id, lesson2.id);
    expect(currentPhase.canEnter, isTrue);
    expect(nextPhase.lesson?.id, lesson5.id);
    expect(nextPhase.canEnter, isTrue);
  });
}