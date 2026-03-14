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
    String? lessonId,
    DateTime? viewedAt,
  }) async {
    final states = await getAllStates();
    final existing = states[contentId];
    states[contentId] = LearningContentState(
      contentId: contentId,
      type: type,
      lessonId: lessonId ?? existing?.lessonId,
      isStarted: true,
      isCompleted: existing?.isCompleted ?? false,
      lastStudiedAt: existing?.lastStudiedAt,
      lastViewedAt: viewedAt ?? DateTime.now(),
      needsReview: existing?.needsReview ?? false,
      isWeak: existing?.isWeak ?? false,
      isFavorited: existing?.isFavorited ?? false,
      reviewPriority: existing?.reviewPriority ?? 0,
    );
    await saveAllStates(states.values);
  }

  static Future<void> setFavorited({
    required String contentId,
    required ReviewContentType type,
    required bool isFavorited,
    String? lessonId,
  }) async {
    final states = await getAllStates();
    final existing = states[contentId];
    states[contentId] = LearningContentState(
      contentId: contentId,
      type: type,
      lessonId: lessonId ?? existing?.lessonId,
      isStarted: existing?.isStarted ?? false,
      isCompleted: existing?.isCompleted ?? false,
      lastStudiedAt: existing?.lastStudiedAt,
      lastViewedAt: existing?.lastViewedAt,
      needsReview: (existing?.needsReview ?? false) || isFavorited,
      isWeak: existing?.isWeak ?? false,
      isFavorited: isFavorited,
      reviewPriority: isFavorited
          ? (existing?.reviewPriority ?? 0) + 1
          : (existing?.reviewPriority ?? 0).clamp(0, 99),
    );
    await saveAllStates(states.values);
  }

  static Future<void> setWeak({
    required String contentId,
    required ReviewContentType type,
    required bool isWeak,
    String? lessonId,
  }) async {
    final states = await getAllStates();
    final existing = states[contentId];
    final basePriority = existing?.reviewPriority ?? 0;
    states[contentId] = LearningContentState(
      contentId: contentId,
      type: type,
      lessonId: lessonId ?? existing?.lessonId,
      isStarted: existing?.isStarted ?? true,
      isCompleted: existing?.isCompleted ?? false,
      lastStudiedAt: existing?.lastStudiedAt,
      lastViewedAt: existing?.lastViewedAt ?? DateTime.now(),
      needsReview: isWeak || (existing?.needsReview ?? false),
      isWeak: isWeak,
      isFavorited: existing?.isFavorited ?? false,
      reviewPriority: isWeak ? basePriority + 2 : (basePriority - 1).clamp(0, 99),
    );
    await saveAllStates(states.values);
  }

  static Future<void> markReviewResult({
    required String contentId,
    required ReviewContentType type,
    required bool remembered,
    String? lessonId,
    DateTime? reviewedAt,
  }) async {
    final states = await getAllStates();
    final existing = states[contentId];
    final now = reviewedAt ?? DateTime.now();
    final currentPriority = existing?.reviewPriority ?? 0;
    states[contentId] = LearningContentState(
      contentId: contentId,
      type: type,
      lessonId: lessonId ?? existing?.lessonId,
      isStarted: true,
      isCompleted: true,
      lastStudiedAt: now,
      lastViewedAt: now,
      needsReview: !remembered,
      isWeak: !remembered,
      isFavorited: existing?.isFavorited ?? false,
      reviewPriority: remembered
          ? (currentPriority - 1).clamp(0, 99)
          : currentPriority + 2,
    );
    await saveAllStates(states.values);
  }
}
