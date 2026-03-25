# 1. Lesson design summary

- `lesson_id`: `V2-A1-04`
- `title`: Short Vowels Make Reading Possible
- `target learner`: absolute beginner who knows the starter letter `ب` and has seen one stable letter family across form variation
- `core objective`: use `fatha`, `kasra`, and `damma` as beginner supports to distinguish and read tiny diacritized Arabic forms
- `can-do statement`: After this lesson, the learner can tell `بَ`, `بِ`, and `بُ` apart, match them to their short sounds, and retrieve at least one supported form again after the comparison strip is gone.
- `target knowledge`:
  - Arabic target: `بَ / بِ / بُ`
  - Meaning: short-vowel-supported reading forms, not vocabulary words
  - Pronunciation notes: `/ba/`, `/bi/`, and `/bu/`
  - Morphology notes: not applicable; this lesson teaches vowel-supported decoding, not word meaning or grammar
- `lesson scope`: one known base letter with three short-vowel supports only
- `estimated time`: 6 to 7 minutes
- `why this lesson should exist`: it closes Stage A with the learner's first believable reading-support success and makes Arabic feel readable instead of merely identifiable

# 2. Stage-by-stage design

## Input

- Start from the already known base letter `ب`.
- Add `fatha`, `kasra`, and `damma` one at a time to produce `بَ`, `بِ`, and `بُ`.
- Pair each form with one short clean audio model.
- Explain only one idea: these marks help beginners hear and read the short sound.

## Recognition

- Recognition step 1: hear `/ba/`, `/bi/`, or `/bu/` and choose the matching form.
- Recognition step 2: see the diacritized form and choose the matching short sound anchor.
- Recognition alternates direction so the learner really links mark, sound, and visible form.
- Three-way choices prevent shallow guessing.

## Recall

- The comparison strip disappears.
- The learner hears one short sound again and must retrieve the matching diacritized form.
- A second supported form appears later, and the learner must recall its sound again without the earlier comparison strip.
- This creates real recall-bearing evidence for supported beginner reading.

## Output

- The learner does one short `speakResponse` by reading one supported form aloud once.
- The output stays tiny and fully supported so the lesson still feels successful.
- The output is not a pronunciation lesson; it is a confidence-building reading action.

## Completion

- Completion should reflect supported short-vowel decoding established, not vocabulary learned.
- A clean pass requires all three supported forms to be distinguished plus at least one unsupported recall-bearing retrieval.
- Weak short-vowel distinctions must route into immediate review.

# 3. Structured lesson content

## Metadata

- `phase_id`: `phase_a_script_entry`
- `group_id`: `a1_short_vowel_support`
- `lesson_type`: beginner diacritic-supported reading micro-lesson
- `source_lesson_ids`: `[]`
- `entry_condition`: recommended after `V2-A1-03`

## Objective

- `objective_id`: `distinguish_read_ba_bi_bu`
- `summary`: distinguish and read `بَ`, `بِ`, and `بُ` with beginner vowel support
- `observable evidence`:
  - selects `بَ`, `بِ`, and `بُ` from sound cues
  - maps `بَ`, `بِ`, and `بُ` back to sound cues from sight
  - retrieves at least one supported form again after the comparison strip disappears
  - reads one supported form aloud once
- `mastery threshold`: `0.80`

## Content items

### Content item A

- `item_id`: `goal_short_vowels`
- `kind`: `goal`
- `title`: Lesson goal
- `body`: Learn the first support marks that make tiny Arabic forms easier to hear and read.
- `objective_ids`: `['distinguish_read_ba_bi_bu']`

### Content item B

- `item_id`: `input_ba_fatha`
- `kind`: `input`
- `title`: First supported form
- `body`: `بَ` uses a short vowel support that helps you hear and read `/ba/`.
- `arabic_text`: `بَ`
- `audio_query_text`: `بَ`
- `transliteration`: `ba`
- `meaning`: `supported reading target`
- `objective_ids`: `['distinguish_read_ba_bi_bu']`

### Content item C

- `item_id`: `input_ba_kasra`
- `kind`: `input`
- `title`: Second supported form
- `body`: `بِ` uses a different support mark that helps you hear and read `/bi/`.
- `arabic_text`: `بِ`
- `audio_query_text`: `بِ`
- `transliteration`: `bi`
- `meaning`: `supported reading target`
- `objective_ids`: `['distinguish_read_ba_bi_bu']`

### Content item D

- `item_id`: `input_ba_damma`
- `kind`: `input`
- `title`: Third supported form
- `body`: `بُ` uses a third support mark that helps you hear and read `/bu/`.
- `arabic_text`: `بُ`
- `audio_query_text`: `بُ`
- `transliteration`: `bu`
- `meaning`: `supported reading target`
- `objective_ids`: `['distinguish_read_ba_bi_bu']`

### Content item E

- `item_id`: `support_mark_note`
- `kind`: `explanation`
- `title`: What these marks do
- `body`: These support marks are here to help beginners connect visible form and short sound. You are not learning vocabulary here. You are learning how supported reading works.
- `objective_ids`: `['distinguish_read_ba_bi_bu']`

### Content item F

- `item_id`: `contrast_ba_bi_bu_strip`
- `kind`: `contrast`
- `title`: Compare the three forms
- `body`: Compare the three supported forms side by side once before you practice.
- `arabic_text`: `بَ / بِ / بُ`
- `objective_ids`: `['distinguish_read_ba_bi_bu']`

## Practice items

### Practice item 1

- `item_id`: `hear_ba_pick_ba_fatha`
- `type`: `listenTap`
- `prompt`: Hear the sound, then tap `بَ`.
- `arabic_text`: `بَ`
- `item_ref_id`: `ba_short`
- `review_object_type`: `symbolReading`
- `review_action_type`: `listen`
- `objective_ids`: `['distinguish_read_ba_bi_bu']`
- `why_this_is_here`: establishes the first sound-to-form link with vowel support

### Practice item 2

- `item_id`: `hear_bi_pick_ba_kasra`
- `type`: `listenTap`
- `prompt`: Hear the sound, then tap `بِ`.
- `arabic_text`: `بِ`
- `item_ref_id`: `bi_short`
- `review_object_type`: `symbolReading`
- `review_action_type`: `listen`
- `objective_ids`: `['distinguish_read_ba_bi_bu']`
- `why_this_is_here`: establishes the second sound-to-form link with vowel support

### Practice item 3

- `item_id`: `hear_bu_pick_ba_damma`
- `type`: `listenTap`
- `prompt`: Hear the sound, then tap `بُ`.
- `arabic_text`: `بُ`
- `item_ref_id`: `bu_short`
- `review_object_type`: `symbolReading`
- `review_action_type`: `listen`
- `objective_ids`: `['distinguish_read_ba_bi_bu']`
- `why_this_is_here`: establishes the third sound-to-form link with vowel support

### Practice item 4

- `item_id`: `see_ba_pick_sound`
- `type`: `comprehensionCheck`
- `prompt`: What short sound matches `بَ`?
- `arabic_text`: `بَ`
- `options`:
  - `ba`
  - `bi`
  - `bu`
- `correct_answer`: `ba`
- `item_ref_id`: `ba_short`
- `review_object_type`: `symbolReading`
- `review_action_type`: `read`
- `objective_ids`: `['distinguish_read_ba_bi_bu']`
- `why_this_is_here`: checks the reverse mapping from form to short sound

### Practice item 5

- `item_id`: `see_bi_pick_sound`
- `type`: `comprehensionCheck`
- `prompt`: What short sound matches `بِ`?
- `arabic_text`: `بِ`
- `options`:
  - `ba`
  - `bi`
  - `bu`
- `correct_answer`: `bi`
- `item_ref_id`: `bi_short`
- `review_object_type`: `symbolReading`
- `review_action_type`: `read`
- `objective_ids`: `['distinguish_read_ba_bi_bu']`
- `why_this_is_here`: checks that the learner can read the second supported form back into sound

### Practice item 6

- `item_id`: `see_bu_pick_sound`
- `type`: `comprehensionCheck`
- `prompt`: What short sound matches `بُ`?
- `arabic_text`: `بُ`
- `options`:
  - `ba`
  - `bi`
  - `bu`
- `correct_answer`: `bu`
- `item_ref_id`: `bu_short`
- `review_object_type`: `symbolReading`
- `review_action_type`: `read`
- `objective_ids`: `['distinguish_read_ba_bi_bu']`
- `why_this_is_here`: completes the reverse-link check across the set

### Practice item 7

- `item_id`: `recall_bi_form`
- `type`: `recallPrompt`
- `prompt`: The comparison strip is gone. Which form matches `/bi/`?
- `expected_answer`: `بِ`
- `item_ref_id`: `bi_short`
- `review_object_type`: `symbolReading`
- `review_action_type`: `read`
- `objective_ids`: `['distinguish_read_ba_bi_bu']`
- `why_this_is_here`: this is the main unsupported recall-bearing retrieval from sound to form
- `runtime_fallback_if_needed`: delayed three-card retrieval from `بَ / بِ / بُ`

### Practice item 8

- `item_id`: `recall_sound_of_bu`
- `type`: `recallPrompt`
- `prompt`: Look at `بُ`. Recall its short sound without the comparison strip.
- `arabic_text`: `بُ`
- `expected_answer`: `bu`
- `item_ref_id`: `bu_short`
- `review_object_type`: `symbolReading`
- `review_action_type`: `repeat`
- `objective_ids`: `['distinguish_read_ba_bi_bu']`
- `why_this_is_here`: confirms the learner can retrieve sound from the supported form after help is removed

### Practice item 9

- `item_id`: `read_one_supported_form`
- `type`: `speakResponse`
- `prompt`: See `بَ`, then read it aloud once.
- `arabic_text`: `بَ`
- `expected_answer`: `ba`
- `item_ref_id`: `ba_short`
- `review_object_type`: `symbolReading`
- `review_action_type`: `repeat`
- `objective_ids`: `['distinguish_read_ba_bi_bu']`
- `why_this_is_here`: gives the learner one visible supported-reading success at the end of Stage A

## Notes on scope

- `بَ`, `بِ`, and `بُ` are supported reading targets, not vocabulary words.
- The lesson goal is not word meaning.
- The lesson goal is first confidence with short-vowel-supported decoding.

# 4. Completion contract

## completion_rule

- `required_practice_item_ids`:
  - `hear_ba_pick_ba_fatha`
  - `hear_bi_pick_ba_kasra`
  - `hear_bu_pick_ba_damma`
  - `see_ba_pick_sound`
  - `see_bi_pick_sound`
  - `see_bu_pick_sound`
  - `recall_bi_form`
- `required_objective_ids`:
  - `distinguish_read_ba_bi_bu`
- `minimum_practice_count`: `7`
- `pass_threshold`: `0.80`

## completion_return

- `mastery_status`
  - `completed`: learner distinguishes all three supported forms and passes at least one unsupported recall-bearing retrieval
  - `core_completed`: learner finishes the lesson path but one support distinction remains weak or the recall-bearing retrieval is unstable
  - `in_progress`: learner exits before all three support forms are attempted
- `learning_evidence`
  - maps `/ba/` to `بَ`
  - maps `/bi/` to `بِ`
  - maps `/bu/` to `بُ`
  - maps `بَ`, `بِ`, and `بُ` back to their short sounds from sight
  - retrieves at least one supported form again after the comparison strip disappears
  - reads one supported form aloud once
- `review_seed_candidates`
  - immediate weak review for any missed short-vowel distinction
  - immediate confusion-pair review if two supported forms are repeatedly mixed
  - delayed stability review for supported forms after a clean pass
- `next_home_action`
  - if `completed`: start Lesson 5
  - if `core_completed`: route to a short review-first refresher on weak short-vowel distinctions
  - if `in_progress`: keep Lesson 4 as the current home recommendation

## anti-fake-mastery rule

- The lesson cannot be marked as mastered by seeing the contrast strip alone.
- Clean completion requires delayed recall after the comparison strip disappears.
- This lesson should be recorded as supported reading confidence established, not vocabulary learned.

# 5. Review seed logic

## Seed A: weak short-vowel seed

- `rule_id`: `rv_short_vowel_weak_single`
- `seed_kind`: `weakPoint`
- `review_object_type`: `symbolReading`
- `review_action_type`: `listen`
- `source_item_ref_id`: dynamic single target: `ba_short`, `bi_short`, or `bu_short`
- `create_when`: the learner misses an individual supported form
- `due_after`: `0h`
- `purpose`: repair the weak short-vowel distinction immediately

## Seed B: short-vowel confusion pair seed

- `rule_id`: `rv_short_vowel_pair`
- `seed_kind`: `confusionPair`
- `review_object_type`: `confusionPair`
- `review_action_type`: `distinguish`
- `source_item_ref_id`: dynamic pair such as `ba_short|bi_short`, `ba_short|bu_short`, or `bi_short|bu_short`
- `create_when`: the same pair is confused more than once
- `due_after`: `0h`
- `purpose`: fix repeated vowel-support confusion at the pair level

## Seed C: stable supported-reading seed

- `rule_id`: `rv_short_vowel_stable_single`
- `seed_kind`: `newVocabulary`
- `review_object_type`: `symbolReading`
- `review_action_type`: `read`
- `source_item_ref_id`: dynamic single target: `ba_short`, `bi_short`, or `bu_short`
- `create_when`: the lesson is completed cleanly
- `due_after`: `18h`
- `purpose`: revisit supported short-vowel reading before confidence fades

# 6. Home progression result

- `if completed`:
  - `recommended_action_type`: `startLesson`
  - `reason`: Stage A foundation is now established, so the learner can move into the first real word lesson in Stage B
  - `suggested_next_lesson_id`: `V2-B1-05`
- `if core_completed`:
  - `recommended_action_type`: `startReview`
  - `reason`: the learner has entered supported reading, but one short-vowel distinction needs reinforcement before real word learning begins
  - `home_card_copy`: Review the weak supported-reading form once before continuing
- `if in_progress`:
  - `recommended_action_type`: `continueLesson`
  - `reason`: Stage A reading-support evidence is still incomplete

# 7. Self-check

- `Exactly one core objective`: yes. The lesson only teaches one thing: distinguish and read `بَ / بِ / بُ` with beginner short-vowel support.
- `Low cognitive load`: yes. One base letter and three short-vowel forms only.
- `Input -> Recognition -> Recall -> Output -> Completion`: yes, in that order.
- `At least one real recall-bearing step`: yes. `recall_bi_form` and `recall_sound_of_bu` both require retrieval after the comparison strip is gone.
- `No unnecessary arrangeResponse`: yes. This lesson does not teach phrase or sentence structure.
- `speakResponse only after enough guided input`: yes. The one read-aloud step comes after recognition and recall work.
- `Completion returns required fields`: yes. `mastery_status`, `learning_evidence`, `review_seed_candidates`, and `next_home_action` are defined.
- `Weak items eligible for review`: yes. Weak single forms and repeated short-vowel confusions both create review seeds.
- `Not passable mainly by guessing`: yes. All three forms must be distinguished, and delayed recall is required.
- `Arabic-specific consistency`: yes. The lesson keeps diacritics visible, aligns sound and text carefully, and treats these forms as supported reading targets rather than vocabulary outcomes.
