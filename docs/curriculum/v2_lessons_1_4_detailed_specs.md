# V2 Lessons 1-4 Detailed Specs

## Lesson 1

1. `lesson number`
- `1`

2. `working title`
- `Arabic Starts Here`

3. `core objective`
- Orient to Arabic learning in the app by correctly following one supported Arabic form from right to left.

4. `why this lesson exists in the progression`
- Lesson 1 must lower anxiety before any real decoding work begins.
- It gives the learner one manageable Arabic success instead of an abstract explanation dump.
- It also introduces the app's logic through lived experience: look, try, check, and review if weak.

5. `learner-visible outcome`
- The learner can look at one Arabic example and know where to start.
- The learner feels that Arabic can be handled one small move at a time.

6. `hidden self-learning outcome`
- The learner starts trusting the V2 loop instead of treating progress as page traversal.
- The learner begins to expect that Arabic should be approached visually and directionally before trying to memorize everything.

7. `target knowledge scope`
- One demo Arabic form: `بَ`
- One beginner rule: Arabic starts on the right
- One support concept: visual guides and diacritics are temporary beginner supports
- One app-flow concept introduced but not heavily tested: weak items return through review
- Explicit non-goals:
  - no letter-name teaching yet
  - no word meaning yet
  - no pronunciation burden yet

8. `Input design`
- Show one large card with `بَ`, with a clear right-to-left guide line and a highlighted starting edge on the right.
- Present one sentence of lesson framing only: "In Arabic, begin from the right. This lesson only teaches that first move."
- Show one miniature V2 loop preview after the Arabic example:
  - see
  - try
  - check
  - review later if weak
- Keep the Arabic exposure limited to the single demo form so the learner does not confuse orientation with letter memorization.

9. `Recognition design`
- Recognition item 1:
  - Prompt: "Where does this Arabic form start?"
  - Interaction: tap the correct side of the `بَ` card
  - Distractors: left side and center highlight
- Recognition item 2:
  - Prompt: "Which reading path matches Arabic here?"
  - Interaction: choose among three directional arrows
  - Correct answer: right to left
  - Distractors: left to right, top to bottom
- Recognition item 3:
  - Prompt: "Which helper belongs to beginner reading?"
  - Interaction: choose the version with the temporary guide arrow and visible diacritic support
  - Purpose: reinforce that support is allowed, not shameful

10. `Recall design`
- Recall-bearing item 1:
  - Show the same `بَ` card again with no arrow and no highlighted start point.
  - Ask the learner to tap where reading begins.
- Recall-bearing item 2:
  - Immediately after the tap, ask the learner to select the correct travel direction again from memory, with the original guided example no longer visible.
- This recall stage is still low-load because the visual content stays constant while the support is removed.

11. `Output design`
- Output action:
  - guided finger trace from the right side of `بَ` toward the left
- The output is physical and directional, not spoken
- Rationale:
  - speaking would add unnecessary load
  - tracing makes the learner perform the rule rather than merely recognize it

12. `Completion design`
- Completion is based on directional understanding, not on whether the learner viewed all cards.
- A clean pass requires:
  - at least one correct guided recognition step
  - at least one correct unsupported recall step
  - one successful guided right-to-left trace
- If the learner finishes the path but misses the unsupported recall step, the lesson should mark the orientation as weak and send the learner to a short review-first action.

13. `completion contract`
- `mastery_status`
  - `completed`: learner passes the unsupported start-point recall and the trace action shows the correct direction
  - `core_completed`: learner finishes the lesson path but misses the unsupported recall-bearing direction check
  - `in_progress`: learner exits before the unsupported recall step is attempted
- `learning_evidence`
  - identifies the right edge as the starting point for the demo form
  - matches the correct right-to-left direction
  - repeats the same decision after supports are removed
  - performs one guided right-to-left trace
- `review_seed_candidates`
  - immediate weak seed for right-to-left start confusion on `rtl_demo_ba`
  - delayed stability seed for `rtl_demo_ba` after a clean pass
- `next_home_action`
  - if `completed`: continue to Lesson 2
  - if `core_completed`: start a short review-first refresher on script direction
  - if `in_progress`: continue Lesson 1 from the recall step

14. `review seed logic`
- Seed A:
  - `seed_kind`: `weakPoint`
  - `focus`: right-edge start confusion
  - `item_ref`: `rtl_demo_ba`
  - `create_when`: unsupported recall step is missed
  - `due_after`: `0h`
  - `priority`: highest
- Seed B:
  - `seed_kind`: `newVocabulary` fallback style, but implemented as orientation stability if supported
  - `focus`: stable right-to-left orientation
  - `item_ref`: `rtl_demo_ba`
  - `create_when`: lesson is completed cleanly
  - `due_after`: `18h`
  - `priority`: medium
- If the current review system cannot support a dedicated script-orientation object, temporarily map this to a lightweight `letterForm` review object with explicit UI copy about direction.

15. `paid-boundary note`
- Free gives:
  - Arabic fear reduction
  - first directional trust
  - first experience of the V2 learn-review loop
- Paid keeps:
  - broader script familiarity
  - full alphabet coverage
  - extended decoding fluency work
  - deeper onboarding and confidence-building breadth

16. `implementation notes for later lesson generation`
- Suggested lesson id: `V2-A1-01`
- Suggested content ids:
  - `goal_orientation`
  - `input_demo_ba`
  - `support_rule_intro`
- Suggested practice ids:
  - `recognize_start_side_ba`
  - `recognize_direction_arrow`
  - `recall_start_side_ba`
  - `trace_rtl_ba`
- Use only one Arabic demo form throughout to avoid accidental letter-teaching overload.
- Do not introduce Arabic keyboard input here.
- Do not explain full diacritic theory here; only frame support markers as temporary beginner helpers.
- Completion copy should clearly distinguish:
  - "you finished the step"
  - "you can now do the step"

## Lesson 2

1. `lesson number`
- `2`

2. `working title`
- `Three Sounds, Three Shapes`

3. `core objective`
- Recognize and recall three starter Arabic letter-sound links in isolated form: `ب`, `م`, and `ل`.

4. `why this lesson exists in the progression`
- Lesson 2 creates the first concrete script win after the orientation lesson.
- The learner now needs a small set of real Arabic units they can reliably identify.
- These letters are useful as future building blocks and are visually distinct enough for a first success set.

5. `learner-visible outcome`
- The learner can look at `ب`, `م`, and `ل`, hear their sounds, and start telling them apart.
- The learner feels they have learned actual Arabic material, not just app instructions.

6. `hidden self-learning outcome`
- The learner starts using contrast to study letters.
- The learner begins to understand that Arabic script learning is a sound-shape link, not a decorative shape memorization task.

7. `target knowledge scope`
- Target letters:
  - `ب`
  - `م`
  - `ل`
- Supported sound anchors:
  - `b`
  - `m`
  - `l`
- Form scope:
  - isolated form only
- Explicit non-goals:
  - no connected-form teaching yet
  - no word meanings yet
  - no full letter-name terminology burden unless needed for audio labeling behind the scenes

8. `Input design`
- Introduce one target letter at a time with:
  - large isolated Arabic form
  - one short audio model
  - one simple sound anchor in the interface language
- Use one minimal contrast cue per letter:
  - `ب`: one dot below
  - `م`: rounded body
  - `ل`: tall upright stroke
- Keep all three on a final summary strip only after the individual exposure phase is complete.

9. `Recognition design`
- Recognition item 1:
  - hear `/b/`, choose `ب`
- Recognition item 2:
  - hear `/m/`, choose `م`
- Recognition item 3:
  - hear `/l/`, choose `ل`
- Recognition item 4:
  - see one isolated letter, choose the matching sound anchor
- Recognition should alternate direction:
  - sound -> shape
  - shape -> sound
- This reduces shallow memorization and makes guessing less effective.

10. `Recall design`
- Recall-bearing item 1:
  - hide the earlier model strip
  - give a sound cue such as `/m/`
  - ask the learner to retrieve the correct Arabic letter from a shuffled mixed deck
- Recall-bearing item 2:
  - show one isolated letter with no sound label
  - ask the learner to recall its sound aloud or enter the one-letter Latin sound anchor if the product needs a typed fallback
- If the product cannot support true free-form letter entry yet, the delayed shuffled mixed deck plus delayed sound production should be treated as the minimum acceptable recall evidence for this lesson.

11. `Output design`
- Output action:
  - one `speakResponse` after the guided recognition phase
- Prompt shape:
  - show one target letter
  - learner says the sound once
- Keep the output limited to one letter at a time; do not chain all three in one production task for absolute beginners.

12. `Completion design`
- Completion requires evidence across the whole starter set, not just one lucky answer.
- A clean pass should require:
  - correct recognition on all three letter-sound links at least once
  - one delayed recall-bearing retrieval from sound to shape
  - one output step where the learner produces the matching sound after support
- If one letter remains weak, the lesson can be `core_completed` but should seed immediate review for that specific letter.

13. `completion contract`
- `mastery_status`
  - `completed`: all three target letter-sound links are recognized, and at least one delayed recall-bearing step is correct
  - `core_completed`: learner finishes the lesson path but one target letter remains weak or the delayed recall step fails once
  - `in_progress`: learner exits before all three target letters are attempted
- `learning_evidence`
  - maps `/b/` to `ب`
  - maps `/m/` to `م`
  - maps `/l/` to `ل`
  - retrieves one target again after the model strip is removed
  - produces one target sound after guided exposure
- `review_seed_candidates`
  - weak seed for any missed letter-sound link
  - confusion-pair seed if two letters are repeatedly mixed
  - delayed stability seeds for `ب`, `م`, and `ل` after a clean pass
- `next_home_action`
  - if `completed`: continue to Lesson 3
  - if `core_completed`: start review on the weak letter before advancing
  - if `in_progress`: continue Lesson 2

14. `review seed logic`
- Seed A:
  - `seed_kind`: `weakPoint`
  - `focus`: individual weak letter-sound link
  - `item_refs`: `ب`, `م`, `ل`
  - `create_when`: the learner misses a target item
  - `due_after`: `0h`
  - `priority`: highest
- Seed B:
  - `seed_kind`: `confusionPair`
  - `focus`: repeated confusion between two specific targets
  - `item_ref`: dynamic pair such as `ب|م` or `م|ل`
  - `create_when`: same pair is missed more than once within the lesson
  - `due_after`: `0h`
  - `priority`: high
- Seed C:
  - `seed_kind`: `newVocabulary` analog for script inventory stabilization
  - `focus`: cleanly learned letter-sound link
  - `item_refs`: `ب`, `م`, `ل`
  - `create_when`: lesson is completed cleanly
  - `due_after`: `18h`
  - `priority`: medium

15. `paid-boundary note`
- Free gives:
  - first real Arabic letter inventory
  - first sound-shape confidence
  - first contrast-based script study habit
- Paid keeps:
  - full alphabet coverage
  - broader sound contrasts
  - handwriting development
  - denser discrimination practice

16. `implementation notes for later lesson generation`
- Suggested lesson id: `V2-A1-02`
- Suggested content ids:
  - `goal_three_letters`
  - `input_ba_letter`
  - `input_mim_letter`
  - `input_lam_letter`
  - `contrast_summary_bml`
- Suggested practice ids:
  - `hear_b_pick_ba`
  - `hear_m_pick_mim`
  - `hear_l_pick_lam`
  - `see_letter_pick_sound`
  - `recall_sound_to_shape`
  - `say_letter_sound_once`
- Use isolated forms only.
- Keep audio crisp and short; no word-level audio yet.
- Do not introduce writing or joining in this lesson.
- Avoid overusing transliteration; use only as a support anchor in the UI language.

## Lesson 3

1. `lesson number`
- `3`

2. `working title`
- `Same Letter, New Shape`

3. `core objective`
- Recognize that one known Arabic letter, `ب`, remains the same letter across isolated and connected forms.

4. `why this lesson exists in the progression`
- Learners often lose confidence when a familiar Arabic letter changes shape in connected writing.
- This lesson protects trust by showing that visual change does not mean a completely new symbol.
- It also prepares the learner to move from isolated letters toward actual reading later on.

5. `learner-visible outcome`
- The learner can see several different-looking forms and still identify the `ب` family.
- The learner feels less intimidated by connected Arabic writing.

6. `hidden self-learning outcome`
- The learner begins looking for stable cues inside variation.
- The learner learns that Arabic should be studied by families and invariants, not by panicking at every surface change.

7. `target knowledge scope`
- Main target family:
  - `ب`
  - `بـ`
  - `ـبـ`
  - `ـب`
- Contrast support only:
  - one or two non-target familiar letters in mixed grids, such as `م` and `ل`
- Invariant cue:
  - the dot below and the base shape family
- Explicit non-goals:
  - no full joining-rule system
  - no new letter inventory burden
  - no word meaning burden

8. `Input design`
- Start with the isolated form `ب` that the learner already knows.
- Reveal the connected variants one by one, always anchored back to the isolated form.
- Use one explicit visual cue:
  - highlight the dot below and the shared body curve
- Show one tiny connected sample where `ب` appears inside a short string, but do not turn the lesson into a word-reading lesson.

9. `Recognition design`
- Recognition item 1:
  - pick all cards that still belong to the `ب` family
- Recognition item 2:
  - choose which connected form is still `ب` when mixed with one or two known decoys
- Recognition item 3:
  - given a short connected sample, tap the part that contains the `ب` family member
- Recognition should move from clean family display to mixed display, then to embedded display.

10. `Recall design`
- Recall-bearing item 1:
  - show one connected `ب` form alone, with no family strip visible
  - ask the learner to identify its home form as `ب`
- Recall-bearing item 2:
  - show a second connected variant after a short delay
  - ask the learner whether it still belongs to the same family
- The recall demand is conceptual: retrieve identity despite surface change.

11. `Output design`
- Output action:
  - sort or drag the four `ب` variants into one family row
- Output rationale:
  - it turns the family concept into an active structure
  - it avoids unnecessary speaking or typing load
- If drag interaction is unavailable, fallback to repeated "same family / not same family" grouping with visible buckets.

12. `Completion design`
- Completion must show that the learner can recover the identity of `ب` after the family strip disappears.
- A clean pass should require:
  - correct family recognition in a mixed grid
  - at least one correct unsupported connected-form recall
  - one successful grouping output action
- If the learner can recognize the family only while the strip is visible, the lesson should be `core_completed`, not `completed`.

13. `completion contract`
- `mastery_status`
  - `completed`: learner identifies connected `ب` correctly even after the family strip is removed
  - `core_completed`: learner completes guided grouping but misses the unsupported connected-form recall
  - `in_progress`: learner exits before the unsupported recall step
- `learning_evidence`
  - recognizes the isolated `ب`
  - recognizes connected `ب` variants in a mixed set
  - retrieves the family identity of a connected variant from memory
  - groups the `ب` family into one row or bucket
- `review_seed_candidates`
  - weak seed for `ب` connected-form family
  - weak seed for whichever positional form fails
  - confusion-pair seed if a specific decoy family is repeatedly mistaken for `ب`
- `next_home_action`
  - if `completed`: continue to Lesson 4
  - if `core_completed`: review connected-form identity before advancing
  - if `in_progress`: continue Lesson 3

14. `review seed logic`
- Seed A:
  - `seed_kind`: `weakPoint`
  - `focus`: `ب` family identity across forms
  - `item_ref`: `ba_family_connected`
  - `create_when`: unsupported connected-form recall fails
  - `due_after`: `0h`
  - `priority`: highest
- Seed B:
  - `seed_kind`: `weakPoint`
  - `focus`: specific positional form, such as `initial_ba` or `final_ba`
  - `create_when`: one specific form repeatedly fails
  - `due_after`: `0h`
  - `priority`: high
- Seed C:
  - `seed_kind`: `confusionPair`
  - `focus`: `ب` family versus the repeated decoy family
  - `create_when`: same confusion happens more than once
  - `due_after`: `0h`
  - `priority`: high
- Seed D:
  - `seed_kind`: stability seed
  - `focus`: `ب` family retention
  - `item_ref`: `ba_family_connected`
  - `create_when`: clean pass
  - `due_after`: `18h`
  - `priority`: medium

15. `paid-boundary note`
- Free gives:
  - first connected-form trust
  - first sense that Arabic variation is patterned
  - one strong example of family-based script study
- Paid keeps:
  - broader connected-form coverage
  - full joining behavior
  - more letters across all positions
  - denser embedded reading practice

16. `implementation notes for later lesson generation`
- Suggested lesson id: `V2-A1-03`
- Suggested content ids:
  - `goal_ba_family`
  - `input_ba_isolated`
  - `input_ba_initial`
  - `input_ba_medial`
  - `input_ba_final`
  - `family_invariant_note`
- Suggested practice ids:
  - `pick_all_ba_family_members`
  - `choose_connected_ba`
  - `recall_home_form_of_connected_ba`
  - `sort_ba_family_row`
- Keep the lesson focused on one main family only.
- Do not expand into a lecture about all Arabic joining rules.
- Reuse familiar decoys only if they stay visually simple.
- Visual highlighting of the invariant cue is more important than verbal explanation.

## Lesson 4

1. `lesson number`
- `4`

2. `working title`
- `Short Vowels Make Reading Possible`

3. `core objective`
- Use `fatha`, `kasra`, and `damma` as beginner supports to distinguish and read tiny diacritized Arabic forms.

4. `why this lesson exists in the progression`
- The learner now needs to feel that Arabic can become readable, not only recognizable.
- Diacritics should be introduced as a practical decoding support before the learner is asked to handle larger reading tasks.
- This lesson closes Stage A with a visible milestone: supported Arabic reading is possible.

5. `learner-visible outcome`
- The learner can distinguish small diacritized forms such as `بَ`, `بِ`, and `بُ`.
- The learner feels that Arabic symbols and sound can line up in a manageable way.

6. `hidden self-learning outcome`
- The learner understands that diacritics are support tools, not decorative marks.
- The learner starts using sound-form alignment as a study habit.

7. `target knowledge scope`
- Core vowel supports:
  - `fatha`
  - `kasra`
  - `damma`
- Core demo set:
  - `بَ`
  - `بِ`
  - `بُ`
- Optional tiny extension only if the lesson still feels light:
  - one extra supported micro-form built from known letters
- Explicit non-goals:
  - no long vowels
  - no `sukun`
  - no `tanwin`
  - no word meanings yet

8. `Input design`
- Present one base letter family the learner already knows: `ب`.
- Add one short vowel mark at a time, each with one clean audio model:
  - `بَ`
  - `بِ`
  - `بُ`
- Use one short explanation only:
  - "These marks help beginners hear and read the short sound."
- Keep all examples fully diacritized.

9. `Recognition design`
- Recognition item 1:
  - hear `/ba/`, choose `بَ`
- Recognition item 2:
  - hear `/bi/`, choose `بِ`
- Recognition item 3:
  - hear `/bu/`, choose `بُ`
- Recognition item 4:
  - see one form and choose the matching short sound label
- Recognition item 5:
  - choose the correct mark for a given short sound on the same base letter
- Use multiple directions of matching so the learner does not treat the lesson as one-way memorization.

10. `Recall design`
- Recall-bearing item 1:
  - remove the full comparison strip
  - give the sound cue `/bi/`
  - ask the learner to retrieve `بِ`
- Recall-bearing item 2:
  - later in the lesson, give the sound cue `/bu/`
  - ask the learner to retrieve `بُ` again without the model strip visible
- If the product does not support direct Arabic entry with diacritics, use a constrained construction or high-contrast delayed selection from the three supported forms as a fallback.

11. `Output design`
- Output action:
  - one `speakResponse` after recognition and recall
- Prompt shape:
  - show one supported form such as `بَ`
  - learner reads it aloud once
- Output should remain tiny and fully supported; do not turn this lesson into pronunciation drilling.

12. `Completion design`
- Completion should measure whether the learner can use vowel marks to recover the sound, not merely notice that the marks look different.
- A clean pass should require:
  - successful recognition across all three short-vowel forms
  - at least one unsupported recall-bearing retrieval from sound to form
  - one supported read-aloud output step
- If one vowel remains unstable, the lesson should be `core_completed` and route to short review before Lesson 5.

13. `completion contract`
- `mastery_status`
  - `completed`: learner distinguishes all three short-vowel supports and passes at least one unsupported recall-bearing retrieval
  - `core_completed`: learner finishes the path but one vowel remains weak or the recall-bearing retrieval is unstable
  - `in_progress`: learner exits before all three short-vowel items are attempted
- `learning_evidence`
  - matches `/ba/` with `بَ`
  - matches `/bi/` with `بِ`
  - matches `/bu/` with `بُ`
  - retrieves one target form again after the model strip is removed
  - reads one diacritized form aloud after support
- `review_seed_candidates`
  - weak seed for the missed short-vowel item
  - confusion-pair seed for repeated short-vowel mix-up
  - delayed stability seeds for cleanly learned diacritized forms
- `next_home_action`
  - if `completed`: continue to Lesson 5
  - if `core_completed`: start short diacritic review first
  - if `in_progress`: continue Lesson 4

14. `review seed logic`
- Seed A:
  - `seed_kind`: `weakPoint`
  - `focus`: individual short-vowel reading item such as `ba_short`, `bi_short`, or `bu_short`
  - `create_when`: learner misses that form
  - `due_after`: `0h`
  - `priority`: highest
- Seed B:
  - `seed_kind`: `confusionPair`
  - `focus`: repeated confusion between two short vowels, such as `ba_short|bi_short`
  - `create_when`: same pair confusion repeats
  - `due_after`: `0h`
  - `priority`: high
- Seed C:
  - `seed_kind`: stability seed
  - `focus`: correctly learned short-vowel support form
  - `create_when`: clean pass
  - `due_after`: `18h`
  - `priority`: medium
- Prefer existing `symbolReading` review objects for these seeds if the runtime supports them.

15. `paid-boundary note`
- Free gives:
  - first workable diacritic support
  - first tiny supported reading success
  - first trust that Arabic sound and script can line up
- Paid keeps:
  - larger phonics range
  - more letters under vowel support
  - more complex reading supports
  - gradual movement toward less-supported reading

16. `implementation notes for later lesson generation`
- Suggested lesson id: `V2-A1-04`
- Suggested content ids:
  - `goal_short_vowels`
  - `input_ba_fatha`
  - `input_ba_kasra`
  - `input_ba_damma`
  - `support_mark_note`
- Suggested practice ids:
  - `hear_ba_pick_ba_fatha`
  - `hear_bi_pick_ba_kasra`
  - `hear_bu_pick_ba_damma`
  - `recall_bi_form`
  - `recall_bu_form`
  - `read_one_supported_form`
- Audio must be aligned exactly to the visible diacritics.
- Keep diacritics visible in all learner-facing Arabic for this lesson.
- Do not introduce long-vowel theory here.
- Lesson 4 should end Stage A with confidence, not with a theory quiz.
