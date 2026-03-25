import '../models/review_models.dart';
import '../models/v2_micro_lesson.dart';

const String _kitab = '\u0643\u062a\u0627\u0628';
const String _bab = '\u0628\u0627\u0628';
const String _qalam = '\u0642\u0644\u0645';
const String _hadhaKitab = '\u0647\u0630\u0627 \u0643\u062a\u0627\u0628';
const String _hadhaQalam = '\u0647\u0630\u0627 \u0642\u0644\u0645';
const String _hadhaBab = '\u0647\u0630\u0627 \u0628\u0627\u0628';
const String _stageBPackDisplay = 'كتاب\nباب\nقلم\nهذا كتاب\nهذا قلم';
const String _stageBPackSequence = 'كتاب باب قلم هذا كتاب هذا قلم';

class StageBPreviewDescriptor {
  final String lessonId;
  final int order;
  final String chapterRole;
  final String learnerVisibleOutcome;
  final String completionEvidence;
  final String chapterBridge;
  final String nextUnlock;

  const StageBPreviewDescriptor({
    required this.lessonId,
    required this.order,
    required this.chapterRole,
    required this.learnerVisibleOutcome,
    required this.completionEvidence,
    required this.chapterBridge,
    required this.nextUnlock,
  });
}

StageBPreviewDescriptor? stageBPreviewDescriptorForLessonId(String lessonId) {
  for (final descriptor in stageBPreviewDescriptors) {
    if (descriptor.lessonId == lessonId) {
      return descriptor;
    }
  }
  return null;
}

const List<StageBPreviewDescriptor> stageBPreviewDescriptors =
    <StageBPreviewDescriptor>[
      StageBPreviewDescriptor(
        lessonId: 'lesson_05_qalam_first_real_word_extension',
        order: 5,
        chapterRole: 'Learn one more real word',
        learnerVisibleOutcome:
            'You can recognize, hear, recall, and say قلم as the Arabic word for pen.',
        completionEvidence:
            'Clean completion means the learner hears قلم, spots it against كتاب and باب, and brings it back from the meaning pen.',
        chapterBridge:
            'Stage B starts by proving that Arabic keeps moving forward through real content: one more useful word joins the pack.',
        nextUnlock:
            'With قلم stable, the next unlock is the first short line: هذا كتاب / هذا قلم.',
      ),
      StageBPreviewDescriptor(
        lessonId: 'lesson_06_hadha_first_fixed_expression',
        order: 6,
        chapterRole: 'Build your first short Arabic line',
        learnerVisibleOutcome:
            'You can understand, build, and say هذا كتاب and هذا قلم as your first tiny Arabic lines.',
        completionEvidence:
            'Clean completion means the learner recognizes one هذا + noun line, rebuilds one full line, and recalls one line with lighter support.',
        chapterBridge:
            'Known words now become reusable inside one stable frame, so Arabic starts feeling usable instead of word-by-word only.',
        nextUnlock:
            'The next unlock is hearing known words and lines more directly from audio.',
      ),
      StageBPreviewDescriptor(
        lessonId: 'lesson_07_audio_first_known_content_recognition',
        order: 7,
        chapterRole: 'Hear what you already know',
        learnerVisibleOutcome:
            'You can catch familiar Arabic by ear across one word and one tiny هذا + noun line.',
        completionEvidence:
            'Clean completion means the learner identifies known content from audio and rebuilds one heard line after the first listen-first pass.',
        chapterBridge:
            'Stage B now shifts the known pack toward the ear without turning the chapter into a broad listening block.',
        nextUnlock:
            'The final Stage B unlock is a small usable Arabic pack you can read, hear, recall, and say.',
      ),
      StageBPreviewDescriptor(
        lessonId: 'lesson_08_first_usable_arabic_pack',
        order: 8,
        chapterRole: 'Finish Stage B with a usable pack',
        learnerVisibleOutcome:
            'You can handle كتاب, باب, قلم, هذا كتاب, and هذا قلم as one small usable Arabic pack.',
        completionEvidence:
            'Clean completion means the learner handles the pack across reading, listening, recall, and one short output step instead of isolated taps only.',
        chapterBridge:
            'Stage B closes by turning separate wins into one beginner pack that feels real and usable.',
        nextUnlock:
            'Stage C can now start from a stable pack instead of restarting from abstract explanation.',
      ),
    ];

const V2MicroLesson lesson5QalamFirstRealWordExtensionPreviewLesson =
    V2MicroLesson(
      lessonId: 'lesson_05_qalam_first_real_word_extension',
      phaseId: 'phase_preview_stage_b_word_growth',
      groupId: 'stage_b_preview_word_growth',
      title: 'One More Real Word: قلم',
      outcomeSummary:
          'After this lesson, you can recognize, hear, recall, and say قلم for pen.',
      estimatedMinutes: 5,
      lessonType: V2MicroLessonType.identityIntroduction,
      objectives: <V2MicroLessonObjective>[
        V2MicroLessonObjective(
          objectiveId: 'recognize_recall_qalam',
          summary: 'Recognize and recall قلم as the Arabic word for pen.',
        ),
      ],
      entryCondition: V2MicroLessonEntryCondition(
        requiredLessonIds: <String>['V2-A1-04-PREVIEW'],
      ),
      contentItems: <V2MicroContentItem>[
        V2MicroContentItem(
          itemId: 'goal_qalam_word',
          kind: V2MicroContentKind.goal,
          title: 'Lesson Goal',
          body: 'Add one more real Arabic word to your pack: قلم = pen.',
          objectiveIds: <String>['recognize_recall_qalam'],
        ),
        V2MicroContentItem(
          itemId: 'input_qalam_word',
          kind: V2MicroContentKind.input,
          title: 'One More Real Word',
          body:
              'Meet قلم as one more useful Arabic word. Keep the whole shape, sound, and meaning together.',
          arabicText: _qalam,
          transliteration: 'qalam',
          meaning: 'pen',
          audioQueryText: _qalam,
          objectiveIds: <String>['recognize_recall_qalam'],
        ),
        V2MicroContentItem(
          itemId: 'support_qalam_pack',
          kind: V2MicroContentKind.explanation,
          title: 'Your Pack Is Growing',
          body:
              'كتاب and باب stay nearby as safe anchors, but this lesson is really about owning قلم as your next real word.',
          arabicText: '$_kitab / $_bab / $_qalam',
          objectiveIds: <String>['recognize_recall_qalam'],
        ),
        V2MicroContentItem(
          itemId: 'contrast_qalam_known_words',
          kind: V2MicroContentKind.contrast,
          title: 'See It In The Pack',
          body:
              'Use whole-word contrast only. قلم should feel like another real item in the pack, not a return to isolated script study.',
          arabicText: '$_kitab / $_bab / $_qalam',
          objectiveIds: <String>['recognize_recall_qalam'],
        ),
      ],
      practiceItems: <V2MicroPracticeItem>[
        V2MicroPracticeItem(
          itemId: 'recognize_qalam_meaning',
          type: V2MicroPracticeType.comprehensionCheck,
          prompt: 'In this lesson, قلم means...',
          arabicText: 'pen',
          meaning: 'قلم = pen',
          choiceOptions: <String>['pen', 'book', 'door'],
          itemRefId: 'word_meaning_qalam',
          reviewObjectType: ReviewObjectType.wordReading,
          reviewActionType: ReviewActionType.read,
          objectiveIds: <String>['recognize_recall_qalam'],
        ),
        V2MicroPracticeItem(
          itemId: 'choose_qalam_from_pack',
          type: V2MicroPracticeType.comprehensionCheck,
          prompt: 'Which Arabic word means pen?',
          arabicText: _qalam,
          meaning: 'pen',
          choiceOptions: <String>[_qalam, _kitab, _bab],
          itemRefId: 'word_contrast_qalam_vs_kitab_bab',
          reviewObjectType: ReviewObjectType.wordReading,
          reviewActionType: ReviewActionType.distinguish,
          objectiveIds: <String>['recognize_recall_qalam'],
        ),
        V2MicroPracticeItem(
          itemId: 'hear_qalam_and_tap',
          type: V2MicroPracticeType.listenTap,
          prompt: 'Listen, then tap قلم.',
          arabicText: _qalam,
          meaning: 'pen',
          choiceOptions: <String>[_qalam, _kitab, _bab],
          itemRefId: 'audio_to_word_qalam',
          reviewObjectType: ReviewObjectType.wordReading,
          reviewActionType: ReviewActionType.listen,
          objectiveIds: <String>['recognize_recall_qalam'],
        ),
        V2MicroPracticeItem(
          itemId: 'recall_qalam_from_pen',
          type: V2MicroPracticeType.recallPrompt,
          prompt: 'You mean pen. Recall the Arabic word from memory.',
          meaning: 'pen',
          expectedAnswer: _qalam,
          itemRefId: 'word_meaning_recall_qalam',
          reviewObjectType: ReviewObjectType.wordReading,
          reviewActionType: ReviewActionType.read,
          objectiveIds: <String>['recognize_recall_qalam'],
        ),
        V2MicroPracticeItem(
          itemId: 'say_qalam_once',
          type: V2MicroPracticeType.speakResponse,
          prompt: 'See pen, say قلم once, then type it to lock it in.',
          arabicText: _qalam,
          transliteration: 'qalam',
          meaning: 'pen',
          expectedAnswer: _qalam,
          itemRefId: 'supported_rebuild_qalam',
          reviewObjectType: ReviewObjectType.wordReading,
          reviewActionType: ReviewActionType.repeat,
          objectiveIds: <String>['recognize_recall_qalam'],
        ),
      ],
      completionRule: V2MicroCompletionRule(
        requiredPracticeItemIds: <String>[
          'recognize_qalam_meaning',
          'choose_qalam_from_pack',
          'hear_qalam_and_tap',
          'recall_qalam_from_pen',
        ],
        requiredObjectiveIds: <String>['recognize_recall_qalam'],
        minimumPracticeCount: 4,
        passThreshold: 0.8,
      ),
      reviewSeedRules: <V2MicroReviewSeedRule>[
        V2MicroReviewSeedRule(
          ruleId: 'word_meaning_recall_qalam',
          seedKind: V2ReviewSeedKind.newVocabulary,
          reviewObjectType: ReviewObjectType.wordReading,
          reviewActionType: ReviewActionType.read,
          sourceItemRefId: 'word_meaning_recall_qalam',
          objectiveIds: <String>['recognize_recall_qalam'],
          dueAfter: Duration(hours: 18),
        ),
        V2MicroReviewSeedRule(
          ruleId: 'audio_to_word_qalam',
          seedKind: V2ReviewSeedKind.weakPoint,
          reviewObjectType: ReviewObjectType.wordReading,
          reviewActionType: ReviewActionType.listen,
          sourceItemRefId: 'audio_to_word_qalam',
          objectiveIds: <String>['recognize_recall_qalam'],
          dueAfter: Duration.zero,
          onlyIfWeak: true,
        ),
        V2MicroReviewSeedRule(
          ruleId: 'word_contrast_qalam_vs_kitab_bab',
          seedKind: V2ReviewSeedKind.confusionPair,
          reviewObjectType: ReviewObjectType.wordReading,
          reviewActionType: ReviewActionType.distinguish,
          sourceItemRefId: 'word_contrast_qalam_vs_kitab_bab',
          objectiveIds: <String>['recognize_recall_qalam'],
          dueAfter: Duration.zero,
          onlyIfWeak: true,
        ),
        V2MicroReviewSeedRule(
          ruleId: 'supported_rebuild_qalam',
          seedKind: V2ReviewSeedKind.weakPoint,
          reviewObjectType: ReviewObjectType.wordReading,
          reviewActionType: ReviewActionType.repeat,
          sourceItemRefId: 'supported_rebuild_qalam',
          objectiveIds: <String>['recognize_recall_qalam'],
          dueAfter: Duration.zero,
          onlyIfWeak: true,
        ),
      ],
      nextActionHints: <V2NextActionHint>[
        V2NextActionHint(
          actionType: V2RecommendedActionType.startLesson,
          label: 'Continue to your first short Arabic line',
          reason:
              'قلم is now stable enough to move into the first tiny هذا + noun line.',
        ),
      ],
    );

const V2MicroLesson lesson6HadhaFirstFixedExpressionPreviewLesson =
    V2MicroLesson(
      lessonId: 'lesson_06_hadha_first_fixed_expression',
      phaseId: 'phase_preview_stage_b_first_expression',
      groupId: 'stage_b_preview_first_expression',
      title: 'This Is... Your First Fixed Expression',
      outcomeSummary:
          'After this lesson, you can understand, build, and say هذا كتاب and هذا قلم.',
      estimatedMinutes: 6,
      lessonType: V2MicroLessonType.responseProduction,
      objectives: <V2MicroLessonObjective>[
        V2MicroLessonObjective(
          objectiveId: 'build_recall_hadha_plus_noun',
          summary:
              'Understand, build, and recall one fixed هذا + noun expression frame.',
        ),
      ],
      entryCondition: V2MicroLessonEntryCondition(
        requiredLessonIds: <String>[
          'lesson_05_qalam_first_real_word_extension',
        ],
      ),
      contentItems: <V2MicroContentItem>[
        V2MicroContentItem(
          itemId: 'goal_hadha_frame',
          kind: V2MicroContentKind.goal,
          title: 'Lesson Goal',
          body:
              'Turn known words into your first tiny Arabic line: هذا + noun.',
          objectiveIds: <String>['build_recall_hadha_plus_noun'],
        ),
        V2MicroContentItem(
          itemId: 'input_hadha_kitab',
          kind: V2MicroContentKind.input,
          title: 'First Short Line',
          body:
              'Start with one useful whole line. هذا كتاب should feel like one tiny readable chunk, not a grammar lecture.',
          arabicText: _hadhaKitab,
          transliteration: 'hadha kitab',
          meaning: 'this is a book',
          audioQueryText: _hadhaKitab,
          objectiveIds: <String>['build_recall_hadha_plus_noun'],
        ),
        V2MicroContentItem(
          itemId: 'input_hadha_qalam',
          kind: V2MicroContentKind.input,
          title: 'Reuse The New Word',
          body: 'Now reuse the same frame with your new word: هذا قلم.',
          arabicText: _hadhaQalam,
          transliteration: 'hadha qalam',
          meaning: 'this is a pen',
          audioQueryText: _hadhaQalam,
          objectiveIds: <String>['build_recall_hadha_plus_noun'],
        ),
        V2MicroContentItem(
          itemId: 'model_hadha_stays_stable',
          kind: V2MicroContentKind.modeling,
          title: 'One Stable Opening',
          body:
              'Keep the opening stable and let the noun change. That is the beginner win here.',
          arabicText: '$_hadhaKitab / $_hadhaQalam / $_hadhaBab',
          objectiveIds: <String>['build_recall_hadha_plus_noun'],
        ),
      ],
      practiceItems: <V2MicroPracticeItem>[
        V2MicroPracticeItem(
          itemId: 'recognize_hadha_kitab_meaning',
          type: V2MicroPracticeType.comprehensionCheck,
          prompt: 'What does هذا كتاب mean?',
          arabicText: 'this is a book',
          meaning: 'هذا كتاب = this is a book',
          choiceOptions: <String>[
            'this is a book',
            'this is a pen',
            'this is a door',
          ],
          itemRefId: 'fixed_frame_hadha_plus_noun',
          reviewObjectType: ReviewObjectType.sentencePattern,
          reviewActionType: ReviewActionType.read,
          objectiveIds: <String>['build_recall_hadha_plus_noun'],
        ),
        V2MicroPracticeItem(
          itemId: 'choose_hadha_qalam_from_meaning',
          type: V2MicroPracticeType.comprehensionCheck,
          prompt: 'Which line means this is a pen?',
          arabicText: _hadhaQalam,
          meaning: 'this is a pen',
          choiceOptions: <String>[_hadhaQalam, _hadhaKitab, _hadhaBab],
          itemRefId: 'noun_substitution_inside_hadha',
          reviewObjectType: ReviewObjectType.sentencePattern,
          reviewActionType: ReviewActionType.distinguish,
          objectiveIds: <String>['build_recall_hadha_plus_noun'],
        ),
        V2MicroPracticeItem(
          itemId: 'hear_hadha_kitab_line',
          type: V2MicroPracticeType.listenTap,
          prompt: 'Listen first, then tap هذا كتاب.',
          arabicText: _hadhaKitab,
          meaning: 'this is a book',
          choiceOptions: <String>[_hadhaKitab, _hadhaQalam, _hadhaBab],
          itemRefId: 'fixed_frame_hadha_plus_noun',
          reviewObjectType: ReviewObjectType.sentencePattern,
          reviewActionType: ReviewActionType.listen,
          objectiveIds: <String>['build_recall_hadha_plus_noun'],
        ),
        V2MicroPracticeItem(
          itemId: 'arrange_hadha_qalam',
          type: V2MicroPracticeType.arrangeResponse,
          prompt: 'Build the full line for this is a pen.',
          meaning: 'this is a pen',
          expectedAnswer: _hadhaQalam,
          itemRefId: 'expression_recall_hadha_qalam',
          reviewObjectType: ReviewObjectType.sentencePattern,
          reviewActionType: ReviewActionType.read,
          objectiveIds: <String>['build_recall_hadha_plus_noun'],
        ),
        V2MicroPracticeItem(
          itemId: 'recall_hadha_kitab_from_meaning',
          type: V2MicroPracticeType.recallPrompt,
          prompt: 'Now recall the full line for this is a book.',
          meaning: 'this is a book',
          expectedAnswer: _hadhaKitab,
          itemRefId: 'expression_recall_hadha_kitab',
          reviewObjectType: ReviewObjectType.sentencePattern,
          reviewActionType: ReviewActionType.read,
          objectiveIds: <String>['build_recall_hadha_plus_noun'],
        ),
        V2MicroPracticeItem(
          itemId: 'say_hadha_qalam_once',
          type: V2MicroPracticeType.speakResponse,
          prompt: 'See the line, say it once, then type it to finish strong.',
          arabicText: _hadhaQalam,
          transliteration: 'hadha qalam',
          meaning: 'this is a pen',
          expectedAnswer: _hadhaQalam,
          itemRefId: 'expression_recall_hadha_qalam',
          reviewObjectType: ReviewObjectType.sentencePattern,
          reviewActionType: ReviewActionType.repeat,
          objectiveIds: <String>['build_recall_hadha_plus_noun'],
        ),
      ],
      completionRule: V2MicroCompletionRule(
        requiredPracticeItemIds: <String>[
          'recognize_hadha_kitab_meaning',
          'choose_hadha_qalam_from_meaning',
          'hear_hadha_kitab_line',
          'arrange_hadha_qalam',
          'recall_hadha_kitab_from_meaning',
        ],
        requiredObjectiveIds: <String>['build_recall_hadha_plus_noun'],
        minimumPracticeCount: 5,
        passThreshold: 0.8,
      ),
      reviewSeedRules: <V2MicroReviewSeedRule>[
        V2MicroReviewSeedRule(
          ruleId: 'fixed_frame_hadha_plus_noun',
          seedKind: V2ReviewSeedKind.coreExpression,
          reviewObjectType: ReviewObjectType.sentencePattern,
          reviewActionType: ReviewActionType.read,
          sourceItemRefId: 'fixed_frame_hadha_plus_noun',
          objectiveIds: <String>['build_recall_hadha_plus_noun'],
          dueAfter: Duration(hours: 18),
        ),
        V2MicroReviewSeedRule(
          ruleId: 'expression_recall_hadha_kitab',
          seedKind: V2ReviewSeedKind.weakPoint,
          reviewObjectType: ReviewObjectType.sentencePattern,
          reviewActionType: ReviewActionType.read,
          sourceItemRefId: 'expression_recall_hadha_kitab',
          objectiveIds: <String>['build_recall_hadha_plus_noun'],
          dueAfter: Duration.zero,
          onlyIfWeak: true,
        ),
        V2MicroReviewSeedRule(
          ruleId: 'expression_recall_hadha_qalam',
          seedKind: V2ReviewSeedKind.weakPoint,
          reviewObjectType: ReviewObjectType.sentencePattern,
          reviewActionType: ReviewActionType.read,
          sourceItemRefId: 'expression_recall_hadha_qalam',
          objectiveIds: <String>['build_recall_hadha_plus_noun'],
          dueAfter: Duration.zero,
          onlyIfWeak: true,
        ),
        V2MicroReviewSeedRule(
          ruleId: 'noun_substitution_inside_hadha',
          seedKind: V2ReviewSeedKind.weakPoint,
          reviewObjectType: ReviewObjectType.sentencePattern,
          reviewActionType: ReviewActionType.distinguish,
          sourceItemRefId: 'noun_substitution_inside_hadha',
          objectiveIds: <String>['build_recall_hadha_plus_noun'],
          dueAfter: Duration.zero,
          onlyIfWeak: true,
        ),
      ],
      nextActionHints: <V2NextActionHint>[
        V2NextActionHint(
          actionType: V2RecommendedActionType.startLesson,
          label: 'Continue to hear what you already know',
          reason:
              'The first short line is stable enough to move into audio-first recognition.',
        ),
      ],
    );

const V2MicroLesson lesson7AudioFirstKnownContentRecognitionPreviewLesson =
    V2MicroLesson(
      lessonId: 'lesson_07_audio_first_known_content_recognition',
      phaseId: 'phase_preview_stage_b_audio_shift',
      groupId: 'stage_b_preview_audio_shift',
      title: 'Hear What You Already Know',
      outcomeSummary:
          'After this lesson, you can catch familiar Arabic from audio across one word and one tiny line.',
      estimatedMinutes: 6,
      lessonType: V2MicroLessonType.listeningRecognition,
      objectives: <V2MicroLessonObjective>[
        V2MicroLessonObjective(
          objectiveId: 'recognize_known_content_from_audio',
          summary:
              'Recognize already known beginner Arabic content directly from audio before relying on print.',
        ),
      ],
      entryCondition: V2MicroLessonEntryCondition(
        requiredLessonIds: <String>[
          'lesson_06_hadha_first_fixed_expression',
        ],
      ),
      contentItems: <V2MicroContentItem>[
        V2MicroContentItem(
          itemId: 'goal_audio_known_pack',
          kind: V2MicroContentKind.goal,
          title: 'Lesson Goal',
          body:
              'Listen for content you already know before your eyes do the work.',
          objectiveIds: <String>['recognize_known_content_from_audio'],
        ),
        V2MicroContentItem(
          itemId: 'input_audio_known_words',
          kind: V2MicroContentKind.input,
          title: 'Listen To The Known Pack',
          body:
              'Nothing new is being added here. كتاب, باب, قلم, and tiny هذا lines are just becoming more audible.',
          arabicText: '$_kitab / $_bab / $_qalam / $_hadhaKitab / $_hadhaQalam',
          meaning: 'known Stage B pack',
          audioQueryText: '$_kitab $_bab $_qalam $_hadhaKitab $_hadhaQalam',
          objectiveIds: <String>['recognize_known_content_from_audio'],
        ),
        V2MicroContentItem(
          itemId: 'model_word_vs_line_audio',
          kind: V2MicroContentKind.modeling,
          title: 'Word Or Tiny Line?',
          body:
              'Listen for whether you heard the word alone or the tiny line that wraps it.',
          arabicText: '$_qalam / $_hadhaQalam',
          objectiveIds: <String>['recognize_known_content_from_audio'],
        ),
        V2MicroContentItem(
          itemId: 'support_audio_first',
          kind: V2MicroContentKind.explanation,
          title: 'Listen First',
          body:
              'This is still a very small listening win. The goal is simply to hear what you already know more directly.',
          objectiveIds: <String>['recognize_known_content_from_audio'],
        ),
      ],
      practiceItems: <V2MicroPracticeItem>[
        V2MicroPracticeItem(
          itemId: 'hear_qalam_word_from_audio',
          type: V2MicroPracticeType.listenTap,
          prompt: 'Listen first, then tap قلم.',
          arabicText: _qalam,
          meaning: 'pen',
          choiceOptions: <String>[_qalam, _kitab, _bab],
          itemRefId: 'audio_word_pack_kitab_bab_qalam',
          reviewObjectType: ReviewObjectType.wordReading,
          reviewActionType: ReviewActionType.listen,
          objectiveIds: <String>['recognize_known_content_from_audio'],
        ),
        V2MicroPracticeItem(
          itemId: 'hear_hadha_kitab_line_from_audio',
          type: V2MicroPracticeType.listenTap,
          prompt: 'Listen first, then tap هذا كتاب.',
          arabicText: _hadhaKitab,
          meaning: 'this is a book',
          choiceOptions: <String>[_hadhaKitab, _hadhaQalam, _hadhaBab],
          itemRefId: 'audio_line_hadha_kitab',
          reviewObjectType: ReviewObjectType.sentencePattern,
          reviewActionType: ReviewActionType.listen,
          objectiveIds: <String>['recognize_known_content_from_audio'],
        ),
        V2MicroPracticeItem(
          itemId: 'hear_hadha_qalam_line_from_audio',
          type: V2MicroPracticeType.listenTap,
          prompt: 'Listen first, then tap هذا قلم.',
          arabicText: _hadhaQalam,
          meaning: 'this is a pen',
          choiceOptions: <String>[_hadhaKitab, _hadhaQalam, _qalam],
          itemRefId: 'audio_line_hadha_qalam',
          reviewObjectType: ReviewObjectType.sentencePattern,
          reviewActionType: ReviewActionType.listen,
          objectiveIds: <String>['recognize_known_content_from_audio'],
        ),
        V2MicroPracticeItem(
          itemId: 'contrast_qalam_word_vs_line',
          type: V2MicroPracticeType.listenTap,
          prompt: 'Listen carefully. Did you hear the word alone or the full line?',
          arabicText: _hadhaQalam,
          meaning: 'this is a pen',
          choiceOptions: <String>[_qalam, _hadhaQalam],
          itemRefId: 'audio_contrast_word_vs_line',
          reviewObjectType: ReviewObjectType.sentencePattern,
          reviewActionType: ReviewActionType.distinguish,
          objectiveIds: <String>['recognize_known_content_from_audio'],
        ),
        V2MicroPracticeItem(
          itemId: 'arrange_heard_hadha_qalam',
          type: V2MicroPracticeType.arrangeResponse,
          prompt: 'You just heard the line. Build it again.',
          meaning: 'this is a pen',
          expectedAnswer: _hadhaQalam,
          itemRefId: 'audio_to_arrange_support_known_line',
          reviewObjectType: ReviewObjectType.sentencePattern,
          reviewActionType: ReviewActionType.read,
          objectiveIds: <String>['recognize_known_content_from_audio'],
        ),
        V2MicroPracticeItem(
          itemId: 'say_heard_hadha_qalam_once',
          type: V2MicroPracticeType.speakResponse,
          prompt: 'Hear it, say it once, then type the same line.',
          arabicText: _hadhaQalam,
          transliteration: 'hadha qalam',
          meaning: 'this is a pen',
          expectedAnswer: _hadhaQalam,
          itemRefId: 'supported_echo_hadha_qalam',
          reviewObjectType: ReviewObjectType.sentencePattern,
          reviewActionType: ReviewActionType.repeat,
          objectiveIds: <String>['recognize_known_content_from_audio'],
        ),
      ],
      completionRule: V2MicroCompletionRule(
        requiredPracticeItemIds: <String>[
          'hear_qalam_word_from_audio',
          'hear_hadha_kitab_line_from_audio',
          'hear_hadha_qalam_line_from_audio',
          'contrast_qalam_word_vs_line',
          'arrange_heard_hadha_qalam',
        ],
        requiredObjectiveIds: <String>['recognize_known_content_from_audio'],
        minimumPracticeCount: 5,
        passThreshold: 0.8,
      ),
      reviewSeedRules: <V2MicroReviewSeedRule>[
        V2MicroReviewSeedRule(
          ruleId: 'audio_word_pack_kitab_bab_qalam',
          seedKind: V2ReviewSeedKind.weakPoint,
          reviewObjectType: ReviewObjectType.wordReading,
          reviewActionType: ReviewActionType.listen,
          sourceItemRefId: 'audio_word_pack_kitab_bab_qalam',
          objectiveIds: <String>['recognize_known_content_from_audio'],
          dueAfter: Duration.zero,
          onlyIfWeak: true,
        ),
        V2MicroReviewSeedRule(
          ruleId: 'audio_line_hadha_kitab',
          seedKind: V2ReviewSeedKind.weakPoint,
          reviewObjectType: ReviewObjectType.sentencePattern,
          reviewActionType: ReviewActionType.listen,
          sourceItemRefId: 'audio_line_hadha_kitab',
          objectiveIds: <String>['recognize_known_content_from_audio'],
          dueAfter: Duration.zero,
          onlyIfWeak: true,
        ),
        V2MicroReviewSeedRule(
          ruleId: 'audio_line_hadha_qalam',
          seedKind: V2ReviewSeedKind.weakPoint,
          reviewObjectType: ReviewObjectType.sentencePattern,
          reviewActionType: ReviewActionType.listen,
          sourceItemRefId: 'audio_line_hadha_qalam',
          objectiveIds: <String>['recognize_known_content_from_audio'],
          dueAfter: Duration.zero,
          onlyIfWeak: true,
        ),
        V2MicroReviewSeedRule(
          ruleId: 'audio_contrast_word_vs_line',
          seedKind: V2ReviewSeedKind.weakPoint,
          reviewObjectType: ReviewObjectType.sentencePattern,
          reviewActionType: ReviewActionType.distinguish,
          sourceItemRefId: 'audio_contrast_word_vs_line',
          objectiveIds: <String>['recognize_known_content_from_audio'],
          dueAfter: Duration.zero,
          onlyIfWeak: true,
        ),
        V2MicroReviewSeedRule(
          ruleId: 'audio_to_arrange_support_known_line',
          seedKind: V2ReviewSeedKind.weakPoint,
          reviewObjectType: ReviewObjectType.sentencePattern,
          reviewActionType: ReviewActionType.read,
          sourceItemRefId: 'audio_to_arrange_support_known_line',
          objectiveIds: <String>['recognize_known_content_from_audio'],
          dueAfter: Duration.zero,
          onlyIfWeak: true,
        ),
      ],
      nextActionHints: <V2NextActionHint>[
        V2NextActionHint(
          actionType: V2RecommendedActionType.startLesson,
          label: 'Continue to the first usable Arabic pack',
          reason:
              'The known content is now audible enough to consolidate into one small usable pack.',
        ),
      ],
    );

const V2MicroLesson lesson8FirstUsableArabicPackPreviewLesson = V2MicroLesson(
  lessonId: 'lesson_08_first_usable_arabic_pack',
  phaseId: 'phase_preview_stage_b_pack_milestone',
  groupId: 'stage_b_preview_pack_milestone',
  title: 'Your First Usable Arabic Pack',
  outcomeSummary:
      'After this lesson, you can handle كتاب, باب, قلم, هذا كتاب, and هذا قلم as one small usable Arabic pack.',
  estimatedMinutes: 6,
  lessonType: V2MicroLessonType.consolidation,
  objectives: <V2MicroLessonObjective>[
    V2MicroLessonObjective(
      objectiveId: 'use_first_stage_b_pack',
      summary:
          'Stabilize one tiny Arabic pack across reading, listening, recall, and short output.',
    ),
  ],
  entryCondition: V2MicroLessonEntryCondition(
    requiredLessonIds: <String>[
      'lesson_07_audio_first_known_content_recognition',
    ],
  ),
  contentItems: <V2MicroContentItem>[
    V2MicroContentItem(
      itemId: 'goal_stage_b_pack',
      kind: V2MicroContentKind.goal,
      title: 'Lesson Goal',
      body:
          'Finish Stage B by using one small Arabic pack across more than one channel.',
      objectiveIds: <String>['use_first_stage_b_pack'],
    ),
    V2MicroContentItem(
      itemId: 'input_stage_b_pack',
      kind: V2MicroContentKind.input,
      title: 'Your First Pack',
      body:
          'These items now belong together as one small Arabic pack you can read, hear, recall, and say.',
      arabicText: _stageBPackDisplay,
      meaning: 'book / door / pen / this is a book / this is a pen',
      audioQueryText: _stageBPackSequence,
      objectiveIds: <String>['use_first_stage_b_pack'],
    ),
    V2MicroContentItem(
      itemId: 'model_stage_b_pack_channels',
      kind: V2MicroContentKind.modeling,
      title: 'More Than Review',
      body:
          'This is not a bland recap. The point is that your early Arabic now works across reading, listening, recall, and one short output step.',
      objectiveIds: <String>['use_first_stage_b_pack'],
    ),
    V2MicroContentItem(
      itemId: 'contrast_stage_b_pack_levels',
      kind: V2MicroContentKind.contrast,
      title: 'Word Or Line?',
      body:
          'Keep noticing the difference between a word on its own and a tiny line that uses it.',
      arabicText: '$_qalam / $_hadhaQalam',
      objectiveIds: <String>['use_first_stage_b_pack'],
    ),
  ],
  practiceItems: <V2MicroPracticeItem>[
    V2MicroPracticeItem(
      itemId: 'recognize_pack_word_qalam',
      type: V2MicroPracticeType.comprehensionCheck,
      prompt: 'Which Arabic word in your pack means pen?',
      arabicText: _qalam,
      meaning: 'pen',
      choiceOptions: <String>[_qalam, _kitab, _bab],
      itemRefId: 'stage_b_pack_mixed_word_stability',
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.distinguish,
      objectiveIds: <String>['use_first_stage_b_pack'],
    ),
    V2MicroPracticeItem(
      itemId: 'hear_pack_line_hadha_qalam',
      type: V2MicroPracticeType.listenTap,
      prompt: 'Listen first, then tap هذا قلم.',
      arabicText: _hadhaQalam,
      meaning: 'this is a pen',
      choiceOptions: <String>[_hadhaQalam, _hadhaKitab, _qalam],
      itemRefId: 'stage_b_pack_audio_mix',
      reviewObjectType: ReviewObjectType.sentencePattern,
      reviewActionType: ReviewActionType.listen,
      objectiveIds: <String>['use_first_stage_b_pack'],
    ),
    V2MicroPracticeItem(
      itemId: 'contrast_pack_word_vs_line',
      type: V2MicroPracticeType.comprehensionCheck,
      prompt: 'Which item is the full line this is a pen?',
      arabicText: _hadhaQalam,
      meaning: 'this is a pen',
      choiceOptions: <String>[_qalam, _hadhaQalam, _hadhaKitab],
      itemRefId: 'stage_b_pack_word_vs_line_contrast',
      reviewObjectType: ReviewObjectType.sentencePattern,
      reviewActionType: ReviewActionType.distinguish,
      objectiveIds: <String>['use_first_stage_b_pack'],
    ),
    V2MicroPracticeItem(
      itemId: 'recall_pack_word_qalam',
      type: V2MicroPracticeType.recallPrompt,
      prompt: 'You mean pen. Recall the Arabic word from your pack.',
      meaning: 'pen',
      expectedAnswer: _qalam,
      itemRefId: 'stage_b_pack_mixed_word_stability',
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.read,
      objectiveIds: <String>['use_first_stage_b_pack'],
    ),
    V2MicroPracticeItem(
      itemId: 'arrange_pack_line_hadha_kitab',
      type: V2MicroPracticeType.arrangeResponse,
      prompt: 'Build the line for this is a book.',
      meaning: 'this is a book',
      expectedAnswer: _hadhaKitab,
      itemRefId: 'stage_b_pack_line_recall',
      reviewObjectType: ReviewObjectType.sentencePattern,
      reviewActionType: ReviewActionType.read,
      objectiveIds: <String>['use_first_stage_b_pack'],
    ),
    V2MicroPracticeItem(
      itemId: 'say_pack_line_hadha_qalam',
      type: V2MicroPracticeType.speakResponse,
      prompt: 'Finish Stage B by saying one full line, then type it.',
      arabicText: _hadhaQalam,
      transliteration: 'hadha qalam',
      meaning: 'this is a pen',
      expectedAnswer: _hadhaQalam,
      itemRefId: 'stage_b_pack_arrange_support',
      reviewObjectType: ReviewObjectType.sentencePattern,
      reviewActionType: ReviewActionType.repeat,
      objectiveIds: <String>['use_first_stage_b_pack'],
    ),
  ],
  completionRule: V2MicroCompletionRule(
    requiredPracticeItemIds: <String>[
      'recognize_pack_word_qalam',
      'hear_pack_line_hadha_qalam',
      'contrast_pack_word_vs_line',
      'recall_pack_word_qalam',
      'arrange_pack_line_hadha_kitab',
      'say_pack_line_hadha_qalam',
    ],
    requiredObjectiveIds: <String>['use_first_stage_b_pack'],
    minimumPracticeCount: 6,
    passThreshold: 0.8,
  ),
  reviewSeedRules: <V2MicroReviewSeedRule>[
    V2MicroReviewSeedRule(
      ruleId: 'stage_b_pack_line_recall',
      seedKind: V2ReviewSeedKind.weakPoint,
      reviewObjectType: ReviewObjectType.sentencePattern,
      reviewActionType: ReviewActionType.read,
      sourceItemRefId: 'stage_b_pack_line_recall',
      objectiveIds: <String>['use_first_stage_b_pack'],
      dueAfter: Duration.zero,
      onlyIfWeak: true,
    ),
    V2MicroReviewSeedRule(
      ruleId: 'stage_b_pack_audio_mix',
      seedKind: V2ReviewSeedKind.weakPoint,
      reviewObjectType: ReviewObjectType.sentencePattern,
      reviewActionType: ReviewActionType.listen,
      sourceItemRefId: 'stage_b_pack_audio_mix',
      objectiveIds: <String>['use_first_stage_b_pack'],
      dueAfter: Duration.zero,
      onlyIfWeak: true,
    ),
    V2MicroReviewSeedRule(
      ruleId: 'stage_b_pack_mixed_word_stability',
      seedKind: V2ReviewSeedKind.weakPoint,
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.read,
      sourceItemRefId: 'stage_b_pack_mixed_word_stability',
      objectiveIds: <String>['use_first_stage_b_pack'],
      dueAfter: Duration.zero,
      onlyIfWeak: true,
    ),
    V2MicroReviewSeedRule(
      ruleId: 'stage_b_pack_word_vs_line_contrast',
      seedKind: V2ReviewSeedKind.weakPoint,
      reviewObjectType: ReviewObjectType.sentencePattern,
      reviewActionType: ReviewActionType.distinguish,
      sourceItemRefId: 'stage_b_pack_word_vs_line_contrast',
      objectiveIds: <String>['use_first_stage_b_pack'],
      dueAfter: Duration.zero,
      onlyIfWeak: true,
    ),
    V2MicroReviewSeedRule(
      ruleId: 'stage_b_pack_arrange_support',
      seedKind: V2ReviewSeedKind.weakPoint,
      reviewObjectType: ReviewObjectType.sentencePattern,
      reviewActionType: ReviewActionType.repeat,
      sourceItemRefId: 'stage_b_pack_arrange_support',
      objectiveIds: <String>['use_first_stage_b_pack'],
      dueAfter: Duration.zero,
      onlyIfWeak: true,
    ),
  ],
  nextActionHints: <V2NextActionHint>[
    V2NextActionHint(
      actionType: V2RecommendedActionType.startNextPhase,
      label: 'Stage B complete',
      reason:
          'You now have a first usable Arabic pack and can move into Stage C pattern growth from real content.',
    ),
  ],
);

const List<V2MicroLesson> stageBPreviewLessons = <V2MicroLesson>[
  lesson5QalamFirstRealWordExtensionPreviewLesson,
  lesson6HadhaFirstFixedExpressionPreviewLesson,
  lesson7AudioFirstKnownContentRecognitionPreviewLesson,
  lesson8FirstUsableArabicPackPreviewLesson,
];
