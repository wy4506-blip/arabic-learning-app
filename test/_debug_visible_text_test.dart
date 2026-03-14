import 'package:flutter_test/flutter_test.dart';

import 'package:arabic_learning_app/features/onboarding/models/onboarding_state.dart';
import 'package:arabic_learning_app/services/grammar_service.dart';
import 'package:arabic_learning_app/services/lesson_service.dart';
import 'package:arabic_learning_app/services/progress_service.dart';
import 'package:arabic_learning_app/services/unlock_service.dart';
import 'package:arabic_learning_app/pages/course_list_page.dart';
import 'package:arabic_learning_app/pages/grammar_category_page.dart';
import 'package:arabic_learning_app/pages/grammar_detail_page.dart';
import 'package:arabic_learning_app/pages/grammar_home_page.dart';
import 'package:arabic_learning_app/pages/home_page.dart';
import 'package:arabic_learning_app/pages/profile_page.dart';
import 'package:arabic_learning_app/pages/review_page.dart';
import 'package:arabic_learning_app/pages/unlock_page.dart';
import 'package:arabic_learning_app/pages/alphabet_page.dart';
import 'package:arabic_learning_app/services/review_service.dart';

import 'test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const completedOnboarding = OnboardingState(
    hasSeenWelcome: true,
    hasCompletedFirstExperience: true,
    firstExperienceStep: 3,
    firstLaunchDate: '2026-03-13',
    hasEnteredHomeAfterFirstExperience: true,
  );

  testWidgets('debug home', (tester) async {
    await pumpLocalizedTestPage(
      tester,
      HomePage(
        settings: kEnglishTestSettings,
        onboardingState: completedOnboarding,
        onOpenTab: (_) {},
      ),
    );
    // ignore: avoid_print
    print('HOME\\n${collectVisibleText(tester)}');
  });

  testWidgets('debug course', (tester) async {
    await pumpLocalizedTestPage(
      tester,
      const CourseListPage(settings: kEnglishTestSettings),
    );
    // ignore: avoid_print
    print('COURSE\\n${collectVisibleText(tester)}');
  });

  testWidgets('debug grammar home', (tester) async {
    await pumpLocalizedTestPage(
      tester,
      const GrammarHomePage(settings: kEnglishTestSettings),
    );
    // ignore: avoid_print
    print('GRAMMAR_HOME\\n${collectVisibleText(tester)}');
  });

  testWidgets('debug grammar category', (tester) async {
    await pumpLocalizedTestPage(
      tester,
      const GrammarCategoryPage(
        categoryId: 'grammar_pronouns',
        settings: kEnglishTestSettings,
      ),
    );
    // ignore: avoid_print
    print('GRAMMAR_CATEGORY\\n${collectVisibleText(tester)}');
  });

  testWidgets('debug grammar detail', (tester) async {
    await pumpLocalizedTestPage(
      tester,
      const GrammarDetailPage(
        pageId: 'personal_pronouns',
        settings: kEnglishTestSettings,
      ),
    );
    // ignore: avoid_print
    print('GRAMMAR_DETAIL\\n${collectVisibleText(tester)}');
  });

  testWidgets('debug unlock', (tester) async {
    await pumpLocalizedTestPage(
      tester,
      const UnlockPage(),
    );
    // ignore: avoid_print
    print('UNLOCK\\n${collectVisibleText(tester)}');
  });

  testWidgets('debug profile', (tester) async {
    await pumpLocalizedTestPage(
      tester,
      ProfilePage(
        settings: kEnglishTestSettings,
        onSettingsChanged: (_) {},
      ),
    );
    // ignore: avoid_print
    print('PROFILE\\n${collectVisibleText(tester)}');
  });

  testWidgets('debug review', (tester) async {
    await pumpLocalizedTestPage(
      tester,
      const ReviewPage(),
      sharedPreferences: <String, Object>{
        'completed_lessons': <String>['U1L1'],
        'started_lessons': <String>['U1L1'],
        'last_lesson_id': 'U1L1',
      },
    );
    // ignore: avoid_print
    print('REVIEW\\n${collectVisibleText(tester)}');
  });

  testWidgets('debug alphabet', (tester) async {
    await pumpLocalizedTestPage(
      tester,
      const AlphabetPage(),
    );
    // ignore: avoid_print
    print('ALPHABET\\n${collectVisibleText(tester)}');
  });

  testWidgets('debug services', (tester) async {
    final lessons = await LessonService().loadLessons();
    final unlocked = await UnlockService.isUnlocked();
    final progress = await ProgressService.getSnapshot();
    final categories = await GrammarService.loadCategories();
    final pages = await GrammarService.loadPages();
    final dashboard = await ReviewService.buildDashboard(kEnglishTestSettings);

    // ignore: avoid_print
    print(
      'SERVICES\\nlessons=${lessons.length}\\nunlocked=$unlocked\\n'
      'completed=${progress.completedLessons.length}\\n'
      'categories=${categories.length}\\npages=${pages.length}\\n'
      'review_today_total=${dashboard.summary.todayPlan.totalCount}\\n'
      'review_pending=${dashboard.summary.todayPlan.pendingCount}\\n'
      'review_weak=${dashboard.weakTasks.length}',
    );

    await pumpLocalizedTestPage(
      tester,
      const ReviewPage(),
      sharedPreferences: <String, Object>{
        'completed_lessons': <String>['U1L1'],
        'started_lessons': <String>['U1L1'],
        'last_lesson_id': 'U1L1',
      },
    );
    // ignore: avoid_print
    print('REVIEW_DEBUG\\n${collectVisibleText(tester)}');

    await pumpLocalizedTestPage(
      tester,
      const AlphabetPage(),
    );
    // ignore: avoid_print
    print('ALPHABET_DEBUG\\n${collectVisibleText(tester)}');
  }, skip: true);
}
