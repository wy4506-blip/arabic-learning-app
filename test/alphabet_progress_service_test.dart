import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:arabic_learning_app/services/alphabet_progress_service.dart';
import 'package:arabic_learning_app/services/alphabet_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('alphabet progress aggregates letter milestones into group completion',
      () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    final groups = await AlphabetService.loadAlphabetGroups();
    final firstGroup = groups.first;

    for (final letter in firstGroup.letters) {
      await AlphabetProgressService.markLetterViewed(letter);
      await AlphabetProgressService.markListenReadCompleted(letter);
      await AlphabetProgressService.markWriteCompleted(letter);
    }

    final snapshot = await AlphabetProgressService.getSnapshot(groups: groups);

    expect(snapshot.completedGroupCount, 1);
    expect(snapshot.totalGroupCount, groups.length);
    expect(snapshot.isStageComplete, isFalse);
  });
}
