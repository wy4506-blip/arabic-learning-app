import 'package:flutter/foundation.dart';

enum ReviewSyncReason {
  manual,
  learningUpdated,
  practiceCompleted,
  stageChanged,
  planChanged,
  sessionLogged,
}

class ReviewSyncService {
  ReviewSyncService._();

  static final ValueNotifier<int> changes = ValueNotifier<int>(0);
  static ReviewSyncReason lastReason = ReviewSyncReason.manual;
  static DateTime? lastUpdatedAt;

  static void bump({
    ReviewSyncReason reason = ReviewSyncReason.manual,
  }) {
    lastReason = reason;
    lastUpdatedAt = DateTime.now();
    changes.value = changes.value + 1;
  }

  static void markLearningUpdated() {
    bump(reason: ReviewSyncReason.learningUpdated);
  }

  static void markPracticeCompleted() {
    bump(reason: ReviewSyncReason.practiceCompleted);
  }

  static void markStageChanged() {
    bump(reason: ReviewSyncReason.stageChanged);
  }

  static void markPlanChanged() {
    bump(reason: ReviewSyncReason.planChanged);
  }

  static void markSessionLogged() {
    bump(reason: ReviewSyncReason.sessionLogged);
  }
}
