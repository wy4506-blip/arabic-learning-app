enum LearningMode {
  onboarding,           // 字母阶段
  newLearning,          // 新学模式
  reviewFirst,          // 复习优先
  phaseConsolidation,   // 单元巩固（第一版不进执行链）
}

enum LearningActionType {
  continueAlphabet,
  startLesson,
  startReview,
}

class LearningRoute {
  final LearningMode mode;
  final LearningActionType primaryAction;
  final String? targetLessonId;
  final String? decisionReason;

  const LearningRoute({
    required this.mode,
    required this.primaryAction,
    this.targetLessonId,
    this.decisionReason,
  });
}

/// PostLesson routing: 课程完成后的下一步建议
enum PostLessonActionType {
  continueNextLesson,     // 进入下一课
  startReview,            // 开始课后复习
  returnToLessonDetail,   // 返回课程详情页
}

class PostLessonRoute {
  final PostLessonActionType action;
  final String? targetLessonId;
  final String? decisionReason;

  const PostLessonRoute({
    required this.action,
    this.targetLessonId,
    this.decisionReason,
  });
}
