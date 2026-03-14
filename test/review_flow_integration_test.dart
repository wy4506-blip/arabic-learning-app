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

    await tester.tap(find.widgetWithText(FilledButton, 'Got It'));
    await tester.pump();

    expect(
      find.text('Warm-Up Done, Opening the Next Lesson'),
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

    await tester.tap(find.widgetWithText(FilledButton, 'Got It'));
    await tester.pump();

    expect(find.text('This Review Pass Is Complete'), findsOneWidget);
    expect(find.text('Enter Now'), findsNothing);
    expect(find.text('Back Home'), findsNothing);
    expect(find.text('Back'), findsOneWidget);
  });
}
