import 'package:flutter_test/flutter_test.dart';

import 'package:arabic_learning_app/pages/review_page.dart';

import 'test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows the upgraded review dashboard in English', (tester) async {
    await pumpLocalizedTestPage(
      tester,
      const ReviewPage(),
      sharedPreferences: <String, Object>{
        'completed_lessons': <String>['U1L1'],
        'started_lessons': <String>['U1L1'],
        'last_lesson_id': 'U1L1',
      },
    );

    expect(find.text('Review'), findsWidgets);
    expect(find.text('Today\'s Snapshot'), findsOneWidget);
    expect(find.text('Quick Actions'), findsOneWidget);
    expect(find.text('Quick Review'), findsOneWidget);
    expect(find.text('Worth Another Look'), findsOneWidget);
  });
}
