import 'package:flutter_test/flutter_test.dart';

import 'package:arabic_learning_app/models/app_settings.dart';
import 'package:arabic_learning_app/models/review_models.dart';
import 'package:arabic_learning_app/services/v2_learning_snapshot_service.dart';
import 'package:arabic_learning_app/services/v2_review_flow_service.dart';

void main() {
  test(
      'pilot review session keeps due items and clears legacy next lesson exit',
      () {
    const settings = AppSettings(
      appLanguage: AppLanguage.en,
      meaningLanguage: ContentLanguage.en,
      showTransliteration: true,
    );
    const baseSession = ReviewSession(
      id: 'today:2026-03-15',
      kind: ReviewSessionKind.today,
      title: 'Today\'s Review',
      subtitle: 'Base review session',
      tasks: <ReviewTask>[
        ReviewTask(
          contentId: 'sentence_pattern:sabah_al_khayr',
          type: ReviewContentType.sentence,
          objectType: ReviewObjectType.sentencePattern,
          actionType: ReviewActionType.repeat,
          origin: ReviewTaskOrigin.due,
          title: 'Morning greeting',
          subtitle: 'Repeat it.',
          estimatedSeconds: 30,
          priority: 5,
        ),
        ReviewTask(
          contentId: 'word_reading:kitab',
          type: ReviewContentType.word,
          objectType: ReviewObjectType.wordReading,
          actionType: ReviewActionType.read,
          origin: ReviewTaskOrigin.recentLesson,
          title: 'kitab',
          subtitle: 'Read it.',
          estimatedSeconds: 20,
          priority: 1,
        ),
      ],
      countTowardActivity: true,
      syncWithTodayPlan: true,
      config: ReviewSessionConfig.reviewTab(
        mode: ReviewSessionMode.formal,
        nextLessonId: 'legacy-lesson-2',
        nextLessonLabel: 'Legacy lesson 2',
      ),
    );
    const dueItems = <V2DueReviewItem>[
      V2DueReviewItem(
        contentId: 'sentence_pattern:sabah_al_khayr',
        lessonId: 'V2-U1-01',
        objectType: ReviewObjectType.sentencePattern,
        actionType: ReviewActionType.repeat,
        priority: 5,
        isWeak: true,
        dueAt: null,
      ),
    ];

    final session = V2ReviewFlowService.buildPilotReviewSession(
      settings: settings,
      baseSession: baseSession,
      dueReviewItems: dueItems,
    );

    expect(session.title, 'Pilot Review');
    expect(session.tasks.length, 1);
    expect(session.tasks.single.contentId, 'sentence_pattern:sabah_al_khayr');
    expect(session.config.source, ReviewEntrySource.reviewTab);
    expect(session.config.nextLessonId, isNull);
    expect(session.config.autoContinueToLesson, isFalse);
  });
}
