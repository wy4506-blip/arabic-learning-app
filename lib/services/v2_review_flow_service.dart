import '../models/app_settings.dart';
import '../models/review_models.dart';
import 'review_service.dart';
import 'v2_learning_snapshot_service.dart';

class V2ReviewFlowService {
  const V2ReviewFlowService._();

  static Future<ReviewSession?> createPilotReviewSession({
    required AppSettings settings,
    required List<V2DueReviewItem> dueReviewItems,
  }) async {
    if (dueReviewItems.isEmpty) {
      return null;
    }

    final baseSession = await ReviewService.createTodaySession(settings);
    if (baseSession == null) {
      return null;
    }

    final session = buildPilotReviewSession(
      settings: settings,
      baseSession: baseSession,
      dueReviewItems: dueReviewItems,
    );
    if (session.tasks.isEmpty) {
      return null;
    }
    return session;
  }

  static ReviewSession buildPilotReviewSession({
    required AppSettings settings,
    required ReviewSession baseSession,
    required List<V2DueReviewItem> dueReviewItems,
  }) {
    final priorityOrder = <String, int>{
      for (var index = 0; index < dueReviewItems.length; index += 1)
        dueReviewItems[index].contentId: index,
    };

    final focusedTasks = _buildDueFocusedTasks(
      baseTasks: baseSession.tasks,
      dueReviewItems: dueReviewItems,
    );
    final tasks = List<ReviewTask>.of(
      focusedTasks,
      growable: true,
    )..sort(
        (left, right) => (priorityOrder[left.contentId] ?? 1 << 20)
            .compareTo(priorityOrder[right.contentId] ?? 1 << 20),
      );

    return ReviewSession(
      id: baseSession.id,
      kind: baseSession.kind,
      title: settings.appLanguage == AppLanguage.en ? 'Pilot Review' : '样板复习',
      subtitle: settings.appLanguage == AppLanguage.en
          ? 'Clear the items blocking the V2 mainline, then return to learning.'
          : '先清掉挡住 V2 主线的复习项，再回到学习。',
      tasks: tasks,
      countTowardActivity: baseSession.countTowardActivity,
      syncWithTodayPlan: baseSession.syncWithTodayPlan,
      completedTaskIds: baseSession.completedTaskIds
          .where((id) => tasks.any((task) => task.contentId == id))
          .toList(growable: false),
      config: const ReviewSessionConfig.reviewTab(
        mode: ReviewSessionMode.formal,
      ),
    );
  }

  static List<ReviewTask> _buildDueFocusedTasks({
    required List<ReviewTask> baseTasks,
    required List<V2DueReviewItem> dueReviewItems,
  }) {
    final pickedIds = <String>{};
    final focused = <ReviewTask>[];

    for (final dueItem in dueReviewItems) {
      ReviewTask? best;
      var bestScore = -1;
      for (final task in baseTasks) {
        if (pickedIds.contains(task.contentId)) {
          continue;
        }
        final score = _matchScore(dueItem: dueItem, task: task);
        if (score > bestScore) {
          bestScore = score;
          best = task;
        }
      }

      // Ignore very weak matches to keep pilot review strictly due-focused.
      if (best != null && bestScore >= 40) {
        focused.add(best);
        pickedIds.add(best.contentId);
      }
    }

    return focused;
  }

  static int _matchScore({
    required V2DueReviewItem dueItem,
    required ReviewTask task,
  }) {
    var score = 0;

    if (task.contentId == dueItem.contentId) {
      score += 200;
    }

    final dueKey = _normalizedContentId(dueItem.contentId);
    final taskKey = _normalizedContentId(task.contentId);
    if (dueKey.isNotEmpty && dueKey == taskKey) {
      score += 120;
    }

    final dueTail = _contentTail(dueItem.contentId);
    final taskTail = _contentTail(task.contentId);
    if (dueTail.isNotEmpty && dueTail == taskTail) {
      score += 70;
    }

    final taskSourceKey = normalizeReviewKey(task.sourceId ?? '');
    if (taskSourceKey.isNotEmpty &&
        (taskSourceKey == dueKey || taskSourceKey == dueTail)) {
      score += 60;
    }

    if ((task.lessonId ?? '') == dueItem.lessonId) {
      score += 45;
    }

    if (task.objectType == dueItem.objectType) {
      score += 35;
    }

    final dueType = reviewContentTypeForObject(dueItem.objectType);
    if (task.type == dueType) {
      score += 25;
    }

    if (task.actionType == dueItem.actionType) {
      score += 12;
    }

    return score;
  }

  static String _normalizedContentId(String value) {
    final parts = value.split(':');
    if (parts.isEmpty) {
      return '';
    }
    final head = parts.first.trim().toLowerCase();
    final tail = parts.length > 1
        ? parts
            .sublist(1)
            .map(normalizeReviewKey)
            .where((item) => item.isNotEmpty)
            .join(':')
        : '';
    return tail.isEmpty ? head : '$head:$tail';
  }

  static String _contentTail(String value) {
    final parts = value.split(':');
    if (parts.length < 2) {
      return '';
    }
    return parts
        .sublist(1)
        .map(normalizeReviewKey)
        .where((item) => item.isNotEmpty)
        .join(':');
  }
}
