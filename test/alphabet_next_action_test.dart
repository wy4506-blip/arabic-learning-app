import 'package:flutter_test/flutter_test.dart';

import 'package:arabic_learning_app/data/sample_alphabet_data.dart';
import 'package:arabic_learning_app/services/alphabet_progress_service.dart';

void main() {
  final groups = sampleAlphabetGroups;
  final firstGroup = groups.first;

  test('buildNextAlphabetAction returns the first incomplete letter in order',
      () {
    final snapshot = AlphabetLearningSnapshot(
      viewedLetters: <String>{firstGroup.letters.first.arabic},
      listenCompletedLetters: <String>{firstGroup.letters.first.arabic},
      writeCompletedLetters: const <String>{},
      totalLetterCount: groups.fold<int>(
        0,
        (total, group) => total + group.letters.length,
      ),
      totalGroupCount: groups.length,
      completedGroupCount: 0,
    );

    final action = AlphabetProgressService.buildNextAlphabetAction(
      snapshot: snapshot,
      groups: groups,
    );

    expect(action.actionType, AlphabetNextActionType.resumeLetter);
    expect(action.currentGroupId, firstGroup.id);
    expect(action.currentLetterKey, firstGroup.letters[1].arabic);
  });

  test('group completion does not depend on writeCompleted', () {
    final completedLetters =
        firstGroup.letters.map((letter) => letter.arabic).toSet();
    final snapshot = AlphabetLearningSnapshot(
      viewedLetters: completedLetters,
      listenCompletedLetters: completedLetters,
      writeCompletedLetters: const <String>{},
      totalLetterCount: groups.fold<int>(
        0,
        (total, group) => total + group.letters.length,
      ),
      totalGroupCount: groups.length,
      completedGroupCount: 1,
    );

    expect(
      AlphabetProgressService.isGroupMainlineCompleted(
        snapshot: snapshot,
        group: firstGroup,
      ),
      isTrue,
    );

    final action = AlphabetProgressService.buildNextAlphabetAction(
      snapshot: snapshot,
      groups: groups,
      preferredGroupId: firstGroup.id,
    );

    expect(action.actionType, AlphabetNextActionType.groupComplete);
    expect(action.isGroupComplete, isTrue);
    expect(action.isAlphabetComplete, isFalse);
  });
}
