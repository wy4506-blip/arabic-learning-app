import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arabic_learning_app/app.dart';
import 'package:arabic_learning_app/data/sample_alphabet_data.dart';
import 'package:arabic_learning_app/data/sample_lessons.dart';
import 'package:arabic_learning_app/features/onboarding/models/first_experience_content.dart';
import 'package:arabic_learning_app/features/onboarding/models/onboarding_state.dart';
import 'package:arabic_learning_app/features/onboarding/pages/first_experience_complete_page.dart';
import 'package:arabic_learning_app/features/onboarding/pages/first_experience_flow_page.dart';
import 'package:arabic_learning_app/features/onboarding/pages/welcome_page.dart';
import 'package:arabic_learning_app/models/word_item.dart';
import 'package:arabic_learning_app/pages/alabic_pronunciation_quiz_page.dart';
import 'package:arabic_learning_app/pages/alphabet_compare_quiz_page.dart';
import 'package:arabic_learning_app/pages/alphabet_group_detail_page.dart';
import 'package:arabic_learning_app/pages/alphabet_hub_page.dart';
import 'package:arabic_learning_app/pages/alphabet_letter_home_page.dart';
import 'package:arabic_learning_app/pages/alphabet_listen_read_page.dart';
import 'package:arabic_learning_app/pages/alphabet_page.dart';
import 'package:arabic_learning_app/pages/alphabet_quiz_page.dart';
import 'package:arabic_learning_app/pages/alphabet_recognition_quiz_page.dart';
import 'package:arabic_learning_app/pages/alphabet_sound_quiz_page.dart';
import 'package:arabic_learning_app/pages/alphabet_write_page.dart';
import 'package:arabic_learning_app/pages/course_list_page.dart';
import 'package:arabic_learning_app/pages/feedback_board_page.dart';
import 'package:arabic_learning_app/pages/grammar_category_page.dart';
import 'package:arabic_learning_app/pages/grammar_detail_page.dart';
import 'package:arabic_learning_app/pages/grammar_home_page.dart';
import 'package:arabic_learning_app/pages/home_page.dart';
import 'package:arabic_learning_app/pages/lesson_detail_page.dart';
import 'package:arabic_learning_app/pages/lesson_quiz_page.dart';
import 'package:arabic_learning_app/pages/profile_page.dart';
import 'package:arabic_learning_app/pages/review_page.dart';
import 'package:arabic_learning_app/pages/unlock_page.dart';
import 'package:arabic_learning_app/pages/vocab_book_page.dart';

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

  final savedWord = WordItem(
    arabic: 'مَرْحَبًا',
    plainArabic: 'مرحبا',
    pronunciation: 'marhaban',
    meaning: '你好',
    partOfSpeech: '固定表达',
  );

  Map<String, Object> wordPrefs() {
    return <String, Object>{
      'favorite_words': <String>[jsonEncode(savedWord.toJson())],
    };
  }

  group('App launch flow in English', () {
    testWidgets('opens the welcome flow in English for first launch',
        (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'app_language': 1,
        'app_meaning_language': 1,
      });

      await tester.pumpWidget(const ArabicLearningApp());
      await pumpTestFrames(tester, count: 8);

      expect(find.text('Start Learning'), findsOneWidget);
      expectNoVisibleChinese(tester);
    });

    testWidgets('opens the main shell in English after onboarding',
        (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'app_language': 1,
        'app_meaning_language': 1,
        'onboarding_has_seen_welcome': true,
        'onboarding_has_completed_first_experience': true,
        'onboarding_first_experience_step': 3,
      });

      await tester.pumpWidget(const ArabicLearningApp());
      await pumpTestFrames(tester, count: 8);

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Lessons'), findsOneWidget);
      expectNoVisibleChinese(tester);
    });
  });

  group('English page smoke tests', () {
    testWidgets('welcome page', (tester) async {
      await pumpLocalizedTestPage(
        tester,
        WelcomePage(
          onStartLearning: () {},
          onGoHome: () {},
        ),
      );

      expect(find.text('Start Learning'), findsOneWidget);
      expectNoVisibleChinese(tester);
    });

    testWidgets('first experience flow', (tester) async {
      await pumpLocalizedTestPage(
        tester,
        FirstExperienceFlowPage(
          content: kFirstExperienceContent,
          initialStep: 1,
          onStepChanged: (_) {},
          onCompleted: () {},
        ),
      );

      expect(find.text('Meet your first Arabic letter'), findsOneWidget);
      expectNoVisibleChinese(tester);
    });

    testWidgets('first experience complete page', (tester) async {
      await pumpLocalizedTestPage(
        tester,
        FirstExperienceCompletePage(
          onContinueLearning: () {},
          onGoHome: () {},
        ),
      );

      expect(find.text('Continue Learning'), findsOneWidget);
      expectNoVisibleChinese(tester);
    });

    testWidgets('home page', (tester) async {
      await pumpLocalizedTestPage(
        tester,
        HomePage(
          settings: kEnglishTestSettings,
          onboardingState: completedOnboarding,
          onOpenTab: (_) {},
        ),
      );

      expect(find.text('Start Here Today'), findsOneWidget);
      expectNoVisibleChinese(tester);
    });

    testWidgets('course list page', (tester) async {
      await pumpLocalizedTestPage(
        tester,
        const CourseListPage(settings: kEnglishTestSettings),
      );

      expect(find.text('Lessons'), findsOneWidget);
      expectNoVisibleChinese(tester);
    });

    testWidgets('lesson detail page', (tester) async {
      await pumpLocalizedTestPage(
        tester,
        LessonDetailPage(
          lesson: sampleLessons.first,
          settings: kEnglishTestSettings,
          isUnlocked: true,
        ),
      );

      expect(find.text('Core Words'), findsOneWidget);
      expectNoVisibleChinese(tester);
    });

    testWidgets('completed lesson detail page shows formal wrap-up handoff', (
      tester,
    ) async {
      await pumpLocalizedTestPage(
        tester,
        LessonDetailPage(
          lesson: sampleLessons.first,
          settings: kEnglishTestSettings,
          isUnlocked: true,
        ),
        sharedPreferences: <String, Object>{
          'completed_lessons': <String>['U1L1'],
          'started_lessons': <String>['U1L1'],
          'last_lesson_id': 'U1L1',
        },
      );
      await pumpTestFrames(tester, count: 8);
      await tester.dragUntilVisible(
        find.text('Reinforce First, Then Next Lesson'),
        find.byType(Scrollable).first,
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('After finishing this lesson, do this formal follow-up first'),
        findsOneWidget,
      );
      expect(find.text('Reinforce First, Then Next Lesson'), findsOneWidget);
      expect(find.textContaining('Introducing Yourself'), findsOneWidget);
      expectNoVisibleChinese(tester);
    });

    testWidgets('lesson quiz page', (tester) async {
      await pumpLocalizedTestPage(
        tester,
        LessonQuizPage(lesson: sampleLessons.first),
      );

      expect(find.textContaining('Question'), findsWidgets);
      expectNoVisibleChinese(tester);
    });

    testWidgets('grammar home page', (tester) async {
      await pumpLocalizedTestPage(
        tester,
        const GrammarHomePage(settings: kEnglishTestSettings),
      );

      expect(find.text('Grammar Quick Reference'), findsWidgets);
      expectNoVisibleChinese(tester);
    });

    testWidgets('grammar category page', (tester) async {
      await pumpLocalizedTestPage(
        tester,
        const GrammarCategoryPage(
          categoryId: 'grammar_pronouns',
          settings: kEnglishTestSettings,
        ),
      );

      expect(find.text('Quick Links'), findsOneWidget);
      expectNoVisibleChinese(tester);
    });

    testWidgets('grammar detail page', (tester) async {
      await pumpLocalizedTestPage(
        tester,
        const GrammarDetailPage(
          pageId: 'personal_pronouns',
          settings: kEnglishTestSettings,
        ),
      );

      expect(find.textContaining('Pronouns'), findsWidgets);
      expectNoVisibleChinese(tester);
    });

    testWidgets('unlock page', (tester) async {
      await pumpLocalizedTestPage(
        tester,
        const UnlockPage(),
      );

      expect(find.textContaining('Unlock'), findsWidgets);
      expectNoVisibleChinese(tester);
    });

    testWidgets('profile page', (tester) async {
      await pumpLocalizedTestPage(
        tester,
        ProfilePage(
          settings: kEnglishTestSettings,
          onSettingsChanged: (_) {},
        ),
      );

      expect(find.text('Profile'), findsOneWidget);
      expectNoVisibleChinese(tester);
    });

    testWidgets('review page', (tester) async {
      await pumpLocalizedTestPage(
        tester,
        const ReviewPage(),
        sharedPreferences: wordPrefs(),
      );

      expect(find.textContaining('Review'), findsWidgets);
      expectNoVisibleChinese(tester);
    });

    testWidgets('feedback board page', (tester) async {
      await pumpLocalizedTestPage(
        tester,
        FeedbackBoardPage(
          onSubmit: (_, __) async {},
        ),
      );

      expect(find.text('Feedback Board'), findsOneWidget);
      expectNoVisibleChinese(tester);
    });

    testWidgets('wordbook page', (tester) async {
      await pumpLocalizedTestPage(
        tester,
        const VocabBookPage(),
        sharedPreferences: wordPrefs(),
      );

      expect(find.textContaining('Wordbook'), findsWidgets);
      expectNoVisibleChinese(tester);
    });

    testWidgets('alphabet page', (tester) async {
      await pumpLocalizedTestPage(
        tester,
        const AlphabetPage(),
      );

      expect(find.text('Alphabet Basics'), findsOneWidget);
      expectNoVisibleChinese(tester);
    });

    testWidgets('alphabet group detail page', (tester) async {
      await pumpLocalizedTestPage(
        tester,
        AlphabetGroupDetailPage(group: sampleAlphabetGroups.first),
      );

      expect(find.textContaining('Group 1'), findsWidgets);
      expectNoVisibleChinese(tester);
    });

    testWidgets('alphabet letter home page', (tester) async {
      await pumpLocalizedTestPage(
        tester,
        AlphabetLetterHomePage(
            letter: sampleAlphabetGroups.first.letters.first),
      );

      expect(find.text('Example Word'), findsOneWidget);
      expect(find.text('Four Common Forms'), findsOneWidget);
      expect(find.text('Write'), findsOneWidget);
      expectNoVisibleChinese(tester);
    });

    testWidgets('alphabet listen page', (tester) async {
      await pumpLocalizedTestPage(
        tester,
        AlphabetListenReadPage(
          letter: sampleAlphabetGroups.first.letters.first,
        ),
      );

      expect(find.text('13 Standard Sound Forms'), findsOneWidget);
      expectNoVisibleChinese(tester);
    });

    testWidgets('alphabet write page', (tester) async {
      await pumpLocalizedTestPage(
        tester,
        AlphabetWritePage(
          letter: sampleAlphabetGroups.first.letters.first,
        ),
      );

      expect(find.text('Writing Forms'), findsOneWidget);
      expectNoVisibleChinese(tester);
    });

    testWidgets('alphabet practice hub page', (tester) async {
      await pumpLocalizedTestPage(
        tester,
        const AlphabetHubPage(),
      );

      expect(find.text('Practice Levels'), findsOneWidget);
      expectNoVisibleChinese(tester);
    });

    testWidgets('alphabet static quiz page', (tester) async {
      await pumpLocalizedTestPage(
        tester,
        const AlphabetQuizPage(),
      );

      expect(find.text('Alphabet Drill'), findsOneWidget);
      expectNoVisibleChinese(tester);
    });

    testWidgets('alphabet recognition quiz page', (tester) async {
      await pumpLocalizedTestPage(
        tester,
        const AlphabetRecognitionQuizPage(),
      );

      expect(find.text('Level 1: Letter Recognition'), findsOneWidget);
      expectNoVisibleChinese(tester);
    });

    testWidgets('alphabet contrast quiz page', (tester) async {
      await pumpLocalizedTestPage(
        tester,
        const AlphabetCompareQuizPage(),
      );

      expect(find.text('Level 2: Letter Contrast'), findsOneWidget);
      expectNoVisibleChinese(tester);
    });

    testWidgets('alphabet sound quiz page', (tester) async {
      await pumpLocalizedTestPage(
        tester,
        const AlphabetSoundQuizPage(),
      );

      expect(find.text('Level 3: Core Sounds'), findsOneWidget);
      expectNoVisibleChinese(tester);
    });

    testWidgets('alphabet pronunciation quiz page', (tester) async {
      await pumpLocalizedTestPage(
        tester,
        const AlabicPronunciationQuizPage(),
      );

      expect(find.text('Level 4: 13 Sound Forms'), findsOneWidget);
      expectNoVisibleChinese(tester);
    });
  });
}
