import 'review_models.dart';

class LearningContentState {
  final String contentId;
  final ReviewContentType type;
  final String? lessonId;
  final bool isStarted;
  final bool isCompleted;
  final DateTime? lastStudiedAt;
  final DateTime? lastViewedAt;
  final bool needsReview;
  final bool isWeak;
  final bool isFavorited;
  final int reviewPriority;

  const LearningContentState({
    required this.contentId,
    required this.type,
    required this.isStarted,
    required this.isCompleted,
    required this.needsReview,
    required this.isWeak,
    required this.isFavorited,
    required this.reviewPriority,
    this.lessonId,
    this.lastStudiedAt,
    this.lastViewedAt,
  });

  LearningContentState copyWith({
    String? contentId,
    ReviewContentType? type,
    String? lessonId,
    bool? isStarted,
    bool? isCompleted,
    DateTime? lastStudiedAt,
    DateTime? lastViewedAt,
    bool? needsReview,
    bool? isWeak,
    bool? isFavorited,
    int? reviewPriority,
  }) {
    return LearningContentState(
      contentId: contentId ?? this.contentId,
      type: type ?? this.type,
      lessonId: lessonId ?? this.lessonId,
      isStarted: isStarted ?? this.isStarted,
      isCompleted: isCompleted ?? this.isCompleted,
      lastStudiedAt: lastStudiedAt ?? this.lastStudiedAt,
      lastViewedAt: lastViewedAt ?? this.lastViewedAt,
      needsReview: needsReview ?? this.needsReview,
      isWeak: isWeak ?? this.isWeak,
      isFavorited: isFavorited ?? this.isFavorited,
      reviewPriority: reviewPriority ?? this.reviewPriority,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'contentId': contentId,
      'type': reviewContentTypeKey(type),
      'lessonId': lessonId,
      'isStarted': isStarted,
      'isCompleted': isCompleted,
      'lastStudiedAt': lastStudiedAt?.toIso8601String(),
      'lastViewedAt': lastViewedAt?.toIso8601String(),
      'needsReview': needsReview,
      'isWeak': isWeak,
      'isFavorited': isFavorited,
      'reviewPriority': reviewPriority,
    };
  }

  factory LearningContentState.fromJson(Map<String, dynamic> json) {
    return LearningContentState(
      contentId: json['contentId'] as String? ?? '',
      type: reviewContentTypeFromKey(json['type'] as String? ?? ''),
      lessonId: json['lessonId'] as String?,
      isStarted: json['isStarted'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
      lastStudiedAt:
          DateTime.tryParse(json['lastStudiedAt'] as String? ?? ''),
      lastViewedAt: DateTime.tryParse(json['lastViewedAt'] as String? ?? ''),
      needsReview: json['needsReview'] as bool? ?? false,
      isWeak: json['isWeak'] as bool? ?? false,
      isFavorited: json['isFavorited'] as bool? ?? false,
      reviewPriority: json['reviewPriority'] as int? ?? 0,
    );
  }
}
