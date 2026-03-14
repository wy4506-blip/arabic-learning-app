import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arabic_learning_app/app.dart';
import 'package:arabic_learning_app/data/sample_alphabet_data.dart';
import 'package:arabic_learning_app/data/sample_lessons.dart';
import 'package:arabic_learning_app/features/onboarding/models/onboarding_state.dart';
import 'package:arabic_learning_app/features/onboarding/pages/welcome_page.dart';
import 'package:arabic_learning_app/models/word_item.dart';
import 'package:arabic_learning_app/pages/alphabet_letter_home_page.dart';
import 'package:arabic_learning_app/pages/alphabet_page.dart';
import 'package:arabic_learning_app/pages/course_list_page.dart';
import 'package:arabic_learning_app/pages/feedback_board_page.dart';
import 'package:arabic_learning_app/pages/grammar_home_page.dart';
import 'package:arabic_learning_app/pages/home_page.dart';
import 'package:arabic_learning_app/pages/lesson_detail_page.dart';
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

  group('App launch flow in Chinese', () {
    testWidgets('opens the welcome flow in Chinese for first launch', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'app_language': 0,
        'app_meaning_language': 0,
      });

      await tester.pumpWidget(const ArabicLearningApp());
      await pumpTestFrames(tester, count: 8);

      expect(find.text('开始学习'), findsOneWidget);
      expect(find.text('Start Learning'), findsNothing);
      expectNoVisibleMojibake(tester);
    });

    testWidgets('opens the main shell in Chinese after onboarding', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'app_language': 0,
        'app_meaning_language': 0,
        'onboarding_has_seen_welcome': true,
        'onboarding_has_completed_first_experience': true,
        'onboarding_first_experience_step': 3,
      });

      await tester.pumpWidget(const ArabicLearningApp());
      await pumpTestFrames(tester, count: 8);

      expect(find.text('首页'), findsOneWidget);
      expect(find.text('课程'), findsOneWidget);
      expect(find.text('Home'), findsNothing);
      expectNoVisibleMojibake(tester);
    });
  });

  group('Chinese page smoke tests', () {
    testWidgets('welcome page', (tester) async {
      await pumpLocalizedTestPage(
        tester,
        WelcomePage(
          onStartLearning: () {},
          onGoHome: () {},
        ),
        settings: kChineseTestSettings,
      );

      expect(find.text('开始学习'), findsOneWidget);
      expect(find.text('Start Learning'), findsNothing);
      expectNoVisibleMojibake(tester);
    });

    testWidgets('home page', (tester) async {
      await pumpLocalizedTestPage(
        tester,
        HomePage(
          settings: kChineseTestSettings,
          onboardingState: completedOnboarding,
          onOpenTab: (_) {},
        ),
        settings: kChineseTestSettings,
      );

      expect(find.text('今天从这里开始'), findsOneWidget);
      expect(find.text('Start Here Today'), findsNothing);
      expect(find.text('Review Only'), findsNothing);
      expectNoVisibleMojibake(tester);
    });

    testWidgets('course list page', (tester) async {
      await pumpLocalizedTestPage(
        tester,
        const CourseListPage(settings: kChineseTestSettings),
        settings: kChineseTestSettings,
      );

      expect(find.text('课程'), findsOneWidget);
      expect(find.text('Lessons'), findsNothing);
      expectNoVisibleMojibake(tester);
    });

    testWidgets('lesson detail page', (tester) async {
      await pumpLocalizedTestPage(
        tester,
        LessonDetailPage(
          lesson: sampleLessons.first,
          settings: kChineseTestSettings,
          isUnlocked: true,
        ),
        settings: kChineseTestSettings,
      );

      expect(find.text('核心词汇'), findsOneWidget);
      expect(find.text('Core Words'), findsNothing);
      expectNoVisibleMojibake(tester);
    });

    testWidgets('grammar home page', (tester) async {
      await pumpLocalizedTestPage(
        tester,
        const GrammarHomePage(settings: kChineseTestSettings),
        settings: kChineseTestSettings,
      );

      expect(find.text('语法速查'), findsWidgets);
      expect(find.text('Grammar Quick Reference'), findsNothing);
      expectNoVisibleMojibake(tester);
    });

    testWidgets('review page', (tester) async {
      await pumpLocalizedTestPage(
        tester,
        const ReviewPage(),
        settings: kChineseTestSettings,
        sharedPreferences: wordPrefs(),
      );

      expect(find.textContaining('复习'), findsWidgets);
      expect(find.text('Review'), findsNothing);
      expectNoVisibleMojibake(tester);
    });

    testWidgets('feedback board page', (tester) async {
      await pumpLocalizedTestPage(
        tester,
        FeedbackBoardPage(
          onSubmit: (_, __) async {},
        ),
        settings: kChineseTestSettings,
      );

      expect(find.text('留言板'), findsOneWidget);
      expect(find.text('Feedback Board'), findsNothing);
      expectNoVisibleMojibake(tester);
    });

    testWidgets('wordbook page', (tester) async {
      await pumpLocalizedTestPage(
        tester,
        const VocabBookPage(),
        settings: kChineseTestSettings,
        sharedPreferences: wordPrefs(),
      );

      expect(find.textContaining('单词本'), findsWidgets);
      expect(find.text('Wordbook'), findsNothing);
      expectNoVisibleMojibake(tester);
    });

    testWidgets('alphabet page', (tester) async {
      await pumpLocalizedTestPage(
        tester,
        const AlphabetPage(),
        settings: kChineseTestSettings,
      );

      expect(find.textContaining('字母'), findsWidgets);
      expect(find.text('Alphabet Basics'), findsNothing);
      expectNoVisibleMojibake(tester);
    });

    testWidgets('alphabet letter home page', (tester) async {
      await pumpLocalizedTestPage(
        tester,
        AlphabetLetterHomePage(
            letter: sampleAlphabetGroups.first.letters.first),
        settings: kChineseTestSettings,
      );

      expect(find.text('字母学习'), findsOneWidget);
      expect(find.text('Letter Study'), findsNothing);
      expect(find.textContaining('基础发音'), findsWidgets);
      expect(find.text('四种常见字形'), findsOneWidget);
      expect(find.text('书写'), findsOneWidget);
      expectNoVisibleMojibake(tester);
    });

    testWidgets('unlock page', (tester) async {
      await pumpLocalizedTestPage(
        tester,
        const UnlockPage(),
        settings: kChineseTestSettings,
      );

      expect(find.textContaining('解锁'), findsWidgets);
      expect(find.textContaining('Unlock'), findsNothing);
      expectNoVisibleMojibake(tester);
    });

    testWidgets('profile page', (tester) async {
      await pumpLocalizedTestPage(
        tester,
        ProfilePage(
          settings: kChineseTestSettings,
          onSettingsChanged: (_) {},
        ),
        settings: kChineseTestSettings,
      );

      expect(find.text('我的'), findsOneWidget);
      expect(find.text('Profile'), findsNothing);
      expectNoVisibleMojibake(tester);
    });
  });
}
