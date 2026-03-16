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

    return buildPilotReviewSession(
      settings: settings,
      baseSession: baseSession,
      dueReviewItems: dueReviewItems,
    );
  }

  static ReviewSession buildPilotReviewSession({
    required AppSettings settings,
    required ReviewSession baseSession,
    required List<V2DueReviewItem> dueReviewItems,
  }) {
    final dueIds = dueReviewItems.map((item) => item.contentId).toSet();
    final priorityOrder = <String, int>{
      for (var index = 0; index < dueReviewItems.length; index += 1)
        dueReviewItems[index].contentId: index,
    };

    final focusedTasks = baseSession.tasks
        .where((task) => dueIds.contains(task.contentId))
        .toList(growable: false);
    final tasks = List<ReviewTask>.of(
      focusedTasks.isEmpty ? baseSession.tasks : focusedTasks,
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
}
