import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/lesson.dart';
import '../models/learning_state_models.dart';
import '../models/v2_lesson_progress_models.dart';
import 'learning_state_service.dart';

class ProgressSnapshot {
  final Set<String> completedLessons;
  final Set<String> startedLessons;
  final int reviewCount;
  final int streakDays;
  final String? lastLessonId;
  final String? currentLessonId;
  final String? currentGroupId;
  final String? currentPhaseId;
  final Map<String, V2LessonProgressRecord> lessonProgressRecords;

  const ProgressSnapshot({
    required this.completedLessons,
    required this.startedLessons,
    required this.reviewCount,
    required this.streakDays,
    this.lastLessonId,
    this.currentLessonId,
    this.currentGroupId,
    this.currentPhaseId,
    this.lessonProgressRecords = const <String, V2LessonProgressRecord>{},
  });

  String? get activeLessonId => currentLessonId ?? lastLessonId;
  int get completedLessonCount => completedLessons.length;
  int get startedLessonCount => startedLessons.length;
  bool get hasStartedAny => startedLessons.isNotEmpty;
}

class ProgressStageSummary {
  final String stageId;
  final int totalLessonCount;
  final int startedLessonCount;
  final int completedLessonCount;
  final bool isCurrent;
  final V2PhaseStatus status;
  final int reviewDueCount;

  const ProgressStageSummary({
    required this.stageId,
    required this.totalLessonCount,
    required this.startedLessonCount,
    required this.completedLessonCount,
    required this.isCurrent,
    required this.status,
    required this.reviewDueCount,
  });

  double get completionRate =>
      totalLessonCount == 0 ? 0 : completedLessonCount / totalLessonCount;
}

class ProgressOverview {
  final String? currentPhaseId;
  final String? currentGroupId;
  final String? currentLessonId;
  final String? recommendedLessonId;
  final int totalLessonCount;
  final int completedLessonCount;
  final int coreCompletedLessonCount;
  final int reviewDueLessonCount;
  final int startedLessonCount;
  final int reviewCount;
  final int streakDays;
  final Map<String, V2LessonStatus> lessonStatuses;
  final List<ProgressStageSummary> stageSummaries;

  const ProgressOverview({
    required this.currentPhaseId,
    required this.currentGroupId,
    required this.currentLessonId,
    required this.recommendedLessonId,
    required this.totalLessonCount,
    required this.completedLessonCount,
    required this.coreCompletedLessonCount,
    required this.reviewDueLessonCount,
    required this.startedLessonCount,
    required this.reviewCount,
    required this.streakDays,
    required this.lessonStatuses,
    required this.stageSummaries,
  });

  int get remainingLessonCount =>
      (totalLessonCount - completedLessonCount).clamp(0, totalLessonCount);

  double get completionRate =>
      totalLessonCount == 0 ? 0 : completedLessonCount / totalLessonCount;

  ProgressStageSummary? get currentStageSummary {
    for (final summary in stageSummaries) {
      if (summary.isCurrent) {
        return summary;
      }
    }
    return null;
  }

  String get progressSummaryText {
    if (totalLessonCount == 0) {
      return '0/0';
    }
    return '$completedLessonCount/$totalLessonCount';
  }

  V2LessonStatus lessonStatusFor(String lessonId) {
    return lessonStatuses[lessonId] ?? V2LessonStatus.available;
  }
}

class ProgressService {
  static const _completedLessonsKey = 'completed_lessons';
  static const _startedLessonsKey = 'started_lessons';
  static const _reviewCountKey = 'review_count';
  static const _streakDaysKey = 'streak_days';
  static const _lastLessonIdKey = 'last_lesson_id';
  static const _currentLessonIdKey = 'current_lesson_id';
  static const _currentGroupIdKey = 'current_group_id';
  static const _currentPhaseIdKey = 'current_phase_id';
  static const _v2LessonProgressKey = 'v2_lesson_progress_records_v1';

  static Future<ProgressSnapshot> getSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    final lastLessonId = prefs.getString(_lastLessonIdKey);
    final currentLessonId = prefs.getString(_currentLessonIdKey);
    return ProgressSnapshot(
      completedLessons:
          (prefs.getStringList(_completedLessonsKey) ?? const []).toSet(),
      startedLessons:
          (prefs.getStringList(_startedLessonsKey) ?? const []).toSet(),
      reviewCount: prefs.getInt(_reviewCountKey) ?? 0,
      streakDays: prefs.getInt(_streakDaysKey) ?? 0,
      lastLessonId: lastLessonId,
      currentLessonId: currentLessonId ?? lastLessonId,
      currentGroupId: prefs.getString(_currentGroupIdKey) ??
          _inferGroupIdFromLessonId(currentLessonId ?? lastLessonId),
      currentPhaseId: prefs.getString(_currentPhaseIdKey) ??
          _inferPhaseIdFromLessonId(currentLessonId ?? lastLessonId),
      lessonProgressRecords: _readLessonProgressRecords(prefs),
    );
  }

  static ProgressOverview buildOverview({
    required List<Lesson> lessons,
    required ProgressSnapshot snapshot,
    bool unlocked = true,
    Map<String, LearningContentState> learningStates =
        const <String, LearningContentState>{},
  }) {
    final lessonStatuses = <String, V2LessonStatus>{
      for (final lesson in lessons)
        lesson.id: resolveLessonStatus(
          lesson: lesson,
          snapshot: snapshot,
          unlocked: unlocked,
          learningStates: learningStates,
        ),
    };
    final completedLessonIds = lessonStatuses.entries
        .where((entry) => entry.value.isCompletedLike)
        .map((entry) => entry.key)
        .toSet();
    final coreCompletedLessonIds = lessonStatuses.entries
        .where((entry) => entry.value == V2LessonStatus.coreCompleted)
        .map((entry) => entry.key)
        .toSet();
    final startedLessonIds = lessonStatuses.entries
        .where((entry) => entry.value.isStartedLike)
        .map((entry) => entry.key)
        .toSet();
    final currentLesson = _resolveCurrentLesson(
      lessons: lessons,
      lessonStatuses: lessonStatuses,
      activeLessonId: snapshot.activeLessonId,
    );
    final recommendedLesson = _resolveRecommendedLesson(
      lessons: lessons,
      lessonStatuses: lessonStatuses,
      currentLessonId: currentLesson?.id,
    );
    final currentPhaseId = snapshot.currentPhaseId ??
        (currentLesson != null
            ? _phaseIdForUnitId(currentLesson.unitId)
            : (_phaseIdForLessons(lessons) ?? 'phase_unknown'));
    final currentGroupId = snapshot.currentGroupId ??
        currentLesson?.unitId ??
        _inferGroupIdFromLessonId(snapshot.activeLessonId);

    final grouped = <String, List<Lesson>>{};
    for (final lesson in lessons) {
      final phaseId = _phaseIdForUnitId(lesson.unitId);
      grouped.putIfAbsent(phaseId, () => <Lesson>[]).add(lesson);
    }

    final stageSummaries = grouped.entries.map((entry) {
      final phaseLessons = entry.value;
      final phaseStatuses = phaseLessons
          .map(
              (lesson) => lessonStatuses[lesson.id] ?? V2LessonStatus.available)
          .toList(growable: false);
      final reviewDueCount = phaseStatuses
          .where((status) => status == V2LessonStatus.dueForReview)
          .length;
      return ProgressStageSummary(
        stageId: entry.key,
        totalLessonCount: phaseLessons.length,
        startedLessonCount:
            phaseStatuses.where((status) => status.isStartedLike).length,
        completedLessonCount:
            phaseStatuses.where((status) => status.isCompletedLike).length,
        isCurrent: entry.key == currentPhaseId,
        status: resolvePhaseStatus(phaseStatuses),
        reviewDueCount: reviewDueCount,
      );
    }).toList(growable: false)
      ..sort((a, b) => a.stageId.compareTo(b.stageId));

    return ProgressOverview(
      currentPhaseId: currentPhaseId,
      currentGroupId: currentGroupId,
      currentLessonId: currentLesson?.id ?? snapshot.activeLessonId,
      recommendedLessonId: recommendedLesson?.id,
      totalLessonCount: lessons.length,
      completedLessonCount: completedLessonIds.length,
      coreCompletedLessonCount: coreCompletedLessonIds.length,
      reviewDueLessonCount: lessonStatuses.values
          .where((status) => status == V2LessonStatus.dueForReview)
          .length,
      startedLessonCount: startedLessonIds.length,
      reviewCount: snapshot.reviewCount,
      streakDays: snapshot.streakDays,
      lessonStatuses: lessonStatuses,
      stageSummaries: stageSummaries,
    );
  }

  static Future<ProgressOverview> getOverview({
    required List<Lesson> lessons,
    bool unlocked = true,
    Map<String, LearningContentState>? learningStates,
  }) async {
    final snapshot = await getSnapshot();
    final resolvedLearningStates =
        learningStates ?? await LearningStateService.getAllStates();
    return buildOverview(
      lessons: lessons,
      snapshot: snapshot,
      unlocked: unlocked,
      learningStates: resolvedLearningStates,
    );
  }

  static V2LessonStatus resolveLessonStatus({
    required Lesson lesson,
    required ProgressSnapshot snapshot,
    required bool unlocked,
    Map<String, LearningContentState> learningStates =
        const <String, LearningContentState>{},
  }) {
    final baseStatus = _resolveStoredLessonStatus(
      lesson: lesson,
      snapshot: snapshot,
      unlocked: unlocked,
    );
    return _resolveEffectiveLessonStatus(
      lessonId: lesson.id,
      snapshot: snapshot,
      baseStatus: baseStatus,
      learningStates: learningStates,
    );
  }

  static V2LessonStatus _resolveStoredLessonStatus({
    required Lesson lesson,
    required ProgressSnapshot snapshot,
    required bool unlocked,
  }) {
    final record = snapshot.lessonProgressRecords[lesson.id];
    if (record != null) {
      if (!unlocked &&
          lesson.isLocked &&
          record.status == V2LessonStatus.available) {
        return V2LessonStatus.locked;
      }
      return record.status;
    }

    if (snapshot.completedLessons.contains(lesson.id)) {
      return V2LessonStatus.completed;
    }
    if (snapshot.startedLessons.contains(lesson.id)) {
      return V2LessonStatus.inProgress;
    }
    if (!unlocked && lesson.isLocked) {
      return V2LessonStatus.locked;
    }
    return V2LessonStatus.available;
  }

  static V2LessonStatus _resolveEffectiveLessonStatus({
    required String lessonId,
    required ProgressSnapshot snapshot,
    required V2LessonStatus baseStatus,
    required Map<String, LearningContentState> learningStates,
  }) {
    if (baseStatus == V2LessonStatus.locked) {
      return baseStatus;
    }

    final hasPendingReview = _lessonHasPendingReview(
      lessonId: lessonId,
      learningStates: learningStates,
    );
    final hasTrackedLearningState = _lessonHasTrackedLearningState(
      lessonId: lessonId,
      learningStates: learningStates,
    );
    if (hasPendingReview &&
        (baseStatus.isCompletedLike ||
            baseStatus == V2LessonStatus.coreCompleted ||
            snapshot.completedLessons.contains(lessonId))) {
      return V2LessonStatus.dueForReview;
    }

    if (baseStatus == V2LessonStatus.dueForReview &&
        hasTrackedLearningState &&
        !hasPendingReview) {
      return _normalizedCompletedStatus(lessonId: lessonId, snapshot: snapshot);
    }

    return baseStatus;
  }

  static bool _lessonHasPendingReview({
    required String lessonId,
    required Map<String, LearningContentState> learningStates,
  }) {
    for (final state in learningStates.values) {
      if (state.lessonId != lessonId || !state.isStarted) {
        continue;
      }
      if (state.isWeak || state.isReviewDue || state.needsReview) {
        return true;
      }
    }
    return false;
  }

  static bool _lessonHasTrackedLearningState({
    required String lessonId,
    required Map<String, LearningContentState> learningStates,
  }) {
    for (final state in learningStates.values) {
      if (state.lessonId == lessonId && state.isStarted) {
        return true;
      }
    }
    return false;
  }

  static V2LessonStatus _normalizedCompletedStatus({
    required String lessonId,
    required ProgressSnapshot snapshot,
  }) {
    final record = snapshot.lessonProgressRecords[lessonId];
    if (record?.status == V2LessonStatus.mastered) {
      return V2LessonStatus.mastered;
    }
    if (record?.status == V2LessonStatus.coreCompleted) {
      return V2LessonStatus.coreCompleted;
    }
    if (snapshot.completedLessons.contains(lessonId) ||
        record?.status == V2LessonStatus.completed ||
        record?.status == V2LessonStatus.dueForReview) {
      return V2LessonStatus.completed;
    }
    if (snapshot.startedLessons.contains(lessonId)) {
      return V2LessonStatus.inProgress;
    }
    return record?.status ?? V2LessonStatus.available;
  }

  static Future<void> markLessonStarted(String lessonId) async {
    final prefs = await SharedPreferences.getInstance();
    final started =
        (prefs.getStringList(_startedLessonsKey) ?? const []).toSet();
    started.add(lessonId);
    await prefs.setStringList(_startedLessonsKey, started.toList());
    await _saveCurrentContext(prefs, lessonId);
    final streak = prefs.getInt(_streakDaysKey) ?? 0;
    if (streak == 0) await prefs.setInt(_streakDaysKey, 1);
  }

  static Future<void> markLessonCompleted(String lessonId) async {
    final prefs = await SharedPreferences.getInstance();
    final completed =
        (prefs.getStringList(_completedLessonsKey) ?? const []).toSet();
    completed.add(lessonId);
    await prefs.setStringList(_completedLessonsKey, completed.toList());
    await markLessonStarted(lessonId);
  }

  static Future<void> incrementReviewCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_reviewCountKey) ?? 0;
    await prefs.setInt(_reviewCountKey, count + 1);
  }

  static Future<void> _saveCurrentContext(
    SharedPreferences prefs,
    String lessonId,
  ) async {
    await prefs.setString(_lastLessonIdKey, lessonId);
    await prefs.setString(_currentLessonIdKey, lessonId);

    final groupId = _inferGroupIdFromLessonId(lessonId);
    if (groupId != null && groupId.isNotEmpty) {
      await prefs.setString(_currentGroupIdKey, groupId);
    }

    final phaseId = _inferPhaseIdFromLessonId(lessonId);
    if (phaseId != null && phaseId.isNotEmpty) {
      await prefs.setString(_currentPhaseIdKey, phaseId);
    }
  }

  static Lesson? _resolveCurrentLesson({
    required List<Lesson> lessons,
    required Map<String, V2LessonStatus> lessonStatuses,
    required String? activeLessonId,
  }) {
    if (activeLessonId != null) {
      for (final lesson in lessons) {
        final status = lessonStatuses[lesson.id] ?? V2LessonStatus.available;
        if (lesson.id == activeLessonId && status.isCurrentLike) {
          return lesson;
        }
      }
    }

    for (final lesson in lessons) {
      final status = lessonStatuses[lesson.id] ?? V2LessonStatus.available;
      if (status.isCurrentLike) {
        return lesson;
      }
    }

    for (final lesson in lessons) {
      final status = lessonStatuses[lesson.id] ?? V2LessonStatus.available;
      if (!status.isCompletedLike && status != V2LessonStatus.locked) {
        return lesson;
      }
    }

    return lessons.isEmpty ? null : lessons.last;
  }

  static Lesson? _resolveRecommendedLesson({
    required List<Lesson> lessons,
    required Map<String, V2LessonStatus> lessonStatuses,
    required String? currentLessonId,
  }) {
    if (currentLessonId != null) {
      for (final lesson in lessons) {
        final status = lessonStatuses[lesson.id] ?? V2LessonStatus.available;
        if (lesson.id == currentLessonId && status.isCurrentLike) {
          return lesson;
        }
      }
    }

    for (final lesson in lessons) {
      final status = lessonStatuses[lesson.id] ?? V2LessonStatus.available;
      if (status == V2LessonStatus.available ||
          status == V2LessonStatus.coreCompleted) {
        return lesson;
      }
    }

    for (final lesson in lessons) {
      final status = lessonStatuses[lesson.id] ?? V2LessonStatus.available;
      if (status == V2LessonStatus.dueForReview) {
        return lesson;
      }
    }

    return lessons.isEmpty ? null : lessons.last;
  }

  static V2PhaseStatus resolvePhaseStatus(List<V2LessonStatus> statuses) {
    if (statuses.isEmpty ||
        statuses.every(
            (status) => !status.isStartedLike && !status.isCompletedLike)) {
      return V2PhaseStatus.notStarted;
    }

    final allCompletedLike = statuses.every(
      (status) => status.isCompletedLike || status == V2LessonStatus.locked,
    );
    final hasDueReview =
        statuses.any((status) => status == V2LessonStatus.dueForReview);
    if (allCompletedLike) {
      return hasDueReview
          ? V2PhaseStatus.consolidation
          : V2PhaseStatus.completed;
    }

    return V2PhaseStatus.active;
  }

  static Map<String, V2LessonProgressRecord> _readLessonProgressRecords(
    SharedPreferences prefs,
  ) {
    final raw = prefs.getString(_v2LessonProgressKey);
    if (raw == null || raw.isEmpty) {
      return const <String, V2LessonProgressRecord>{};
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final records = decoded
          .whereType<Map<String, dynamic>>()
          .map(V2LessonProgressRecord.fromJson)
          .toList(growable: false);
      return <String, V2LessonProgressRecord>{
        for (final record in records) record.lessonId: record,
      };
    } catch (_) {
      return const <String, V2LessonProgressRecord>{};
    }
  }

  static String? _inferGroupIdFromLessonId(String? lessonId) {
    if (lessonId == null || lessonId.isEmpty) {
      return null;
    }
    final match = RegExp(r'^(U\d+)').firstMatch(lessonId);
    return match?.group(1);
  }

  static String? _inferPhaseIdFromLessonId(String? lessonId) {
    final groupId = _inferGroupIdFromLessonId(lessonId);
    return _phaseIdForUnitId(groupId);
  }

  static String? _phaseIdForLessons(List<Lesson> lessons) {
    if (lessons.isEmpty) {
      return null;
    }
    return _phaseIdForUnitId(lessons.first.unitId);
  }

  static String _phaseIdForUnitId(String? unitId) {
    if (unitId == null || unitId.isEmpty) {
      return 'phase_unknown';
    }
    return 'phase_${unitId.toLowerCase()}';
  }
}
