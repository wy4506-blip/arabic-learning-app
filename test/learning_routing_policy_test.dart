import 'package:flutter_test/flutter_test.dart';

import 'package:arabic_learning_app/models/v2_lesson_progress_models.dart';
import 'package:arabic_learning_app/services/learning_routing_models.dart';
import 'package:arabic_learning_app/services/learning_routing_policy.dart';

void main() {
  group('decidePostLessonRoute', () {
    test('advances in home today flow when target is reached', () {
      final route = LearningRoutingPolicy.decidePostLessonRoute(
        resultStatus: V2LessonStatus.completed,
        targetReached: true,
        nextLessonId: 'U1L2',
        fromHomeTodayPlan: true,
      );

      expect(route.action, PostLessonActionType.continueNextLesson);
      expect(route.targetLessonId, 'U1L2');
      expect(route.decisionReason, 'home_today_advance');
    });

    test('starts review for core completed lessons', () {
      final route = LearningRoutingPolicy.decidePostLessonRoute(
        resultStatus: V2LessonStatus.coreCompleted,
        targetReached: false,
        nextLessonId: 'U1L2',
        fromHomeTodayPlan: false,
      );

      expect(route.action, PostLessonActionType.startReview);
      expect(route.targetLessonId, isNull);
      expect(route.decisionReason, 'lesson_needs_review');
    });

    test('advances when lesson is completed and next lesson exists', () {
      final route = LearningRoutingPolicy.decidePostLessonRoute(
        resultStatus: V2LessonStatus.completed,
        targetReached: true,
        nextLessonId: 'U1L2',
        fromHomeTodayPlan: false,
      );

      expect(route.action, PostLessonActionType.continueNextLesson);
      expect(route.targetLessonId, 'U1L2');
      expect(route.decisionReason, 'lesson_completed_advance');
    });

    test('returns to lesson detail when no rule advances or starts review', () {
      final route = LearningRoutingPolicy.decidePostLessonRoute(
        resultStatus: V2LessonStatus.completed,
        targetReached: true,
        nextLessonId: null,
        fromHomeTodayPlan: false,
      );

      expect(route.action, PostLessonActionType.returnToLessonDetail);
      expect(route.targetLessonId, isNull);
      expect(route.decisionReason, 'lesson_complete_return');
    });
  });
}
