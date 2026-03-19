import 'package:flutter/material.dart';

import '../data/v2_micro_lessons.dart';
import '../l10n/localized_text.dart';
import '../l10n/v2_micro_lesson_localizer.dart';
import '../models/app_settings.dart';
import '../models/review_models.dart';
import '../models/v2_lesson_progress_models.dart';
import '../models/v2_micro_lesson.dart';
import '../services/v2_micro_lesson_completion_orchestrator.dart';

class V2MicroLessonCompletionPage extends StatelessWidget {
  final AppSettings settings;
  final V2MicroLessonCompletionResult result;

  const V2MicroLessonCompletionPage({
    super.key,
    required this.settings,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final lesson = v2PilotMicroLessons.firstWhere(
      (item) => item.lessonId == result.lessonId,
      orElse: () => const V2MicroLesson(
        lessonId: 'fallback',
        phaseId: 'fallback',
        groupId: 'fallback',
        title: '',
        outcomeSummary: '',
        estimatedMinutes: 0,
        lessonType: V2MicroLessonType.consolidation,
        objectives: <V2MicroLessonObjective>[],
        entryCondition: V2MicroLessonEntryCondition(),
        contentItems: <V2MicroContentItem>[],
        practiceItems: <V2MicroPracticeItem>[],
        completionRule: V2MicroCompletionRule(),
        reviewSeedRules: <V2MicroReviewSeedRule>[],
        nextActionHints: <V2NextActionHint>[],
      ),
    );
    final language = settings.appLanguage;
    final objectiveResultsById = {
      for (final item in result.updatedObjectives) item.objectiveId: item,
    };
    final achieved = lesson.objectives
        .where(
          (objective) =>
              objectiveResultsById[objective.objectiveId]?.reachedThreshold ==
              true,
        )
        .map(
          (objective) => V2MicroLessonLocalizer.objectiveSummary(
            objective.objectiveId,
            language,
            fallback: objective.summary,
          ),
        )
        .toList(growable: false);
    final unstable = lesson.objectives
        .where(
          (objective) =>
              objectiveResultsById[objective.objectiveId]?.reachedThreshold ==
              false,
        )
        .map(
          (objective) => V2MicroLessonLocalizer.objectiveSummary(
            objective.objectiveId,
            language,
            fallback: objective.summary,
          ),
        )
        .toList(growable: false);
    final learnedOutcome = lesson.lessonId == 'fallback'
        ? result.completionSummary.learnedOutcome
        : V2MicroLessonLocalizer.outcomeSummary(lesson, language);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizedText(
            context,
            zh: '这节课结束了',
            en: 'Lesson Complete',
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizedText(
                  context,
                  zh: '你已经会了什么',
                  en: 'What You Can Do Now',
                ),
                style: text.titleLarge,
              ),
              const SizedBox(height: 10),
              Text(learnedOutcome, style: text.bodyLarge),
              const SizedBox(height: 10),
              Text(
                _localizedLearningFeedback(
                  achieved: achieved,
                  unstable: unstable,
                  language: language,
                ),
                style: text.bodyMedium,
              ),
              const SizedBox(height: 20),
              if (achieved.isNotEmpty) ...[
                Text(
                  localizedText(
                    context,
                    zh: '这轮你已经做到',
                    en: 'You Can Already Do',
                  ),
                  style: text.titleMedium,
                ),
                const SizedBox(height: 8),
                ...achieved.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('- $item', style: text.bodyMedium),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                localizedText(
                  context,
                  zh: '下一轮优先回看',
                  en: 'Review Next',
                ),
                style: text.titleMedium,
              ),
              const SizedBox(height: 8),
              if (unstable.isEmpty)
                Text(
                  localizedText(
                    context,
                    zh: '这一轮没有明显薄弱点，可以继续主线。',
                    en: 'No clear weak point showed up in this pass. You can continue the mainline.',
                  ),
                  style: text.bodyMedium,
                )
              else
                ...unstable.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('- $item', style: text.bodyMedium),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                localizedText(
                  context,
                  zh: '复习结果',
                  en: 'Review Result',
                ),
                style: text.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _localizedReviewSummary(result.createdReviewSeeds, language),
                style: text.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                localizedText(
                  context,
                  zh: '下一步建议',
                  en: 'Next Step',
                ),
                style: text.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _localizedNextStepSummary(
                  actionType: result.recommendedAction.actionType,
                  recommendedLessonId: result.recommendedLessonId,
                  language: language,
                ),
                style: text.bodyMedium,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(
                    localizedText(
                      context,
                      zh: '回到首页',
                      en: 'Back Home',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _localizedNextStepSummary({
    required V2RecommendedActionType actionType,
    required String? recommendedLessonId,
    required AppLanguage language,
  }) {
    final recommendedLessonTitle = recommendedLessonId == null
        ? null
        : V2MicroLessonLocalizer.lessonTitleById(
            recommendedLessonId,
            language,
          );
    if (language != AppLanguage.en) {
      switch (actionType) {
        case V2RecommendedActionType.startLesson:
          return recommendedLessonTitle == null
              ? '下一步建议继续进入新课。'
              : '下一步建议进入：$recommendedLessonTitle。';
        case V2RecommendedActionType.continueLesson:
          return recommendedLessonTitle == null
              ? '下一步建议先继续当前进行中的课程。'
              : '下一步建议先继续：$recommendedLessonTitle。';
        case V2RecommendedActionType.startReview:
          return '下一步建议先回看这轮还不稳的点。';
        case V2RecommendedActionType.startConsolidation:
          return '下一步建议先做这一阶段的巩固。';
        case V2RecommendedActionType.startNextPhase:
          return '下一步建议进入下一阶段。';
        case V2RecommendedActionType.noAction:
          return '当前没有新的主动任务可执行。';
      }
    }

    switch (actionType) {
      case V2RecommendedActionType.startLesson:
        return recommendedLessonTitle == null
            ? 'Next, move into the next pilot lesson.'
            : 'Next, move into $recommendedLessonTitle.';
      case V2RecommendedActionType.continueLesson:
        return recommendedLessonTitle == null
            ? 'Next, continue the pilot lesson already in progress.'
            : 'Next, continue $recommendedLessonTitle.';
      case V2RecommendedActionType.startReview:
        return 'Next, revisit the weak or due points from this lesson first.';
      case V2RecommendedActionType.startConsolidation:
        return 'Next, do a short consolidation pass for this phase.';
      case V2RecommendedActionType.startNextPhase:
        return 'Next, move into the next phase.';
      case V2RecommendedActionType.noAction:
        return 'There is no new primary action right now.';
    }
  }

  String _localizedLearningFeedback({
    required List<String> achieved,
    required List<String> unstable,
    required AppLanguage language,
  }) {
    if (language != AppLanguage.en) {
      if (achieved.isNotEmpty && unstable.isEmpty) {
        return '这一轮你已经把本课主目标做出来了，可以直接继续下一步。';
      }
      if (achieved.isNotEmpty) {
        return '这一轮你已经先站稳了本课里的关键动作，剩下的点下轮再补稳。';
      }
      return '这一轮先记住本课的主句和主动作，下一步优先回看薄弱点。';
    }

    if (achieved.isNotEmpty && unstable.isEmpty) {
      return 'This pass locked in the main action of the lesson, so you can keep moving.';
    }
    if (achieved.isNotEmpty) {
      return 'This pass already stabilized the core action of the lesson, with a few points left to revisit.';
    }
    return 'This pass set up the main line of the lesson. Revisit the weak point once more before moving on.';
  }

  String _localizedReviewSummary(
    List<V2ReviewSeedRecord> seeds,
    AppLanguage language,
  ) {
    if (seeds.isEmpty) {
      return language == AppLanguage.en
          ? 'No new review point was added from this lesson.'
          : '这一轮没有新增复习点。';
    }

    final labels = seeds
        .map((seed) => _reviewTypeLabel(seed.objectType, language))
        .toSet()
        .toList(growable: false);
    final joined = labels.join(language == AppLanguage.en ? ', ' : '、');
    if (language == AppLanguage.en) {
      return '${seeds.length} review ${seeds.length == 1 ? 'point was' : 'points were'} added for $joined.';
    }
    return '这一轮已加入 ${seeds.length} 个复习点，重点回看：$joined。';
  }

  String _reviewTypeLabel(
    ReviewObjectType objectType,
    AppLanguage language,
  ) {
    if (language != AppLanguage.en) {
      switch (objectType) {
        case ReviewObjectType.letterName:
          return '字母命名';
        case ReviewObjectType.letterSound:
          return '字母听辨';
        case ReviewObjectType.letterForm:
          return '字形识别';
        case ReviewObjectType.symbolReading:
          return '短元音听辨';
        case ReviewObjectType.wordReading:
          return '词语认读';
        case ReviewObjectType.confusionPair:
          return '易混对比';
        case ReviewObjectType.sentencePattern:
          return '句型跟说';
        case ReviewObjectType.grammarReference:
          return '语法回看';
      }
    }

    switch (objectType) {
      case ReviewObjectType.letterName:
        return 'letter naming';
      case ReviewObjectType.letterSound:
        return 'letter listening';
      case ReviewObjectType.letterForm:
        return 'letter form recognition';
      case ReviewObjectType.symbolReading:
        return 'short-vowel listening';
      case ReviewObjectType.wordReading:
        return 'word reading';
      case ReviewObjectType.confusionPair:
        return 'confusable pair contrast';
      case ReviewObjectType.sentencePattern:
        return 'pattern repetition';
      case ReviewObjectType.grammarReference:
        return 'grammar review';
    }
  }
}
