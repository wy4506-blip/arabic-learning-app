import '../models/review_models.dart';
import '../models/v2_micro_lesson.dart';

const String _kitab = '\u0643\u062a\u0627\u0628';
const String _bab = '\u0628\u0627\u0628';
const String _qalam = '\u0642\u0644\u0645';
const String _bayt = '\u0628\u064a\u062a';
const String _baytSupported = '\u0628\u064e\u064a\u0652\u062a';
const String _sayyara = '\u0633\u064a\u0627\u0631\u0629';
const String _sayyaraStem = '\u0633\u064a\u0627\u0631';
const String _sayyaraat = '\u0633\u064a\u0627\u0631\u0627\u062a';
const String _kalima = '\u0643\u0644\u0645\u0629';
const String _kalimat = '\u0643\u0644\u0645\u0627\u062a';
const String _taMarbuta = '\u0629';
const String _sayyaraPlaceholder = '\u0633\u064a\u0627\u0631_';
const String _stageCTinyCardDisplay = 'كتاب\nقلم\nبيت\nسيارة\nسيارات';

const String _stageCTinyCardSequence = 'كتاب قلم بيت سيارة سيارات';

class StageCPreviewDescriptor {
  final String lessonId;
  final int order;
  final String chapterRole;
  final String learnerVisibleOutcome;
  final String completionEvidence;
  final String chapterBridge;
  final String nextUnlock;

  const StageCPreviewDescriptor({
    required this.lessonId,
    required this.order,
    required this.chapterRole,
    required this.learnerVisibleOutcome,
    required this.completionEvidence,
    required this.chapterBridge,
    required this.nextUnlock,
  });
}

StageCPreviewDescriptor? stageCPreviewDescriptorForLessonId(String lessonId) {
  for (final descriptor in stageCPreviewDescriptors) {
    if (descriptor.lessonId == lessonId) {
      return descriptor;
    }
  }
  return null;
}

const List<StageCPreviewDescriptor> stageCPreviewDescriptors =
    <StageCPreviewDescriptor>[
      StageCPreviewDescriptor(
        lessonId: 'lesson_09_bayt_make_it_stick',
        order: 9,
        chapterRole: 'Learn one real new word',
        learnerVisibleOutcome:
            'You can recognize, hear, recall, and say بيت as the Arabic word for house.',
        completionEvidence:
            'Clean completion means the learner hears بيت, recognizes it in the pack, and brings it back from memory as house.',
        chapterBridge:
            'Stage C starts with one real new-word win so the chapter moves forward through content, not theory.',
        nextUnlock:
            'With بيت stable, the next unlock is one helpful page clue in سيارة.',
      ),
      StageCPreviewDescriptor(
        lessonId: 'lesson_10_arabic_gives_you_a_clue_ta_marbuta',
        order: 10,
        chapterRole: 'Find one page clue',
        learnerVisibleOutcome:
            'You can spot one helpful page clue, ة, in سيارة, with كلمة as a light confirmation.',
        completionEvidence:
            'Clean completion means the learner spots the clue in the main word, confirms it once in support, and restores سيارة after support is reduced.',
        chapterBridge:
            'Arabic now starts feeling less random because one real word gives a small clue on the page.',
        nextUnlock:
            'The next unlock is another tiny clue: one car versus more than one car.',
      ),
      StageCPreviewDescriptor(
        lessonId: 'lesson_11_one_or_more_another_arabic_clue',
        order: 11,
        chapterRole: 'Find a quantity clue in one tiny pair',
        learnerVisibleOutcome:
            'You can tell when this tiny pair points to one car or more than one car.',
        completionEvidence:
            'Clean completion means the learner identifies سيارات as more than one, confirms the clue once in كلمات, and rebuilds the main pair with reduced support.',
        chapterBridge:
            'Keep the clue feeling concrete by staying inside one tiny pair instead of drifting into a system lesson.',
        nextUnlock:
            'The next unlock is the Stage C payoff: a tiny Arabic card you can actually handle.',
      ),
      StageCPreviewDescriptor(
        lessonId: 'lesson_12_you_can_read_a_tiny_arabic_card',
        order: 12,
        chapterRole: 'Finish Stage C with a tiny Arabic card',
        learnerVisibleOutcome:
            'You can get through one tiny Arabic card using known words plus the first Stage C clues.',
        completionEvidence:
            'Clean completion means the learner hears and finds بيت, spots سيارة and سيارات as clue items, and rebuilds the tiny card in order.',
        chapterBridge:
            'Stage C closes by turning the word win plus two clue wins into one small readable Arabic moment.',
        nextUnlock:
            'Stage C ends here with a real handling win and points naturally toward the next chapter.',
      ),
    ];

const V2MicroLesson lesson9BaytMakeItStickPreviewLesson = V2MicroLesson(
  lessonId: 'lesson_09_bayt_make_it_stick',
  phaseId: 'phase_preview_stage_c_word_growth',
  groupId: 'stage_c_preview_word_growth',
  title: 'بيت Means House',
  outcomeSummary:
      'After this lesson, you can recognize, hear, recall, and say بيت for house.',
  estimatedMinutes: 6,
  lessonType: V2MicroLessonType.consolidation,
  objectives: <V2MicroLessonObjective>[
    V2MicroLessonObjective(
      objectiveId: 'recognize_recall_bayt',
      summary: 'Recognize and recall بيت as the Arabic word for house.',
    ),
  ],
  entryCondition: V2MicroLessonEntryCondition(),
  contentItems: <V2MicroContentItem>[
    V2MicroContentItem(
      itemId: 'goal_bayt_word',
      kind: V2MicroContentKind.goal,
      title: 'Lesson Goal',
      body:
          'Add one real Arabic word to your pack: بيت = house.',
      objectiveIds: <String>['recognize_recall_bayt'],
    ),
    V2MicroContentItem(
      itemId: 'input_bayt_word',
      kind: V2MicroContentKind.input,
      title: 'One More Real Word',
      body:
          'See, hear, and keep one new real Arabic word as a whole until house starts to feel attached to بيت.',
      arabicText: _baytSupported,
      transliteration: 'bayt',
      meaning: 'house',
      audioQueryText: _bayt,
      objectiveIds: <String>['recognize_recall_bayt'],
    ),
    V2MicroContentItem(
      itemId: 'explain_bayt_stick',
      kind: V2MicroContentKind.explanation,
      title: 'Make It Stick',
      body:
          'Keep one tiny support note only: بيت means one house. The real win is learning the word itself.',
      objectiveIds: <String>['recognize_recall_bayt'],
    ),
    V2MicroContentItem(
      itemId: 'contrast_bayt_pack_bridge',
      kind: V2MicroContentKind.contrast,
      title: 'Your Pack Is Growing',
      body:
          'Known words stay nearby so بيت feels like one more real word in the pack, not an isolated card.',
      arabicText: '$_kitab / $_bab / $_qalam / $_bayt',
      objectiveIds: <String>['recognize_recall_bayt'],
    ),
  ],
  practiceItems: <V2MicroPracticeItem>[
    V2MicroPracticeItem(
      itemId: 'recognize_bayt_meaning',
      type: V2MicroPracticeType.comprehensionCheck,
      prompt: 'In this lesson, بيت means...',
      arabicText: 'house',
      meaning: 'بيت = house',
      choiceOptions: <String>['house', 'book', 'door', 'pen'],
      itemRefId: 'bayt_meaning_recognition',
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.read,
      objectiveIds: <String>['recognize_recall_bayt'],
    ),
    V2MicroPracticeItem(
      itemId: 'choose_bayt_from_pack',
      type: V2MicroPracticeType.comprehensionCheck,
      prompt: 'Which Arabic word means house?',
      arabicText: _bayt,
      meaning: 'house',
      choiceOptions: <String>[_bayt, _kitab, _bab, _qalam],
      itemRefId: 'pack_contrast_bayt_vs_kitab_bab_qalam',
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.distinguish,
      objectiveIds: <String>['recognize_recall_bayt'],
    ),
    V2MicroPracticeItem(
      itemId: 'hear_bayt_and_tap',
      type: V2MicroPracticeType.listenTap,
      prompt: 'Listen, then tap بيت.',
      arabicText: _bayt,
      meaning: 'house',
      choiceOptions: <String>[_bayt, _kitab, _bab, _qalam],
      itemRefId: 'audio_to_word_bayt',
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.listen,
      objectiveIds: <String>['recognize_recall_bayt'],
    ),
    V2MicroPracticeItem(
      itemId: 'recognize_bayt_note',
      type: V2MicroPracticeType.comprehensionCheck,
      prompt: 'Which light support note fits بيت here?',
      arabicText: 'one house',
      meaning: 'light memory note',
      choiceOptions: <String>['one house', 'many houses', 'short line'],
      itemRefId: 'word_note_bayt_singular',
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.read,
      objectiveIds: <String>['recognize_recall_bayt'],
    ),
    V2MicroPracticeItem(
      itemId: 'recall_bayt_from_house',
      type: V2MicroPracticeType.recallPrompt,
      prompt: 'You mean house. Recall the Arabic word from memory.',
      meaning: 'house',
      expectedAnswer: _bayt,
      itemRefId: 'word_meaning_recall_bayt',
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.read,
      objectiveIds: <String>['recognize_recall_bayt'],
    ),
    V2MicroPracticeItem(
      itemId: 'say_bayt_once',
      type: V2MicroPracticeType.speakResponse,
      prompt: 'See house, say بيت once, then type it to lock it in.',
      arabicText: _bayt,
      transliteration: 'bayt',
      meaning: 'house',
      expectedAnswer: _bayt,
      itemRefId: 'supported_rebuild_bayt',
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.repeat,
      objectiveIds: <String>['recognize_recall_bayt'],
    ),
  ],
  completionRule: V2MicroCompletionRule(
    requiredPracticeItemIds: <String>[
      'recognize_bayt_meaning',
      'choose_bayt_from_pack',
      'hear_bayt_and_tap',
      'recognize_bayt_note',
      'recall_bayt_from_house',
    ],
    requiredObjectiveIds: <String>['recognize_recall_bayt'],
    minimumPracticeCount: 5,
    passThreshold: 0.8,
  ),
  reviewSeedRules: <V2MicroReviewSeedRule>[
    V2MicroReviewSeedRule(
      ruleId: 'word_meaning_recall_bayt',
      seedKind: V2ReviewSeedKind.newVocabulary,
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.read,
      sourceItemRefId: 'word_meaning_recall_bayt',
      objectiveIds: <String>['recognize_recall_bayt'],
      dueAfter: Duration(hours: 18),
    ),
    V2MicroReviewSeedRule(
      ruleId: 'audio_to_word_bayt',
      seedKind: V2ReviewSeedKind.weakPoint,
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.listen,
      sourceItemRefId: 'audio_to_word_bayt',
      objectiveIds: <String>['recognize_recall_bayt'],
      dueAfter: Duration.zero,
      onlyIfWeak: true,
    ),
    V2MicroReviewSeedRule(
      ruleId: 'pack_contrast_bayt_vs_kitab_bab_qalam',
      seedKind: V2ReviewSeedKind.confusionPair,
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.distinguish,
      sourceItemRefId: 'pack_contrast_bayt_vs_kitab_bab_qalam',
      objectiveIds: <String>['recognize_recall_bayt'],
      dueAfter: Duration.zero,
      onlyIfWeak: true,
    ),
    V2MicroReviewSeedRule(
      ruleId: 'word_note_bayt_singular',
      seedKind: V2ReviewSeedKind.weakPoint,
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.read,
      sourceItemRefId: 'word_note_bayt_singular',
      objectiveIds: <String>['recognize_recall_bayt'],
      dueAfter: Duration.zero,
      onlyIfWeak: true,
    ),
    V2MicroReviewSeedRule(
      ruleId: 'supported_rebuild_bayt',
      seedKind: V2ReviewSeedKind.weakPoint,
      reviewObjectType: ReviewObjectType.wordReading,
      reviewActionType: ReviewActionType.repeat,
      sourceItemRefId: 'supported_rebuild_bayt',
      objectiveIds: <String>['recognize_recall_bayt'],
      dueAfter: Duration.zero,
      onlyIfWeak: true,
    ),
  ],
  nextActionHints: <V2NextActionHint>[
    V2NextActionHint(
      actionType: V2RecommendedActionType.startLesson,
      label: 'Continue to the first helpful page clue',
      reason:
          'بيت is now stable enough to carry into the next Stage C clue lesson.',
    ),
  ],
);

const V2MicroLesson lesson10ArabicGivesYouAClueTaMarbutaPreviewLesson =
    V2MicroLesson(
      lessonId: 'lesson_10_arabic_gives_you_a_clue_ta_marbuta',
      phaseId: 'phase_preview_stage_c_clues',
      groupId: 'stage_c_preview_clue_ta_marbuta',
      title: 'Arabic Gives You a Clue: ة',
      outcomeSummary:
          'After this lesson, you can spot one helpful page clue, ة, in سيارة, with كلمة as a light confirmation.',
      estimatedMinutes: 6,
      lessonType: V2MicroLessonType.consolidation,
      objectives: <V2MicroLessonObjective>[
        V2MicroLessonObjective(
          objectiveId: 'notice_ta_marbuta_clue',
          summary:
              'Notice ة as a helpful clue on the page in one tiny controlled set.',
        ),
      ],
      entryCondition: V2MicroLessonEntryCondition(),
      contentItems: <V2MicroContentItem>[
        V2MicroContentItem(
          itemId: 'goal_ta_marbuta_clue',
          kind: V2MicroContentKind.goal,
          title: 'Lesson Goal',
          body:
              'Look for one helpful page clue. In this lesson, Arabic gives you one small visible hint: ة.',
          objectiveIds: <String>['notice_ta_marbuta_clue'],
        ),
        V2MicroContentItem(
          itemId: 'input_sayyara_clue',
          kind: V2MicroContentKind.input,
          title: 'Main Clue Word',
          body:
              'Start with one real clue-carrier. سيارة is the main word that makes this clue feel useful and readable.',
          arabicText: _sayyara,
          transliteration: 'sayyara',
          meaning: 'car',
          audioQueryText: _sayyara,
          objectiveIds: <String>['notice_ta_marbuta_clue'],
        ),
        V2MicroContentItem(
          itemId: 'explain_ta_marbuta_clue',
          kind: V2MicroContentKind.explanation,
          title: 'Arabic Gives You A Clue',
          body:
              'When you see ة in this tiny set, let it feel like a page clue. You are not memorizing a rule block.',
          objectiveIds: <String>['notice_ta_marbuta_clue'],
        ),
        V2MicroContentItem(
          itemId: 'support_kalima_clue',
          kind: V2MicroContentKind.contrast,
          title: 'One Light Confirmation',
          body:
              'You see the same clue again in كلمة. This confirms the pattern, but سيارة stays the main anchor.',
          arabicText: _kalima,
          transliteration: 'kalima',
          meaning: 'word',
          audioQueryText: _kalima,
          objectiveIds: <String>['notice_ta_marbuta_clue'],
        ),
        V2MicroContentItem(
          itemId: 'contrast_no_clue_words',
          kind: V2MicroContentKind.contrast,
          title: 'See The Clue, See The Difference',
          body:
              'Known words help you notice the difference between words that show the clue and words that do not.',
          arabicText: '$_sayyara / $_kalima / $_kitab / $_bayt',
          objectiveIds: <String>['notice_ta_marbuta_clue'],
        ),
      ],
      practiceItems: <V2MicroPracticeItem>[
        V2MicroPracticeItem(
          itemId: 'spot_ta_marbuta_in_sayyara',
          type: V2MicroPracticeType.comprehensionCheck,
          prompt: 'Which ending is the helpful page clue in سيارة?',
          arabicText: _taMarbuta,
          meaning: 'helpful ending clue',
          choiceOptions: <String>[_taMarbuta, 'ر', 'س'],
          itemRefId: 'clue_spot_ta_marbuta',
          reviewObjectType: ReviewObjectType.wordReading,
          reviewActionType: ReviewActionType.read,
          objectiveIds: <String>['notice_ta_marbuta_clue'],
        ),
        V2MicroPracticeItem(
          itemId: 'recognize_kalima_shares_clue',
          type: V2MicroPracticeType.comprehensionCheck,
          prompt: 'Which other word in this lesson shows the same clue as سيارة?',
          arabicText: _kalima,
          meaning: 'support clue word',
          choiceOptions: <String>[_kalima, _kitab, _bayt],
          itemRefId: 'clue_word_kalima_support',
          reviewObjectType: ReviewObjectType.wordReading,
          reviewActionType: ReviewActionType.distinguish,
          objectiveIds: <String>['notice_ta_marbuta_clue'],
        ),
        V2MicroPracticeItem(
          itemId: 'clue_vs_no_clue_contrast',
          type: V2MicroPracticeType.comprehensionCheck,
          prompt: 'Which word in this tiny set shows the clue?',
          arabicText: _sayyara,
          meaning: 'main clue word',
          choiceOptions: <String>[_sayyara, _kitab, _bayt],
          itemRefId: 'clue_contrast_ta_marbuta_vs_no_clue',
          reviewObjectType: ReviewObjectType.wordReading,
          reviewActionType: ReviewActionType.distinguish,
          objectiveIds: <String>['notice_ta_marbuta_clue'],
        ),
        V2MicroPracticeItem(
          itemId: 'recognize_sayyara_meaning',
          type: V2MicroPracticeType.comprehensionCheck,
          prompt: 'In this clue lesson, سيارة means...',
          arabicText: 'car',
          meaning: 'main clue-carrier meaning',
          choiceOptions: <String>['car', 'word', 'book'],
          itemRefId: 'clue_word_sayyara_primary',
          reviewObjectType: ReviewObjectType.wordReading,
          reviewActionType: ReviewActionType.read,
          objectiveIds: <String>['notice_ta_marbuta_clue'],
        ),
        V2MicroPracticeItem(
          itemId: 'restore_ta_marbuta_in_context',
          type: V2MicroPracticeType.recallPrompt,
          prompt:
              'Complete the clue word with reduced support: $_sayyaraPlaceholder',
          meaning: 'car',
          expectedAnswer: _sayyara,
          itemRefId: 'restore_ta_marbuta_in_context',
          reviewObjectType: ReviewObjectType.wordReading,
          reviewActionType: ReviewActionType.read,
          objectiveIds: <String>['notice_ta_marbuta_clue'],
        ),
        V2MicroPracticeItem(
          itemId: 'mark_ta_marbuta_output',
          type: V2MicroPracticeType.arrangeResponse,
          prompt:
              'Build the clue-marking action in order: $_sayyaraStem then ة.',
          expectedAnswer: '$_sayyaraStem $_taMarbuta',
          itemRefId: 'clue_spot_ta_marbuta',
          reviewObjectType: ReviewObjectType.wordReading,
          reviewActionType: ReviewActionType.distinguish,
          objectiveIds: <String>['notice_ta_marbuta_clue'],
        ),
      ],
      completionRule: V2MicroCompletionRule(
        requiredPracticeItemIds: <String>[
          'spot_ta_marbuta_in_sayyara',
          'recognize_kalima_shares_clue',
          'clue_vs_no_clue_contrast',
          'restore_ta_marbuta_in_context',
          'mark_ta_marbuta_output',
        ],
        requiredObjectiveIds: <String>['notice_ta_marbuta_clue'],
        minimumPracticeCount: 5,
        passThreshold: 0.8,
      ),
      reviewSeedRules: <V2MicroReviewSeedRule>[
        V2MicroReviewSeedRule(
          ruleId: 'clue_spot_ta_marbuta',
          seedKind: V2ReviewSeedKind.newVocabulary,
          reviewObjectType: ReviewObjectType.wordReading,
          reviewActionType: ReviewActionType.read,
          sourceItemRefId: 'clue_spot_ta_marbuta',
          objectiveIds: <String>['notice_ta_marbuta_clue'],
          dueAfter: Duration(hours: 18),
        ),
        V2MicroReviewSeedRule(
          ruleId: 'clue_contrast_ta_marbuta_vs_no_clue',
          seedKind: V2ReviewSeedKind.weakPoint,
          reviewObjectType: ReviewObjectType.wordReading,
          reviewActionType: ReviewActionType.distinguish,
          sourceItemRefId: 'clue_contrast_ta_marbuta_vs_no_clue',
          objectiveIds: <String>['notice_ta_marbuta_clue'],
          dueAfter: Duration.zero,
          onlyIfWeak: true,
        ),
        V2MicroReviewSeedRule(
          ruleId: 'clue_word_sayyara_primary',
          seedKind: V2ReviewSeedKind.weakPoint,
          reviewObjectType: ReviewObjectType.wordReading,
          reviewActionType: ReviewActionType.read,
          sourceItemRefId: 'clue_word_sayyara_primary',
          objectiveIds: <String>['notice_ta_marbuta_clue'],
          dueAfter: Duration.zero,
          onlyIfWeak: true,
        ),
        V2MicroReviewSeedRule(
          ruleId: 'clue_word_kalima_support',
          seedKind: V2ReviewSeedKind.weakPoint,
          reviewObjectType: ReviewObjectType.wordReading,
          reviewActionType: ReviewActionType.distinguish,
          sourceItemRefId: 'clue_word_kalima_support',
          objectiveIds: <String>['notice_ta_marbuta_clue'],
          dueAfter: Duration.zero,
          onlyIfWeak: true,
        ),
        V2MicroReviewSeedRule(
          ruleId: 'clue_meaning_feminine_hint',
          seedKind: V2ReviewSeedKind.weakPoint,
          reviewObjectType: ReviewObjectType.wordReading,
          reviewActionType: ReviewActionType.read,
          sourceItemRefId: 'clue_meaning_feminine_hint',
          objectiveIds: <String>['notice_ta_marbuta_clue'],
          dueAfter: Duration.zero,
          onlyIfWeak: true,
        ),
        V2MicroReviewSeedRule(
          ruleId: 'restore_ta_marbuta_in_context',
          seedKind: V2ReviewSeedKind.weakPoint,
          reviewObjectType: ReviewObjectType.wordReading,
          reviewActionType: ReviewActionType.read,
          sourceItemRefId: 'restore_ta_marbuta_in_context',
          objectiveIds: <String>['notice_ta_marbuta_clue'],
          dueAfter: Duration.zero,
          onlyIfWeak: true,
        ),
      ],
      nextActionHints: <V2NextActionHint>[
        V2NextActionHint(
          actionType: V2RecommendedActionType.startLesson,
          label: 'Continue to another useful clue',
          reason:
              'This clue is stable enough to carry into the next lesson on one versus more than one.',
        ),
      ],
    );

const V2MicroLesson lesson11OneOrMoreAnotherArabicCluePreviewLesson =
    V2MicroLesson(
      lessonId: 'lesson_11_one_or_more_another_arabic_clue',
      phaseId: 'phase_preview_stage_c_clues',
      groupId: 'stage_c_preview_quantity_clue',
      title: 'One Or More? A Tiny Arabic Clue',
      outcomeSummary:
          'After this lesson, you can tell when this tiny pair points to one car or more than one car.',
      estimatedMinutes: 6,
      lessonType: V2MicroLessonType.consolidation,
      objectives: <V2MicroLessonObjective>[
        V2MicroLessonObjective(
          objectiveId: 'notice_one_vs_more_in_tiny_set',
          summary:
              'Notice one versus more than one in one tiny controlled Arabic set.',
        ),
      ],
      entryCondition: V2MicroLessonEntryCondition(),
      contentItems: <V2MicroContentItem>[
        V2MicroContentItem(
          itemId: 'goal_one_vs_more_clue',
          kind: V2MicroContentKind.goal,
          title: 'Lesson Goal',
          body:
              'Stay with one small clue win: in one tiny Arabic pair, the word itself can show one or more than one.',
          objectiveIds: <String>['notice_one_vs_more_in_tiny_set'],
        ),
        V2MicroContentItem(
          itemId: 'input_main_pair_sayyara',
          kind: V2MicroContentKind.input,
          title: 'One Tiny Pair',
          body:
              'See one car and more than one car together first. The pair itself is the lesson.',
          arabicText: '$_sayyara / $_sayyaraat',
          transliteration: 'sayyara / sayyaraat',
          meaning: 'one car / cars',
          audioQueryText: '$_sayyara $_sayyaraat',
          objectiveIds: <String>['notice_one_vs_more_in_tiny_set'],
        ),
        V2MicroContentItem(
          itemId: 'explain_quantity_clue',
          kind: V2MicroContentKind.explanation,
          title: 'The Word Gives A Clue',
          body:
              'In this tiny set, one form points to one car and the other points to more than one. That is enough for this lesson.',
          objectiveIds: <String>['notice_one_vs_more_in_tiny_set'],
        ),
        V2MicroContentItem(
          itemId: 'contrast_support_pair',
          kind: V2MicroContentKind.contrast,
          title: 'One Light Confirmation',
          body:
              'You will see the same kind of clue once more in $_kalima / $_kalimat, but it stays a light confirmation only.',
          arabicText: '$_kalima / $_kalimat',
          meaning: 'word / words',
          audioQueryText: '$_kalima $_kalimat',
          objectiveIds: <String>['notice_one_vs_more_in_tiny_set'],
        ),
        V2MicroContentItem(
          itemId: 'contrast_known_anchors',
          kind: V2MicroContentKind.contrast,
          title: 'Known Anchors Stay In Place',
          body:
              'Known words stay in the background only. They are anchors, not new evidence targets here.',
          arabicText: '$_kitab / $_bab / $_qalam / $_bayt',
          objectiveIds: <String>['notice_one_vs_more_in_tiny_set'],
        ),
      ],
      practiceItems: <V2MicroPracticeItem>[
        V2MicroPracticeItem(
          itemId: 'recognize_more_than_one_main_pair',
          type: V2MicroPracticeType.comprehensionCheck,
          prompt: 'Which form in the main pair shows more than one?',
          arabicText: _sayyaraat,
          meaning: 'cars / more than one',
          choiceOptions: <String>[_sayyara, _sayyaraat],
          itemRefId: 'one_vs_more_main_pair_sayyara',
          reviewObjectType: ReviewObjectType.wordReading,
          reviewActionType: ReviewActionType.distinguish,
          objectiveIds: <String>['notice_one_vs_more_in_tiny_set'],
        ),
        V2MicroPracticeItem(
          itemId: 'match_many_cars_main_pair',
          type: V2MicroPracticeType.comprehensionCheck,
          prompt: 'Which form in the tiny pair matches many cars?',
          arabicText: _sayyaraat,
          meaning: 'cars / more than one',
          choiceOptions: <String>[_sayyara, _sayyaraat],
          itemRefId: 'main_pair_quantity_match',
          reviewObjectType: ReviewObjectType.wordReading,
          reviewActionType: ReviewActionType.recognize,
          objectiveIds: <String>['notice_one_vs_more_in_tiny_set'],
        ),
        V2MicroPracticeItem(
          itemId: 'confirm_more_than_one_support_pair',
          type: V2MicroPracticeType.comprehensionCheck,
          prompt: 'Which support word means more than one word?',
          arabicText: _kalimat,
          meaning: 'words / more than one',
          choiceOptions: <String>[_kalima, _kalimat],
          itemRefId: 'one_vs_more_support_pair_kalima',
          reviewObjectType: ReviewObjectType.wordReading,
          reviewActionType: ReviewActionType.read,
          objectiveIds: <String>['notice_one_vs_more_in_tiny_set'],
        ),
        V2MicroPracticeItem(
          itemId: 'recover_more_than_one_main_pair',
          type: V2MicroPracticeType.recallPrompt,
          prompt:
              'The meaning is cars. Complete the Arabic form with reduced support: $_sayyaraPlaceholder',
          meaning: 'cars',
          expectedAnswer: _sayyaraat,
          itemRefId: 'recover_more_than_one_form_sayyaraat',
          reviewObjectType: ReviewObjectType.wordReading,
          reviewActionType: ReviewActionType.read,
          objectiveIds: <String>['notice_one_vs_more_in_tiny_set'],
        ),
        V2MicroPracticeItem(
          itemId: 'sort_main_pair_one_vs_more',
          type: V2MicroPracticeType.arrangeResponse,
          prompt:
              'Build the guided sort in order: one -> $_sayyara, more-than-one -> $_sayyaraat.',
          expectedAnswer: 'one $_sayyara more-than-one $_sayyaraat',
          itemRefId: 'main_pair_quantity_match',
          reviewObjectType: ReviewObjectType.wordReading,
          reviewActionType: ReviewActionType.distinguish,
          objectiveIds: <String>['notice_one_vs_more_in_tiny_set'],
        ),
      ],
      completionRule: V2MicroCompletionRule(
        requiredPracticeItemIds: <String>[
          'recognize_more_than_one_main_pair',
          'match_many_cars_main_pair',
          'confirm_more_than_one_support_pair',
          'recover_more_than_one_main_pair',
          'sort_main_pair_one_vs_more',
        ],
        requiredObjectiveIds: <String>['notice_one_vs_more_in_tiny_set'],
        minimumPracticeCount: 5,
        passThreshold: 0.8,
      ),
      reviewSeedRules: <V2MicroReviewSeedRule>[
        V2MicroReviewSeedRule(
          ruleId: 'one_vs_more_main_pair_sayyara',
          seedKind: V2ReviewSeedKind.newVocabulary,
          reviewObjectType: ReviewObjectType.wordReading,
          reviewActionType: ReviewActionType.distinguish,
          sourceItemRefId: 'one_vs_more_main_pair_sayyara',
          objectiveIds: <String>['notice_one_vs_more_in_tiny_set'],
          dueAfter: Duration(hours: 18),
        ),
        V2MicroReviewSeedRule(
          ruleId: 'recover_more_than_one_form_sayyaraat',
          seedKind: V2ReviewSeedKind.weakPoint,
          reviewObjectType: ReviewObjectType.wordReading,
          reviewActionType: ReviewActionType.read,
          sourceItemRefId: 'recover_more_than_one_form_sayyaraat',
          objectiveIds: <String>['notice_one_vs_more_in_tiny_set'],
          dueAfter: Duration.zero,
          onlyIfWeak: true,
        ),
        V2MicroReviewSeedRule(
          ruleId: 'main_pair_quantity_match',
          seedKind: V2ReviewSeedKind.weakPoint,
          reviewObjectType: ReviewObjectType.wordReading,
          reviewActionType: ReviewActionType.distinguish,
          sourceItemRefId: 'main_pair_quantity_match',
          objectiveIds: <String>['notice_one_vs_more_in_tiny_set'],
          dueAfter: Duration.zero,
          onlyIfWeak: true,
        ),
        V2MicroReviewSeedRule(
          ruleId: 'one_vs_more_support_pair_kalima',
          seedKind: V2ReviewSeedKind.weakPoint,
          reviewObjectType: ReviewObjectType.wordReading,
          reviewActionType: ReviewActionType.read,
          sourceItemRefId: 'one_vs_more_support_pair_kalima',
          objectiveIds: <String>['notice_one_vs_more_in_tiny_set'],
          dueAfter: Duration.zero,
          onlyIfWeak: true,
        ),
      ],
      nextActionHints: <V2NextActionHint>[
        V2NextActionHint(
          actionType: V2RecommendedActionType.startLesson,
          label: 'Continue to a tiny supported Arabic card',
          reason:
              'The one-versus-more-than-one clue is stable enough to carry into a tiny supported Arabic card next.',
        ),
      ],
    );


const V2MicroLesson lesson12YouCanReadATinyArabicCardPreviewLesson =
    V2MicroLesson(
      lessonId: 'lesson_12_you_can_read_a_tiny_arabic_card',
      phaseId: 'phase_preview_stage_c_supported_card',
      groupId: 'stage_c_preview_supported_card',
      title: 'You Can Read a Tiny Arabic Card',
      outcomeSummary:
          'After this lesson, you can get through one tiny Arabic card using known words and the first Stage C clues.',
      estimatedMinutes: 6,
      lessonType: V2MicroLessonType.consolidation,
      objectives: <V2MicroLessonObjective>[
        V2MicroLessonObjective(
          objectiveId: 'process_tiny_supported_arabic_card',
          summary:
              'Process one tiny supported Arabic card using known words and early Stage C clues.',
        ),
      ],
      entryCondition: V2MicroLessonEntryCondition(),
      contentItems: <V2MicroContentItem>[
        V2MicroContentItem(
          itemId: 'goal_tiny_supported_card',
          kind: V2MicroContentKind.goal,
          title: 'Lesson Goal',
          body:
              'Use what you already know to finish Stage C with one tiny Arabic card.',
          objectiveIds: <String>['process_tiny_supported_arabic_card'],
        ),
        V2MicroContentItem(
          itemId: 'input_tiny_supported_card',
          kind: V2MicroContentKind.input,
          title: 'Tiny Arabic Card',
          body:
              'This is one small Arabic card you can actually get through by leaning on known words and two helpful clues.',
          arabicText: _stageCTinyCardDisplay,
          meaning: 'book / pen / house / car / cars',
          audioQueryText: _stageCTinyCardSequence,
          objectiveIds: <String>['process_tiny_supported_arabic_card'],
        ),
        V2MicroContentItem(
          itemId: 'model_tiny_card_strategy',
          kind: V2MicroContentKind.modeling,
          title: 'Use Known Words First',
          body:
              'Anchor on كتاب and قلم first, catch بيت, then use سيارة and سيارات to finish the card.',
          objectiveIds: <String>['process_tiny_supported_arabic_card'],
        ),
        V2MicroContentItem(
          itemId: 'explain_tiny_card_clues',
          kind: V2MicroContentKind.explanation,
          title: 'The Card Still Gives Clues',
          body:
              'This card is the Stage C payoff. You are not learning a new system here. You are proving you can handle a small piece of Arabic.',
          objectiveIds: <String>['process_tiny_supported_arabic_card'],
        ),
      ],
      practiceItems: <V2MicroPracticeItem>[
        V2MicroPracticeItem(
          itemId: 'hear_bayt_on_tiny_card',
          type: V2MicroPracticeType.listenTap,
          prompt: 'Listen, then tap بيت on the tiny card.',
          arabicText: _bayt,
          meaning: 'house',
          choiceOptions: <String>[_kitab, _qalam, _bayt, _sayyara, _sayyaraat],
          itemRefId: 'supported_card_audio_bayt',
          reviewObjectType: ReviewObjectType.wordReading,
          reviewActionType: ReviewActionType.listen,
          objectiveIds: <String>['process_tiny_supported_arabic_card'],
        ),
        V2MicroPracticeItem(
          itemId: 'main_meaning_house_on_tiny_card',
          type: V2MicroPracticeType.comprehensionCheck,
          prompt: 'Which item on the card means house?',
          arabicText: _bayt,
          meaning: 'house',
          choiceOptions: <String>[_bayt, _qalam, _sayyara],
          itemRefId: 'supported_card_house_bayt',
          reviewObjectType: ReviewObjectType.wordReading,
          reviewActionType: ReviewActionType.read,
          objectiveIds: <String>['process_tiny_supported_arabic_card'],
        ),
        V2MicroPracticeItem(
          itemId: 'spot_clue_item_on_tiny_card',
          type: V2MicroPracticeType.comprehensionCheck,
          prompt: 'Which item on the card shows the ة clue?',
          arabicText: _sayyara,
          meaning: 'clue-bearing item',
          choiceOptions: <String>[_sayyara, _kitab, _bayt],
          itemRefId: 'supported_card_clue_item_sayyara',
          reviewObjectType: ReviewObjectType.wordReading,
          reviewActionType: ReviewActionType.distinguish,
          objectiveIds: <String>['process_tiny_supported_arabic_card'],
        ),
        V2MicroPracticeItem(
          itemId: 'spot_more_than_one_on_tiny_card',
          type: V2MicroPracticeType.comprehensionCheck,
          prompt: 'Which item on the card shows more than one?',
          arabicText: _sayyaraat,
          meaning: 'cars / more than one',
          choiceOptions: <String>[_sayyara, _sayyaraat, _qalam],
          itemRefId: 'supported_card_more_than_one_sayyaraat',
          reviewObjectType: ReviewObjectType.wordReading,
          reviewActionType: ReviewActionType.read,
          objectiveIds: <String>['process_tiny_supported_arabic_card'],
        ),
        V2MicroPracticeItem(
          itemId: 'rebuild_tiny_card_order',
          type: V2MicroPracticeType.arrangeResponse,
          prompt: 'Build the tiny card back in the same order.',
          expectedAnswer: _stageCTinyCardSequence,
          itemRefId: 'tiny_card_order_instability',
          reviewObjectType: ReviewObjectType.sentencePattern,
          reviewActionType: ReviewActionType.read,
          objectiveIds: <String>['process_tiny_supported_arabic_card'],
        ),
        V2MicroPracticeItem(
          itemId: 'recall_house_from_tiny_card',
          type: V2MicroPracticeType.recallPrompt,
          prompt: 'From the tiny card, recall the Arabic word for house.',
          meaning: 'house',
          expectedAnswer: _bayt,
          itemRefId: 'supported_card_house_bayt',
          reviewObjectType: ReviewObjectType.wordReading,
          reviewActionType: ReviewActionType.read,
          objectiveIds: <String>['process_tiny_supported_arabic_card'],
        ),
      ],
      completionRule: V2MicroCompletionRule(
        requiredPracticeItemIds: <String>[
          'hear_bayt_on_tiny_card',
          'main_meaning_house_on_tiny_card',
          'spot_clue_item_on_tiny_card',
          'spot_more_than_one_on_tiny_card',
          'rebuild_tiny_card_order',
          'recall_house_from_tiny_card',
        ],
        requiredObjectiveIds: <String>['process_tiny_supported_arabic_card'],
        minimumPracticeCount: 6,
        passThreshold: 0.8,
      ),
      reviewSeedRules: <V2MicroReviewSeedRule>[
        V2MicroReviewSeedRule(
          ruleId: 'tiny_card_order_instability',
          seedKind: V2ReviewSeedKind.weakPoint,
          reviewObjectType: ReviewObjectType.sentencePattern,
          reviewActionType: ReviewActionType.read,
          sourceItemRefId: 'tiny_card_order_instability',
          objectiveIds: <String>['process_tiny_supported_arabic_card'],
          dueAfter: Duration.zero,
          onlyIfWeak: true,
        ),
        V2MicroReviewSeedRule(
          ruleId: 'supported_card_house_bayt',
          seedKind: V2ReviewSeedKind.newVocabulary,
          reviewObjectType: ReviewObjectType.wordReading,
          reviewActionType: ReviewActionType.read,
          sourceItemRefId: 'supported_card_house_bayt',
          objectiveIds: <String>['process_tiny_supported_arabic_card'],
          dueAfter: Duration(hours: 18),
        ),
        V2MicroReviewSeedRule(
          ruleId: 'supported_card_audio_bayt',
          seedKind: V2ReviewSeedKind.weakPoint,
          reviewObjectType: ReviewObjectType.wordReading,
          reviewActionType: ReviewActionType.listen,
          sourceItemRefId: 'supported_card_audio_bayt',
          objectiveIds: <String>['process_tiny_supported_arabic_card'],
          dueAfter: Duration.zero,
          onlyIfWeak: true,
        ),
        V2MicroReviewSeedRule(
          ruleId: 'supported_card_clue_item_sayyara',
          seedKind: V2ReviewSeedKind.weakPoint,
          reviewObjectType: ReviewObjectType.wordReading,
          reviewActionType: ReviewActionType.distinguish,
          sourceItemRefId: 'supported_card_clue_item_sayyara',
          objectiveIds: <String>['process_tiny_supported_arabic_card'],
          dueAfter: Duration.zero,
          onlyIfWeak: true,
        ),
        V2MicroReviewSeedRule(
          ruleId: 'supported_card_more_than_one_sayyaraat',
          seedKind: V2ReviewSeedKind.weakPoint,
          reviewObjectType: ReviewObjectType.wordReading,
          reviewActionType: ReviewActionType.read,
          sourceItemRefId: 'supported_card_more_than_one_sayyaraat',
          objectiveIds: <String>['process_tiny_supported_arabic_card'],
          dueAfter: Duration.zero,
          onlyIfWeak: true,
        ),
        V2MicroReviewSeedRule(
          ruleId: 'supported_card_anchor_pack',
          seedKind: V2ReviewSeedKind.weakPoint,
          reviewObjectType: ReviewObjectType.wordReading,
          reviewActionType: ReviewActionType.read,
          sourceItemRefId: 'supported_card_anchor_pack',
          objectiveIds: <String>['process_tiny_supported_arabic_card'],
          dueAfter: Duration.zero,
          onlyIfWeak: true,
        ),
      ],
      nextActionHints: <V2NextActionHint>[
        V2NextActionHint(
          actionType: V2RecommendedActionType.startNextPhase,
          label: 'Stage C complete: continue beyond the clue chapter',
          reason:
              'You can now handle one tiny Arabic card using your pack and the first two clue types.',
        ),
      ],
    );

const List<V2MicroLesson> stageCPreviewLessons = <V2MicroLesson>[
  lesson9BaytMakeItStickPreviewLesson,
  lesson10ArabicGivesYouAClueTaMarbutaPreviewLesson,
  lesson11OneOrMoreAnotherArabicCluePreviewLesson,
  lesson12YouCanReadATinyArabicCardPreviewLesson,
];







