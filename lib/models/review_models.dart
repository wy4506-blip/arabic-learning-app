enum ReviewContentType {
  alphabet,
  pronunciation,
  word,
  pair,
  sentence,
  grammar,
}

enum ReviewObjectType {
  letterName,
  letterSound,
  letterForm,
  symbolReading,
  wordReading,
  confusionPair,
  sentencePattern,
  grammarReference,
}

enum ReviewActionType { recognize, listen, read, distinguish, repeat }

enum ReviewPracticeArea { letters, pronunciation, words }

enum ReviewTaskOrigin {
  recentLesson,
  due,
  weak,
  favorite,
  grammarRecent,
  grammarRelated,
  alphabetRecent,
  lessonBridge,
  fallback,
}

enum ReviewSessionKind {
  today,
  quick,
  weak,
  typeFocus,
  practice,
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

enum ReviewSessionMode { formal, freePractice }

class ReviewSessionConfig {
  final ReviewEntrySource source;
  final ReviewSessionMode mode;
  final bool autoContinueToLesson;
  final String? nextLessonId;
  final String? nextLessonLabel;
  final bool allowSkip;
  final String? headerTitle;
  final String? headerSubtitle;

  const ReviewSessionConfig({
    required this.source,
    this.mode = ReviewSessionMode.formal,
    this.autoContinueToLesson = false,
    this.nextLessonId,
    this.nextLessonLabel,
    this.allowSkip = false,
    this.headerTitle,
    this.headerSubtitle,
  });

  const ReviewSessionConfig.reviewTab({
    this.mode = ReviewSessionMode.formal,
    this.nextLessonId,
    this.nextLessonLabel,
  })  : source = ReviewEntrySource.reviewTab,
        autoContinueToLesson = false,
        allowSkip = false,
        headerTitle = null,
        headerSubtitle = null;
}

String reviewContentTypeKey(ReviewContentType value) {
  switch (value) {
    case ReviewContentType.alphabet:
      return 'alphabet';
    case ReviewContentType.pronunciation:
      return 'pronunciation';
    case ReviewContentType.word:
      return 'word';
    case ReviewContentType.pair:
      return 'pair';
    case ReviewContentType.sentence:
      return 'sentence';
    case ReviewContentType.grammar:
      return 'grammar';
  }
}

ReviewContentType reviewContentTypeFromKey(String value) {
  switch (value) {
    case 'alphabet':
      return ReviewContentType.alphabet;
    case 'pronunciation':
      return ReviewContentType.pronunciation;
    case 'word':
      return ReviewContentType.word;
    case 'pair':
      return ReviewContentType.pair;
    case 'sentence':
      return ReviewContentType.sentence;
    case 'grammar':
      return ReviewContentType.grammar;
    default:
      return ReviewContentType.word;
  }
}

String reviewObjectTypeKey(ReviewObjectType value) {
  switch (value) {
    case ReviewObjectType.letterName:
      return 'letter_name';
    case ReviewObjectType.letterSound:
      return 'letter_sound';
    case ReviewObjectType.letterForm:
      return 'letter_form';
    case ReviewObjectType.symbolReading:
      return 'symbol_reading';
    case ReviewObjectType.wordReading:
      return 'word_reading';
    case ReviewObjectType.confusionPair:
      return 'confusion_pair';
    case ReviewObjectType.sentencePattern:
      return 'sentence_pattern';
    case ReviewObjectType.grammarReference:
      return 'grammar_reference';
  }
}

ReviewObjectType reviewObjectTypeFromKey(String value) {
  switch (value) {
    case 'letter_name':
      return ReviewObjectType.letterName;
    case 'letter_sound':
      return ReviewObjectType.letterSound;
    case 'letter_form':
      return ReviewObjectType.letterForm;
    case 'symbol_reading':
      return ReviewObjectType.symbolReading;
    case 'word_reading':
      return ReviewObjectType.wordReading;
    case 'confusion_pair':
      return ReviewObjectType.confusionPair;
    case 'sentence_pattern':
      return ReviewObjectType.sentencePattern;
    case 'grammar_reference':
      return ReviewObjectType.grammarReference;
    default:
      return ReviewObjectType.wordReading;
  }
}

String reviewActionTypeKey(ReviewActionType value) {
  switch (value) {
    case ReviewActionType.recognize:
      return 'recognize';
    case ReviewActionType.listen:
      return 'listen';
    case ReviewActionType.read:
      return 'read';
    case ReviewActionType.distinguish:
      return 'distinguish';
    case ReviewActionType.repeat:
      return 'repeat';
  }
}

ReviewActionType reviewActionTypeFromKey(String value) {
  switch (value) {
    case 'recognize':
      return ReviewActionType.recognize;
    case 'listen':
      return ReviewActionType.listen;
    case 'read':
      return ReviewActionType.read;
    case 'distinguish':
      return ReviewActionType.distinguish;
    case 'repeat':
      return ReviewActionType.repeat;
    default:
      return ReviewActionType.recognize;
  }
}

String reviewPracticeAreaKey(ReviewPracticeArea value) {
  switch (value) {
    case ReviewPracticeArea.letters:
      return 'letters';
    case ReviewPracticeArea.pronunciation:
      return 'pronunciation';
    case ReviewPracticeArea.words:
      return 'words';
  }
}

ReviewPracticeArea reviewPracticeAreaFromKey(String value) {
  switch (value) {
    case 'letters':
      return ReviewPracticeArea.letters;
    case 'pronunciation':
      return ReviewPracticeArea.pronunciation;
    case 'words':
      return ReviewPracticeArea.words;
    default:
      return ReviewPracticeArea.words;
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
    case ReviewTaskOrigin.fallback:
      return 'fallback';
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
    case 'fallback':
      return ReviewTaskOrigin.fallback;
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
    case ReviewSessionKind.practice:
      return 'practice';
    case ReviewSessionKind.lessonPreview:
      return 'lesson_preview';
    case ReviewSessionKind.lessonWrapUp:
      return 'lesson_wrap_up';
    case ReviewSessionKind.single:
      return 'single';
  }
}

String reviewSessionModeKey(ReviewSessionMode value) {
  switch (value) {
    case ReviewSessionMode.formal:
      return 'formal';
    case ReviewSessionMode.freePractice:
      return 'free_practice';
  }
}

ReviewSessionMode reviewSessionModeFromKey(String value) {
  switch (value) {
    case 'formal':
      return ReviewSessionMode.formal;
    case 'free_practice':
      return ReviewSessionMode.freePractice;
    default:
      return ReviewSessionMode.formal;
  }
}

ReviewContentType reviewContentTypeForObject(ReviewObjectType objectType) {
  switch (objectType) {
    case ReviewObjectType.letterName:
    case ReviewObjectType.letterSound:
    case ReviewObjectType.letterForm:
      return ReviewContentType.alphabet;
    case ReviewObjectType.symbolReading:
      return ReviewContentType.pronunciation;
    case ReviewObjectType.wordReading:
      return ReviewContentType.word;
    case ReviewObjectType.confusionPair:
      return ReviewContentType.pair;
    case ReviewObjectType.sentencePattern:
      return ReviewContentType.sentence;
    case ReviewObjectType.grammarReference:
      return ReviewContentType.grammar;
  }
}

ReviewPracticeArea? reviewPracticeAreaForObject(ReviewObjectType objectType) {
  switch (objectType) {
    case ReviewObjectType.letterName:
    case ReviewObjectType.letterSound:
    case ReviewObjectType.letterForm:
    case ReviewObjectType.confusionPair:
      return ReviewPracticeArea.letters;
    case ReviewObjectType.symbolReading:
      return ReviewPracticeArea.pronunciation;
    case ReviewObjectType.wordReading:
      return ReviewPracticeArea.words;
    case ReviewObjectType.sentencePattern:
    case ReviewObjectType.grammarReference:
      return null;
  }
}

class ReviewTask {
  final String contentId;
  final ReviewContentType type;
  final ReviewObjectType objectType;
  final ReviewActionType actionType;
  final ReviewTaskOrigin origin;
  final String title;
  final String subtitle;
  final String? arabicText;
  final String? transliteration;
  final String? helperText;
  final String? lessonId;
  final String? sourceId;
  final String? variantKey;
  final String? audioQueryText;
  final int estimatedSeconds;
  final int priority;

  const ReviewTask({
    required this.contentId,
    required this.type,
    this.objectType = ReviewObjectType.wordReading,
    this.actionType = ReviewActionType.repeat,
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
    this.variantKey,
    this.audioQueryText,
  });

  ReviewTask copyWith({
    String? contentId,
    ReviewContentType? type,
    ReviewObjectType? objectType,
    ReviewActionType? actionType,
    ReviewTaskOrigin? origin,
    String? title,
    String? subtitle,
    String? arabicText,
    String? transliteration,
    String? helperText,
    String? lessonId,
    String? sourceId,
    String? variantKey,
    String? audioQueryText,
    int? estimatedSeconds,
    int? priority,
  }) {
    return ReviewTask(
      contentId: contentId ?? this.contentId,
      type: type ?? this.type,
      objectType: objectType ?? this.objectType,
      actionType: actionType ?? this.actionType,
      origin: origin ?? this.origin,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      arabicText: arabicText ?? this.arabicText,
      transliteration: transliteration ?? this.transliteration,
      helperText: helperText ?? this.helperText,
      lessonId: lessonId ?? this.lessonId,
      sourceId: sourceId ?? this.sourceId,
      variantKey: variantKey ?? this.variantKey,
      audioQueryText: audioQueryText ?? this.audioQueryText,
      estimatedSeconds: estimatedSeconds ?? this.estimatedSeconds,
      priority: priority ?? this.priority,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'contentId': contentId,
      'type': reviewContentTypeKey(type),
      'objectType': reviewObjectTypeKey(objectType),
      'actionType': reviewActionTypeKey(actionType),
      'origin': reviewTaskOriginKey(origin),
      'title': title,
      'subtitle': subtitle,
      'arabicText': arabicText,
      'transliteration': transliteration,
      'helperText': helperText,
      'lessonId': lessonId,
      'sourceId': sourceId,
      'variantKey': variantKey,
      'audioQueryText': audioQueryText,
      'estimatedSeconds': estimatedSeconds,
      'priority': priority,
    };
  }

  factory ReviewTask.fromJson(Map<String, dynamic> json) {
    final type = reviewContentTypeFromKey(json['type'] as String? ?? '');
    final objectType = reviewObjectTypeFromKey(
      json['objectType'] as String? ?? _legacyObjectTypeKey(type),
    );
    return ReviewTask(
      contentId: json['contentId'] as String? ?? '',
      type: type,
      objectType: objectType,
      actionType: reviewActionTypeFromKey(
        json['actionType'] as String? ?? _defaultActionTypeKey(objectType),
      ),
      origin: reviewTaskOriginFromKey(json['origin'] as String? ?? ''),
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      arabicText: json['arabicText'] as String?,
      transliteration: json['transliteration'] as String?,
      helperText: json['helperText'] as String?,
      lessonId: json['lessonId'] as String?,
      sourceId: json['sourceId'] as String?,
      variantKey: json['variantKey'] as String?,
      audioQueryText: json['audioQueryText'] as String?,
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
  final Map<ReviewPracticeArea, int> practiceCounts;
  final String? recommendedLessonId;
  final String? recommendedLessonTitle;

  const ReviewSummary({
    required this.todayPlan,
    required this.streakDays,
    required this.weeklyReviewCount,
    this.typeCounts = const <ReviewContentType, int>{},
    this.practiceCounts = const <ReviewPracticeArea, int>{},
    this.recommendedLessonId,
    this.recommendedLessonTitle,
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

  bool get hasFormalTask {
    return summary.todayPlan.tasks.isNotEmpty;
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

String buildLetterNameContentId(String arabic) {
  return 'letter_name:${normalizeReviewKey(arabic)}';
}

String buildLetterSoundContentId(String arabic) {
  return 'letter_sound:${normalizeReviewKey(arabic)}';
}

String buildLetterFormContentId(String arabic) {
  return 'letter_form:${normalizeReviewKey(arabic)}';
}

String buildSymbolReadingContentId(String arabic, String symbolKey) {
  return 'symbol_reading:${normalizeReviewKey(arabic)}:${normalizeReviewKey(symbolKey)}';
}

String buildWordReadingContentId(String plainArabic) {
  return 'word_reading:${normalizeReviewKey(plainArabic)}';
}

String buildConfusionPairContentId(String leftArabic, String rightArabic) {
  final pair = <String>[
    normalizeReviewKey(leftArabic),
    normalizeReviewKey(rightArabic),
  ]..sort();
  return 'confusion_pair:${pair.join('__')}';
}

String buildSentencePatternContentId(String arabic) {
  return 'sentence_pattern:${normalizeReviewKey(arabic)}';
}

String buildGrammarReferenceContentId(String pageId) {
  return 'grammar_reference:${normalizeReviewKey(pageId)}';
}

String buildWordContentId(String plainArabic) {
  return buildWordReadingContentId(plainArabic);
}

String buildSentenceContentId(String arabic) {
  return buildSentencePatternContentId(arabic);
}

String buildGrammarContentId(String pageId) {
  return buildGrammarReferenceContentId(pageId);
}

String buildAlphabetContentId(String arabic) {
  return buildLetterSoundContentId(arabic);
}

String? reviewSourceIdFromContentId(String contentId) {
  final parts = contentId.split(':');
  if (parts.length < 2) {
    return null;
  }
  switch (parts.first) {
    case 'symbol_reading':
      return parts[1];
    case 'confusion_pair':
      return parts.sublist(1).join(':');
    default:
      return parts.sublist(1).join(':');
  }
}

String? reviewVariantKeyFromContentId(String contentId) {
  final parts = contentId.split(':');
  if (parts.first != 'symbol_reading' || parts.length < 3) {
    return null;
  }
  return parts[2];
}

String _legacyObjectTypeKey(ReviewContentType type) {
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

String _defaultActionTypeKey(ReviewObjectType objectType) {
  switch (objectType) {
    case ReviewObjectType.letterName:
    case ReviewObjectType.letterForm:
    case ReviewObjectType.grammarReference:
      return 'recognize';
    case ReviewObjectType.letterSound:
      return 'listen';
    case ReviewObjectType.symbolReading:
    case ReviewObjectType.sentencePattern:
      return 'read';
    case ReviewObjectType.wordReading:
      return 'repeat';
    case ReviewObjectType.confusionPair:
      return 'distinguish';
  }
}