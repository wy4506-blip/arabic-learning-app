import 'review_models.dart';

enum LearningStage {
  newItem,
  learning,
  weak,
  reviewDue,
  stable,
  mastered,
}

String learningStageKey(LearningStage value) {
  switch (value) {
    case LearningStage.newItem:
      return 'new';
    case LearningStage.learning:
      return 'learning';
    case LearningStage.weak:
      return 'weak';
    case LearningStage.reviewDue:
      return 'review_due';
    case LearningStage.stable:
      return 'stable';
    case LearningStage.mastered:
      return 'mastered';
  }
}

LearningStage learningStageFromKey(String value) {
  switch (value) {
    case 'new':
      return LearningStage.newItem;
    case 'learning':
      return LearningStage.learning;
    case 'weak':
      return LearningStage.weak;
    case 'review_due':
      return LearningStage.reviewDue;
    case 'stable':
      return LearningStage.stable;
    case 'mastered':
      return LearningStage.mastered;
    default:
      return LearningStage.learning;
  }
}

class LearningContentState {
  final String contentId;
  final ReviewContentType type;
  final ReviewObjectType objectType;
  final String? lessonId;
  final bool isStarted;
  final bool isCompleted;
  final DateTime? lastStudiedAt;
  final DateTime? lastViewedAt;
  final DateTime? lastReviewedAt;
  final DateTime? nextReviewAt;
  final LearningStage stage;
  final bool needsReview;
  final bool isWeak;
  final bool isFavorited;
  final int reviewPriority;
  final int reviewCount;
  final int successCount;
  final int lapseCount;

  const LearningContentState({
    required this.contentId,
    required this.type,
    required this.objectType,
    required this.isStarted,
    required this.isCompleted,
    required this.needsReview,
    required this.isWeak,
    required this.isFavorited,
    required this.reviewPriority,
    this.stage = LearningStage.learning,
    this.reviewCount = 0,
    this.successCount = 0,
    this.lapseCount = 0,
    this.lessonId,
    this.lastStudiedAt,
    this.lastViewedAt,
    this.lastReviewedAt,
    this.nextReviewAt,
  });

  bool get isReviewDue =>
      stage == LearningStage.reviewDue ||
      (nextReviewAt != null && !nextReviewAt!.isAfter(DateTime.now()));

  LearningContentState copyWith({
    String? contentId,
    ReviewContentType? type,
    ReviewObjectType? objectType,
    String? lessonId,
    bool? isStarted,
    bool? isCompleted,
    DateTime? lastStudiedAt,
    DateTime? lastViewedAt,
    DateTime? lastReviewedAt,
    DateTime? nextReviewAt,
    LearningStage? stage,
    bool? needsReview,
    bool? isWeak,
    bool? isFavorited,
    int? reviewPriority,
    int? reviewCount,
    int? successCount,
    int? lapseCount,
  }) {
    return LearningContentState(
      contentId: contentId ?? this.contentId,
      type: type ?? this.type,
      objectType: objectType ?? this.objectType,
      lessonId: lessonId ?? this.lessonId,
      isStarted: isStarted ?? this.isStarted,
      isCompleted: isCompleted ?? this.isCompleted,
      lastStudiedAt: lastStudiedAt ?? this.lastStudiedAt,
      lastViewedAt: lastViewedAt ?? this.lastViewedAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      stage: stage ?? this.stage,
      needsReview: needsReview ?? this.needsReview,
      isWeak: isWeak ?? this.isWeak,
      isFavorited: isFavorited ?? this.isFavorited,
      reviewPriority: reviewPriority ?? this.reviewPriority,
      reviewCount: reviewCount ?? this.reviewCount,
      successCount: successCount ?? this.successCount,
      lapseCount: lapseCount ?? this.lapseCount,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'contentId': contentId,
      'type': reviewContentTypeKey(type),
      'objectType': reviewObjectTypeKey(objectType),
      'lessonId': lessonId,
      'isStarted': isStarted,
      'isCompleted': isCompleted,
      'lastStudiedAt': lastStudiedAt?.toIso8601String(),
      'lastViewedAt': lastViewedAt?.toIso8601String(),
      'lastReviewedAt': lastReviewedAt?.toIso8601String(),
      'nextReviewAt': nextReviewAt?.toIso8601String(),
      'stage': learningStageKey(stage),
      'needsReview': needsReview,
      'isWeak': isWeak,
      'isFavorited': isFavorited,
      'reviewPriority': reviewPriority,
      'reviewCount': reviewCount,
      'successCount': successCount,
      'lapseCount': lapseCount,
    };
  }

  factory LearningContentState.fromJson(Map<String, dynamic> json) {
    final type = reviewContentTypeFromKey(json['type'] as String? ?? '');
    final legacyNeedsReview = json['needsReview'] as bool? ?? false;
    final legacyIsWeak = json['isWeak'] as bool? ?? false;
    final legacyIsCompleted = json['isCompleted'] as bool? ?? false;
    return LearningContentState(
      contentId: json['contentId'] as String? ?? '',
      type: type,
      objectType: reviewObjectTypeFromKey(
        json['objectType'] as String? ?? _inferObjectTypeKey(json['contentId'] as String? ?? '', type),
      ),
      lessonId: json['lessonId'] as String?,
      isStarted: json['isStarted'] as bool? ?? false,
      isCompleted: legacyIsCompleted,
      lastStudiedAt:
          DateTime.tryParse(json['lastStudiedAt'] as String? ?? ''),
      lastViewedAt: DateTime.tryParse(json['lastViewedAt'] as String? ?? ''),
      lastReviewedAt:
          DateTime.tryParse(json['lastReviewedAt'] as String? ?? ''),
      nextReviewAt: DateTime.tryParse(json['nextReviewAt'] as String? ?? ''),
      stage: json['stage'] == null
          ? _legacyStage(
              isCompleted: legacyIsCompleted,
              needsReview: legacyNeedsReview,
              isWeak: legacyIsWeak,
            )
          : learningStageFromKey(json['stage'] as String? ?? ''),
      needsReview: legacyNeedsReview,
      isWeak: legacyIsWeak,
      isFavorited: json['isFavorited'] as bool? ?? false,
      reviewPriority: json['reviewPriority'] as int? ?? 0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      successCount: json['successCount'] as int? ?? 0,
      lapseCount: json['lapseCount'] as int? ?? 0,
    );
  }
}

LearningStage _legacyStage({
  required bool isCompleted,
  required bool needsReview,
  required bool isWeak,
}) {
  if (isWeak) {
    return LearningStage.weak;
  }
  if (needsReview) {
    return LearningStage.reviewDue;
  }
  if (isCompleted) {
    return LearningStage.stable;
  }
  return LearningStage.learning;
}

String _inferObjectTypeKey(String contentId, ReviewContentType type) {
  if (contentId.startsWith('letter_name:')) {
    return 'letter_name';
  }
  if (contentId.startsWith('letter_sound:')) {
    return 'letter_sound';
  }
  if (contentId.startsWith('letter_form:')) {
    return 'letter_form';
  }
  if (contentId.startsWith('symbol_reading:')) {
    return 'symbol_reading';
  }
  if (contentId.startsWith('word_reading:') || contentId.startsWith('word:')) {
    return 'word_reading';
  }
  if (contentId.startsWith('confusion_pair:')) {
    return 'confusion_pair';
  }
  if (contentId.startsWith('sentence_pattern:') || contentId.startsWith('sentence:')) {
    return 'sentence_pattern';
  }
  if (contentId.startsWith('grammar_reference:') || contentId.startsWith('grammar:')) {
    return 'grammar_reference';
  }
  switch (type) {
    case ReviewContentType.alphabet:
      return 'letter_sound';
    case ReviewContentType.pronunciation:
      return 'symbol_reading';
    case ReviewContentType.word:
      return 'word_reading';
    case ReviewContentType.pair:
      return 'confusion_pair';
    case ReviewContentType.sentence:
      return 'sentence_pattern';
    case ReviewContentType.grammar:
      return 'grammar_reference';
  }
}
