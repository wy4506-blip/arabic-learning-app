import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/learning_state_models.dart';
import '../models/lesson.dart';
import '../models/review_models.dart';
import '../models/v2_lesson_progress_models.dart';
import 'progress_service.dart';

class LessonCompletionEvaluation {
  final List<String> completedBlockIds;
  final List<V2ObjectiveProgressRecord> objectiveResults;
  final double? currentScore;
  final bool confirmationPassed;
  final String? nextRecommendedLessonId;

  const LessonCompletionEvaluation({
    required this.completedBlockIds,
    required this.objectiveResults,
    this.currentScore,
    this.confirmationPassed = true,
    this.nextRecommendedLessonId,
  });
}

class LessonCompletionEvaluator {
  const LessonCompletionEvaluator._();

  static V2LessonProgressRecord apply({
    required V2LessonProgressRecord existing,
    required LessonCompletionEvaluation evaluation,
  }) {
    final weakObjectiveIds = evaluation.objectiveResults
        .where((item) =>
            item.status == V2ObjectiveStatus.weak || !item.reachedThreshold)
        .map((item) => item.objectiveId)
        .toList(growable: false);
    final allReached = evaluation.objectiveResults.isNotEmpty &&
        weakObjectiveIds.isEmpty &&
        evaluation.confirmationPassed;

    return existing.copyWith(
      status:
          allReached ? V2LessonStatus.completed : V2LessonStatus.coreCompleted,
      currentScore: evaluation.currentScore,
      targetReached: allReached,
      weakObjectiveIds: weakObjectiveIds,
      objectiveResults: evaluation.objectiveResults,
      completedBlockIds: evaluation.completedBlockIds,
      lastCompletedAt: DateTime.now(),
      nextRecommendedLessonId: evaluation.nextRecommendedLessonId ??
          existing.nextRecommendedLessonId,
    );
  }
}

class LessonReviewSeeder {
  const LessonReviewSeeder._();

  static List<String> seedIds(List<V2ReviewSeedRecord> seeds) {
    return seeds.map((seed) => seed.reviewId).toList(growable: false);
  }

  static List<V2ReviewSeedRecord> seedRecordsForLesson(
    Lesson lesson, {
    DateTime? now,
  }) {
    final moment = now ?? DateTime.now();
    final tomorrow = DateTime(moment.year, moment.month, moment.day + 1, 7);

    return <V2ReviewSeedRecord>[
      ...lesson.vocabulary.map(
        (word) => V2ReviewSeedRecord(
          reviewId: buildWordContentId(word.text.plain),
          lessonId: lesson.id,
          objectType: ReviewObjectType.wordReading,
          actionType: ReviewActionType.read,
          itemRefId: word.id ?? word.text.plain,
          initialStage: LearningStage.reviewDue,
          dueAt: tomorrow,
        ),
      ),
      ...lesson.patterns.map(
        (pattern) => V2ReviewSeedRecord(
          reviewId: buildSentenceContentId(pattern.text.plain),
          lessonId: lesson.id,
          objectType: ReviewObjectType.sentencePattern,
          actionType: ReviewActionType.repeat,
          itemRefId: pattern.text.plain,
          initialStage: LearningStage.reviewDue,
          dueAt: tomorrow,
        ),
      ),
      ...lesson.letters.map(
        (letter) => V2ReviewSeedRecord(
          reviewId: buildLetterSoundContentId(letter),
          lessonId: lesson.id,
          objectType: ReviewObjectType.letterSound,
          actionType: ReviewActionType.listen,
          itemRefId: letter,
          initialStage: LearningStage.reviewDue,
          dueAt: tomorrow,
        ),
      ),
    ];
  }
}

class LessonProgressService {
  LessonProgressService._();

  static const String _lessonProgressKey = 'v2_lesson_progress_records_v1';

  static Future<Map<String, V2LessonProgressRecord>> getAllRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lessonProgressKey);
    if (raw == null || raw.isEmpty) {
      return <String, V2LessonProgressRecord>{};
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    final records = decoded
        .whereType<Map<String, dynamic>>()
        .map(V2LessonProgressRecord.fromJson)
        .toList(growable: false);

    return <String, V2LessonProgressRecord>{
      for (final record in records) record.lessonId: record,
    };
  }

  static Future<V2LessonProgressRecord?> getRecord(String lessonId) async {
    final records = await getAllRecords();
    return records[lessonId];
  }

  static Future<void> saveRecord(V2LessonProgressRecord record) async {
    final records = await getAllRecords();
    records[record.lessonId] = record;
    await _saveAll(records.values);
  }

  static Future<V2LessonProgressRecord> ensureRecord({
    required String lessonId,
    List<String> sourceLessonIds = const <String>[],
  }) async {
    final existing = await getRecord(lessonId);
    if (existing != null) {
      return existing;
    }
    final record = V2LessonProgressRecord(
      lessonId: lessonId,
      sourceLessonIds: sourceLessonIds,
      status: V2LessonStatus.available,
    );
    await saveRecord(record);
    return record;
  }

  static Future<V2LessonProgressRecord> markLessonStarted({
    required String lessonId,
    List<String> sourceLessonIds = const <String>[],
  }) async {
    final existing = await ensureRecord(
      lessonId: lessonId,
      sourceLessonIds: sourceLessonIds,
    );
    final updated = existing.copyWith(
      status: V2LessonStatus.inProgress,
      attemptCount: existing.attemptCount + 1,
      lastStartedAt: DateTime.now(),
      sourceLessonIds:
          sourceLessonIds.isEmpty ? existing.sourceLessonIds : sourceLessonIds,
    );
    await saveRecord(updated);
    await ProgressService.markLessonStarted(lessonId);
    return updated;
  }

  static Future<V2LessonProgressRecord> markCoreCompleted({
    required String lessonId,
    required List<String> completedBlockIds,
  }) async {
    final existing = await ensureRecord(lessonId: lessonId);
    final updated = existing.copyWith(
      status: V2LessonStatus.coreCompleted,
      completedBlockIds: completedBlockIds,
      lastCompletedAt: DateTime.now(),
    );
    await saveRecord(updated);
    return updated;
  }

  static Future<V2LessonProgressRecord> applyEvaluation({
    required String lessonId,
    required LessonCompletionEvaluation evaluation,
  }) async {
    final existing = await ensureRecord(lessonId: lessonId);
    final updated = LessonCompletionEvaluator.apply(
      existing: existing,
      evaluation: evaluation,
    );
    await saveRecord(updated);
    if (updated.targetReached) {
      await ProgressService.markLessonCompleted(lessonId);
    }
    return updated;
  }

  static Future<V2LessonProgressRecord> attachReviewSeeds({
    required String lessonId,
    required List<V2ReviewSeedRecord> seeds,
  }) async {
    final existing = await ensureRecord(lessonId: lessonId);
    final seedIds = <String>{
      ...existing.seededReviewIds,
      ...LessonReviewSeeder.seedIds(seeds),
    };
    final now = DateTime.now();
    final needsReview = seeds.any(
      (seed) =>
          seed.initialStage == LearningStage.weak ||
          (seed.initialStage == LearningStage.reviewDue &&
              !seed.dueAt.isAfter(now)),
    );
    final updated = existing.copyWith(
      seededReviewIds: seedIds.toList(growable: false),
      status: needsReview && existing.isCompletedLike
          ? V2LessonStatus.dueForReview
          : existing.status,
    );
    await saveRecord(updated);
    return updated;
  }

  static Future<V2LessonProgressRecord> markLessonMastered(
    String lessonId,
  ) async {
    final existing = await ensureRecord(lessonId: lessonId);
    final updated = existing.copyWith(
      status: V2LessonStatus.mastered,
      targetReached: true,
      lastMasteredAt: DateTime.now(),
    );
    await saveRecord(updated);
    await ProgressService.markLessonCompleted(lessonId);
    return updated;
  }

  static Future<V2CoursePhaseProgress> buildPhaseProgress({
    required String phaseId,
    required List<String> lessonIds,
  }) async {
    final records = await getAllRecords();
    final resolved = lessonIds
        .map((lessonId) => records[lessonId])
        .whereType<V2LessonProgressRecord>()
        .toList(growable: false);
    final lessonStatuses = lessonIds
        .map(
          (lessonId) => records[lessonId]?.status ?? V2LessonStatus.available,
        )
        .toList(growable: false);

    final completedLessonCount =
        lessonStatuses.where((status) => status.isCompletedLike).length;
    final masteredLessonCount = lessonStatuses
        .where((status) => status == V2LessonStatus.mastered)
        .length;
    final weakLessonIds = resolved
        .where((record) => record.weakObjectiveIds.isNotEmpty)
        .map((record) => record.lessonId)
        .toList(growable: false);
    final reviewDueCount = lessonStatuses
        .where((status) => status == V2LessonStatus.dueForReview)
        .length;
    final status = ProgressService.resolvePhaseStatus(lessonStatuses);

    return V2CoursePhaseProgress(
      phaseId: phaseId,
      status: status,
      unlockedLessonIds: lessonIds
          .where(
            (lessonId) =>
                (records[lessonId]?.status ?? V2LessonStatus.available) !=
                V2LessonStatus.locked,
          )
          .toList(growable: false),
      completedLessonCount: completedLessonCount,
      masteredLessonCount: masteredLessonCount,
      weakLessonIds: weakLessonIds,
      reviewDueCount: reviewDueCount,
    );
  }

  static Future<void> debugClearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lessonProgressKey);
  }

  static Future<void> _saveAll(Iterable<V2LessonProgressRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode(
      records.map((record) => record.toJson()).toList(growable: false),
    );
    await prefs.setString(_lessonProgressKey, payload);
  }
}
