import 'package:arabic_learning_app/data/v2_micro_lesson_catalog.dart';

void main() {
  for (var i = 0; i < foundationPilotMicroLessons.length; i++) {
    final lesson = foundationPilotMicroLessons[i];
    print('${i + 1}\t${lesson.lessonId}\t${lesson.title}\t${lesson.contentItems.length}\t${lesson.practiceItems.length}');
  }
}
