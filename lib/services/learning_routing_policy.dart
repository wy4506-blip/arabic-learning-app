import '../models/v2_lesson_progress_models.dart';
import 'learning_routing_models.dart';

class LearningRoutingPolicy {
  LearningRoutingPolicy._();

  /// Decide home route based on progress overview and user state.
  ///
  /// Rules (in order of priority):
  /// 1. !onboardingCompleted → onboarding + continueAlphabet
  /// 2. shouldPrioritizeReview && completedLessonCount > 0 → reviewFirst + startReview
  /// 3. totalLessonCount > 0 && completedLessonCount >= totalLessonCount → reviewFirst + startReview
  /// 4. recommendedLessonId != null → newLearning + startLesson + targetLessonId=recommendedLessonId
  /// 5. default → newLearning + startLesson + targetLessonId=currentLessonId ?? recommendedLessonId
  static LearningRoute decideHomeRoute({
    required String? recommendedLessonId,
    required String? currentLessonId,
    required int totalLessonCount,
    required int completedLessonCount,
    required bool onboardingCompleted,
    required bool shouldPrioritizeReview,
  }) {
    // Rule 1: !onboardingCompleted
    if (!onboardingCompleted) {
      return LearningRoute(
        mode: LearningMode.onboarding,
        primaryAction: LearningActionType.continueAlphabet,
        targetLessonId: null,
        decisionReason: 'alphabet_not_completed',
      );
    }

    // Rule 2: shouldPrioritizeReview && completedLessonCount > 0
    if (shouldPrioritizeReview && completedLessonCount > 0) {
      return LearningRoute(
        mode: LearningMode.reviewFirst,
        primaryAction: LearningActionType.startReview,
        targetLessonId: null,
        decisionReason: 'high_pressure_review',
      );
    }

    // Rule 3: totalLessonCount > 0 && completedLessonCount >= totalLessonCount
    if (totalLessonCount > 0 && completedLessonCount >= totalLessonCount) {
      return LearningRoute(
        mode: LearningMode.reviewFirst,
        primaryAction: LearningActionType.startReview,
        targetLessonId: null,
        decisionReason: 'all_lessons_completed',
      );
    }

    // Rule 4: recommendedLessonId != null
    if (recommendedLessonId != null) {
      return LearningRoute(
        mode: LearningMode.newLearning,
        primaryAction: LearningActionType.startLesson,
        targetLessonId: recommendedLessonId,
        decisionReason: 'recommended_lesson_available',
      );
    }

    // Rule 5: default
    final fallbackLessonId = currentLessonId ?? recommendedLessonId;
    return LearningRoute(
      mode: LearningMode.newLearning,
      primaryAction: LearningActionType.startLesson,
      targetLessonId: fallbackLessonId,
      decisionReason: 'default_next_lesson',
    );
  }

  static PostLessonRoute decidePostLessonRoute({
    required V2LessonStatus resultStatus,
    required bool targetReached,
    required String? nextLessonId,
    required bool fromHomeTodayPlan,
  }) {
    if (fromHomeTodayPlan && nextLessonId != null && targetReached) {
      return PostLessonRoute(
        action: PostLessonActionType.continueNextLesson,
        targetLessonId: nextLessonId,
        decisionReason: 'home_today_advance',
      );
    }

    if (resultStatus == V2LessonStatus.coreCompleted ||
        resultStatus == V2LessonStatus.dueForReview) {
      return const PostLessonRoute(
        action: PostLessonActionType.startReview,
        decisionReason: 'lesson_needs_review',
      );
    }

    if (targetReached && nextLessonId != null) {
      return PostLessonRoute(
        action: PostLessonActionType.continueNextLesson,
        targetLessonId: nextLessonId,
        decisionReason: 'lesson_completed_advance',
      );
    }

    return const PostLessonRoute(
      action: PostLessonActionType.returnToLessonDetail,
      decisionReason: 'lesson_complete_return',
    );
  }
}
