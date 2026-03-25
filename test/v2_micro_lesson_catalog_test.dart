import 'package:flutter_test/flutter_test.dart';

import 'package:arabic_learning_app/data/generated_stage_a_preview_lessons.dart';
import 'package:arabic_learning_app/data/v2_micro_lesson_catalog.dart';
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

  test('catalog resolves both live pilot and foundation pilot lessons', () {
    expect(containsV2MicroLesson('V2-ALPHA-CL-01'), isTrue);
    expect(containsV2MicroLesson('V2-A1-01-PREVIEW'), isTrue);

    expect(v2MicroLessonById('V2-ALPHA-CL-01').lessonId, 'V2-ALPHA-CL-01');
    expect(v2MicroLessonById('V2-A1-01-PREVIEW').lessonId, 'V2-A1-01-PREVIEW');
  });

  test('catalog returns the correct track for a foundation lesson id', () {
    final track = v2MicroLessonTrackForLessonId('V2-A1-01-PREVIEW');

    expect(track, same(foundationPilotMicroLessons));
    expect(track.first.lessonId, stageAFoundationPreviewLessons.first.lessonId);
    expect(track.first.lessonId, 'V2-A1-01-PREVIEW');
    expect(track.last.lessonId, 'lesson_12_you_can_read_a_tiny_arabic_card');
  });

  test('catalog keeps the existing live pilot track unchanged', () {
    final track = v2MicroLessonTrackForLessonId('V2-ALPHA-CL-01');

    expect(track, same(v2PilotMicroLessons));
    expect(track.first.lessonId, 'V2-ALPHA-CL-01');
  });
}
