# 1. Lesson design summary

- `lesson_id`: `V2-A1-02`
- `title`: First Script Success
- `target learner`: absolute beginner who has just completed the Arabic entry/orientation lesson
- `core objective`: recognize and recall three starter Arabic letter-sound links in isolated form: `ب`, `م`, and `ل`
- `can-do statement`: After this lesson, the learner can look at `ب`, `م`, and `ل`, connect them to their basic sounds, and retrieve at least one of them again after the support strip is gone.
- `target knowledge`:
  - Arabic target: `ب / م / ل`
  - Meaning: starter script-sound set, not vocabulary items
  - Pronunciation notes: short beginner sound anchors `/b/`, `/m/`, and `/l/`
  - Morphology notes: not applicable; this is a script-and-sound lesson, not a word lesson
- `lesson scope`: three isolated Arabic letters only, with one clean sound anchor each
- `estimated time`: 6 to 7 minutes
- `why this lesson should exist`: it gives the learner the first real feeling of “I can already recognize a little Arabic” and turns Stage A from orientation into real script ownership

# 2. Stage-by-stage design

## Input

- Introduce `ب`, `م`, and `ل` one at a time in isolated form.
- Pair each letter with one short audio model and one simple sound anchor.
- Use only one light visual cue per letter so the learner is not overloaded:
  - `ب`: one dot below
  - `م`: rounded body shape
  - `ل`: tall upright stroke
- End the input phase with one small summary strip showing all three together.

## Recognition

- Recognition step 1: hear a target sound and choose the matching Arabic letter.
- Recognition step 2: see a target Arabic letter and choose the matching sound anchor.
- Recognition alternates direction so the learner builds a real sound-shape link instead of one-way memorization.
- Mixed three-way choices prevent the lesson from being passable by luck.

## Recall

- The summary strip disappears.
- The learner hears one of the target sounds again and must retrieve the correct Arabic letter from memory.
- The learner then sees one isolated target letter without its sound label and must recall the sound again.
- This is the first true recall-bearing evidence in the script track.

## Output

- After guided recognition and recall, the learner does one short `speakResponse`.
- The learner sees one target letter and says its sound once.
- Output stays minimal so the lesson still feels achievable for an absolute beginner.

## Completion

- Completion should reflect first script-sound ownership, not page traversal.
- A clean pass requires all three starter links to be recognized and at least one delayed recall step to succeed.
- Weak letters must become immediate review candidates.

# 3. Structured lesson content

## Metadata

- `phase_id`: `phase_a_script_entry`
- `group_id`: `a1_first_script_success`
- `lesson_type`: beginner letter-sound recognition micro-lesson
- `source_lesson_ids`: `[]`
- `entry_condition`: recommended after `V2-A1-01`

## Objective

- `objective_id`: `recognize_recall_bml_isolated`
- `summary`: recognize and recall the isolated Arabic letters `ب`, `م`, and `ل` with their starter sound links
- `observable evidence`:
  - selects `ب`, `م`, and `ل` from sound cues
  - maps `ب`, `م`, and `ل` back to sound cues from sight
  - retrieves at least one target again after the support strip is removed
  - produces one target sound aloud after guided input
- `mastery threshold`: `0.80`

## Content items

### Content item A

- `item_id`: `goal_three_letters`
- `kind`: `goal`
- `title`: Lesson goal
- `body`: Learn three real Arabic letters well enough to recognize them, hear them, and bring at least one back from memory.
- `objective_ids`: `['recognize_recall_bml_isolated']`

### Content item B

- `item_id`: `input_ba_letter`
- `kind`: `input`
- `title`: First target
- `body`: Meet `ب` in isolated form. Keep one cue in mind: the dot below helps you spot it.
- `arabic_text`: `ب`
- `audio_query_text`: `ب`
- `transliteration`: `b`
- `meaning`: `starter script target`
- `objective_ids`: `['recognize_recall_bml_isolated']`

### Content item C

- `item_id`: `input_mim_letter`
- `kind`: `input`
- `title`: Second target
- `body`: Meet `م` in isolated form. Keep the rounded body shape in mind.
- `arabic_text`: `م`
- `audio_query_text`: `م`
- `transliteration`: `m`
- `meaning`: `starter script target`
- `objective_ids`: `['recognize_recall_bml_isolated']`

### Content item D

- `item_id`: `input_lam_letter`
- `kind`: `input`
- `title`: Third target
- `body`: Meet `ل` in isolated form. Notice the tall upright line.
- `arabic_text`: `ل`
- `audio_query_text`: `ل`
- `transliteration`: `l`
- `meaning`: `starter script target`
- `objective_ids`: `['recognize_recall_bml_isolated']`

### Content item E

- `item_id`: `contrast_summary_bml`
- `kind`: `contrast`
- `title`: See them side by side
- `body`: Compare the three targets together once before practice begins. You only need to tell these three apart.
- `arabic_text`: `ب / م / ل`
- `objective_ids`: `['recognize_recall_bml_isolated']`

### Content item F

- `item_id`: `support_note_script_not_vocab`
- `kind`: `explanation`
- `title`: Real script success
- `body`: These are real Arabic script targets. In this lesson, you are not learning words yet. You are learning how to recognize and recall small pieces of the script itself.
- `objective_ids`: `['recognize_recall_bml_isolated']`

## Practice items

### Practice item 1

- `item_id`: `hear_b_pick_ba`
- `type`: `listenTap`
- `prompt`: Hear the sound, then tap `ب`.
- `arabic_text`: `ب`
- `item_ref_id`: `ب`
- `review_object_type`: `letterSound`
- `review_action_type`: `listen`
- `objective_ids`: `['recognize_recall_bml_isolated']`
- `why_this_is_here`: establishes the first sound-to-shape link

### Practice item 2

- `item_id`: `hear_m_pick_mim`
- `type`: `listenTap`
- `prompt`: Hear the sound, then tap `م`.
- `arabic_text`: `م`
- `item_ref_id`: `م`
- `review_object_type`: `letterSound`
- `review_action_type`: `listen`
- `objective_ids`: `['recognize_recall_bml_isolated']`
- `why_this_is_here`: establishes the second sound-to-shape link

### Practice item 3

- `item_id`: `hear_l_pick_lam`
- `type`: `listenTap`
- `prompt`: Hear the sound, then tap `ل`.
- `arabic_text`: `ل`
- `item_ref_id`: `ل`
- `review_object_type`: `letterSound`
- `review_action_type`: `listen`
- `objective_ids`: `['recognize_recall_bml_isolated']`
- `why_this_is_here`: establishes the third sound-to-shape link

### Practice item 4

- `item_id`: `see_b_pick_sound`
- `type`: `comprehensionCheck`
- `prompt`: What sound anchor matches `ب`?
- `arabic_text`: `ب`
- `options`:
  - `b`
  - `m`
  - `l`
- `correct_answer`: `b`
- `item_ref_id`: `ب`
- `review_object_type`: `letterSound`
- `review_action_type`: `read`
- `objective_ids`: `['recognize_recall_bml_isolated']`
- `why_this_is_here`: checks the reverse link from shape to sound

### Practice item 5

- `item_id`: `see_m_pick_sound`
- `type`: `comprehensionCheck`
- `prompt`: What sound anchor matches `م`?
- `arabic_text`: `م`
- `options`:
  - `b`
  - `m`
  - `l`
- `correct_answer`: `m`
- `item_ref_id`: `م`
- `review_object_type`: `letterSound`
- `review_action_type`: `read`
- `objective_ids`: `['recognize_recall_bml_isolated']`
- `why_this_is_here`: checks that the learner can read the second target back into sound

### Practice item 6

- `item_id`: `see_l_pick_sound`
- `type`: `comprehensionCheck`
- `prompt`: What sound anchor matches `ل`?
- `arabic_text`: `ل`
- `options`:
  - `b`
  - `m`
  - `l`
- `correct_answer`: `l`
- `item_ref_id`: `ل`
- `review_object_type`: `letterSound`
- `review_action_type`: `read`
- `objective_ids`: `['recognize_recall_bml_isolated']`
- `why_this_is_here`: completes the bidirectional check across all three targets

### Practice item 7

- `item_id`: `recall_sound_to_shape_m`
- `type`: `recallPrompt`
- `prompt`: The summary strip is gone. Which Arabic letter says `/m/`?
- `expected_answer`: `م`
- `item_ref_id`: `م`
- `review_object_type`: `letterSound`
- `review_action_type`: `read`
- `objective_ids`: `['recognize_recall_bml_isolated']`
- `why_this_is_here`: this is the main delayed recall-bearing retrieval from sound to shape
- `runtime_fallback_if_needed`: delayed shuffled three-card retrieval if direct Arabic entry is not available

### Practice item 8

- `item_id`: `recall_sound_of_lam`
- `type`: `recallPrompt`
- `prompt`: Look at `ل`. Recall its sound without the earlier support strip.
- `arabic_text`: `ل`
- `expected_answer`: `l`
- `item_ref_id`: `ل`
- `review_object_type`: `letterSound`
- `review_action_type`: `repeat`
- `objective_ids`: `['recognize_recall_bml_isolated']`
- `why_this_is_here`: checks that at least one target can be brought back from sight to sound after support is removed
- `runtime_fallback_if_needed`: one-letter Latin sound anchor if speech capture is not used here

### Practice item 9

- `item_id`: `say_b_sound_once`
- `type`: `speakResponse`
- `prompt`: See `ب`, then say its sound once.
- `arabic_text`: `ب`
- `expected_answer`: `b`
- `item_ref_id`: `ب`
- `review_object_type`: `letterSound`
- `review_action_type`: `repeat`
- `objective_ids`: `['recognize_recall_bml_isolated']`
- `why_this_is_here`: gives the learner one visible output moment without overloading the lesson

## Notes on scope

- `ب`, `م`, and `ل` are formal script targets in this lesson.
- They are not treated as vocabulary words with meanings.
- The lesson goal is first script-sound ownership, not word reading or connected-form reading.

# 4. Completion contract

## completion_rule

- `required_practice_item_ids`:
  - `hear_b_pick_ba`
  - `hear_m_pick_mim`
  - `hear_l_pick_lam`
  - `see_b_pick_sound`
  - `see_m_pick_sound`
  - `see_l_pick_sound`
  - `recall_sound_to_shape_m`
- `required_objective_ids`:
  - `recognize_recall_bml_isolated`
- `minimum_practice_count`: `7`
- `pass_threshold`: `0.80`

## completion_return

- `mastery_status`
  - `completed`: learner recognizes all three starter links and succeeds on at least one delayed recall-bearing retrieval
  - `core_completed`: learner finishes the lesson path but one target remains weak or the delayed recall-bearing retrieval fails
  - `in_progress`: learner exits before all three target letters are attempted
- `learning_evidence`
  - maps `/b/` to `ب`
  - maps `/m/` to `م`
  - maps `/l/` to `ل`
  - maps `ب`, `م`, and `ل` back to their sound anchors from sight
  - retrieves at least one target again after the support strip is removed
  - produces one target sound aloud after guided exposure
- `review_seed_candidates`
  - immediate weak review for any missed letter-sound link
  - immediate confusion-pair review if two targets are repeatedly mixed
  - delayed stability review seeds for `ب`, `م`, and `ل` after a clean pass
- `next_home_action`
  - if `completed`: start Lesson 3
  - if `core_completed`: route to a short review-first step on the weak letter or pair
  - if `in_progress`: keep Lesson 2 as the current home recommendation

## anti-fake-mastery rule

- The lesson cannot be marked as mastered by tapping through the input cards.
- Clean completion requires at least one delayed recall-bearing step after the summary strip is removed.
- One lucky recognition success is not enough because all three starter links must be demonstrated.

# 5. Review seed logic

## Seed A: weak single-letter sound seed

- `rule_id`: `rv_bml_weak_single`
- `seed_kind`: `weakPoint`
- `review_object_type`: `letterSound`
- `review_action_type`: `listen`
- `source_item_ref_id`: dynamic single target: `ب`, `م`, or `ل`
- `create_when`: the learner misses an individual letter-sound link
- `due_after`: `0h`
- `purpose`: repair the weak starter link immediately

## Seed B: confusion pair seed

- `rule_id`: `rv_bml_confusion_pair`
- `seed_kind`: `confusionPair`
- `review_object_type`: `confusionPair`
- `review_action_type`: `distinguish`
- `source_item_ref_id`: dynamic pair such as `ب|م`, `ب|ل`, or `م|ل`
- `create_when`: the same pair is confused more than once inside the lesson
- `due_after`: `0h`
- `purpose`: fix repeated visual or sound confusion at the pair level

## Seed C: stable starter-letter seed

- `rule_id`: `rv_bml_stable_single`
- `seed_kind`: `newVocabulary`
- `review_object_type`: `letterSound`
- `review_action_type`: `read`
- `source_item_ref_id`: dynamic single target: `ب`, `م`, or `ل`
- `create_when`: the lesson is completed cleanly
- `due_after`: `18h`
- `purpose`: bring the learner back to the newly learned script-sound link before it fades

# 6. Home progression result

- `if completed`:
  - `recommended_action_type`: `startLesson`
  - `reason`: the learner now owns a tiny real set of Arabic letters and is ready to see how one known letter changes shape in connected writing
  - `suggested_next_lesson_id`: `V2-A1-03`
- `if core_completed`:
  - `recommended_action_type`: `startReview`
  - `reason`: first script success has started, but one target still needs reinforcement before connected-form variation is introduced
  - `home_card_copy`: Review the weak starter letter once before continuing
- `if in_progress`:
  - `recommended_action_type`: `continueLesson`
  - `reason`: the first real script set is still in progress

# 7. Self-check

- `Exactly one core objective`: yes. The lesson only teaches one thing: recognize and recall the isolated starter set `ب / م / ل` with their sound links.
- `Low cognitive load`: yes. Three isolated letters only, no words, no meanings, no connected forms.
- `Input -> Recognition -> Recall -> Output -> Completion`: yes, in that order.
- `At least one real recall-bearing step`: yes. `recall_sound_to_shape_m` and `recall_sound_of_lam` both remove the support strip and require retrieval.
- `No unnecessary arrangeResponse`: yes. This lesson does not teach phrase or sentence structure.
- `speakResponse only after enough guided input`: yes. The single output step comes only after all guided recognition and delayed recall work.
- `Completion returns required fields`: yes. `mastery_status`, `learning_evidence`, `review_seed_candidates`, and `next_home_action` are defined.
- `Weak items eligible for review`: yes. Any weak single letter or repeated pair confusion creates immediate review seeds.
- `Not passable mainly by guessing`: yes. All three targets must be demonstrated, and the lesson also requires delayed recall-bearing evidence.
- `Arabic-specific consistency`: yes. The lesson uses real Arabic letters, keeps scope narrow, and treats them as formal script targets rather than fake vocabulary items.
