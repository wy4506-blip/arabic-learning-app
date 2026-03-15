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
    final completedLetterCount = group.letters.where((letter) {
      final letterKey = _letterKey(letter);
      return snapshot.viewedLetters.contains(letterKey) &&
          snapshot.listenCompletedLetters.contains(letterKey);
    }).length;

    return AlphabetGroupProgress(
      completedLetterCount: completedLetterCount,
      totalLetterCount: group.letters.length,
      isCompleted: group.letters.isNotEmpty &&
          completedLetterCount >= group.letters.length,
    );
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
