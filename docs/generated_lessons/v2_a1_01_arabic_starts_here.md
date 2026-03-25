# 1. Lesson design summary

- `lesson_id`: `V2-A1-01`
- `title`: Arabic Starts Here
- `target learner`: absolute beginner with no prior Arabic study
- `core objective`: orient to Arabic by correctly following one supported Arabic form from right to left
- `can-do statement`: After this lesson, the learner can look at one simple Arabic form, start from the right, and repeat the same choice once the guide is removed.
- `target knowledge`:
  - Arabic target: `بَ`
  - Meaning: starter reading demo, not a vocabulary target
  - Pronunciation notes: `ba`; used only as a support example, not as a vocabulary goal
  - Morphology notes: not applicable; this lesson teaches direction and beginner support use, not word meaning
- `lesson scope`: one demo form only, one direction rule, one support concept
- `estimated time`: 4 to 5 minutes
- `why this lesson should exist`: it reduces fear early, gives the learner one real Arabic success immediately, and introduces the product's learn-check-review logic through action instead of abstract explanation

# 2. Stage-by-stage design

## Input

- Show `بَ` large on screen with a visible right-edge starting cue and a simple right-to-left guide.
- Keep the lesson framing minimal: Arabic starts on the right, and beginner supports are allowed.
- Show one tiny preview of the app loop: see, try, check, review if weak.
- Do not add extra letters, words, or meanings.

## Recognition

- Recognition step 1: learner identifies where reading starts on `بَ`.
- Recognition step 2: learner picks the correct reading direction for the same form.
- Recognition step 3: learner recognizes which supported version is appropriate for a beginner.
- These steps make the lesson about directional confidence, not about passive viewing.

## Recall

- The same form `بَ` appears again with the starting cue removed.
- The learner must recall where to begin and what direction to follow without the original guide.
- This is the real recall-bearing evidence for the lesson.

## Output

- The learner performs one guided right-to-left trace over `بَ`.
- If the final runtime does not support tracing, the fallback is selecting the correct trace animation from multiple options.
- The output is directional action, not speech.

## Completion

- Completion confirms whether the learner only followed help or can now repeat the right-to-left move independently.
- Weak performance must seed a short review for direction and starting-side confusion.

# 3. Structured lesson content

## Metadata

- `phase_id`: `phase_a_script_entry`
- `group_id`: `a1_orientation`
- `lesson_type`: beginner script orientation micro-lesson
- `source_lesson_ids`: `[]`
- `entry_condition`: no prerequisite lesson required

## Objective

- `objective_id`: `orient_rtl_demo`
- `summary`: follow one supported Arabic form from right to left
- `observable evidence`:
  - identifies the right edge as the start point for `بَ`
  - identifies the correct right-to-left movement path
  - repeats the same decisions after support is removed
  - performs one correct guided trace
- `mastery threshold`: `0.80`

## Content items

### Content item A

- `item_id`: `goal_orientation`
- `kind`: `goal`
- `title`: Lesson goal
- `body`: Learn the first move that makes Arabic less scary: begin from the right and follow one simple form correctly.
- `objective_ids`: `['orient_rtl_demo']`

### Content item B

- `item_id`: `input_demo_ba`
- `kind`: `input`
- `title`: First Arabic example
- `body`: Look at one simple Arabic form with full beginner support. You only need to notice where Arabic starts and how it moves.
- `arabic_text`: `بَ`
- `audio_query_text`: `بَ`
- `transliteration`: `ba`
- `meaning`: `starter reading demo`
- `objective_ids`: `['orient_rtl_demo']`

### Content item C

- `item_id`: `support_rule_intro`
- `kind`: `explanation`
- `title`: Beginner support is allowed
- `body`: In this course, guides and diacritics help you read early Arabic forms. They are learning supports, not signs of failure.
- `objective_ids`: `['orient_rtl_demo']`

### Content item D

- `item_id`: `contrast_direction`
- `kind`: `contrast`
- `title`: Watch the direction
- `body`: The key contrast here is simple: Arabic starts from the right on this example, not from the left.
- `arabic_text`: `بَ`
- `objective_ids`: `['orient_rtl_demo']`

## Practice items

### Practice item 1

- `item_id`: `recognize_start_side_ba`
- `type`: `comprehensionCheck`
- `prompt`: Where does this Arabic form start?
- `arabic_text`: `بَ`
- `options`:
  - `right edge`
  - `left edge`
  - `center`
- `correct_answer`: `right edge`
- `item_ref_id`: `rtl_demo_ba`
- `review_object_type`: `letterForm`
- `review_action_type`: `read`
- `objective_ids`: `['orient_rtl_demo']`
- `why_this_is_here`: checks the first directional decision without any vocabulary burden

### Practice item 2

- `item_id`: `recognize_direction_arrow`
- `type`: `contrastChoice`
- `prompt`: Which movement path matches Arabic here?
- `arabic_text`: `بَ`
- `options`:
  - `right to left`
  - `left to right`
  - `top to bottom`
- `correct_answer`: `right to left`
- `item_ref_id`: `rtl_demo_direction`
- `review_object_type`: `letterForm`
- `review_action_type`: `read`
- `objective_ids`: `['orient_rtl_demo']`
- `why_this_is_here`: checks direction explicitly so the lesson is not passable by one lucky tap

### Practice item 3

- `item_id`: `recognize_beginner_helper`
- `type`: `comprehensionCheck`
- `prompt`: Which version is the correct beginner-supported view for this lesson?
- `options`:
  - `guided form with visible start cue and diacritic`
  - `plain mirrored guide`
  - `unsupported guess version`
- `correct_answer`: `guided form with visible start cue and diacritic`
- `item_ref_id`: `rtl_support_demo`
- `review_object_type`: `letterForm`
- `review_action_type`: `read`
- `objective_ids`: `['orient_rtl_demo']`
- `why_this_is_here`: reinforces that beginner support is part of learning, not something to ignore

### Practice item 4

- `item_id`: `recall_start_side_ba`
- `type`: `recallPrompt`
- `prompt`: The guide is gone. Tap where reading begins on `بَ`.
- `arabic_text`: `بَ`
- `expected_answer`: `right edge`
- `item_ref_id`: `rtl_demo_ba`
- `review_object_type`: `letterForm`
- `review_action_type`: `read`
- `objective_ids`: `['orient_rtl_demo']`
- `why_this_is_here`: this is the first unsupported recall-bearing step

### Practice item 5

- `item_id`: `recall_direction_no_guide`
- `type`: `recallPrompt`
- `prompt`: Without the original guide, which way should you follow this form?
- `arabic_text`: `بَ`
- `expected_answer`: `right to left`
- `item_ref_id`: `rtl_demo_direction`
- `review_object_type`: `letterForm`
- `review_action_type`: `read`
- `objective_ids`: `['orient_rtl_demo']`
- `why_this_is_here`: confirms the learner can repeat the rule after support is removed

### Practice item 6

- `item_id`: `trace_rtl_ba`
- `type`: `guidedAction`
- `prompt`: Trace the form once from the right side toward the left.
- `arabic_text`: `بَ`
- `expected_answer`: `right to left trace`
- `item_ref_id`: `rtl_trace_demo`
- `review_object_type`: `letterForm`
- `review_action_type`: `read`
- `objective_ids`: `['orient_rtl_demo']`
- `why_this_is_here`: turns the direction rule into one concrete action instead of one more recognition click
- `runtime_fallback_if_needed`: `comprehensionCheck` with three trace animations

## Notes on scope

- `بَ` is only a visual teaching example here.
- It must not be treated as a real vocabulary word learned for meaning.
- The lesson goal is orientation confidence, not letter naming or word learning.

# 4. Completion contract

## completion_rule

- `required_practice_item_ids`:
  - `recognize_start_side_ba`
  - `recognize_direction_arrow`
  - `recall_start_side_ba`
  - `recall_direction_no_guide`
  - `trace_rtl_ba`
- `required_objective_ids`:
  - `orient_rtl_demo`
- `minimum_practice_count`: `5`
- `pass_threshold`: `0.80`

## completion_return

- `mastery_status`
  - `completed`: learner passes the unsupported recall of both start side and direction, then completes the guided trace correctly
  - `core_completed`: learner finishes the lesson path but misses one unsupported recall-bearing step
  - `in_progress`: learner exits before the unsupported recall steps are collected
- `learning_evidence`
  - identifies the right edge as the start point on `بَ`
  - identifies the correct right-to-left direction
  - repeats those same choices after the guide disappears
  - performs one right-to-left trace action
- `review_seed_candidates`
  - immediate weak review for start-side confusion on `rtl_demo_ba`
  - immediate weak review for direction confusion on `rtl_demo_direction`
  - delayed stability review for `rtl_demo_ba` after a clean pass
- `next_home_action`
  - if `completed`: start Lesson 2
  - if `core_completed`: route to a short review-first refresher on Arabic direction
  - if `in_progress`: keep Lesson 1 as the current home recommendation

## anti-fake-mastery rule

- The lesson cannot be marked as mastered by page traversal alone.
- Recognition-only success is not enough.
- Clean completion requires at least one unsupported recall of where Arabic starts and which way it moves.

# 5. Review seed logic

## Seed A: weak start-side seed

- `rule_id`: `rv_rtl_demo_start`
- `seed_kind`: `weakPoint`
- `review_object_type`: `letterForm`
- `review_action_type`: `read`
- `source_item_ref_id`: `rtl_demo_ba`
- `create_when`: the learner misses `recall_start_side_ba`
- `due_after`: `0h`
- `purpose`: repair the core right-edge start decision immediately

## Seed B: weak direction seed

- `rule_id`: `rv_rtl_demo_direction`
- `seed_kind`: `weakPoint`
- `review_object_type`: `letterForm`
- `review_action_type`: `read`
- `source_item_ref_id`: `rtl_demo_direction`
- `create_when`: the learner misses `recall_direction_no_guide`
- `due_after`: `0h`
- `purpose`: repair the right-to-left movement rule immediately

## Seed C: stable orientation seed

- `rule_id`: `rv_rtl_demo_stable`
- `seed_kind`: `newVocabulary`
- `review_object_type`: `letterForm`
- `review_action_type`: `read`
- `source_item_ref_id`: `rtl_demo_ba`
- `create_when`: the lesson is completed cleanly
- `due_after`: `18h`
- `purpose`: bring the learner back to the orientation move before the new confidence fades

# 6. Home progression result

- `if completed`:
  - `recommended_action_type`: `startLesson`
  - `reason`: the learner can now approach Arabic from the correct side and is ready for the first real letter-sound lesson
  - `suggested_next_lesson_id`: `V2-A1-02`
- `if core_completed`:
  - `recommended_action_type`: `startReview`
  - `reason`: the learner followed the guided path but still needs one short direction refresher before new script content
  - `home_card_copy`: Review the first Arabic move once before continuing
- `if in_progress`:
  - `recommended_action_type`: `continueLesson`
  - `reason`: the unsupported recall evidence is still missing

# 7. Self-check

- `Exactly one core objective`: yes. The lesson only teaches one thing: how to begin and follow one Arabic form from the right.
- `Low cognitive load`: yes. One form, one direction rule, one support concept.
- `Input -> Recognition -> Recall -> Output -> Completion`: yes, in that order.
- `At least one real recall-bearing step`: yes. `recall_start_side_ba` and `recall_direction_no_guide` both require unsupported retrieval.
- `No unnecessary arrangeResponse`: yes. This lesson does not teach phrase or sentence structure.
- `speakResponse only after enough guided input`: yes. No speech output is required here.
- `Completion returns required fields`: yes. `mastery_status`, `learning_evidence`, `review_seed_candidates`, and `next_home_action` are defined.
- `Weak items eligible for review`: yes. Start-side and direction confusion both create immediate weak review seeds.
- `Not passable mainly by guessing`: yes. The learner must succeed on repeated recognition plus unsupported recall, then perform one directional action.
- `Arabic-specific consistency`: yes. The lesson uses a real Arabic form, keeps the diacritic visible, and treats it as a support example rather than fake vocabulary.
