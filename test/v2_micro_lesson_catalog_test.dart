import 'package:flutter_test/flutter_test.dart';

import 'package:arabic_learning_app/data/v2_micro_lessons.dart';

void main() {
  test('pilot micro lessons cover the first V2 runnable loop', () {
    expect(v2PilotMicroLessons.length, greaterThanOrEqualTo(6));
    expect(
      v2PilotMicroLessons.map((lesson) => lesson.lessonId),
      containsAll(<String>[
        'V2-ALPHA-CL-01',
        'V2-BRIDGE-01',
        'V2-U1-01',
        'V2-U1-02',
        'V2-U1-03',
        'V2-U1-04',
        'V2-U1-05',
      ]),
    );
  });

  test('every pilot lesson is sized as a micro lesson and has runnable rules',
      () {
    for (final lesson in v2PilotMicroLessons) {
      expect(lesson.isPilotSized, isTrue, reason: lesson.lessonId);
      expect(lesson.contentItems, isNotEmpty, reason: lesson.lessonId);
      expect(lesson.practiceItems, isNotEmpty, reason: lesson.lessonId);
      expect(lesson.reviewSeedRules, isNotEmpty, reason: lesson.lessonId);
      expect(lesson.nextActionHints, isNotEmpty, reason: lesson.lessonId);
      expect(
        lesson.completionRule.minimumPracticeCount,
        greaterThanOrEqualTo(1),
        reason: lesson.lessonId,
      );
    }
  });
}
