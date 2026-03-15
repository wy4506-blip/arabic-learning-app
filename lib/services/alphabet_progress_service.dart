import 'package:shared_preferences/shared_preferences.dart';

import '../models/alphabet_group.dart';
import 'alphabet_service.dart';

class AlphabetLearningSnapshot {
  final Set<String> viewedLetters;
  final Set<String> listenCompletedLetters;
  final Set<String> writeCompletedLetters;
  final int totalLetterCount;
  final int totalGroupCount;
  final int completedGroupCount;

  const AlphabetLearningSnapshot({
    required this.viewedLetters,
    required this.listenCompletedLetters,
    required this.writeCompletedLetters,
    required this.totalLetterCount,
    required this.totalGroupCount,
    required this.completedGroupCount,
  });

  static const empty = AlphabetLearningSnapshot(
    viewedLetters: <String>{},
    listenCompletedLetters: <String>{},
    writeCompletedLetters: <String>{},
    totalLetterCount: 0,
    totalGroupCount: 0,
    completedGroupCount: 0,
  );

  int get viewedLetterCount => viewedLetters.length;

  int get listenCompletedCount => listenCompletedLetters.length;

  int get writeCompletedCount => writeCompletedLetters.length;

  bool get hasStarted =>
      viewedLetters.isNotEmpty ||
      listenCompletedLetters.isNotEmpty ||
      writeCompletedLetters.isNotEmpty;

  bool get isStageComplete =>
      totalGroupCount > 0 && completedGroupCount >= totalGroupCount;
}

class AlphabetGroupProgress {
  final int completedLetterCount;
  final int totalLetterCount;
  final bool isCompleted;

  const AlphabetGroupProgress({
    required this.completedLetterCount,
    required this.totalLetterCount,
    required this.isCompleted,
  });
}

enum AlphabetNextActionType {
  resumeLetter,
  groupComplete,
  alphabetComplete,
}

class AlphabetNextAction {
  final AlphabetNextActionType actionType;
  final int? currentGroupId;
  final String? currentLetterKey;
  final String? nextLetterKey;
  final bool isAlphabetComplete;
  final bool isGroupComplete;

  const AlphabetNextAction({
    required this.actionType,
    this.currentGroupId,
    this.currentLetterKey,
    this.nextLetterKey,
    required this.isAlphabetComplete,
    required this.isGroupComplete,
  });
}

class AlphabetProgressService {
  AlphabetProgressService._();

  static const String _viewedLettersKey = 'alphabet_progress_viewed_letters_v1';
  static const String _listenLettersKey = 'alphabet_progress_listen_letters_v1';
  static const String _writeLettersKey = 'alphabet_progress_write_letters_v1';

  static Future<void> markLetterViewed(AlphabetLetter letter) async {
    await _append(_viewedLettersKey, _letterKey(letter));
  }

  static Future<void> markListenReadCompleted(AlphabetLetter letter) async {
    await _append(_listenLettersKey, _letterKey(letter));
  }

  static Future<void> markWriteCompleted(AlphabetLetter letter) async {
    await _append(_writeLettersKey, _letterKey(letter));
  }

  static Future<AlphabetLearningSnapshot> getSnapshot({
    List<AlphabetGroup>? groups,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final viewedLetters =
        prefs.getStringList(_viewedLettersKey)?.toSet() ?? <String>{};
    final listenCompletedLetters =
        prefs.getStringList(_listenLettersKey)?.toSet() ?? <String>{};
    final writeCompletedLetters =
        prefs.getStringList(_writeLettersKey)?.toSet() ?? <String>{};

    final resolvedGroups = groups ?? await AlphabetService.loadAlphabetGroups();
    final totalLetterCount = resolvedGroups.fold<int>(
      0,
      (total, group) => total + group.letters.length,
    );

    var completedGroupCount = 0;
    for (final group in resolvedGroups) {
      final letterKeys = group.letters.map(_letterKey).toList(growable: false);
      final groupCompleted = letterKeys.every(
        (letterKey) =>
            viewedLetters.contains(letterKey) &&
        listenCompletedLetters.contains(letterKey),
      );
      if (groupCompleted) {
        completedGroupCount += 1;
      }
    }

    return AlphabetLearningSnapshot(
      viewedLetters: viewedLetters,
      listenCompletedLetters: listenCompletedLetters,
      writeCompletedLetters: writeCompletedLetters,
      totalLetterCount: totalLetterCount,
      totalGroupCount: resolvedGroups.length,
      completedGroupCount: completedGroupCount,
    );
  }

  static Future<AlphabetGroupProgress> getGroupProgress(
    AlphabetGroup group,
  ) async {
    final snapshot = await getSnapshot(groups: <AlphabetGroup>[group]);
    final completedLetterCount = group.letters
        .where(
          (letter) => isLetterMainlineCompleted(
            snapshot: snapshot,
            letter: letter,
          ),
        )
        .length;

    return AlphabetGroupProgress(
      completedLetterCount: completedLetterCount,
      totalLetterCount: group.letters.length,
      isCompleted: group.letters.isNotEmpty &&
          completedLetterCount >= group.letters.length,
    );
  }

  static bool isLetterMainlineCompleted({
    required AlphabetLearningSnapshot snapshot,
    required AlphabetLetter letter,
  }) {
    final letterKey = _letterKey(letter);
    return snapshot.viewedLetters.contains(letterKey) &&
        snapshot.listenCompletedLetters.contains(letterKey);
  }

  static bool isGroupMainlineCompleted({
    required AlphabetLearningSnapshot snapshot,
    required AlphabetGroup group,
  }) {
    return group.letters.isNotEmpty &&
        group.letters.every(
          (letter) => isLetterMainlineCompleted(
            snapshot: snapshot,
            letter: letter,
          ),
        );
  }

  static Future<AlphabetNextAction> getNextAlphabetAction({
    List<AlphabetGroup>? groups,
    int? preferredGroupId,
  }) async {
    final resolvedGroups = groups ?? await AlphabetService.loadAlphabetGroups();
    final snapshot = await getSnapshot(groups: resolvedGroups);
    return buildNextAlphabetAction(
      snapshot: snapshot,
      groups: resolvedGroups,
      preferredGroupId: preferredGroupId,
    );
  }

  static AlphabetNextAction buildNextAlphabetAction({
    required AlphabetLearningSnapshot snapshot,
    required List<AlphabetGroup> groups,
    int? preferredGroupId,
  }) {
    if (preferredGroupId != null) {
      final preferredGroup = findGroupById(groups, preferredGroupId);
      if (preferredGroup != null) {
        final preferredLetter = firstIncompleteLetter(
          snapshot: snapshot,
          group: preferredGroup,
        );
        if (preferredLetter != null) {
          final letterKey = _letterKey(preferredLetter);
          return AlphabetNextAction(
            actionType: AlphabetNextActionType.resumeLetter,
            currentGroupId: preferredGroup.id,
            currentLetterKey: letterKey,
            nextLetterKey: letterKey,
            isAlphabetComplete: false,
            isGroupComplete: false,
          );
        }

        final alphabetComplete = groups.every(
          (group) => isGroupMainlineCompleted(snapshot: snapshot, group: group),
        );
        return AlphabetNextAction(
          actionType: alphabetComplete
              ? AlphabetNextActionType.alphabetComplete
              : AlphabetNextActionType.groupComplete,
          currentGroupId: preferredGroup.id,
          isAlphabetComplete: alphabetComplete,
          isGroupComplete: true,
        );
      }
    }

    for (final group in groups) {
      final letter = firstIncompleteLetter(snapshot: snapshot, group: group);
      if (letter != null) {
        final letterKey = _letterKey(letter);
        return AlphabetNextAction(
          actionType: AlphabetNextActionType.resumeLetter,
          currentGroupId: group.id,
          currentLetterKey: letterKey,
          nextLetterKey: letterKey,
          isAlphabetComplete: false,
          isGroupComplete: false,
        );
      }
    }

    return const AlphabetNextAction(
      actionType: AlphabetNextActionType.alphabetComplete,
      isAlphabetComplete: true,
      isGroupComplete: true,
    );
  }

  static AlphabetGroup? findGroupById(
    List<AlphabetGroup> groups,
    int? groupId,
  ) {
    if (groupId == null) {
      return null;
    }
    for (final group in groups) {
      if (group.id == groupId) {
        return group;
      }
    }
    return null;
  }

  static AlphabetLetter? findLetterByKey(
    AlphabetGroup group,
    String? letterKey,
  ) {
    if (letterKey == null || letterKey.isEmpty) {
      return null;
    }
    for (final letter in group.letters) {
      if (_letterKey(letter) == letterKey) {
        return letter;
      }
    }
    return null;
  }

  static AlphabetLetter? firstIncompleteLetter({
    required AlphabetLearningSnapshot snapshot,
    required AlphabetGroup group,
  }) {
    for (final letter in group.letters) {
      if (!isLetterMainlineCompleted(snapshot: snapshot, letter: letter)) {
        return letter;
      }
    }
    return null;
  }

  static Future<void> _append(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    final items = prefs.getStringList(key)?.toSet() ?? <String>{};
    if (!items.add(value)) {
      return;
    }
    await prefs.setStringList(key, items.toList(growable: false));
  }

  static String _letterKey(AlphabetLetter letter) => letter.arabic.trim();
}
