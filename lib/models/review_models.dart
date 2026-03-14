enum ReviewContentType { word, sentence, grammar, alphabet }

enum ReviewTaskOrigin {
  recentLesson,
  due,
  weak,
  favorite,
  grammarRecent,
  grammarRelated,
  alphabetRecent,
  lessonBridge,
}

enum ReviewSessionKind {
  today,
  quick,
  weak,
  typeFocus,
  lessonPreview,
  lessonWrapUp,
  single,
}

enum ReviewEntrySource {
  homeTodayPlan,
  reviewTab,
  lessonFollowUp,
  vocabBook,
}

class ReviewSessionConfig {
  final ReviewEntrySource source;
  final bool autoContinueToLesson;
  final String? nextLessonId;
  final bool allowSkip;
  final String? headerTitle;
  final String? headerSubtitle;

  const ReviewSessionConfig({
    required this.source,
    this.autoContinueToLesson = false,
    this.nextLessonId,
    this.allowSkip = false,
    this.headerTitle,
    this.headerSubtitle,
  });

  const ReviewSessionConfig.reviewTab()
      : source = ReviewEntrySource.reviewTab,
        autoContinueToLesson = false,
        nextLessonId = null,
        allowSkip = false,
        headerTitle = null,
        headerSubtitle = null;
}

String reviewContentTypeKey(ReviewContentType value) {
  switch (value) {
    case ReviewContentType.word:
      return 'word';
    case ReviewContentType.sentence:
      return 'sentence';
    case ReviewContentType.grammar:
      return 'grammar';
    case ReviewContentType.alphabet:
      return 'alphabet';
  }
}

ReviewContentType reviewContentTypeFromKey(String value) {
  switch (value) {
    case 'word':
      return ReviewContentType.word;
    case 'sentence':
      return ReviewContentType.sentence;
    case 'grammar':
      return ReviewContentType.grammar;
    case 'alphabet':
      return ReviewContentType.alphabet;
    default:
      return ReviewContentType.word;
  }
}

String reviewTaskOriginKey(ReviewTaskOrigin value) {
  switch (value) {
    case ReviewTaskOrigin.recentLesson:
      return 'recent_lesson';
    case ReviewTaskOrigin.due:
      return 'due';
    case ReviewTaskOrigin.weak:
      return 'weak';
    case ReviewTaskOrigin.favorite:
      return 'favorite';
    case ReviewTaskOrigin.grammarRecent:
      return 'grammar_recent';
    case ReviewTaskOrigin.grammarRelated:
      return 'grammar_related';
    case ReviewTaskOrigin.alphabetRecent:
      return 'alphabet_recent';
    case ReviewTaskOrigin.lessonBridge:
      return 'lesson_bridge';
  }
}

ReviewTaskOrigin reviewTaskOriginFromKey(String value) {
  switch (value) {
    case 'recent_lesson':
      return ReviewTaskOrigin.recentLesson;
    case 'due':
      return ReviewTaskOrigin.due;
    case 'weak':
      return ReviewTaskOrigin.weak;
    case 'favorite':
      return ReviewTaskOrigin.favorite;
    case 'grammar_recent':
      return ReviewTaskOrigin.grammarRecent;
    case 'grammar_related':
      return ReviewTaskOrigin.grammarRelated;
    case 'alphabet_recent':
      return ReviewTaskOrigin.alphabetRecent;
    case 'lesson_bridge':
      return ReviewTaskOrigin.lessonBridge;
    default:
      return ReviewTaskOrigin.recentLesson;
  }
}

String reviewSessionKindKey(ReviewSessionKind value) {
  switch (value) {
    case ReviewSessionKind.today:
      return 'today';
    case ReviewSessionKind.quick:
      return 'quick';
    case ReviewSessionKind.weak:
      return 'weak';
    case ReviewSessionKind.typeFocus:
      return 'type_focus';
    case ReviewSessionKind.lessonPreview:
      return 'lesson_preview';
    case ReviewSessionKind.lessonWrapUp:
      return 'lesson_wrap_up';
    case ReviewSessionKind.single:
      return 'single';
  }
}

class ReviewTask {
  final String contentId;
  final ReviewContentType type;
  final ReviewTaskOrigin origin;
  final String title;
  final String subtitle;
  final String? arabicText;
  final String? transliteration;
  final String? helperText;
  final String? lessonId;
  final String? sourceId;
  final int estimatedSeconds;
  final int priority;

  const ReviewTask({
    required this.contentId,
    required this.type,
    required this.origin,
    required this.title,
    required this.subtitle,
    required this.estimatedSeconds,
    required this.priority,
    this.arabicText,
    this.transliteration,
    this.helperText,
    this.lessonId,
    this.sourceId,
  });

  ReviewTask copyWith({
    String? contentId,
    ReviewContentType? type,
    ReviewTaskOrigin? origin,
    String? title,
    String? subtitle,
    String? arabicText,
    String? transliteration,
    String? helperText,
    String? lessonId,
    String? sourceId,
    int? estimatedSeconds,
    int? priority,
  }) {
    return ReviewTask(
      contentId: contentId ?? this.contentId,
      type: type ?? this.type,
      origin: origin ?? this.origin,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      arabicText: arabicText ?? this.arabicText,
      transliteration: transliteration ?? this.transliteration,
      helperText: helperText ?? this.helperText,
      lessonId: lessonId ?? this.lessonId,
      sourceId: sourceId ?? this.sourceId,
      estimatedSeconds: estimatedSeconds ?? this.estimatedSeconds,
      priority: priority ?? this.priority,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'contentId': contentId,
      'type': reviewContentTypeKey(type),
      'origin': reviewTaskOriginKey(origin),
      'title': title,
      'subtitle': subtitle,
      'arabicText': arabicText,
      'transliteration': transliteration,
      'helperText': helperText,
      'lessonId': lessonId,
      'sourceId': sourceId,
      'estimatedSeconds': estimatedSeconds,
      'priority': priority,
    };
  }

  factory ReviewTask.fromJson(Map<String, dynamic> json) {
    return ReviewTask(
      contentId: json['contentId'] as String? ?? '',
      type: reviewContentTypeFromKey(json['type'] as String? ?? ''),
      origin: reviewTaskOriginFromKey(json['origin'] as String? ?? ''),
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      arabicText: json['arabicText'] as String?,
      transliteration: json['transliteration'] as String?,
      helperText: json['helperText'] as String?,
      lessonId: json['lessonId'] as String?,
      sourceId: json['sourceId'] as String?,
      estimatedSeconds: json['estimatedSeconds'] as int? ?? 45,
      priority: json['priority'] as int? ?? 0,
    );
  }
}

class DailyReviewPlan {
  final String dateKey;
  final List<ReviewTask> tasks;
  final List<String> completedTaskIds;
  final DateTime? startedAt;
  final DateTime? completedAt;

  const DailyReviewPlan({
    required this.dateKey,
    required this.tasks,
    required this.completedTaskIds,
    this.startedAt,
    this.completedAt,
  });

  int get totalCount => tasks.length;

  int get completedCount => completedTaskIds.length;

  int get pendingCount => (totalCount - completedCount).clamp(0, totalCount);

  bool get hasStarted => startedAt != null;

  bool get isCompleted => totalCount > 0 && completedCount >= totalCount;

  int get estimatedSeconds => tasks.fold<int>(
        0,
        (sum, task) => sum + task.estimatedSeconds,
      );

  DailyReviewPlan copyWith({
    String? dateKey,
    List<ReviewTask>? tasks,
    List<String>? completedTaskIds,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return DailyReviewPlan(
      dateKey: dateKey ?? this.dateKey,
      tasks: tasks ?? this.tasks,
      completedTaskIds: completedTaskIds ?? this.completedTaskIds,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'dateKey': dateKey,
      'tasks': tasks.map((task) => task.toJson()).toList(growable: false),
      'completedTaskIds': completedTaskIds,
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory DailyReviewPlan.fromJson(Map<String, dynamic> json) {
    return DailyReviewPlan(
      dateKey: json['dateKey'] as String? ?? '',
      tasks: (json['tasks'] as List? ?? const <dynamic>[])
          .map((item) => ReviewTask.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      completedTaskIds:
          List<String>.from(json['completedTaskIds'] as List? ?? const []),
      startedAt: DateTime.tryParse(json['startedAt'] as String? ?? ''),
      completedAt: DateTime.tryParse(json['completedAt'] as String? ?? ''),
    );
  }
}

class ReviewSummary {
  final DailyReviewPlan todayPlan;
  final int streakDays;
  final int weeklyReviewCount;
  final Map<ReviewContentType, int> typeCounts;

  const ReviewSummary({
    required this.todayPlan,
    required this.streakDays,
    required this.weeklyReviewCount,
    required this.typeCounts,
  });
}

class ReviewDashboardData {
  final ReviewSummary summary;
  final List<ReviewTask> weakTasks;
  final List<ReviewTask> recentTasks;

  const ReviewDashboardData({
    required this.summary,
    required this.weakTasks,
    required this.recentTasks,
  });

  bool get canContinueToday {
    return summary.todayPlan.hasStarted && !summary.todayPlan.isCompleted;
  }
}

class ReviewSession {
  final String id;
  final ReviewSessionKind kind;
  final String title;
  final String subtitle;
  final List<ReviewTask> tasks;
  final bool countTowardActivity;
  final bool syncWithTodayPlan;
  final List<String> completedTaskIds;
  final ReviewSessionConfig config;

  const ReviewSession({
    required this.id,
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.tasks,
    required this.countTowardActivity,
    required this.syncWithTodayPlan,
    this.completedTaskIds = const <String>[],
    this.config = const ReviewSessionConfig.reviewTab(),
  });
}

String reviewDateKey(DateTime value) {
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

String normalizeReviewKey(String value) {
  final diacritics = RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]');
  return value
      .replaceAll(diacritics, '')
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), '_');
}

String buildWordContentId(String plainArabic) {
  return 'word:${normalizeReviewKey(plainArabic)}';
}

String buildSentenceContentId(String arabic) {
  return 'sentence:${normalizeReviewKey(arabic)}';
}

String buildGrammarContentId(String pageId) {
  return 'grammar:${normalizeReviewKey(pageId)}';
}

String buildAlphabetContentId(String arabic) {
  return 'alphabet:${normalizeReviewKey(arabic)}';
}
