import 'dart:convert';

import 'package:flutter/services.dart';

import '../data/sample_lessons.dart';
import '../models/lesson.dart';

class LessonService {
  static List<Lesson>? _cachedLessons;

  Future<List<Lesson>> loadLessons() async {
    final cached = _cachedLessons;
    if (cached != null) {
      return cached;
    }

    try {
      final jsonString =
          await rootBundle.loadString('assets/data/lessons.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      final lessons = jsonData
          .map((item) => Lesson.fromJson(item as Map<String, dynamic>))
          .toList();
      if (lessons.isNotEmpty) {
        lessons.sort((a, b) => a.sequence.compareTo(b.sequence));
        _cachedLessons = List<Lesson>.from(lessons);
        return _cachedLessons!;
      }
    } catch (_) {
      // Fall back to the built-in sample curriculum when local JSON is absent or invalid.
    }

    _cachedLessons = List<Lesson>.from(sampleLessons)
      ..sort((a, b) => a.sequence.compareTo(b.sequence));
    return _cachedLessons!;
  }

  Future<Map<String, List<Lesson>>> loadLessonsGroupedByUnit() async {
    final lessons = await loadLessons();
    final Map<String, List<Lesson>> grouped = {};

    for (final lesson in lessons) {
      grouped.putIfAbsent(lesson.unitId, () => []);
      grouped[lesson.unitId]!.add(lesson);
    }

    return grouped;
  }

  static void debugClearCache() {
    _cachedLessons = null;
  }
}
