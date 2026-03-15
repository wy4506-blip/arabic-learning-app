import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arabic_learning_app/models/review_models.dart';
import 'package:arabic_learning_app/pages/review_session_page.dart';

import 'test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('home today review completion shows next-step guidance', (
    tester,
  ) async {
    const session = ReviewSession(
      id: 'home-today:test',
      kind: ReviewSessionKind.today,
      title: 'Today\'s Warm-Up',
      subtitle: 'Review a few key points first.',
      tasks: <ReviewTask>[
        ReviewTask(
          contentId: 'word:marhaban',
          type: ReviewContentType.word,
          origin: ReviewTaskOrigin.recentLesson,
          title: 'Hello',
          subtitle: 'Greeting',
          arabicText: 'مَرْحَبًا',
          transliteration: 'marhaban',
          helperText: 'A common greeting.',
          lessonId: 'U1L1',
          sourceId: 'U1L1',
          estimatedSeconds: 30,
          priority: 10,
        ),
      ],
      countTowardActivity: true,
      syncWithTodayPlan: false,
      config: ReviewSessionConfig(
        source: ReviewEntrySource.homeTodayPlan,
        autoContinueToLesson: true,
        nextLessonId: 'U1L1',
        allowSkip: true,
      ),
    );

    await pumpLocalizedTestPage(
      tester,
      const ReviewSessionPage(session: session),
    );

    await tester.tap(find.widgetWithText(FilledButton, 'I Can Say It'));
    await tester.pump();

    expect(
      find.text('Warm-Up Complete, Opening the Next Lesson'),
      findsOneWidget,
    );
    expect(find.text('Enter Now'), findsOneWidget);
    expect(find.text('Back Home'), findsOneWidget);
  });

  testWidgets('review tab completion stays in regular completion mode', (
    tester,
  ) async {
    const session = ReviewSession(
      id: 'today:test',
      kind: ReviewSessionKind.today,
      title: 'Today\'s Review',
      subtitle: 'A light set based on recent lessons.',
      tasks: <ReviewTask>[
        ReviewTask(
          contentId: 'word:marhaban',
          type: ReviewContentType.word,
          origin: ReviewTaskOrigin.recentLesson,
          title: 'Hello',
          subtitle: 'Greeting',
          arabicText: 'مَرْحَبًا',
          transliteration: 'marhaban',
          helperText: 'A common greeting.',
          lessonId: 'U1L1',
          sourceId: 'U1L1',
          estimatedSeconds: 30,
          priority: 10,
        ),
      ],
      countTowardActivity: true,
      syncWithTodayPlan: false,
      config: ReviewSessionConfig.reviewTab(),
    );

    await pumpLocalizedTestPage(
      tester,
      const ReviewSessionPage(session: session),
    );

    await tester.tap(find.widgetWithText(FilledButton, 'I Can Say It'));
    await tester.pump();

    expect(find.text('This Review Pass Is Complete'), findsOneWidget);
    expect(find.text('Enter Now'), findsNothing);
    expect(find.text('Back Home'), findsNothing);
    expect(find.text('Return to Learning'), findsOneWidget);
  });

  testWidgets('formal lesson follow-up can continue to the next lesson', (
    tester,
  ) async {
    const session = ReviewSession(
      id: 'lesson-wrap:test',
      kind: ReviewSessionKind.lessonWrapUp,
      title: 'Lesson Review',
      subtitle: 'A short reinforcement loop.',
      tasks: <ReviewTask>[
        ReviewTask(
          contentId: 'word:marhaban',
          type: ReviewContentType.word,
          origin: ReviewTaskOrigin.lessonBridge,
          title: 'Hello',
          subtitle: 'Greeting',
          arabicText: 'مَرْحَبًا',
          transliteration: 'marhaban',
          helperText: 'A common greeting.',
          lessonId: 'U1L1',
          sourceId: 'U1L1',
          estimatedSeconds: 30,
          priority: 10,
        ),
      ],
      countTowardActivity: true,
      syncWithTodayPlan: false,
      config: ReviewSessionConfig(
        source: ReviewEntrySource.lessonFollowUp,
        mode: ReviewSessionMode.formal,
        nextLessonId: 'U1L2',
        nextLessonLabel: 'Introducing Yourself',
      ),
    );

    await pumpLocalizedTestPage(
      tester,
      const ReviewSessionPage(session: session),
    );

    await tester.tap(find.widgetWithText(FilledButton, 'I Can Say It'));
    await tester.pump();

    expect(find.text('Continue to Next Lesson'), findsOneWidget);
    expect(find.text('Stay on Current Lesson'), findsOneWidget);
    expect(find.text('Next Step'), findsOneWidget);
    expect(find.text('Introducing Yourself'), findsOneWidget);
  });

  testWidgets('listen task shows audio guidance and play action', (
    tester,
  ) async {
    const session = ReviewSession(
      id: 'listen:test',
      kind: ReviewSessionKind.single,
      title: 'Pronunciation Review',
      subtitle: 'Listen carefully.',
      tasks: <ReviewTask>[
        ReviewTask(
          contentId: 'symbol_reading:alif:a',
          type: ReviewContentType.pronunciation,
          objectType: ReviewObjectType.symbolReading,
          actionType: ReviewActionType.listen,
          origin: ReviewTaskOrigin.due,
          title: 'Fatha sound',
          subtitle: 'Short vowel sound',
          arabicText: 'أَ',
          transliteration: 'a',
          audioQueryText: 'أَ',
          estimatedSeconds: 25,
          priority: 10,
        ),
      ],
      countTowardActivity: false,
      syncWithTodayPlan: false,
      config: ReviewSessionConfig.reviewTab(mode: ReviewSessionMode.formal),
    );

    await pumpLocalizedTestPage(
      tester,
      const ReviewSessionPage(session: session),
    );

    expect(find.text('Listen'), findsWidgets);
    expect(find.text('Play Audio'), findsOneWidget);
    expect(
      find.text('Listen first, then decide whether you truly caught it.'),
      findsOneWidget,
    );
  });

  testWidgets('distinguish task shows contrast view', (
    tester,
  ) async {
    const session = ReviewSession(
      id: 'pair:test',
      kind: ReviewSessionKind.single,
      title: 'Sound Contrast',
      subtitle: 'Split the pair clearly.',
      tasks: <ReviewTask>[
        ReviewTask(
          contentId: 'confusion_pair:ba__ta',
          type: ReviewContentType.pair,
          objectType: ReviewObjectType.confusionPair,
          actionType: ReviewActionType.distinguish,
          origin: ReviewTaskOrigin.weak,
          title: 'Tell these two apart',
          subtitle: 'ba vs ta',
          arabicText: 'ب  ت',
          sourceId: 'ب|ت',
          estimatedSeconds: 25,
          priority: 10,
        ),
      ],
      countTowardActivity: false,
      syncWithTodayPlan: false,
      config: ReviewSessionConfig.reviewTab(mode: ReviewSessionMode.formal),
    );

    await pumpLocalizedTestPage(
      tester,
      const ReviewSessionPage(session: session),
    );

    expect(find.text('Play Contrast Audio'), findsOneWidget);
    expect(find.text('You only need to separate these two clearly.'), findsOneWidget);
    expect(find.text('ب'), findsWidgets);
    expect(find.text('ت'), findsWidgets);
  });
}
