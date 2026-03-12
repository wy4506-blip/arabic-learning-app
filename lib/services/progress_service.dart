import 'package:shared_preferences/shared_preferences.dart';

class ProgressSnapshot {
  final Set<String> completedLessons;
  final Set<String> startedLessons;
  final int reviewCount;
  final int streakDays;
  final String? lastLessonId;

  const ProgressSnapshot({
    required this.completedLessons,
    required this.startedLessons,
    required this.reviewCount,
    required this.streakDays,
    this.lastLessonId,
  });
}

class ProgressService {
  static const _completedLessonsKey = 'completed_lessons';
  static const _startedLessonsKey = 'started_lessons';
  static const _reviewCountKey = 'review_count';
  static const _streakDaysKey = 'streak_days';
  static const _lastLessonIdKey = 'last_lesson_id';

  static Future<ProgressSnapshot> getSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    return ProgressSnapshot(
      completedLessons: (prefs.getStringList(_completedLessonsKey) ?? const [])
          .toSet(),
      startedLessons: (prefs.getStringList(_startedLessonsKey) ?? const [])
          .toSet(),
      reviewCount: prefs.getInt(_reviewCountKey) ?? 0,
      streakDays: prefs.getInt(_streakDaysKey) ?? 0,
      lastLessonId: prefs.getString(_lastLessonIdKey),
    );
  }

  static Future<void> markLessonStarted(String lessonId) async {
    final prefs = await SharedPreferences.getInstance();
    final started = (prefs.getStringList(_startedLessonsKey) ?? const []).toSet();
    started.add(lessonId);
    await prefs.setStringList(_startedLessonsKey, started.toList());
    await prefs.setString(_lastLessonIdKey, lessonId);
    final streak = prefs.getInt(_streakDaysKey) ?? 0;
    if (streak == 0) await prefs.setInt(_streakDaysKey, 1);
  }

  static Future<void> markLessonCompleted(String lessonId) async {
    final prefs = await SharedPreferences.getInstance();
    final completed = (prefs.getStringList(_completedLessonsKey) ?? const []).toSet();
    completed.add(lessonId);
    await prefs.setStringList(_completedLessonsKey, completed.toList());
    await markLessonStarted(lessonId);
  }

  static Future<void> incrementReviewCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_reviewCountKey) ?? 0;
    await prefs.setInt(_reviewCountKey, count + 1);
  }
}
