import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:arabic_learning_app/models/app_settings.dart';
import 'package:arabic_learning_app/pages/home_page.dart';
import 'package:arabic_learning_app/pages/v2_micro_lesson_completion_page.dart';
import 'package:arabic_learning_app/pages/v2_micro_lesson_page.dart';

import 'test_helpers.dart';
import 'v2_home_flow_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await resetV2HomeFlowState();
  });

  testWidgets('home card shows the next V2 lesson and enters it directly',
      (tester) async {
    await pumpV2Home(tester);

    expect(find.text('V2 Pilot Path'), findsOneWidget);
    expect(find.text('Alphabet Closure: Hear ث / ذ / ظ Clearly'), findsOneWidget);
    expect(
      find.text('Home now sends you straight into the next real action in the pilot path.'),
      findsOneWidget,
    );
    expect(find.widgetWithText(FilledButton, 'Start This V2 Lesson'), findsOneWidget);
    expect(find.byType(V2MicroLessonPage), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Start This V2 Lesson'));
    await pumpForTransition(tester);

    expect(find.byType(V2MicroLessonPage), findsOneWidget);
    expect(find.text('Alphabet Closure: Hear ث / ذ / ظ Clearly'), findsWidgets);

    await completeAlphabetClosureLesson(
      tester,
      language: AppLanguage.en,
    );

    expect(find.byType(V2MicroLessonCompletionPage), findsOneWidget);
    expect(find.text('Lesson Complete'), findsOneWidget);
    expect(find.text('You Can Already Do'), findsOneWidget);
    expect(
      find.textContaining('After this lesson, you can hear and pick out ث / ذ / ظ as a confusable set'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Back Home'));
    await pumpForTransition(tester);

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Short Vowel Bridge: Hear a / i / u'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Start This V2 Lesson'), findsOneWidget);
  });

  testWidgets('micro lesson completion returns home with a refreshed next recommendation',
      (tester) async {
    await pumpV2Home(tester);

    expect(find.text('Alphabet Closure: Hear ث / ذ / ظ Clearly'), findsOneWidget);
    expect(find.text('Short Vowel Bridge: Hear a / i / u'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Start This V2 Lesson'));
    await pumpForTransition(tester);

    await completeAlphabetClosureLesson(
      tester,
      language: AppLanguage.en,
    );

    expect(find.byType(V2MicroLessonCompletionPage), findsOneWidget);
    expect(find.text('Alphabet Closure: Hear ث / ذ / ظ Clearly'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Back Home'));
    await pumpForTransition(tester);

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Alphabet Closure: Hear ث / ذ / ظ Clearly'), findsNothing);
    expect(find.text('Short Vowel Bridge: Hear a / i / u'), findsOneWidget);
    expect(find.text('Continue This V2 Lesson'), findsNothing);
  });

  testWidgets('chinese home card shows the next V2 lesson and enters it directly',
      (tester) async {
    await pumpV2Home(
      tester,
      settings: kChineseTestSettings,
    );

    expect(find.text('V2 样板主线'), findsOneWidget);
    expect(find.text('字母收口：听清 ث / ذ / ظ'), findsOneWidget);
    expect(find.text('首页现在直接给出样板主线里的下一个真实动作。'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '开始这节 V2 小课'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, '开始这节 V2 小课'));
    await pumpForTransition(tester);

    expect(find.byType(V2MicroLessonPage), findsOneWidget);
    expect(find.text('字母收口：听清 ث / ذ / ظ'), findsWidgets);
    expect(find.text('本课目标'), findsOneWidget);
  });

  testWidgets('chinese micro lesson completion refreshes home recommendation',
      (tester) async {
    await pumpV2Home(
      tester,
      settings: kChineseTestSettings,
    );

    expect(find.text('字母收口：听清 ث / ذ / ظ'), findsOneWidget);
    expect(find.text('短元音桥接：听清 a / i / u'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, '开始这节 V2 小课'));
    await pumpForTransition(tester);

    await completeAlphabetClosureLesson(
      tester,
      language: AppLanguage.zh,
    );

    expect(find.byType(V2MicroLessonCompletionPage), findsOneWidget);
    expect(find.text('这节课结束了'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, '回到首页'));
    await pumpForTransition(tester);

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('字母收口：听清 ث / ذ / ظ'), findsNothing);
    expect(find.text('短元音桥接：听清 a / i / u'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '开始这节 V2 小课'), findsOneWidget);
  });
}