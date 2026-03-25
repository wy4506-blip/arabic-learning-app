import 'generated_stage_a_preview_lessons.dart';
import 'generated_stage_b_preview_lessons.dart';
import 'generated_stage_c_preview_lessons.dart';
import 'v2_micro_lessons.dart';
import '../models/v2_micro_lesson.dart';

const List<V2MicroLesson> foundationPilotMicroLessons = <V2MicroLesson>[
  ...stageAFoundationPreviewLessons,
  ...stageBPreviewLessons,
  ...stageCPreviewLessons,
];

const List<V2MicroLesson> allRegisteredV2MicroLessons = <V2MicroLesson>[
  ...v2PilotMicroLessons,
  ...foundationPilotMicroLessons,
];

final Map<String, V2MicroLesson> _registeredLessonsById =
    <String, V2MicroLesson>{
  for (final lesson in allRegisteredV2MicroLessons) lesson.lessonId: lesson,
};

final Set<String> _foundationPilotLessonIds =
    foundationPilotMicroLessons.map((lesson) => lesson.lessonId).toSet();

final Set<String> _currentPilotLessonIds =
    v2PilotMicroLessons.map((lesson) => lesson.lessonId).toSet();

V2MicroLesson v2MicroLessonById(String lessonId) {
  final lesson = maybeV2MicroLessonById(lessonId);
  if (lesson == null) {
    throw StateError('Unknown V2 micro lesson: $lessonId');
  }
  return lesson;
}

V2MicroLesson? maybeV2MicroLessonById(String lessonId) {
  return _registeredLessonsById[lessonId];
}

bool containsV2MicroLesson(String lessonId) {
  return _registeredLessonsById.containsKey(lessonId);
}

bool isFoundationPilotLessonId(String lessonId) {
  return _foundationPilotLessonIds.contains(lessonId);
}

List<V2MicroLesson> v2MicroLessonTrackForLessonId(String lessonId) {
  if (_foundationPilotLessonIds.contains(lessonId)) {
    return foundationPilotMicroLessons;
  }
  if (_currentPilotLessonIds.contains(lessonId)) {
    return v2PilotMicroLessons;
  }
  throw StateError('Unknown V2 micro lesson track for: $lessonId');
}
