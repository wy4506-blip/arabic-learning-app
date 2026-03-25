import '../models/review_models.dart';
import '../models/v2_micro_lesson.dart';

const String _ba = '\u0628';
const String _kitab = '\u0643\u062a\u0627\u0628';
const String _kitabSupported = '\u0643\u0650\u062a\u0627\u0628';
const String _bab = '\u0628\u0627\u0628';
const String _babSupported = '\u0628\u064e\u0627\u0628';
const String _bayt = '\u0628\u064a\u062a';
const String _qalam = '\u0642\u0644\u0645';
const String _salam = '\u0633\u0644\u0627\u0645';

class StageAPreviewDescriptor {
  final String lessonId;
  final int order;
  final String chapterRole;
  final String learnerVisibleOutcome;
  final String completionEvidence;
  final String chapterBridge;
  final String nextUnlock;

  const StageAPreviewDescriptor({
    required this.lessonId,
    required this.order,
    required this.chapterRole,
    required this.learnerVisibleOutcome,
    required this.completionEvidence,
    required this.chapterBridge,
    required this.nextUnlock,
  });
}

StageAPreviewDescriptor? stageAPreviewDescriptorForLessonId(String lessonId) {
  for (final descriptor in stageAPreviewDescriptors) {
    if (descriptor.lessonId == lessonId) {
      return descriptor;
    }
  }
  return null;
}

const List<StageAPreviewDescriptor> stageAPreviewDescriptors =
    <StageAPreviewDescriptor>[
      StageAPreviewDescriptor(
        lessonId: 'V2-A1-01-PREVIEW',
        order: 1,
        chapterRole: 'Arabic entry through one real word',
        learnerVisibleOutcome:
            'You can find where Arabic starts on \u0643\u062a\u0627\u0628 and keep one real meaning anchor attached: book.',
        completionEvidence:
            'Clean completion means you recover the reading direction on a real Arabic word and keep the book anchor attached once support is reduced.',
        chapterBridge:
            'This is still the chapter entry point, but the learner enters Arabic through a real word instead of abstract script only.',
        nextUnlock:
            'Unlocks the first real word success: \u0643\u062a\u0627\u0628 = book.',
      ),
      StageAPreviewDescriptor(
        lessonId: 'V2-A1-02-PREVIEW',
        order: 2,
        chapterRole: 'First real word success',
        learnerVisibleOutcome:
            'You can recognize and recall \u0643\u062a\u0627\u0628 as the Arabic word for book. This is your first owned Arabic word.',
        completionEvidence:
            'Clean completion means the learner can recognize \u0643\u062a\u0627\u0628 from sound and sight, then bring it back again from memory.',
        chapterBridge:
            'This lesson turns the entry word into the learner\u2019s first strong content win: one real Arabic word is now theirs.',
        nextUnlock:
            'You now own 1 real word. Next unlock: connection awareness through \u0628\u0627\u0628.',
      ),
      StageAPreviewDescriptor(
        lessonId: 'V2-A1-03-PREVIEW',
        order: 3,
        chapterRole: 'Connection awareness through a real word',
        learnerVisibleOutcome:
            'You can recognize and recall \u0628\u0627\u0628 as the Arabic word for door, giving you two real words in Stage A while noticing how the same \u0628 family changes shape inside the word.',
        completionEvidence:
            'Clean completion means the learner retrieves \u0628\u0627\u0628 as a whole word and shows awareness that the repeated \u0628 family changes position inside the word.',
        chapterBridge:
            'This lesson introduces connection and form awareness inside a meaningful word, so script behavior stays in service of content learning.',
        nextUnlock:
            'You now own 2 real words. Next unlock: supported reading and a tiny usage glimpse.',
      ),
      StageAPreviewDescriptor(
        lessonId: 'V2-A1-04-PREVIEW',
        order: 4,
        chapterRole: 'Supported reading of known words',
        learnerVisibleOutcome:
            'You can read \u0643\u0650\u062a\u0627\u0628 and \u0628\u064e\u0627\u0628 with beginner support and start catching them inside tiny Arabic snippets.',
        completionEvidence:
            'Clean completion means the learner distinguishes two supported real words and recalls at least one supported form after the side-by-side support is removed.',
        chapterBridge:
            'This closes Stage A by making Arabic feel readable through real content, not just through script concepts.',
        nextUnlock:
            'Stage A now ends with 2 real words, supported reading, and a tiny usage glimpse before this preview stops.',
      ),
    ];

const V2MicroLesson stageAOrientationPreviewLesson = V2MicroLesson(
  lessonId: 'V2-A1-01-PREVIEW',
  phaseId: 'phase_a_script_entry_preview',
  groupId: 'stage_a_preview_orientation',
  title: 'Arabic Starts Here',
  outcomeSummary:
      'You can find where Arabic starts on \u0643\u062a\u0627\u0628 and keep one real meaning anchor attached: book.',
  estimatedMinutes: 5,
  lessonType: V2MicroLessonType.identityIntroduction,
  objectives: <V2MicroLessonObjective>[
    V2MicroLessonObjective(
      objectiveId: 'orient_to_real_word_anchor',
      summary:
          'Enter Arabic through one supported real word by following it from right to left and linking it to one meaning anchor.',
    ),
  ],
  entryCondition: V2MicroLessonEntryCondition(),
  contentItems: <V2MicroContentItem>[
    V2MicroContentItem(
      itemId: 'goal_entry_word',
      kind: V2MicroContentKind.goal,
      title: 'Lesson Goal',
      body:
          'Enter Arabic through one real word. You only need to notice where Arabic starts and keep one meaning anchor attached.',
      objectiveIds: <String>['orient_to_real_word_anchor'],
    ),
    V2MicroContentItem(
      itemId: 'input_kitab_anchor',
      kind: V2MicroContentKind.input,
      title: 'First Arabic Anchor',
      body:
          'Use one real Arabic word to enter the script. You do not need every letter yet. Just follow the whole word from the right and connect it to book.',
      arabicText: _kitab,
      transliteration: 'kitab',
      meaning: 'book',
      audioQueryText: _kitab,
      objectiveIds: <String>['orient_to_real_word_anchor'],
    ),
    V2MicroContentItem(
      itemId: 'support_rule_real_word',
      kind: V2MicroContentKind.explanation,
      title: 'Beginner Support Is Allowed',
      body:
          'You do not need to decode every letter yet. The whole word, audio, and meaning cue are all allowed supports for your first Arabic step.',
      objectiveIds: <String>['orient_to_real_word_anchor'],
    ),
    V2MicroContentItem(
      itemId: 'entry_word_contrast',
      kind: V2MicroContentKind.contrast,
      title: 'Watch The Entry Move',
      body:
          'For this first step, keep two things together: start on the right, and let the whole word already mean book.',
      arabicText: _kitab,
      objectiveIds: <String>['orient_to_real_word_anchor'],
    ),
  ],
  practiceItems: <V2MicroPracticeItem>[
    V2MicroPracticeItem(
      itemId: 'hear_kitab_anchor',
      type: V2MicroPracticeType.listenTap,
      prompt: 'Hear the word, then tap \u0643\u062a\u0627\u0628.',
      arabicText: _kitab,
      choiceOptions: <String>[_kitab, _bab, _salam],
      itemRefId: 'word_kitab_anchor',
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.listen,
      objectiveIds: <String>['orient_to_real_word_anchor'],
    ),
    V2MicroPracticeItem(
      itemId: 'recognize_start_side_kitab',
      type: V2MicroPracticeType.comprehensionCheck,
      prompt: 'On \u0643\u062a\u0627\u0628, where does reading begin?',
      arabicText: 'right edge',
      choiceOptions: <String>['right edge', 'left edge', 'center'],
      itemRefId: 'word_kitab_direction',
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.read,
      objectiveIds: <String>['orient_to_real_word_anchor'],
    ),
    V2MicroPracticeItem(
      itemId: 'recognize_kitab_meaning',
      type: V2MicroPracticeType.comprehensionCheck,
      prompt: 'In this chapter entry, \u0643\u062a\u0627\u0628 means...',
      arabicText: 'book',
      choiceOptions: <String>['book', 'door', 'pen'],
      itemRefId: 'word_kitab_anchor',
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.read,
      objectiveIds: <String>['orient_to_real_word_anchor'],
    ),
    V2MicroPracticeItem(
      itemId: 'recall_start_side_kitab',
      type: V2MicroPracticeType.recallPrompt,
      prompt: 'Without the guide, type the side where reading begins on \u0643\u062a\u0627\u0628.',
      arabicText: _kitab,
      expectedAnswer: 'right edge',
      itemRefId: 'word_kitab_direction',
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.read,
      objectiveIds: <String>['orient_to_real_word_anchor'],
    ),
    V2MicroPracticeItem(
      itemId: 'recall_kitab_meaning',
      type: V2MicroPracticeType.recallPrompt,
      prompt: 'The English hint is gone. Type the meaning anchor for \u0643\u062a\u0627\u0628.',
      arabicText: _kitab,
      expectedAnswer: 'book',
      itemRefId: 'word_kitab_anchor',
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.read,
      objectiveIds: <String>['orient_to_real_word_anchor'],
    ),
    V2MicroPracticeItem(
      itemId: 'build_kitab_pair',
      type: V2MicroPracticeType.arrangeResponse,
      prompt: 'Build the pair you will carry into the next lesson.',
      expectedAnswer: '\u0643\u062a\u0627\u0628 book',
      itemRefId: 'word_kitab_pair',
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.read,
      objectiveIds: <String>['orient_to_real_word_anchor'],
    ),
  ],
  completionRule: V2MicroCompletionRule(
    requiredPracticeItemIds: <String>[
      'hear_kitab_anchor',
      'recognize_start_side_kitab',
      'recognize_kitab_meaning',
      'recall_start_side_kitab',
      'recall_kitab_meaning',
    ],
    requiredObjectiveIds: <String>['orient_to_real_word_anchor'],
    minimumPracticeCount: 5,
    passThreshold: 0.8,
  ),
  reviewSeedRules: <V2MicroReviewSeedRule>[
    V2MicroReviewSeedRule(
      ruleId: 'rv_kitab_entry_direction_weak',
      seedKind: V2ReviewSeedKind.weakPoint,
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.read,
      sourceItemRefId: 'word_kitab_direction',
      objectiveIds: <String>['orient_to_real_word_anchor'],
      dueAfter: Duration.zero,
      onlyIfWeak: true,
    ),
    V2MicroReviewSeedRule(
      ruleId: 'rv_kitab_entry_anchor_weak',
      seedKind: V2ReviewSeedKind.weakPoint,
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.read,
      sourceItemRefId: 'word_kitab_anchor',
      objectiveIds: <String>['orient_to_real_word_anchor'],
      dueAfter: Duration.zero,
      onlyIfWeak: true,
    ),
    V2MicroReviewSeedRule(
      ruleId: 'rv_kitab_entry_stable',
      seedKind: V2ReviewSeedKind.newVocabulary,
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.read,
      sourceItemRefId: 'word_kitab_anchor',
      objectiveIds: <String>['orient_to_real_word_anchor'],
      dueAfter: Duration(hours: 18),
    ),
  ],
  nextActionHints: <V2NextActionHint>[
    V2NextActionHint(
      actionType: V2RecommendedActionType.startLesson,
      label: 'Continue to the first real word success lesson',
      reason:
          'The learner has entered Arabic through one real word and can now learn that word properly: \u0643\u062a\u0627\u0628 = book.',
    ),
  ],
);

const V2MicroLesson stageAFirstScriptSuccessPreviewLesson = V2MicroLesson(
  lessonId: 'V2-A1-02-PREVIEW',
  phaseId: 'phase_a_script_entry_preview',
  groupId: 'stage_a_preview_first_script_success',
  title: 'First Real Word Success',
  outcomeSummary:
      'You can recognize and recall \u0643\u062a\u0627\u0628 as the Arabic word for book. This is your first owned Arabic word.',
  estimatedMinutes: 7,
  lessonType: V2MicroLessonType.identityIntroduction,
  objectives: <V2MicroLessonObjective>[
    V2MicroLessonObjective(
      objectiveId: 'recognize_recall_kitab_word',
      summary:
          'Recognize and recall \u0643\u062a\u0627\u0628 as the Arabic word for book.',
    ),
  ],
  entryCondition: V2MicroLessonEntryCondition(
    requiredLessonIds: <String>['V2-A1-01-PREVIEW'],
  ),
  contentItems: <V2MicroContentItem>[
    V2MicroContentItem(
      itemId: 'goal_kitab_word',
      kind: V2MicroContentKind.goal,
      title: 'Lesson Goal',
      body:
          'Learn one real Arabic word well enough to hear it, spot it, and bring it back from memory.',
      objectiveIds: <String>['recognize_recall_kitab_word'],
    ),
    V2MicroContentItem(
      itemId: 'input_kitab_word',
      kind: V2MicroContentKind.input,
      title: 'Whole Word First',
      body:
          'Meet \u0643\u062a\u0627\u0628 as one meaningful Arabic word. Let the whole shape, sound, and meaning stay together.',
      arabicText: _kitab,
      transliteration: 'kitab',
      meaning: 'book',
      audioQueryText: _kitab,
      objectiveIds: <String>['recognize_recall_kitab_word'],
    ),
    V2MicroContentItem(
      itemId: 'support_note_whole_word',
      kind: V2MicroContentKind.explanation,
      title: 'Whole Word Support',
      body:
          'You do not need to study every letter in isolation first. For this lesson, the whole word is the learning unit.',
      objectiveIds: <String>['recognize_recall_kitab_word'],
    ),
    V2MicroContentItem(
      itemId: 'contrast_real_words',
      kind: V2MicroContentKind.contrast,
      title: 'See The Whole Shape',
      body:
          'Use contrast at the whole-word level. You are learning \u0643\u062a\u0627\u0628 as book, not memorizing isolated letters.',
      arabicText: '\u0643\u062a\u0627\u0628 / \u0628\u0627\u0628 / \u0642\u0644\u0645',
      objectiveIds: <String>['recognize_recall_kitab_word'],
    ),
  ],
  practiceItems: <V2MicroPracticeItem>[
    V2MicroPracticeItem(
      itemId: 'hear_kitab_pick_word',
      type: V2MicroPracticeType.listenTap,
      prompt: 'Hear the word, then tap \u0643\u062a\u0627\u0628.',
      arabicText: _kitab,
      choiceOptions: <String>[_kitab, _bab, _qalam],
      itemRefId: 'word_kitab',
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.listen,
      objectiveIds: <String>['recognize_recall_kitab_word'],
    ),
    V2MicroPracticeItem(
      itemId: 'see_kitab_pick_meaning',
      type: V2MicroPracticeType.comprehensionCheck,
      prompt: 'What does \u0643\u062a\u0627\u0628 mean?',
      arabicText: 'book',
      choiceOptions: <String>['book', 'door', 'pen'],
      itemRefId: 'word_kitab',
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.read,
      objectiveIds: <String>['recognize_recall_kitab_word'],
    ),
    V2MicroPracticeItem(
      itemId: 'recognize_kitab_shape',
      type: V2MicroPracticeType.comprehensionCheck,
      prompt: 'Which whole-word shape is \u0643\u062a\u0627\u0628?',
      arabicText: _kitab,
      choiceOptions: <String>[_kitab, _bab, _qalam],
      itemRefId: 'word_kitab',
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.read,
      objectiveIds: <String>['recognize_recall_kitab_word'],
    ),
    V2MicroPracticeItem(
      itemId: 'recall_kitab_from_meaning',
      type: V2MicroPracticeType.recallPrompt,
      prompt: 'The English prompt is all you get now. Type the Arabic word for book.',
      expectedAnswer: _kitab,
      itemRefId: 'word_kitab',
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.read,
      objectiveIds: <String>['recognize_recall_kitab_word'],
    ),
    V2MicroPracticeItem(
      itemId: 'recall_meaning_of_kitab',
      type: V2MicroPracticeType.recallPrompt,
      prompt: 'Look at \u0643\u062a\u0627\u0628. Type its meaning.',
      arabicText: _kitab,
      expectedAnswer: 'book',
      itemRefId: 'word_kitab',
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.repeat,
      objectiveIds: <String>['recognize_recall_kitab_word'],
    ),
    V2MicroPracticeItem(
      itemId: 'say_kitab_once',
      type: V2MicroPracticeType.speakResponse,
      prompt: 'See \u0643\u062a\u0627\u0628, then say kitab once.',
      arabicText: _kitab,
      expectedAnswer: 'kitab',
      itemRefId: 'word_kitab',
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.repeat,
      objectiveIds: <String>['recognize_recall_kitab_word'],
    ),
  ],
  completionRule: V2MicroCompletionRule(
    requiredPracticeItemIds: <String>[
      'hear_kitab_pick_word',
      'see_kitab_pick_meaning',
      'recognize_kitab_shape',
      'recall_kitab_from_meaning',
    ],
    requiredObjectiveIds: <String>['recognize_recall_kitab_word'],
    minimumPracticeCount: 4,
    passThreshold: 0.8,
  ),
  reviewSeedRules: <V2MicroReviewSeedRule>[
    V2MicroReviewSeedRule(
      ruleId: 'rv_kitab_weak_listen',
      seedKind: V2ReviewSeedKind.weakPoint,
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.listen,
      sourceItemRefId: 'word_kitab',
      objectiveIds: <String>['recognize_recall_kitab_word'],
      dueAfter: Duration.zero,
      onlyIfWeak: true,
    ),
    V2MicroReviewSeedRule(
      ruleId: 'rv_kitab_weak_read',
      seedKind: V2ReviewSeedKind.weakPoint,
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.read,
      sourceItemRefId: 'word_kitab',
      objectiveIds: <String>['recognize_recall_kitab_word'],
      dueAfter: Duration.zero,
      onlyIfWeak: true,
    ),
    V2MicroReviewSeedRule(
      ruleId: 'rv_kitab_stable',
      seedKind: V2ReviewSeedKind.newVocabulary,
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.read,
      sourceItemRefId: 'word_kitab',
      objectiveIds: <String>['recognize_recall_kitab_word'],
      dueAfter: Duration(hours: 18),
    ),
  ],
  nextActionHints: <V2NextActionHint>[
    V2NextActionHint(
      actionType: V2RecommendedActionType.startLesson,
      label: 'Continue to connection awareness through a real word',
      reason:
          'The learner now owns one real Arabic word and can meet a second word that reveals connection and form changes inside meaningful content.',
    ),
  ],
);

const V2MicroLesson stageASameLetterNewShapePreviewLesson = V2MicroLesson(
  lessonId: 'V2-A1-03-PREVIEW',
  phaseId: 'phase_a_script_entry_preview',
  groupId: 'stage_a_preview_same_letter_new_shape',
  title: 'One Word, Connected Shape',
  outcomeSummary:
      'You can recognize and recall \u0628\u0627\u0628 as the Arabic word for door, giving you two real words in Stage A while noticing how the same \u0628 family changes shape inside the word.',
  estimatedMinutes: 6,
  lessonType: V2MicroLessonType.identityIntroduction,
  objectives: <V2MicroLessonObjective>[
    V2MicroLessonObjective(
      objectiveId: 'recognize_recall_bab_connected_word',
      summary:
          'Recognize and recall \u0628\u0627\u0628 as a real connected word while noticing how the repeated \u0628 family changes position inside it.',
    ),
  ],
  entryCondition: V2MicroLessonEntryCondition(
    requiredLessonIds: <String>['V2-A1-02-PREVIEW'],
  ),
  contentItems: <V2MicroContentItem>[
    V2MicroContentItem(
      itemId: 'goal_bab_word',
      kind: V2MicroContentKind.goal,
      title: 'Lesson Goal',
      body:
          'Learn one new real word and notice how Arabic connection works inside it without turning the lesson into isolated letter drill.',
      objectiveIds: <String>['recognize_recall_bab_connected_word'],
    ),
    V2MicroContentItem(
      itemId: 'input_bab_word',
      kind: V2MicroContentKind.input,
      title: 'Whole Word First',
      body:
          'Meet \u0628\u0627\u0628 as a whole word meaning door. Learn the word first, then let the script behavior become visible inside it.',
      arabicText: _bab,
      transliteration: 'baab',
      meaning: 'door',
      audioQueryText: _bab,
      objectiveIds: <String>['recognize_recall_bab_connected_word'],
    ),
    V2MicroContentItem(
      itemId: 'connection_note_inside_word',
      kind: V2MicroContentKind.explanation,
      title: 'Connection Inside One Word',
      body:
          'In \u0628\u0627\u0628, the same \u0628 family appears at the beginning and end of a real word. The shape changes with position, but the word still stays one meaningful item.',
      arabicText: _bab,
      objectiveIds: <String>['recognize_recall_bab_connected_word'],
    ),
    V2MicroContentItem(
      itemId: 'contrast_known_words',
      kind: V2MicroContentKind.contrast,
      title: 'Compare Whole Words',
      body:
          'Use whole-word contrast here. The learner should see \u0628\u0627\u0628 as door, not as a pile of isolated letters.',
      arabicText: '\u0628\u0627\u0628 / \u0643\u062a\u0627\u0628 / \u0628\u064a\u062a',
      objectiveIds: <String>['recognize_recall_bab_connected_word'],
    ),
  ],
  practiceItems: <V2MicroPracticeItem>[
    V2MicroPracticeItem(
      itemId: 'hear_bab_pick_word',
      type: V2MicroPracticeType.listenTap,
      prompt: 'Hear the word, then tap \u0628\u0627\u0628.',
      arabicText: _bab,
      choiceOptions: <String>[_bab, _kitab, _bayt],
      itemRefId: 'word_bab',
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.listen,
      objectiveIds: <String>['recognize_recall_bab_connected_word'],
    ),
    V2MicroPracticeItem(
      itemId: 'see_bab_pick_meaning',
      type: V2MicroPracticeType.comprehensionCheck,
      prompt: 'What does \u0628\u0627\u0628 mean?',
      arabicText: 'door',
      choiceOptions: <String>['door', 'book', 'house'],
      itemRefId: 'word_bab',
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.read,
      objectiveIds: <String>['recognize_recall_bab_connected_word'],
    ),
    V2MicroPracticeItem(
      itemId: 'recognize_b_family_inside_bab',
      type: V2MicroPracticeType.comprehensionCheck,
      prompt: 'Inside \u0628\u0627\u0628, which family shows up at both ends?',
      arabicText: '\u0628 family',
      choiceOptions: <String>['\u0628 family', '\u062a family', '\u0643 family'],
      itemRefId: 'word_bab_connection',
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.read,
      objectiveIds: <String>['recognize_recall_bab_connected_word'],
    ),
    V2MicroPracticeItem(
      itemId: 'recall_bab_from_meaning',
      type: V2MicroPracticeType.recallPrompt,
      prompt: 'The meaning prompt is all you get now. Type the Arabic word for door.',
      expectedAnswer: _bab,
      itemRefId: 'word_bab',
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.read,
      objectiveIds: <String>['recognize_recall_bab_connected_word'],
    ),
    V2MicroPracticeItem(
      itemId: 'recall_repeated_family_in_bab',
      type: V2MicroPracticeType.recallPrompt,
      prompt: 'Look at \u0628\u0627\u0628. Type the family that repeats at the beginning and end.',
      arabicText: _bab,
      expectedAnswer: _ba,
      itemRefId: 'word_bab_connection',
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.read,
      objectiveIds: <String>['recognize_recall_bab_connected_word'],
    ),
    V2MicroPracticeItem(
      itemId: 'build_bab_from_connection',
      type: V2MicroPracticeType.arrangeResponse,
      prompt: 'Build the connected word path for \u0628\u0627\u0628 from beginning to end.',
      expectedAnswer: '\u0628\u0640 \u0627 \u0640\u0628',
      itemRefId: 'word_bab_connection',
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.read,
      objectiveIds: <String>['recognize_recall_bab_connected_word'],
    ),
  ],
  completionRule: V2MicroCompletionRule(
    requiredPracticeItemIds: <String>[
      'hear_bab_pick_word',
      'see_bab_pick_meaning',
      'recognize_b_family_inside_bab',
      'recall_bab_from_meaning',
      'build_bab_from_connection',
    ],
    requiredObjectiveIds: <String>['recognize_recall_bab_connected_word'],
    minimumPracticeCount: 5,
    passThreshold: 0.8,
  ),
  reviewSeedRules: <V2MicroReviewSeedRule>[
    V2MicroReviewSeedRule(
      ruleId: 'rv_bab_word_weak',
      seedKind: V2ReviewSeedKind.weakPoint,
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.listen,
      sourceItemRefId: 'word_bab',
      objectiveIds: <String>['recognize_recall_bab_connected_word'],
      dueAfter: Duration.zero,
      onlyIfWeak: true,
    ),
    V2MicroReviewSeedRule(
      ruleId: 'rv_bab_connection_weak',
      seedKind: V2ReviewSeedKind.weakPoint,
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.read,
      sourceItemRefId: 'word_bab_connection',
      objectiveIds: <String>['recognize_recall_bab_connected_word'],
      dueAfter: Duration.zero,
      onlyIfWeak: true,
    ),
    V2MicroReviewSeedRule(
      ruleId: 'rv_bab_stable',
      seedKind: V2ReviewSeedKind.newVocabulary,
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.read,
      sourceItemRefId: 'word_bab',
      objectiveIds: <String>['recognize_recall_bab_connected_word'],
      dueAfter: Duration(hours: 18),
    ),
  ],
  nextActionHints: <V2NextActionHint>[
    V2NextActionHint(
      actionType: V2RecommendedActionType.startLesson,
      label: 'Continue to supported reading for known words',
      reason:
          'The learner now owns two real words and can use beginner reading support to read them more confidently.',
    ),
  ],
);

const V2MicroLesson stageAShortVowelPreviewLesson = V2MicroLesson(
  lessonId: 'V2-A1-04-PREVIEW',
  phaseId: 'phase_a_script_entry_preview',
  groupId: 'stage_a_preview_short_vowels',
  title: 'Reading Support For Real Words',
  outcomeSummary:
      'You can read \u0643\u0650\u062a\u0627\u0628 and \u0628\u064e\u0627\u0628 with beginner support and start catching them inside tiny Arabic snippets.',
  estimatedMinutes: 7,
  lessonType: V2MicroLessonType.phonicsBridge,
  objectives: <V2MicroLessonObjective>[
    V2MicroLessonObjective(
      objectiveId: 'distinguish_read_supported_real_words',
      summary:
          'Distinguish and read \u0643\u0650\u062a\u0627\u0628 and \u0628\u064e\u0627\u0628 with beginner support.',
    ),
  ],
  entryCondition: V2MicroLessonEntryCondition(
    requiredLessonIds: <String>['V2-A1-03-PREVIEW'],
  ),
  contentItems: <V2MicroContentItem>[
    V2MicroContentItem(
      itemId: 'goal_supported_real_words',
      kind: V2MicroContentKind.goal,
      title: 'Lesson Goal',
      body:
          'Use beginner reading support to read real words you now know, not abstract symbol drills.',
      objectiveIds: <String>['distinguish_read_supported_real_words'],
    ),
    V2MicroContentItem(
      itemId: 'input_kitab_supported',
      kind: V2MicroContentKind.input,
      title: 'Supported Book',
      body:
          '\u0643\u0650\u062a\u0627\u0628 keeps the real word book in view while the support mark helps you hear its opening more clearly.',
      arabicText: _kitabSupported,
      transliteration: 'kitab',
      meaning: 'book',
      audioQueryText: _kitabSupported,
      objectiveIds: <String>['distinguish_read_supported_real_words'],
    ),
    V2MicroContentItem(
      itemId: 'input_bab_supported',
      kind: V2MicroContentKind.input,
      title: 'Supported Door',
      body:
          '\u0628\u064e\u0627\u0628 keeps the real word door in view while the support mark helps you hear its opening more clearly.',
      arabicText: _babSupported,
      transliteration: 'baab',
      meaning: 'door',
      audioQueryText: _babSupported,
      objectiveIds: <String>['distinguish_read_supported_real_words'],
    ),
    V2MicroContentItem(
      itemId: 'support_mark_note_real_words',
      kind: V2MicroContentKind.explanation,
      title: 'What These Marks Do',
      body:
          'These support marks are here to make whole words easier to read. In Stage A, they serve the words, not the other way around.',
      objectiveIds: <String>['distinguish_read_supported_real_words'],
    ),
    V2MicroContentItem(
      itemId: 'contrast_supported_known_words',
      kind: V2MicroContentKind.contrast,
      title: 'Compare The Known Words',
      body:
          'See the supported forms side by side once before you practice reading them.',
      arabicText: '\u0643\u0650\u062a\u0627\u0628 / \u0628\u064e\u0627\u0628',
      objectiveIds: <String>['distinguish_read_supported_real_words'],
    ),
    V2MicroContentItem(
      itemId: 'tiny_usage_glimpse',
      kind: V2MicroContentKind.modeling,
      title: 'Tiny Arabic Glimpse',
      body:
          'You are not learning a full new sentence here. Just notice that known words can already appear inside tiny Arabic snippets.',
      arabicText:
          '\u0647\u0630\u0627 \u0643\u0650\u062a\u0627\u0628 / \u0647\u0630\u0627 \u0628\u064e\u0627\u0628',
      transliteration: 'hadha kitab / hadha baab',
      meaning: 'this is a book / this is a door',
      audioQueryText: '\u0647\u0630\u0627 \u0643\u0650\u062a\u0627\u0628',
      objectiveIds: <String>['distinguish_read_supported_real_words'],
    ),
  ],
  practiceItems: <V2MicroPracticeItem>[
    V2MicroPracticeItem(
      itemId: 'hear_kitab_supported',
      type: V2MicroPracticeType.listenTap,
      prompt: 'Hear the word, then tap \u0643\u0650\u062a\u0627\u0628.',
      arabicText: _kitabSupported,
      choiceOptions: <String>[_kitabSupported, _babSupported, _qalam],
      itemRefId: 'word_kitab_supported',
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.listen,
      objectiveIds: <String>['distinguish_read_supported_real_words'],
    ),
    V2MicroPracticeItem(
      itemId: 'hear_bab_supported',
      type: V2MicroPracticeType.listenTap,
      prompt: 'Hear the word, then tap \u0628\u064e\u0627\u0628.',
      arabicText: _babSupported,
      choiceOptions: <String>[_kitabSupported, _babSupported, _qalam],
      itemRefId: 'word_bab_supported',
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.listen,
      objectiveIds: <String>['distinguish_read_supported_real_words'],
    ),
    V2MicroPracticeItem(
      itemId: 'see_kitab_supported_meaning',
      type: V2MicroPracticeType.comprehensionCheck,
      prompt: 'What does \u0643\u0650\u062a\u0627\u0628 mean?',
      arabicText: 'book',
      choiceOptions: <String>['book', 'door', 'pen'],
      itemRefId: 'word_kitab_supported',
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.read,
      objectiveIds: <String>['distinguish_read_supported_real_words'],
    ),
    V2MicroPracticeItem(
      itemId: 'see_bab_supported_meaning',
      type: V2MicroPracticeType.comprehensionCheck,
      prompt: 'What does \u0628\u064e\u0627\u0628 mean?',
      arabicText: 'door',
      choiceOptions: <String>['book', 'door', 'house'],
      itemRefId: 'word_bab_supported',
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.read,
      objectiveIds: <String>['distinguish_read_supported_real_words'],
    ),
    V2MicroPracticeItem(
      itemId: 'recall_supported_kitab',
      type: V2MicroPracticeType.recallPrompt,
      prompt: 'The side-by-side support is gone. Type the supported Arabic word for book.',
      expectedAnswer: _kitabSupported,
      itemRefId: 'word_kitab_supported',
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.read,
      objectiveIds: <String>['distinguish_read_supported_real_words'],
    ),
    V2MicroPracticeItem(
      itemId: 'recall_supported_bab_meaning',
      type: V2MicroPracticeType.recallPrompt,
      prompt: 'Look at \u0628\u064e\u0627\u0628. Type its meaning.',
      arabicText: _babSupported,
      expectedAnswer: 'door',
      itemRefId: 'word_bab_supported',
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.repeat,
      objectiveIds: <String>['distinguish_read_supported_real_words'],
    ),
    V2MicroPracticeItem(
      itemId: 'read_supported_kitab_once',
      type: V2MicroPracticeType.speakResponse,
      prompt: 'See \u0643\u0650\u062a\u0627\u0628, then read it aloud once.',
      arabicText: _kitabSupported,
      expectedAnswer: 'kitab',
      itemRefId: 'word_kitab_supported',
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.repeat,
      objectiveIds: <String>['distinguish_read_supported_real_words'],
    ),
  ],
  completionRule: V2MicroCompletionRule(
    requiredPracticeItemIds: <String>[
      'hear_kitab_supported',
      'hear_bab_supported',
      'see_kitab_supported_meaning',
      'see_bab_supported_meaning',
      'recall_supported_kitab',
    ],
    requiredObjectiveIds: <String>['distinguish_read_supported_real_words'],
    minimumPracticeCount: 5,
    passThreshold: 0.8,
  ),
  reviewSeedRules: <V2MicroReviewSeedRule>[
    V2MicroReviewSeedRule(
      ruleId: 'rv_kitab_supported_weak',
      seedKind: V2ReviewSeedKind.weakPoint,
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.listen,
      sourceItemRefId: 'word_kitab_supported',
      objectiveIds: <String>['distinguish_read_supported_real_words'],
      dueAfter: Duration.zero,
      onlyIfWeak: true,
    ),
    V2MicroReviewSeedRule(
      ruleId: 'rv_bab_supported_weak',
      seedKind: V2ReviewSeedKind.weakPoint,
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.listen,
      sourceItemRefId: 'word_bab_supported',
      objectiveIds: <String>['distinguish_read_supported_real_words'],
      dueAfter: Duration.zero,
      onlyIfWeak: true,
    ),
    V2MicroReviewSeedRule(
      ruleId: 'rv_supported_real_words_stable_book',
      seedKind: V2ReviewSeedKind.newVocabulary,
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.read,
      sourceItemRefId: 'word_kitab_supported',
      objectiveIds: <String>['distinguish_read_supported_real_words'],
      dueAfter: Duration(hours: 18),
    ),
    V2MicroReviewSeedRule(
      ruleId: 'rv_supported_real_words_stable_door',
      seedKind: V2ReviewSeedKind.newVocabulary,
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.read,
      sourceItemRefId: 'word_bab_supported',
      objectiveIds: <String>['distinguish_read_supported_real_words'],
      dueAfter: Duration(hours: 18),
    ),
  ],
  nextActionHints: <V2NextActionHint>[
    V2NextActionHint(
      actionType: V2RecommendedActionType.startNextPhase,
      label: 'Stage A complete',
      reason:
          'The learner has finished Stage A with two real words, supported reading confidence, and a first tiny Arabic usage glimpse, while the debug preview still stops before Stage B.',
    ),
  ],
);

const List<V2MicroLesson> stageAFoundationPreviewLessons = <V2MicroLesson>[
  stageAOrientationPreviewLesson,
  stageAFirstScriptSuccessPreviewLesson,
  stageASameLetterNewShapePreviewLesson,
  stageAShortVowelPreviewLesson,
];
