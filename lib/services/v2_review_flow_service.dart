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
    List<ReviewTask>? candidateTasks,
  }) {
    final priorityOrder = <String, int>{
      for (var index = 0; index < dueReviewItems.length; index += 1)
        dueReviewItems[index].contentId: index,
    };

    final focusedTasks = _buildDueFocusedTasks(
      candidateTasks: candidateTasks ?? baseSession.tasks,
      dueReviewItems: dueReviewItems,
      settings: settings,
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
    required List<ReviewTask> candidateTasks,
    required List<V2DueReviewItem> dueReviewItems,
    required AppSettings settings,
  }) {
    final pickedIds = <String>{};
    final focused = <ReviewTask>[];

    for (final dueItem in dueReviewItems) {
      ReviewTask? best;
      var bestScore = -1;
      for (final task in candidateTasks) {
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
      } else {
        focused.add(_buildFallbackTask(settings: settings, dueItem: dueItem));
      }
    }

    return focused;
  }
  static ReviewTask _buildFallbackTask({
    required AppSettings settings,
    required V2DueReviewItem dueItem,
  }) {
    final promptText = _promptTextFor(dueItem.contentId);
    return ReviewTask(
      contentId: dueItem.contentId,
      type: reviewContentTypeForObject(dueItem.objectType),
      objectType: dueItem.objectType,
      actionType: dueItem.actionType,
      origin: dueItem.isWeak ? ReviewTaskOrigin.weak : ReviewTaskOrigin.due,
      title: _fallbackTitle(settings, dueItem.objectType),
      subtitle: _fallbackSubtitle(settings, dueItem.actionType),
      arabicText: promptText,
      audioQueryText: promptText,
      lessonId: dueItem.lessonId,
      sourceId: promptText,
      estimatedSeconds: 25,
      priority: dueItem.priority,
    );
  }

  static String _promptTextFor(String contentId) {
    final parts = contentId.split(':');
    final raw = parts.length > 1 ? parts.sublist(1).join(' ') : contentId;
    return raw.replaceAll('_', ' ').trim();
  }

  static String _fallbackTitle(
    AppSettings settings,
    ReviewObjectType objectType,
  ) {
    switch (objectType) {
      case ReviewObjectType.letterName:
        return settings.appLanguage == AppLanguage.en ? 'Letter Name' : '字母名称';
      case ReviewObjectType.letterSound:
        return settings.appLanguage == AppLanguage.en ? 'Letter Sound' : '字母发音';
      case ReviewObjectType.letterForm:
        return settings.appLanguage == AppLanguage.en ? 'Letter Form' : '字母字形';
      case ReviewObjectType.symbolReading:
        return settings.appLanguage == AppLanguage.en ? 'Sound Reading' : '读音符号';
      case ReviewObjectType.wordReading:
        return settings.appLanguage == AppLanguage.en ? 'Word Reading' : '单词朗读';
      case ReviewObjectType.confusionPair:
        return settings.appLanguage == AppLanguage.en ? 'Contrast Pair' : '易混对比';
      case ReviewObjectType.sentencePattern:
        return settings.appLanguage == AppLanguage.en ? 'Sentence Pattern' : '句型复习';
      case ReviewObjectType.grammarReference:
        return settings.appLanguage == AppLanguage.en ? 'Grammar Reference' : '语法复习';
    }
  }

  static String _fallbackSubtitle(
    AppSettings settings,
    ReviewActionType actionType,
  ) {
    switch (actionType) {
      case ReviewActionType.listen:
        return settings.appLanguage == AppLanguage.en
            ? 'Listen once and confirm it feels clear.'
            : '听一遍并确认你已经清楚。';
      case ReviewActionType.read:
        return settings.appLanguage == AppLanguage.en
            ? 'Read it once to clear this review item.'
            : '读一遍，清掉这条复习项。';
      case ReviewActionType.distinguish:
        return settings.appLanguage == AppLanguage.en
            ? 'Compare it carefully before moving on.'
            : '先仔细区分，再继续学习。';
      case ReviewActionType.repeat:
        return settings.appLanguage == AppLanguage.en
            ? 'Say it once to finish this blocked review item.'
            : '说一遍，完成这条阻塞复习。';
      case ReviewActionType.recognize:
        return settings.appLanguage == AppLanguage.en
            ? 'Recognize it once to continue forward.'
            : '识别一次，然后继续前进。';
    }
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
