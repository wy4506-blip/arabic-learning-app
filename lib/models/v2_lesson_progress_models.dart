import 'learning_state_models.dart';
import 'review_models.dart';

enum V2PhaseStatus {
  notStarted,
  active,
  consolidation,
  completed,
}

enum V2LessonStatus {
  locked,
  available,
  inProgress,
  coreCompleted,
  completed,
  mastered,
  dueForReview,
}

enum V2ObjectiveStatus {
  notStarted,
  attempted,
  reached,
  weak,
  stable,
}

extension V2LessonStatusX on V2LessonStatus {
  bool get isCompletedLike =>
      this == V2LessonStatus.completed ||
      this == V2LessonStatus.mastered ||
      this == V2LessonStatus.dueForReview;

  bool get isStartedLike =>
      this == V2LessonStatus.inProgress ||
      this == V2LessonStatus.coreCompleted ||
      isCompletedLike;

  bool get isCurrentLike =>
      this == V2LessonStatus.inProgress ||
      this == V2LessonStatus.coreCompleted;
}

String v2PhaseStatusKey(V2PhaseStatus value) {
  switch (value) {
    case V2PhaseStatus.notStarted:
      return 'not_started';
    case V2PhaseStatus.active:
      return 'active';
    case V2PhaseStatus.consolidation:
      return 'consolidation';
    case V2PhaseStatus.completed:
      return 'completed';
  }
}

V2PhaseStatus v2PhaseStatusFromKey(String value) {
  switch (value) {
    case 'not_started':
      return V2PhaseStatus.notStarted;
    case 'active':
      return V2PhaseStatus.active;
    case 'consolidation':
      return V2PhaseStatus.consolidation;
    case 'completed':
      return V2PhaseStatus.completed;
    default:
      return V2PhaseStatus.notStarted;
  }
}

String v2LessonStatusKey(V2LessonStatus value) {
  switch (value) {
    case V2LessonStatus.locked:
      return 'locked';
    case V2LessonStatus.available:
      return 'available';
    case V2LessonStatus.inProgress:
      return 'in_progress';
    case V2LessonStatus.coreCompleted:
      return 'core_completed';
    case V2LessonStatus.completed:
      return 'completed';
    case V2LessonStatus.mastered:
      return 'mastered';
    case V2LessonStatus.dueForReview:
      return 'due_for_review';
  }
}

V2LessonStatus v2LessonStatusFromKey(String value) {
  switch (value) {
    case 'locked':
      return V2LessonStatus.locked;
    case 'available':
      return V2LessonStatus.available;
    case 'in_progress':
      return V2LessonStatus.inProgress;
    case 'core_completed':
      return V2LessonStatus.coreCompleted;
    case 'completed':
      return V2LessonStatus.completed;
    case 'mastered':
      return V2LessonStatus.mastered;
    case 'due_for_review':
      return V2LessonStatus.dueForReview;
    default:
      return V2LessonStatus.available;
  }
}

String v2ObjectiveStatusKey(V2ObjectiveStatus value) {
  switch (value) {
    case V2ObjectiveStatus.notStarted:
      return 'not_started';
    case V2ObjectiveStatus.attempted:
      return 'attempted';
    case V2ObjectiveStatus.reached:
      return 'reached';
    case V2ObjectiveStatus.weak:
      return 'weak';
    case V2ObjectiveStatus.stable:
      return 'stable';
  }
}

V2ObjectiveStatus v2ObjectiveStatusFromKey(String value) {
  switch (value) {
    case 'not_started':
      return V2ObjectiveStatus.notStarted;
    case 'attempted':
      return V2ObjectiveStatus.attempted;
    case 'reached':
      return V2ObjectiveStatus.reached;
    case 'weak':
      return V2ObjectiveStatus.weak;
    case 'stable':
      return V2ObjectiveStatus.stable;
    default:
      return V2ObjectiveStatus.notStarted;
  }
}

class V2ObjectiveProgressRecord {
  final String lessonId;
  final String objectiveId;
  final V2ObjectiveStatus status;
  final double? accuracy;
  final int evidenceCount;
  final double? threshold;
  final DateTime? lastEvaluatedAt;

  const V2ObjectiveProgressRecord({
    required this.lessonId,
    required this.objectiveId,
    required this.status,
    this.accuracy,
    this.evidenceCount = 0,
    this.threshold,
    this.lastEvaluatedAt,
  });

  bool get reachedThreshold {
    if (threshold == null || accuracy == null) {
      return status == V2ObjectiveStatus.reached ||
          status == V2ObjectiveStatus.stable;
    }
    return accuracy! >= threshold!;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'lessonId': lessonId,
      'objectiveId': objectiveId,
      'status': v2ObjectiveStatusKey(status),
      'accuracy': accuracy,
      'evidenceCount': evidenceCount,
      'threshold': threshold,
      'lastEvaluatedAt': lastEvaluatedAt?.toIso8601String(),
    };
  }

  factory V2ObjectiveProgressRecord.fromJson(Map<String, dynamic> json) {
    return V2ObjectiveProgressRecord(
      lessonId: json['lessonId'] as String? ?? '',
      objectiveId: json['objectiveId'] as String? ?? '',
      status: v2ObjectiveStatusFromKey(json['status'] as String? ?? ''),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      evidenceCount: json['evidenceCount'] as int? ?? 0,
      threshold: (json['threshold'] as num?)?.toDouble(),
      lastEvaluatedAt:
          DateTime.tryParse(json['lastEvaluatedAt'] as String? ?? ''),
    );
  }
}

class V2ReviewSeedRecord {
  final String reviewId;
  final String lessonId;
  final ReviewObjectType objectType;
  final ReviewActionType actionType;
  final String itemRefId;
  final LearningStage initialStage;
  final DateTime dueAt;

  const V2ReviewSeedRecord({
    required this.reviewId,
    required this.lessonId,
    required this.objectType,
    required this.actionType,
    required this.itemRefId,
    required this.initialStage,
    required this.dueAt,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'reviewId': reviewId,
      'lessonId': lessonId,
      'objectType': reviewObjectTypeKey(objectType),
      'actionType': reviewActionTypeKey(actionType),
      'itemRefId': itemRefId,
      'initialStage': learningStageKey(initialStage),
      'dueAt': dueAt.toIso8601String(),
    };
  }

  factory V2ReviewSeedRecord.fromJson(Map<String, dynamic> json) {
    return V2ReviewSeedRecord(
      reviewId: json['reviewId'] as String? ?? '',
      lessonId: json['lessonId'] as String? ?? '',
      objectType: reviewObjectTypeFromKey(json['objectType'] as String? ?? ''),
      actionType: reviewActionTypeFromKey(json['actionType'] as String? ?? ''),
      itemRefId: json['itemRefId'] as String? ?? '',
      initialStage: learningStageFromKey(json['initialStage'] as String? ?? ''),
      dueAt: DateTime.tryParse(json['dueAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class V2LessonProgressRecord {
  final String lessonId;
  final List<String> sourceLessonIds;
  final V2LessonStatus status;
  final int attemptCount;
  final DateTime? lastStartedAt;
  final DateTime? lastCompletedAt;
  final DateTime? lastMasteredAt;
  final double? currentScore;
  final bool targetReached;
  final List<String> weakObjectiveIds;
  final List<String> seededReviewIds;
  final String? nextRecommendedLessonId;
  final List<V2ObjectiveProgressRecord> objectiveResults;
  final List<String> completedBlockIds;

  const V2LessonProgressRecord({
    required this.lessonId,
    this.sourceLessonIds = const <String>[],
    this.status = V2LessonStatus.available,
    this.attemptCount = 0,
    this.lastStartedAt,
    this.lastCompletedAt,
    this.lastMasteredAt,
    this.currentScore,
    this.targetReached = false,
    this.weakObjectiveIds = const <String>[],
    this.seededReviewIds = const <String>[],
    this.nextRecommendedLessonId,
    this.objectiveResults = const <V2ObjectiveProgressRecord>[],
    this.completedBlockIds = const <String>[],
  });

  bool get isCompletedLike => status.isCompletedLike;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'lessonId': lessonId,
      'sourceLessonIds': sourceLessonIds,
      'status': v2LessonStatusKey(status),
      'attemptCount': attemptCount,
      'lastStartedAt': lastStartedAt?.toIso8601String(),
      'lastCompletedAt': lastCompletedAt?.toIso8601String(),
      'lastMasteredAt': lastMasteredAt?.toIso8601String(),
      'currentScore': currentScore,
      'targetReached': targetReached,
      'weakObjectiveIds': weakObjectiveIds,
      'seededReviewIds': seededReviewIds,
      'nextRecommendedLessonId': nextRecommendedLessonId,
      'objectiveResults': objectiveResults.map((item) => item.toJson()).toList(growable: false),
      'completedBlockIds': completedBlockIds,
    };
  }

  factory V2LessonProgressRecord.fromJson(Map<String, dynamic> json) {
    final objectiveResults = (json['objectiveResults'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(V2ObjectiveProgressRecord.fromJson)
        .toList(growable: false);
    return V2LessonProgressRecord(
      lessonId: json['lessonId'] as String? ?? '',
      sourceLessonIds: (json['sourceLessonIds'] as List<dynamic>? ?? const <dynamic>[])
          .map((item) => item.toString())
          .toList(growable: false),
      status: v2LessonStatusFromKey(json['status'] as String? ?? ''),
      attemptCount: json['attemptCount'] as int? ?? 0,
      lastStartedAt: DateTime.tryParse(json['lastStartedAt'] as String? ?? ''),
      lastCompletedAt:
          DateTime.tryParse(json['lastCompletedAt'] as String? ?? ''),
      lastMasteredAt:
          DateTime.tryParse(json['lastMasteredAt'] as String? ?? ''),
      currentScore: (json['currentScore'] as num?)?.toDouble(),
      targetReached: json['targetReached'] as bool? ?? false,
      weakObjectiveIds: (json['weakObjectiveIds'] as List<dynamic>? ?? const <dynamic>[])
          .map((item) => item.toString())
          .toList(growable: false),
      seededReviewIds: (json['seededReviewIds'] as List<dynamic>? ?? const <dynamic>[])
          .map((item) => item.toString())
          .toList(growable: false),
      nextRecommendedLessonId: json['nextRecommendedLessonId'] as String?,
      objectiveResults: objectiveResults,
      completedBlockIds: (json['completedBlockIds'] as List<dynamic>? ?? const <dynamic>[])
          .map((item) => item.toString())
          .toList(growable: false),
    );
  }

  V2LessonProgressRecord copyWith({
    List<String>? sourceLessonIds,
    V2LessonStatus? status,
    int? attemptCount,
    DateTime? lastStartedAt,
    DateTime? lastCompletedAt,
    DateTime? lastMasteredAt,
    double? currentScore,
    bool? targetReached,
    List<String>? weakObjectiveIds,
    List<String>? seededReviewIds,
    String? nextRecommendedLessonId,
    List<V2ObjectiveProgressRecord>? objectiveResults,
    List<String>? completedBlockIds,
  }) {
    return V2LessonProgressRecord(
      lessonId: lessonId,
      sourceLessonIds: sourceLessonIds ?? this.sourceLessonIds,
      status: status ?? this.status,
      attemptCount: attemptCount ?? this.attemptCount,
      lastStartedAt: lastStartedAt ?? this.lastStartedAt,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
      lastMasteredAt: lastMasteredAt ?? this.lastMasteredAt,
      currentScore: currentScore ?? this.currentScore,
      targetReached: targetReached ?? this.targetReached,
      weakObjectiveIds: weakObjectiveIds ?? this.weakObjectiveIds,
      seededReviewIds: seededReviewIds ?? this.seededReviewIds,
      nextRecommendedLessonId:
          nextRecommendedLessonId ?? this.nextRecommendedLessonId,
      objectiveResults: objectiveResults ?? this.objectiveResults,
      completedBlockIds: completedBlockIds ?? this.completedBlockIds,
    );
  }
}

class V2CoursePhaseProgress {
  final String phaseId;
  final V2PhaseStatus status;
  final List<String> unlockedLessonIds;
  final int completedLessonCount;
  final int masteredLessonCount;
  final List<String> weakLessonIds;
  final int reviewDueCount;

  const V2CoursePhaseProgress({
    required this.phaseId,
    required this.status,
    this.unlockedLessonIds = const <String>[],
    this.completedLessonCount = 0,
    this.masteredLessonCount = 0,
    this.weakLessonIds = const <String>[],
    this.reviewDueCount = 0,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'phaseId': phaseId,
      'status': v2PhaseStatusKey(status),
      'unlockedLessonIds': unlockedLessonIds,
      'completedLessonCount': completedLessonCount,
      'masteredLessonCount': masteredLessonCount,
      'weakLessonIds': weakLessonIds,
      'reviewDueCount': reviewDueCount,
    };
  }
}