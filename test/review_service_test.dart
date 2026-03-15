import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arabic_learning_app/models/review_models.dart';
import 'package:arabic_learning_app/services/lesson_service.dart';
import 'package:arabic_learning_app/services/review_service.dart';

import 'test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('builds today plan and records review progress', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'completed_lessons': <String>['U1L1'],
      'started_lessons': <String>['U1L1'],
      'last_lesson_id': 'U1L1',
    });

    final plan = await ReviewService.getTodayPlan(kEnglishTestSettings);

    expect(plan.tasks, isNotEmpty);
    expect(plan.pendingCount, greaterThan(0));

    final task = plan.tasks.first;
    final completedToday = await ReviewService.recordTaskResult(
      task,
      remembered: false,
      syncWithTodayPlan: true,
    );

    expect(completedToday, isFalse);

    final dashboard = await ReviewService.buildDashboard(kEnglishTestSettings);
    expect(dashboard.summary.todayPlan.completedCount, 1);
    expect(
      dashboard.weakTasks.any((item) => item.contentId == task.contentId),
      isTrue,
    );
  });

  test('creates a typed review session when content exists', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'completed_lessons': <String>['U1L1'],
      'started_lessons': <String>['U1L1'],
      'last_lesson_id': 'U1L1',
    });

    final session = await ReviewService.createTypeSession(
      kEnglishTestSettings,
      ReviewContentType.word,
    );

    expect(session, isNotNull);
    expect(session!.tasks, isNotEmpty);
    expect(
      session.tasks.every((task) => task.type == ReviewContentType.word),
      isTrue,
    );
  });

  test('creates a short home warm-up session with lesson handoff config',
      () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'completed_lessons': <String>['U1L1'],
      'started_lessons': <String>['U1L1'],
      'last_lesson_id': 'U1L1',
    });

    final session = await ReviewService.createHomeTodayFlowSession(
      kEnglishTestSettings,
      nextLessonId: 'U1L2',
    );

    expect(session, isNotNull);
    expect(session!.config.source, ReviewEntrySource.homeTodayPlan);
    expect(session.config.autoContinueToLesson, isTrue);
    expect(session.config.nextLessonId, 'U1L2');
    expect(session.config.allowSkip, isTrue);
    expect(session.config.headerTitle, 'Lesson Warm-Up');
    expect(session.tasks.length, inInclusiveRange(2, 5));
  });

  test('creates lesson wrap-up session with next lesson handoff when available',
      () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'completed_lessons': <String>['U1L1'],
      'started_lessons': <String>['U1L1'],
      'last_lesson_id': 'U1L1',
    });

    final lessons = await LessonService().loadLessons();
    final session = await ReviewService.createLessonWrapUpSession(
      kEnglishTestSettings,
      lessons.first,
    );

    expect(session, isNotNull);
    expect(session!.config.mode, ReviewSessionMode.formal);
    expect(session.config.nextLessonId, isNotEmpty);
  });

  test('free-practice sessions do not advance the formal today plan', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'completed_lessons': <String>['U1L1'],
      'started_lessons': <String>['U1L1'],
      'last_lesson_id': 'U1L1',
    });

    final initialPlan = await ReviewService.getTodayPlan(kEnglishTestSettings);
    expect(initialPlan.completedCount, 0);

    final quickSession = await ReviewService.createQuickSession(
      kEnglishTestSettings,
    );
    expect(quickSession, isNotNull);
    expect(quickSession!.syncWithTodayPlan, isFalse);
    await ReviewService.recordTaskResult(
      quickSession.tasks.first,
      remembered: true,
      syncWithTodayPlan: quickSession.syncWithTodayPlan,
    );

    final afterQuick = await ReviewService.getTodayPlan(kEnglishTestSettings);
    expect(afterQuick.completedCount, 0);

    await ReviewService.recordTaskResult(
      initialPlan.tasks.first,
      remembered: false,
      syncWithTodayPlan: false,
    );

    final weakSession = await ReviewService.createWeakSession(
      kEnglishTestSettings,
    );
    expect(weakSession, isNotNull);
    expect(weakSession!.syncWithTodayPlan, isFalse);
    await ReviewService.recordTaskResult(
      weakSession.tasks.first,
      remembered: true,
      syncWithTodayPlan: weakSession.syncWithTodayPlan,
    );

    final afterWeak = await ReviewService.getTodayPlan(kEnglishTestSettings);
    expect(afterWeak.completedCount, 0);

    final typeSession = await ReviewService.createTypeSession(
      kEnglishTestSettings,
      ReviewContentType.word,
    );
    expect(typeSession, isNotNull);
    expect(typeSession!.syncWithTodayPlan, isFalse);
    await ReviewService.recordTaskResult(
      typeSession.tasks.first,
      remembered: true,
      syncWithTodayPlan: typeSession.syncWithTodayPlan,
    );

    final afterType = await ReviewService.getTodayPlan(kEnglishTestSettings);
    expect(afterType.completedCount, 0);
  });
}
