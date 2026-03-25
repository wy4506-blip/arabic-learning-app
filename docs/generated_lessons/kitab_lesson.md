# 1. Lesson design summary

- `lesson_id`: `V2-U0-WORD-KITAB-01`
- `title`: First Word Link: `كتاب`
- `target learner`: absolute beginner with no prior Arabic vocabulary
- `core objective`: recognize and recall the Arabic word `كتاب` as "book"
- `can-do statement`: After this lesson, the learner can see or hear `كتاب` and know it means "book", then recall `كتاب` again from the meaning cue alone.
- `target knowledge`:
  - Arabic target: `كتاب`
  - Diacritics-aware form for input/audio alignment: `كِتَاب`
  - Meaning: `book`
  - Pronunciation notes: `kitāb`
  - Morphology notes: singular noun
- `lesson scope`: one concrete noun only; no plural, no sentence frame, no extra grammar target
- `estimated time`: 5 to 6 minutes
- `why this lesson should exist`: it creates one clean meaning link between a real object word and its Arabic form, which is the smallest useful beginner vocabulary win

# 2. Stage-by-stage design

## Input

- Show `كِتَاب / كتاب` with audio and the meaning `book`.
- Keep the explanation minimal: "This is one object word. You only need to connect the Arabic form to the meaning."
- Do not introduce plural forms or sentence usage yet.

## Recognition

- Recognition step 1: learner sees the meaning `book` and picks `كتاب` from three Arabic options.
- Recognition step 2: learner hears `كِتَاب` and taps `كتاب`.
- These two steps reduce pure guessing by checking both visual and audio recognition.

## Recall

- The learner sees only the meaning cue `book`.
- The learner must recall the Arabic word from memory and type or say `كتاب`.
- This is the first real recall-bearing step and is required for completion.

## Output

- After recall, the learner does one short `speakResponse` step: see `book`, then say `كتاب` aloud once.
- This is reinforcement, not a separate lesson objective.

## Completion

- Completion tells the learner whether the word link is stable, weak, or still incomplete.
- Weak performance must create a review candidate for `كتاب`.

# 3. Structured lesson content

## Metadata

- `phase_id`: `phase_u0_first_words`
- `group_id`: `u0_first_objects`
- `lesson_type`: beginner vocabulary recognition micro-lesson
- `source_lesson_ids`: `[]`
- `entry_condition`: no prerequisite lesson required

## Objective

- `objective_id`: `recognize_recall_kitab`
- `summary`: recognize and recall `كتاب` as `book`
- `observable evidence`:
  - selects `كتاب` when prompted with `book`
  - taps `كتاب` after hearing `كِتَاب`
  - recalls `كتاب` from the meaning cue alone
- `mastery threshold`: `0.80`

## Content items

### Content item A

- `item_id`: `goal_kitab`
- `kind`: `goal`
- `title`: Lesson goal
- `body`: Learn one useful object word: connect `كتاب` directly to `book`, then bring it back from memory once.
- `objective_ids`: `['recognize_recall_kitab']`

### Content item B

- `item_id`: `input_kitab_word`
- `kind`: `input`
- `title`: See and hear the word
- `body`: Look at the Arabic word, hear it once, and connect it to the meaning `book`.
- `arabic_text`: `كِتَاب`
- `display_text_note`: learner-facing display may use `كتاب`
- `meaning`: `book`
- `transliteration`: `kitāb`
- `audio_query_text`: `كِتَاب`
- `objective_ids`: `['recognize_recall_kitab']`

### Content item C

- `item_id`: `minimal_note_kitab`
- `kind`: `explanation`
- `title`: Small note
- `body`: `كتاب` is a singular noun. In this lesson, just keep one link in mind: `كتاب = book`.
- `objective_ids`: `['recognize_recall_kitab']`

## Practice items

### Practice item 1

- `item_id`: `pick_kitab_from_meaning`
- `type`: `comprehensionCheck`
- `prompt`: Which Arabic word means `book`?
- `shown_meaning`: `book`
- `options`:
  - `كتاب`
  - `قلم`
  - `باب`
- `correct_answer`: `كتاب`
- `item_ref_id`: `كتاب`
- `review_object_type`: `wordReading`
- `review_action_type`: `read`
- `objective_ids`: `['recognize_recall_kitab']`
- `why_this_is_here`: checks visual recognition of the target form

### Practice item 2

- `item_id`: `hear_kitab_and_tap`
- `type`: `listenTap`
- `prompt`: Hear the word, then tap `كتاب`.
- `audio_query_text`: `كِتَاب`
- `options`:
  - `كتاب`
  - `قلم`
  - `باب`
- `correct_answer`: `كتاب`
- `item_ref_id`: `كتاب`
- `review_object_type`: `wordReading`
- `review_action_type`: `listen`
- `objective_ids`: `['recognize_recall_kitab']`
- `why_this_is_here`: checks audio-to-word recognition

### Practice item 3

- `item_id`: `recall_kitab_from_book`
- `type`: `recallPrompt`
- `prompt`: You see `book`. Recall the Arabic word from memory.
- `meaning_only_cue`: `book`
- `expected_answer`: `كتاب`
- `diacritics_accepted_answer`: `كِتَاب`
- `item_ref_id`: `كتاب`
- `review_object_type`: `wordReading`
- `review_action_type`: `read`
- `objective_ids`: `['recognize_recall_kitab']`
- `why_this_is_here`: this is the required recall-bearing step

### Practice item 4

- `item_id`: `say_kitab_once`
- `type`: `speakResponse`
- `prompt`: See `book`, then say `كتاب` aloud once.
- `meaning_only_cue`: `book`
- `expected_answer`: `كتاب`
- `item_ref_id`: `كتاب`
- `review_object_type`: `wordReading`
- `review_action_type`: `repeat`
- `objective_ids`: `['recognize_recall_kitab']`
- `why_this_is_here`: reinforces retrieval after recall without turning the lesson into a pronunciation lesson

## Notes on distractors

- `قلم` and `باب` are decoys only.
- They are not lesson targets.
- They must not produce mastery or review credit in this lesson.

# 4. Completion contract

## completion_rule

- `required_practice_item_ids`:
  - `pick_kitab_from_meaning`
  - `hear_kitab_and_tap`
  - `recall_kitab_from_book`
- `required_objective_ids`:
  - `recognize_recall_kitab`
- `minimum_practice_count`: `3`
- `pass_threshold`: `0.80`

## completion_return

- `mastery_status`
  - `completed`: required recognition steps pass and the recall step passes
  - `core_completed`: learner finishes the path but recall is weak or score is below threshold
  - `in_progress`: learner exits before the required recall evidence is collected
- `learning_evidence`
  - selected `كتاب` from meaning cue
  - identified `كتاب` from audio cue
  - recalled `كتاب` from `book` without the Arabic prompt shown
  - optionally repeated `كتاب` aloud once after recall
- `review_seed_candidates`
  - weak or failed target-word review for `كتاب`
  - future-due vocabulary review for `كتاب` after a clean pass
- `next_home_action`
  - if `completed`: continue to the next single-word beginner lesson
  - if `core_completed`: route to a short review-first step for `كتاب`
  - if `in_progress`: keep this lesson as the current home recommendation

## anti-fake-mastery rule

- The lesson cannot be considered mastered by page traversal alone.
- A clean completion requires the recall-bearing item, not just recognition clicks.

# 5. Review seed logic

## Seed A: new vocabulary seed

- `rule_id`: `rv_kitab_new_word`
- `seed_kind`: `newVocabulary`
- `review_object_type`: `wordReading`
- `review_action_type`: `read`
- `source_item_ref_id`: `كتاب`
- `create_when`: lesson is completed cleanly
- `due_after`: `18h`
- `purpose`: bring the learner back to the word before it fades

## Seed B: weak word seed

- `rule_id`: `rv_kitab_weak_word`
- `seed_kind`: `weakPoint`
- `review_object_type`: `wordReading`
- `review_action_type`: `read`
- `source_item_ref_id`: `كتاب`
- `create_when`: recall step fails, or required evidence stays below threshold
- `due_after`: `0h`
- `purpose`: make weak recall eligible for immediate review

## Seed C: weak audio link seed

- `rule_id`: `rv_kitab_audio_link`
- `seed_kind`: `weakPoint`
- `review_object_type`: `wordReading`
- `review_action_type`: `listen`
- `source_item_ref_id`: `كتاب`
- `create_when`: the learner misses the audio recognition step
- `due_after`: `0h`
- `purpose`: repair the sound-to-word link, not just the visual form

# 6. Home progression result

- `if completed`:
  - `recommended_action_type`: `startLesson`
  - `reason`: the learner now has one stable beginner noun and can take the next small vocabulary lesson
  - `suggested_next_lesson_shape`: another single concrete noun with the same low-load loop
- `if core_completed`:
  - `recommended_action_type`: `startReview`
  - `reason`: recognition exists, but recall of `كتاب` is not stable enough yet
  - `home_card_copy`: Review `كتاب` once before moving on
- `if in_progress`:
  - `recommended_action_type`: `continueLesson`
  - `reason`: the recall-bearing evidence is still missing

# 7. Self-check

- `Exactly one core objective`: yes. The whole lesson is only about recognizing and recalling `كتاب`.
- `Low cognitive load`: yes. One noun, one meaning, one light morphology note.
- `Input -> Recognition -> Recall -> Output -> Completion`: yes, in that exact order.
- `At least one real recall-bearing step`: yes. `recall_kitab_from_book` is required.
- `No unnecessary arrangeResponse`: yes. No phrase or sentence structure is being taught.
- `speakResponse only after enough guided input`: yes. It comes after input, recognition, and recall.
- `Completion returns required fields`: yes. `mastery_status`, `learning_evidence`, `review_seed_candidates`, and `next_home_action` are all defined.
- `Weak items eligible for review`: yes. Failed recall and weak audio recognition both create weak review seeds.
- `Not passable mainly by guessing`: yes. Recognition is checked twice in different ways, and completion still requires recall.
- `Arabic-specific consistency`: yes. The lesson keeps `كتاب` as the target, supports the diacritics-aware form `كِتَاب`, and stays compatible with undiacritized display.
