import 'package:flutter_test/flutter_test.dart';

import 'package:arabic_learning_app/pages/v2_micro_lesson_page.dart';

import 'v2_home_flow_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await resetV2HomeFlowState();
  });

  testWidgets('alphabet stage completion naturally hands off to the first lesson',
      (tester) async {
    await pumpV2Home(tester);

    expect(find.text('Start This V2 Lesson'), findsOneWidget);
    expect(find.text('Start Pilot Review'), findsNothing);

    await tester.tap(find.text('Start This V2 Lesson').first);
    await pumpForTransition(tester);

    expect(find.byType(V2MicroLessonPage), findsOneWidget);
  });
}
