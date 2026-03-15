import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/learning_state_models.dart';
import '../models/review_models.dart';
import 'review_sync_service.dart';

enum LearningPracticeKind {
  viewed,
  listenRead,
  write,
  recognize,
  compare,
  pronounce,
}

class LearningPracticeState {
  final String contentId;
  final bool viewed;
  final bool listenReadCompleted;
  final bool writeCompleted;
  final bool recognitionCompleted;
  final bool comparisonCompleted;
  final bool pronunciationCompleted;
  final DateTime? lastUpdatedAt;

  const LearningPracticeState({
    required this.contentId,
    this.viewed = false,
    this.listenReadCompleted = false,
    this.writeCompleted = false,
    this.recognitionCompleted = false,
    this.comparisonCompleted = false,
    this.pronunciationCompleted = false,
    this.lastUpdatedAt,
  });

  int get completedPracticeCount {
    var count = 0;
    if (listenReadCompleted) count++;
    if (writeCompleted) count++;
    if (recognitionCompleted) count++;
    if (comparisonCompleted) count++;
    if (pronunciationCompleted) count++;
    return count;
  }

  LearningPracticeState copyWith({
    String? contentId,
    bool? viewed,
    bool? listenReadCompleted,
    bool? writeCompleted,
    bool? recognitionCompleted,
    bool? comparisonCompleted,
    bool? pronunciationCompleted,
    DateTime? lastUpdatedAt,
  }) {
    return LearningPracticeState(
      contentId: contentId ?? this.contentId,
      viewed: viewed ?? this.viewed,
      listenReadCompleted: listenReadCompleted ?? this.listenReadCompleted,
      writeCompleted: writeCompleted ?? this.writeCompleted,
      recognitionCompleted:
          recognitionCompleted ?? this.recognitionCompleted,
      comparisonCompleted:
          comparisonCompleted ?? this.comparisonCompleted,
      pronunciationCompleted:
          pronunciationCompleted ?? this.pronunciationCompleted,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'contentId': contentId,
      'viewed': viewed,
      'listenReadCompleted': listenReadCompleted,
      'writeCompleted': writeCompleted,
      'recognitionCompleted': recognitionCompleted,
      'comparisonCompleted': comparisonCompleted,
      'pronunciationCompleted': pronunciationCompleted,
      'lastUpdatedAt': lastUpdatedAt?.toIso8601String(),
    };
  }

  factory LearningPracticeState.fromJson(Map<String, dynamic> json) {
    return LearningPracticeState(
      contentId: json['contentId'] as String? ?? '',
      viewed: json['viewed'] as bool? ?? false,
      listenReadCompleted: json['listenReadCompleted'] as bool? ?? false,
      writeCompleted: json['writeCompleted'] as bool? ?? false,
      recognitionCompleted: json['recognitionCompleted'] as bool? ?? false,
      comparisonCompleted: json['comparisonCompleted'] as bool? ?? false,
      pronunciationCompleted:
          json['pronunciationCompleted'] as bool? ?? false,
      lastUpdatedAt: DateTime.tryParse(json['lastUpdatedAt'] as String? ?? ''),
    );
  }
}

class LearningObjectSnapshot {
  final LearningContentState? state;
  final LearningPracticeState practice;

  const LearningObjectSnapshot({
    required this.state,
    required this.practice,
  });

  LearningStage get status => state?.stage ?? LearningStage.newItem;
  bool get hasViewed => practice.viewed || state?.lastViewedAt != null;
  DateTime? get lastLearningAt => state?.lastStudiedAt ?? state?.lastViewedAt;
  int get errorCount => state?.lapseCount ?? 0;
  int get consecutiveCorrectCount => state?.successCount ?? 0;
}

class LearningStateSummary {
  final int trackedObjectCount;
  final int introducedCount;
  final int practicingCount;
  final int weakCount;
  final int stableCount;
  final int masteredCount;
  final int dueCount;
  final int overdueCount;

  const LearningStateSummary({
    required this.trackedObjectCount,
    required this.introducedCount,
    required this.practicingCount,
    required this.weakCount,
    required this.stableCount,
    required this.masteredCount,
    required this.dueCount,
    required this.overdueCount,
  });
}

class LearningStateService {
  LearningStateService._();

  static const String _statesKey = 'learning_content_states_v1';
  static const String _practiceStatesKey = 'learning_practice_states_v1';

  static Future<Map<String, LearningContentState>> getAllStates() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_statesKey);
    if (raw == null || raw.isEmpty) {
      return <String, LearningContentState>{};
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final items = decoded
          .map(
            (item) => LearningContentState.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(growable: false);
      return <String, LearningContentState>{
        for (final item in items) item.contentId: item,
      };
    } catch (_) {
      return <String, LearningContentState>{};
    }
  }

  static Future<LearningContentState?> getState(String contentId) async {
    final states = await getAllStates();
    return states[contentId];
  }

  static Future<Map<String, LearningPracticeState>> getAllPracticeStates() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_practiceStatesKey);
    if (raw == null || raw.isEmpty) {
      return <String, LearningPracticeState>{};
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final items = decoded
          .map(
            (item) => LearningPracticeState.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(growable: false);
      return <String, LearningPracticeState>{
        for (final item in items) item.contentId: item,
      };
    } catch (_) {
      return <String, LearningPracticeState>{};
    }
  }

  static Future<LearningPracticeState> getPracticeState(String contentId) async {
    final states = await getAllPracticeStates();
    return states[contentId] ?? LearningPracticeState(contentId: contentId);
  }

  static Future<LearningObjectSnapshot> getObjectSnapshot(String contentId) async {
    final results = await Future.wait<dynamic>([
      getState(contentId),
      getPracticeState(contentId),
    ]);
    return LearningObjectSnapshot(
      state: results[0] as LearningContentState?,
      practice: results[1] as LearningPracticeState,
    );
  }

  static Future<LearningStateSummary> getSummary({
    DateTime? now,
  }) async {
    final moment = now ?? DateTime.now();
    final states = await getAllStates();
    var introducedCount = 0;
    var practicingCount = 0;
    var weakCount = 0;
    var stableCount = 0;
    var masteredCount = 0;
    var dueCount = 0;
    var overdueCount = 0;

    for (final state in states.values) {
      switch (state.stage) {
        case LearningStage.newItem:
          break;
        case LearningStage.learning:
          if ((state.reviewCount == 0) && !state.isCompleted) {
            introducedCount++;
          } else {
            practicingCount++;
          }
        case LearningStage.weak:
          weakCount++;
        case LearningStage.reviewDue:
          practicingCount++;
        case LearningStage.stable:
          stableCount++;
        case LearningStage.mastered:
          masteredCount++;
      }

      if (state.isReviewDue || state.needsReview) {
        dueCount++;
      }
      if (state.nextReviewAt != null && state.nextReviewAt!.isBefore(moment)) {
        overdueCount++;
      }
    }

    return LearningStateSummary(
      trackedObjectCount: states.length,
      introducedCount: introducedCount,
      practicingCount: practicingCount,
      weakCount: weakCount,
      stableCount: stableCount,
      masteredCount: masteredCount,
      dueCount: dueCount,
      overdueCount: overdueCount,
    );
  }

  static Future<void> saveAllStates(
    Iterable<LearningContentState> states, {
    bool notify = true,
    ReviewSyncReason syncReason = ReviewSyncReason.learningUpdated,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _statesKey,
      jsonEncode(
        states.map((state) => state.toJson()).toList(growable: false),
      ),
    );
    if (notify) {
      ReviewSyncService.bump(reason: syncReason);
    }
  }

  static Future<void> saveAllPracticeStates(
    Iterable<LearningPracticeState> states, {
    bool notify = true,
    ReviewSyncReason syncReason = ReviewSyncReason.practiceCompleted,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _practiceStatesKey,
      jsonEncode(
        states.map((state) => state.toJson()).toList(growable: false),
      ),
    );
    if (notify) {
      ReviewSyncService.bump(reason: syncReason);
    }
  }

  static Future<void> markViewed({
    required String contentId,
    required ReviewContentType type,
    ReviewObjectType? objectType,
    String? lessonId,
    DateTime? viewedAt,
  }) async {
    final states = await getAllStates();
    final existing = states[contentId];
    final now = viewedAt ?? DateTime.now();
    states[contentId] = _mergeState(
      existing: existing,
      contentId: contentId,
      type: type,
      objectType: objectType,
      lessonId: lessonId,
      lastViewedAt: now,
      isStarted: true,
      stage: existing?.stage == LearningStage.newItem
          ? LearningStage.learning
          : (existing?.stage ?? LearningStage.learning),
    );
    await _markPracticeFlags(
      contentId: contentId,
      updates: const <LearningPracticeKind>{LearningPracticeKind.viewed},
      notify: false,
    );
    await saveAllStates(states.values, syncReason: ReviewSyncReason.learningUpdated);
  }

  static Future<void> setFavorited({
    required String contentId,
    required ReviewContentType type,
    ReviewObjectType? objectType,
    required bool isFavorited,
    String? lessonId,
  }) async {
    final states = await getAllStates();
    final existing = states[contentId];
    final priority = existing?.reviewPriority ?? 0;
    states[contentId] = _mergeState(
      existing: existing,
      contentId: contentId,
      type: type,
      objectType: objectType,
      lessonId: lessonId,
      isFavorited: isFavorited,
      needsReview: (existing?.needsReview ?? false) || isFavorited,
      reviewPriority: isFavorited ? priority + 1 : priority.clamp(0, 99),
    );
    await saveAllStates(states.values, syncReason: ReviewSyncReason.learningUpdated);
  }

  static Future<void> setWeak({
    required String contentId,
    required ReviewContentType type,
    ReviewObjectType? objectType,
    required bool isWeak,
    String? lessonId,
  }) async {
    final states = await getAllStates();
    final existing = states[contentId];
    final basePriority = existing?.reviewPriority ?? 0;
    states[contentId] = _mergeState(
      existing: existing,
      contentId: contentId,
      type: type,
      objectType: objectType,
      lessonId: lessonId,
      isStarted: true,
      lastViewedAt: existing?.lastViewedAt ?? DateTime.now(),
      needsReview: isWeak || (existing?.needsReview ?? false),
      isWeak: isWeak,
      nextReviewAt: isWeak ? DateTime.now() : existing?.nextReviewAt,
      stage: isWeak ? LearningStage.weak : (existing?.stage ?? LearningStage.learning),
      reviewPriority: isWeak ? basePriority + 2 : (basePriority - 1).clamp(0, 99),
    );
    await saveAllStates(states.values, syncReason: ReviewSyncReason.stageChanged);
  }

  static Future<void> markReviewResult({
    required String contentId,
    required ReviewContentType type,
    ReviewObjectType? objectType,
    required bool remembered,
    String? lessonId,
    DateTime? reviewedAt,
  }) async {
    final states = await getAllStates();
    final existing = states[contentId];
    final now = reviewedAt ?? DateTime.now();
    final currentPriority = existing?.reviewPriority ?? 0;
    final successCount = existing?.successCount ?? 0;
    final nextSuccessCount = remembered ? successCount + 1 : successCount;
    final stage = remembered
        ? (nextSuccessCount >= 3 ? LearningStage.mastered : LearningStage.stable)
        : LearningStage.weak;
    states[contentId] = _mergeState(
      existing: existing,
      contentId: contentId,
      type: type,
      objectType: objectType,
      lessonId: lessonId,
      isStarted: true,
      isCompleted: true,
      lastStudiedAt: now,
      lastViewedAt: now,
      lastReviewedAt: now,
      nextReviewAt: remembered
          ? now.add(Duration(days: nextSuccessCount >= 2 ? 3 : 1))
          : now.add(const Duration(hours: 8)),
      stage: stage,
      needsReview: !remembered,
      isWeak: !remembered,
      reviewPriority: remembered
          ? (currentPriority - 1).clamp(0, 99)
          : currentPriority + 2,
      reviewCount: (existing?.reviewCount ?? 0) + 1,
      successCount: nextSuccessCount,
      lapseCount: remembered
          ? (existing?.lapseCount ?? 0)
          : (existing?.lapseCount ?? 0) + 1,
    );
    await saveAllStates(states.values, syncReason: ReviewSyncReason.stageChanged);
  }

  static Future<void> upsertLearningState({
    required String contentId,
    required ReviewContentType type,
    required ReviewObjectType objectType,
    required LearningStage stage,
    String? lessonId,
    DateTime? lastViewedAt,
    DateTime? lastStudiedAt,
    DateTime? lastReviewedAt,
    DateTime? nextReviewAt,
    bool? isStarted,
    bool? isCompleted,
    bool? needsReview,
    bool? isWeak,
    bool? isFavorited,
    int? reviewPriority,
    int? reviewCount,
    int? successCount,
    int? lapseCount,
  }) async {
    final states = await getAllStates();
    states[contentId] = _mergeState(
      existing: states[contentId],
      contentId: contentId,
      type: type,
      objectType: objectType,
      lessonId: lessonId,
      lastViewedAt: lastViewedAt,
      lastStudiedAt: lastStudiedAt,
      lastReviewedAt: lastReviewedAt,
      nextReviewAt: nextReviewAt,
      stage: stage,
      isStarted: isStarted,
      isCompleted: isCompleted,
      needsReview: needsReview,
      isWeak: isWeak,
      isFavorited: isFavorited,
      reviewPriority: reviewPriority,
      reviewCount: reviewCount,
      successCount: successCount,
      lapseCount: lapseCount,
    );
    await saveAllStates(states.values, syncReason: ReviewSyncReason.learningUpdated);
  }

  static Future<void> markPracticeCompleted({
    required String contentId,
    required ReviewContentType type,
    required ReviewObjectType objectType,
    required LearningPracticeKind practiceKind,
    String? lessonId,
    DateTime? completedAt,
  }) async {
    final now = completedAt ?? DateTime.now();
    final states = await getAllStates();
    final existing = states[contentId];
    states[contentId] = _mergeState(
      existing: existing,
      contentId: contentId,
      type: type,
      objectType: objectType,
      lessonId: lessonId,
      isStarted: true,
      isCompleted: true,
      lastViewedAt: now,
      lastStudiedAt: now,
      stage: _resolvedStageAfterPractice(existing?.stage, practiceKind),
      needsReview: practiceKind == LearningPracticeKind.listenRead ||
          practiceKind == LearningPracticeKind.pronounce,
      reviewPriority: _priorityAfterPractice(existing?.reviewPriority ?? 0, practiceKind),
      nextReviewAt: _nextReviewAtAfterPractice(now, practiceKind),
    );
    await _markPracticeFlags(
      contentId: contentId,
      updates: <LearningPracticeKind>{practiceKind},
      updatedAt: now,
      notify: false,
    );
    await saveAllStates(states.values, syncReason: ReviewSyncReason.practiceCompleted);
  }

  static LearningContentState _mergeState({
    required LearningContentState? existing,
    required String contentId,
    required ReviewContentType type,
    ReviewObjectType? objectType,
    String? lessonId,
    DateTime? lastViewedAt,
    DateTime? lastStudiedAt,
    DateTime? lastReviewedAt,
    DateTime? nextReviewAt,
    LearningStage? stage,
    bool? isStarted,
    bool? isCompleted,
    bool? needsReview,
    bool? isWeak,
    bool? isFavorited,
    int? reviewPriority,
    int? reviewCount,
    int? successCount,
    int? lapseCount,
  }) {
    final resolvedObjectType = objectType ?? existing?.objectType ?? _inferObjectType(type, contentId);
    final resolvedStage = stage ?? existing?.stage ?? LearningStage.learning;
    final resolvedNeedsReview = needsReview ??
        (resolvedStage == LearningStage.reviewDue || resolvedStage == LearningStage.weak);
    final resolvedIsWeak = isWeak ?? (resolvedStage == LearningStage.weak);
    final resolvedIsCompleted = isCompleted ??
        existing?.isCompleted ??
        (resolvedStage == LearningStage.stable || resolvedStage == LearningStage.mastered);
    return LearningContentState(
      contentId: contentId,
      type: type,
      objectType: resolvedObjectType,
      lessonId: lessonId ?? existing?.lessonId,
      isStarted: isStarted ?? existing?.isStarted ?? true,
      isCompleted: resolvedIsCompleted,
      lastStudiedAt: lastStudiedAt ?? existing?.lastStudiedAt,
      lastViewedAt: lastViewedAt ?? existing?.lastViewedAt,
      lastReviewedAt: lastReviewedAt ?? existing?.lastReviewedAt,
      nextReviewAt: nextReviewAt ?? existing?.nextReviewAt,
      stage: resolvedStage,
      needsReview: resolvedNeedsReview,
      isWeak: resolvedIsWeak,
      isFavorited: isFavorited ?? existing?.isFavorited ?? false,
      reviewPriority: reviewPriority ?? existing?.reviewPriority ?? 0,
      reviewCount: reviewCount ?? existing?.reviewCount ?? 0,
      successCount: successCount ?? existing?.successCount ?? 0,
      lapseCount: lapseCount ?? existing?.lapseCount ?? 0,
    );
  }

  static Future<void> _markPracticeFlags({
    required String contentId,
    required Set<LearningPracticeKind> updates,
    DateTime? updatedAt,
    bool notify = true,
  }) async {
    final practiceStates = await getAllPracticeStates();
    final existing = practiceStates[contentId] ??
        LearningPracticeState(contentId: contentId);
    practiceStates[contentId] = existing.copyWith(
      viewed: updates.contains(LearningPracticeKind.viewed) ? true : null,
      listenReadCompleted:
          updates.contains(LearningPracticeKind.listenRead) ? true : null,
      writeCompleted: updates.contains(LearningPracticeKind.write) ? true : null,
      recognitionCompleted:
          updates.contains(LearningPracticeKind.recognize) ? true : null,
      comparisonCompleted:
          updates.contains(LearningPracticeKind.compare) ? true : null,
      pronunciationCompleted:
          updates.contains(LearningPracticeKind.pronounce) ? true : null,
      lastUpdatedAt: updatedAt ?? DateTime.now(),
    );
    await saveAllPracticeStates(
      practiceStates.values,
      notify: notify,
      syncReason: ReviewSyncReason.practiceCompleted,
    );
  }

  static LearningStage _resolvedStageAfterPractice(
    LearningStage? currentStage,
    LearningPracticeKind practiceKind,
  ) {
    if (currentStage == LearningStage.weak || currentStage == LearningStage.reviewDue) {
      return currentStage!;
    }
    switch (practiceKind) {
      case LearningPracticeKind.viewed:
        return LearningStage.learning;
      case LearningPracticeKind.listenRead:
      case LearningPracticeKind.write:
      case LearningPracticeKind.recognize:
      case LearningPracticeKind.compare:
      case LearningPracticeKind.pronounce:
        return LearningStage.reviewDue;
    }
  }

  static int _priorityAfterPractice(int currentPriority, LearningPracticeKind kind) {
    switch (kind) {
      case LearningPracticeKind.viewed:
        return currentPriority;
      case LearningPracticeKind.listenRead:
      case LearningPracticeKind.pronounce:
        return currentPriority + 2;
      case LearningPracticeKind.write:
      case LearningPracticeKind.recognize:
      case LearningPracticeKind.compare:
        return currentPriority + 1;
    }
  }

  static DateTime? _nextReviewAtAfterPractice(
    DateTime now,
    LearningPracticeKind kind,
  ) {
    switch (kind) {
      case LearningPracticeKind.viewed:
        return null;
      case LearningPracticeKind.listenRead:
      case LearningPracticeKind.pronounce:
        return now;
      case LearningPracticeKind.write:
      case LearningPracticeKind.recognize:
      case LearningPracticeKind.compare:
        return now.add(const Duration(hours: 6));
    }
  }

  static ReviewObjectType _inferObjectType(
    ReviewContentType type,
    String contentId,
  ) {
    if (contentId.startsWith('letter_name:')) {
      return ReviewObjectType.letterName;
    }
    if (contentId.startsWith('letter_form:')) {
      return ReviewObjectType.letterForm;
    }
    if (contentId.startsWith('symbol_reading:')) {
      return ReviewObjectType.symbolReading;
    }
    if (contentId.startsWith('confusion_pair:')) {
      return ReviewObjectType.confusionPair;
    }
    if (contentId.startsWith('sentence_pattern:')) {
      return ReviewObjectType.sentencePattern;
    }
    if (contentId.startsWith('grammar_reference:')) {
      return ReviewObjectType.grammarReference;
    }
    switch (type) {
      case ReviewContentType.alphabet:
        return ReviewObjectType.letterSound;
      case ReviewContentType.pronunciation:
        return ReviewObjectType.symbolReading;
      case ReviewContentType.word:
        return ReviewObjectType.wordReading;
      case ReviewContentType.pair:
        return ReviewObjectType.confusionPair;
      case ReviewContentType.sentence:
        return ReviewObjectType.sentencePattern;
      case ReviewContentType.grammar:
        return ReviewObjectType.grammarReference;
    }
  }
}
