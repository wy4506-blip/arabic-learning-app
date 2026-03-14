import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/learning_state_models.dart';
import '../models/review_models.dart';
import 'review_sync_service.dart';

class LearningStateService {
  LearningStateService._();

  static const String _statesKey = 'learning_content_states_v1';

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

  static Future<void> saveAllStates(
    Iterable<LearningContentState> states, {
    bool notify = true,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _statesKey,
      jsonEncode(
        states.map((state) => state.toJson()).toList(growable: false),
      ),
    );
    if (notify) {
      ReviewSyncService.bump();
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
    await saveAllStates(states.values);
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
    await saveAllStates(states.values);
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
    await saveAllStates(states.values);
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
    await saveAllStates(states.values);
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
    await saveAllStates(states.values);
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
