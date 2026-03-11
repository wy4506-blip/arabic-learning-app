import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/lesson.dart';

class LessonService {
  Future<List<Lesson>> loadLessons() async {
    final jsonString = await rootBundle.loadString('assets/data/lessons.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    return jsonData.map((e) => Lesson.fromJson(e)).toList();
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
}
