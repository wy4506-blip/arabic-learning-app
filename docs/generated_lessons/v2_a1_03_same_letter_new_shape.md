# 1. Lesson design summary

- `lesson_id`: `V2-A1-03`
- `title`: Same Letter, New Shape
- `target learner`: absolute beginner who already knows the isolated starter letter `ب`
- `core objective`: recognize that `ب` remains the same letter across isolated and connected forms
- `can-do statement`: After this lesson, the learner can look at `ب`, `بـ`, `ـبـ`, and `ـب` and understand that they all belong to the same letter family.
- `target knowledge`:
  - Arabic target: `ب / بـ / ـبـ / ـب`
  - Meaning: one script family, not vocabulary
  - Pronunciation notes: the same `b` sound anchor carries across the family, but the lesson focus is visual identity, not pronunciation practice
  - Morphology notes: not applicable; this lesson teaches script variation, not word structure
- `lesson scope`: one known letter family only, with one or two familiar decoy letters for contrast
- `estimated time`: 5 to 6 minutes
- `why this lesson should exist`: it protects learner confidence at the exact point many beginners start feeling that Arabic changes shape too much to trust

# 2. Stage-by-stage design

## Input

- Start from the already known isolated `ب`.
- Reveal `بـ`, `ـبـ`, and `ـب` one by one, always tying them back to the same home form.
- Highlight one stable cue: the dot below and the shared base family shape.
- Keep the lesson centered on one family only so the learner does not feel buried under joining rules.

## Recognition

- Recognition step 1: choose which connected form is still `ب` from a mixed set.
- Recognition step 2: recognize `ب` inside a short connected visual string.
- Recognition step 3: distinguish `ب` family forms from one or two familiar decoy families.
- The recognition path moves from clean contrast to slightly more embedded contrast.

## Recall

- The family strip disappears.
- One connected `ب` form appears alone, and the learner must recall its home identity as `ب`.
- A second connected form appears later, and the learner must again recall that it belongs to the same family.
- This is real recall-bearing evidence because the learner must retrieve identity despite surface variation.

## Output

- The learner builds one full `ب` family row from isolated to final form.
- If a free ordering interaction is not available in the runtime, the fallback is choosing the one fully correct family row from several options.
- The output is structural, not spoken, because the lesson goal is family recognition across forms.

## Completion

- Completion should reflect connected-form identity established, not mere exposure to different shapes.
- A clean pass requires successful mixed recognition, at least one unsupported connected-form recall, and one full family-row output action.
- Weak family recognition must route to immediate review before new reading support is layered on top.

# 3. Structured lesson content

## Metadata

- `phase_id`: `phase_a_script_entry`
- `group_id`: `a1_form_awareness`
- `lesson_type`: beginner connected-form identity micro-lesson
- `source_lesson_ids`: `[]`
- `entry_condition`: recommended after `V2-A1-02`

## Objective

- `objective_id`: `recognize_ba_family_across_forms`
- `summary`: recognize that `ب` stays the same letter across isolated and connected forms
- `observable evidence`:
  - recognizes `ب` in isolated form
  - recognizes `بـ`, `ـبـ`, and `ـب` as the same family in mixed choices
  - retrieves the home identity `ب` when one connected form appears alone
  - builds one complete family row correctly
- `mastery threshold`: `0.80`

## Content items

### Content item A

- `item_id`: `goal_ba_family`
- `kind`: `goal`
- `title`: Lesson goal
- `body`: Learn one confidence-building rule about Arabic writing: a known letter can change shape and still remain the same letter.
- `objective_ids`: `['recognize_ba_family_across_forms']`

### Content item B

- `item_id`: `input_ba_isolated`
- `kind`: `input`
- `title`: Home form
- `body`: Start from the isolated form you already know.
- `arabic_text`: `ب`
- `audio_query_text`: `ب`
- `transliteration`: `b`
- `meaning`: `starter script family`
- `objective_ids`: `['recognize_ba_family_across_forms']`

### Content item C

- `item_id`: `input_ba_initial`
- `kind`: `input`
- `title`: One connected version
- `body`: This is still `ب`, now shown at the beginning of a connected string.
- `arabic_text`: `بـ`
- `objective_ids`: `['recognize_ba_family_across_forms']`

### Content item D

- `item_id`: `input_ba_medial`
- `kind`: `input`
- `title`: Another connected version
- `body`: This is still the same letter family in a middle position.
- `arabic_text`: `ـبـ`
- `objective_ids`: `['recognize_ba_family_across_forms']`

### Content item E

- `item_id`: `input_ba_final`
- `kind`: `input`
- `title`: Final connected version
- `body`: This is still `ب`, now shown at the end of a connected string.
- `arabic_text`: `ـب`
- `objective_ids`: `['recognize_ba_family_across_forms']`

### Content item F

- `item_id`: `family_invariant_note`
- `kind`: `explanation`
- `title`: What stays stable
- `body`: The surface shape changes, but the family cue stays stable. Keep your eye on the dot below and the shared body pattern.
- `objective_ids`: `['recognize_ba_family_across_forms']`

### Content item G

- `item_id`: `contrast_ba_with_known_decoys`
- `kind`: `contrast`
- `title`: Compare with known decoys
- `body`: Compare the `ب` family with familiar non-target letters only to make the family boundary clearer.
- `arabic_text`: `ب / م / ل`
- `objective_ids`: `['recognize_ba_family_across_forms']`

## Practice items

### Practice item 1

- `item_id`: `choose_initial_ba`
- `type`: `contrastChoice`
- `prompt`: Which connected form is still `ب` at the start?
- `options`:
  - `بـ`
  - `مـ`
  - `لـ`
- `correct_answer`: `بـ`
- `item_ref_id`: `initial_ba`
- `review_object_type`: `letterForm`
- `review_action_type`: `read`
- `objective_ids`: `['recognize_ba_family_across_forms']`
- `why_this_is_here`: first mixed recognition of the target family in connected form

### Practice item 2

- `item_id`: `choose_medial_ba`
- `type`: `contrastChoice`
- `prompt`: Which connected form is still `ب` in the middle?
- `options`:
  - `ـبـ`
  - `ـمـ`
  - `ـلـ`
- `correct_answer`: `ـبـ`
- `item_ref_id`: `medial_ba`
- `review_object_type`: `letterForm`
- `review_action_type`: `read`
- `objective_ids`: `['recognize_ba_family_across_forms']`
- `why_this_is_here`: extends family recognition to a second positional form

### Practice item 3

- `item_id`: `choose_final_ba`
- `type`: `contrastChoice`
- `prompt`: Which connected form is still `ب` at the end?
- `options`:
  - `ـب`
  - `ـم`
  - `ـل`
- `correct_answer`: `ـب`
- `item_ref_id`: `final_ba`
- `review_object_type`: `letterForm`
- `review_action_type`: `read`
- `objective_ids`: `['recognize_ba_family_across_forms']`
- `why_this_is_here`: completes basic positional recognition across the family

### Practice item 4

- `item_id`: `find_ba_inside_string`
- `type`: `comprehensionCheck`
- `prompt`: In this tiny connected sample, which part is the `ب` family member?
- `arabic_text`: `مـبـل`
- `options`:
  - `middle form`
  - `first form`
  - `last form`
- `correct_answer`: `middle form`
- `item_ref_id`: `ba_inside_string`
- `review_object_type`: `letterForm`
- `review_action_type`: `read`
- `objective_ids`: `['recognize_ba_family_across_forms']`
- `why_this_is_here`: helps the learner recognize the family when it is embedded rather than isolated
- `note`: the sample is a visual string, not a vocabulary target

### Practice item 5

- `item_id`: `recall_home_form_of_medial_ba`
- `type`: `recallPrompt`
- `prompt`: The family strip is gone. What is the home letter for `ـبـ`?
- `arabic_text`: `ـبـ`
- `expected_answer`: `ب`
- `item_ref_id`: `medial_ba`
- `review_object_type`: `letterForm`
- `review_action_type`: `read`
- `objective_ids`: `['recognize_ba_family_across_forms']`
- `why_this_is_here`: this is the main unsupported recall-bearing step

### Practice item 6

- `item_id`: `recall_home_form_of_final_ba`
- `type`: `recallPrompt`
- `prompt`: Look at `ـب`. Does it still belong to the same family as `ب`?
- `arabic_text`: `ـب`
- `expected_answer`: `yes, it is ب`
- `item_ref_id`: `final_ba`
- `review_object_type`: `letterForm`
- `review_action_type`: `read`
- `objective_ids`: `['recognize_ba_family_across_forms']`
- `why_this_is_here`: confirms the learner can repeat the family identity judgment without support

### Practice item 7

- `item_id`: `build_ba_family_row`
- `type`: `arrangeResponse`
- `prompt`: Build the full `ب` family row from isolated form to final connected form.
- `expected_answer`: `ب بـ ـبـ ـب`
- `item_ref_id`: `ba_family_connected`
- `review_object_type`: `letterForm`
- `review_action_type`: `read`
- `objective_ids`: `['recognize_ba_family_across_forms']`
- `why_this_is_here`: turns family identity into one visible structural output action
- `runtime_fallback_if_needed`: `comprehensionCheck` selecting the one fully correct family row

## Notes on scope

- `ب`, `بـ`, `ـبـ`, and `ـب` are script-family targets, not vocabulary.
- The short connected sample exists only to support visual recognition.
- The learner is not expected to know joining rules in general after this lesson.

# 4. Completion contract

## completion_rule

- `required_practice_item_ids`:
  - `choose_initial_ba`
  - `choose_medial_ba`
  - `choose_final_ba`
  - `recall_home_form_of_medial_ba`
  - `build_ba_family_row`
- `required_objective_ids`:
  - `recognize_ba_family_across_forms`
- `minimum_practice_count`: `5`
- `pass_threshold`: `0.80`

## completion_return

- `mastery_status`
  - `completed`: learner recognizes the `ب` family in mixed form and passes at least one unsupported connected-form recall before building the family row correctly
  - `core_completed`: learner finishes the lesson path but misses the unsupported connected-form recall or leaves one positional form weak
  - `in_progress`: learner exits before the unsupported recall step is attempted
- `learning_evidence`
  - recognizes `بـ`, `ـبـ`, and `ـب` as belonging to the same family as `ب`
  - identifies `ب` when it appears inside a tiny connected visual string
  - retrieves the home identity `ب` from a connected form after support is removed
  - builds one full family row correctly
- `review_seed_candidates`
  - immediate weak review for connected-form family confusion
  - immediate weak review for a specific positional form
  - immediate confusion-pair review if one decoy family is repeatedly mistaken for `ب`
  - delayed stability review for the `ب` family after a clean pass
- `next_home_action`
  - if `completed`: start Lesson 4
  - if `core_completed`: route to a short review-first step on the weak family form
  - if `in_progress`: keep Lesson 3 as the current home recommendation

## anti-fake-mastery rule

- The lesson cannot be marked as mastered by viewing the family strip alone.
- Guided recognition without unsupported family recall is not enough.
- Clean completion requires the learner to recover `ب` from a connected form after support is removed.

# 5. Review seed logic

## Seed A: weak family identity seed

- `rule_id`: `rv_ba_family_weak`
- `seed_kind`: `weakPoint`
- `review_object_type`: `letterForm`
- `review_action_type`: `read`
- `source_item_ref_id`: `ba_family_connected`
- `create_when`: the learner misses `recall_home_form_of_medial_ba` or `recall_home_form_of_final_ba`
- `due_after`: `0h`
- `purpose`: repair the core family identity immediately

## Seed B: weak positional-form seed

- `rule_id`: `rv_ba_form_position`
- `seed_kind`: `weakPoint`
- `review_object_type`: `letterForm`
- `review_action_type`: `read`
- `source_item_ref_id`: dynamic form such as `initial_ba`, `medial_ba`, or `final_ba`
- `create_when`: one positional form repeatedly fails
- `due_after`: `0h`
- `purpose`: repair one unstable connected-form position without reteaching the entire lesson

## Seed C: confusion pair seed

- `rule_id`: `rv_ba_family_confusion_pair`
- `seed_kind`: `confusionPair`
- `review_object_type`: `confusionPair`
- `review_action_type`: `distinguish`
- `source_item_ref_id`: dynamic pair such as `ب|م` or `ب|ل`
- `create_when`: the same decoy family is confused with `ب` more than once
- `due_after`: `0h`
- `purpose`: fix repeated family-boundary confusion

## Seed D: stable family seed

- `rule_id`: `rv_ba_family_stable`
- `seed_kind`: `newVocabulary`
- `review_object_type`: `letterForm`
- `review_action_type`: `read`
- `source_item_ref_id`: `ba_family_connected`
- `create_when`: the lesson is completed cleanly
- `due_after`: `18h`
- `purpose`: revisit the family idea before confidence fades

# 6. Home progression result

- `if completed`:
  - `recommended_action_type`: `startLesson`
  - `reason`: the learner can now trust one letter family across shape changes and is ready for the first vowel-support decoding lesson
  - `suggested_next_lesson_id`: `V2-A1-04`
- `if core_completed`:
  - `recommended_action_type`: `startReview`
  - `reason`: connected-form awareness has started, but one family cue still needs reinforcement before reading support expands
  - `home_card_copy`: Review the `ب` family once before continuing
- `if in_progress`:
  - `recommended_action_type`: `continueLesson`
  - `reason`: connected-form identity evidence is still missing

# 7. Self-check

- `Exactly one core objective`: yes. The lesson only teaches one thing: `ب` stays the same letter across isolated and connected forms.
- `Low cognitive load`: yes. One family only, one main invariant cue, and only familiar decoys.
- `Input -> Recognition -> Recall -> Output -> Completion`: yes, in that order.
- `At least one real recall-bearing step`: yes. `recall_home_form_of_medial_ba` and `recall_home_form_of_final_ba` both require unsupported family retrieval.
- `No unnecessary arrangeResponse`: yes. `arrangeResponse` is used only as a structural family-building output action, not as fake sentence work.
- `speakResponse only after enough guided input`: yes. No speech output is required here.
- `Completion returns required fields`: yes. `mastery_status`, `learning_evidence`, `review_seed_candidates`, and `next_home_action` are defined.
- `Weak items eligible for review`: yes. Family identity confusion, weak positional forms, and repeated decoy confusion all generate review seeds.
- `Not passable mainly by guessing`: yes. Multiple mixed recognitions plus unsupported family recall are required.
- `Arabic-specific consistency`: yes. The lesson uses real Arabic form variation and treats it as script-family knowledge, not as vocabulary.
