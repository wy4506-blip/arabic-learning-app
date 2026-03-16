import 'review_models.dart';
import 'v2_lesson_progress_models.dart';

enum V2CanonicalLessonStatus {
  locked,
  notStarted,
  inProgress,
  coreCompleted,
  completed,
  dueForReview,
  mastered,
}

enum V2MicroLessonType {
  alphabetClosure,
  phonicsBridge,
  listeningRecognition,
  responseProduction,
  identityIntroduction,
  classroomCommand,
  consolidation,
}

enum V2MicroContentKind {
  goal,
  input,
  explanation,
  modeling,
  contrast,
  recall,
  feedback,
}

enum V2MicroPracticeType {
  listenTap,
  speakResponse,
  arrangeResponse,
  recallPrompt,
  contrastChoice,
  comprehensionCheck,
}

enum V2RecommendedActionType {
  startLesson,
  continueLesson,
  startReview,
  startConsolidation,
  startNextPhase,
  noAction,
}

enum V2ReviewSeedKind {
  newVocabulary,
  coreExpression,
  weakPoint,
  mistake,
  confusionPair,
}

class V2MicroLessonObjective {
  final String objectiveId;
  final String summary;
  final List<String> keyPoints;
  final double masteryThreshold;

  const V2MicroLessonObjective({
    required this.objectiveId,
    required this.summary,
    this.keyPoints = const <String>[],
    this.masteryThreshold = 0.8,
  });
}

class V2MicroLessonEntryCondition {
  final List<String> requiredLessonIds;
  final List<String> requiredObjectiveIds;
  final bool requiresAlphabetStageComplete;
  final bool requiresDueReviewClear;

  const V2MicroLessonEntryCondition({
    this.requiredLessonIds = const <String>[],
    this.requiredObjectiveIds = const <String>[],
    this.requiresAlphabetStageComplete = false,
    this.requiresDueReviewClear = false,
  });
}

class V2MicroContentItem {
  final String itemId;
  final V2MicroContentKind kind;
  final String title;
  final String body;
  final String? arabicText;
  final String? transliteration;
  final String? meaning;
  final String? audioQueryText;
  final List<String> objectiveIds;

  const V2MicroContentItem({
    required this.itemId,
    required this.kind,
    required this.title,
    required this.body,
    this.arabicText,
    this.transliteration,
    this.meaning,
    this.audioQueryText,
    this.objectiveIds = const <String>[],
  });
}

class V2MicroPracticeItem {
  final String itemId;
  final V2MicroPracticeType type;
  final String prompt;
  final String? arabicText;
  final String? transliteration;
  final String? meaning;
  final String itemRefId;
  final ReviewObjectType reviewObjectType;
  final ReviewActionType reviewActionType;
  final List<String> objectiveIds;
  final String? expectedAnswer;
  final String? confusionWithRefId;

  const V2MicroPracticeItem({
    required this.itemId,
    required this.type,
    required this.prompt,
    required this.itemRefId,
    required this.reviewObjectType,
    required this.reviewActionType,
    this.arabicText,
    this.transliteration,
    this.meaning,
    this.objectiveIds = const <String>[],
    this.expectedAnswer,
    this.confusionWithRefId,
  });
}

class V2MicroCompletionRule {
  final List<String> requiredPracticeItemIds;
  final List<String> requiredObjectiveIds;
  final int minimumPracticeCount;
  final double passThreshold;

  const V2MicroCompletionRule({
    this.requiredPracticeItemIds = const <String>[],
    this.requiredObjectiveIds = const <String>[],
    this.minimumPracticeCount = 1,
    this.passThreshold = 0.8,
  });
}

class V2MicroReviewSeedRule {
  final String ruleId;
  final V2ReviewSeedKind seedKind;
  final ReviewObjectType reviewObjectType;
  final ReviewActionType reviewActionType;
  final String sourceItemRefId;
  final List<String> objectiveIds;
  final Duration dueAfter;
  final bool onlyIfWeak;
  final int maxSeeds;

  const V2MicroReviewSeedRule({
    required this.ruleId,
    required this.seedKind,
    required this.reviewObjectType,
    required this.reviewActionType,
    required this.sourceItemRefId,
    this.objectiveIds = const <String>[],
    this.dueAfter = const Duration(hours: 18),
    this.onlyIfWeak = false,
    this.maxSeeds = 1,
  });
}

class V2NextActionHint {
  final V2RecommendedActionType actionType;
  final String label;
  final String? targetLessonId;
  final String reason;

  const V2NextActionHint({
    required this.actionType,
    required this.label,
    required this.reason,
    this.targetLessonId,
  });
}

class V2MicroLesson {
  final String lessonId;
  final String phaseId;
  final String groupId;
  final String title;
  final String outcomeSummary;
  final int estimatedMinutes;
  final V2MicroLessonType lessonType;
  final List<V2MicroLessonObjective> objectives;
  final V2MicroLessonEntryCondition entryCondition;
  final List<V2MicroContentItem> contentItems;
  final List<V2MicroPracticeItem> practiceItems;
  final V2MicroCompletionRule completionRule;
  final List<V2MicroReviewSeedRule> reviewSeedRules;
  final List<V2NextActionHint> nextActionHints;
  final List<String> sourceLessonIds;

  const V2MicroLesson({
    required this.lessonId,
    required this.phaseId,
    required this.groupId,
    required this.title,
    required this.outcomeSummary,
    required this.estimatedMinutes,
    required this.lessonType,
    required this.objectives,
    required this.entryCondition,
    required this.contentItems,
    required this.practiceItems,
    required this.completionRule,
    required this.reviewSeedRules,
    required this.nextActionHints,
    this.sourceLessonIds = const <String>[],
  });

  bool get isPilotSized =>
      estimatedMinutes >= 6 &&
      estimatedMinutes <= 10 &&
      objectives.length >= 2 &&
      objectives.length <= 4;
}

V2CanonicalLessonStatus canonicalLessonStatusFromProgress(
  V2LessonStatus? value,
) {
  switch (value) {
    case V2LessonStatus.locked:
      return V2CanonicalLessonStatus.locked;
    case V2LessonStatus.available:
      return V2CanonicalLessonStatus.notStarted;
    case V2LessonStatus.inProgress:
      return V2CanonicalLessonStatus.inProgress;
    case V2LessonStatus.coreCompleted:
      return V2CanonicalLessonStatus.coreCompleted;
    case V2LessonStatus.completed:
      return V2CanonicalLessonStatus.completed;
    case V2LessonStatus.dueForReview:
      return V2CanonicalLessonStatus.dueForReview;
    case V2LessonStatus.mastered:
      return V2CanonicalLessonStatus.mastered;
    case null:
      return V2CanonicalLessonStatus.notStarted;
  }
}

extension V2CanonicalLessonStatusX on V2CanonicalLessonStatus {
  bool get isStartedLike =>
      this == V2CanonicalLessonStatus.inProgress ||
      this == V2CanonicalLessonStatus.coreCompleted ||
      isCompletedLike;

  bool get isCompletedLike =>
      this == V2CanonicalLessonStatus.completed ||
      this == V2CanonicalLessonStatus.dueForReview ||
      this == V2CanonicalLessonStatus.mastered;

  bool get canAdvanceMainline =>
      this == V2CanonicalLessonStatus.coreCompleted || isCompletedLike;

  bool get needsReview => this == V2CanonicalLessonStatus.dueForReview;
}
