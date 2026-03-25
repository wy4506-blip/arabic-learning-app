# 1. Working title

Hear What You Already Know

# 2. Core objective

Help the learner recognize already known beginner Arabic content directly from audio before relying on visible text.

# 3. Why this lesson exists after Lesson 6

By the end of Lesson 6, the learner already owns a small meaningful Arabic pack: `كتاب`, `باب`, `قلم`, and short `هذا + noun` lines. That is enough for Arabic to stop being only something seen on the screen and start becoming something heard.

Lesson 7 exists to shift that known content toward the ear without adding a broad new listening burden. The learner should feel that familiar Arabic can now be caught more directly from sound, not only decoded from print.

This lesson should not feel like a reset into isolated vocabulary practice, because the targets are already known. It should also not become a broad listening lesson. Its role is narrower and more important: move a small owned Arabic pack into audio-first recognition so the learner becomes less print-dependent before Stage B consolidation.

# 4. Learner-visible outcome

By the end of the lesson, the learner should feel:

- "I can hear familiar Arabic and catch what it is."
- "I can tell whether I heard `كتاب`, `باب`, `قلم`, or a tiny `هذا ...` line."
- "Arabic is starting to sound familiar, not only look familiar."
- "I can follow a very small amount of Arabic by ear already."

# 5. Hidden self-learning outcome

The lesson quietly reinforces that known Arabic content should live in more than one channel:

- visual form
- sound pattern
- meaning link
- retrieval under light pressure

It also builds an early sound-first learning habit. The learner begins to understand that "knowing" Arabic means being able to catch familiar content from audio, not only recognize it when text is already visible.

# 6. Target knowledge scope

Primary audio targets:

- `كتاب`
- `باب`
- `قلم`
- `هذا كتاب`
- `هذا قلم`

Optional low-stakes transfer item:

- `هذا باب`

Scope boundary:

- No new vocabulary targets.
- No new phrase frame beyond already known `هذا + noun`.
- No broad listening expansion, no dialogue, and no multi-sentence comprehension.
- The lesson focuses only on already known content becoming more audible.

# 7. Input design

Input should reassure the learner that nothing new is being piled on. The message is: you already know this content, and now you will start hearing it more directly.

Recommended input flow:

1. Known-pack audio reactivation
   - Briefly replay `كتاب`, `باب`, and `قلم` with meaning support
   - Re-show `هذا كتاب` and `هذا قلم` once with audio and meaning support
   - Learner-facing line: "You already know these. Now listen for them first."

2. Audio-first modeling
   - Play a known word before showing the text
   - Let the learner try to notice it from sound
   - Reveal the Arabic text after the first listening pass

3. Word-versus-line modeling
   - Contrast a single word and a short line, such as `قلم` and `هذا قلم`
   - Help the learner notice that both are still built from known content
   - This is not grammar analysis; it is audio familiarity support

Input should avoid:

- long listening segments
- new speakers or noisy audio variation
- large audio sets
- explanation-heavy listening strategy teaching

# 8. Recognition design

Recognition should prove that the learner can map sound to already known Arabic content with minimal visual dependence.

Recommended recognition sequence:

1. Audio -> meaning for known words
   - Play `كتاب`, `باب`, or `قلم`
   - Ask the learner to identify the meaning from a very small set

2. Audio -> Arabic text for known words
   - Play one familiar word
   - Ask the learner to choose the matching Arabic form without showing the answer first

3. Audio -> expression recognition
   - Play `هذا كتاب` or `هذا قلم`
   - Ask the learner to choose the matching short line

4. Word-versus-line contrast recognition
   - Contrast pairs such as `قلم` versus `هذا قلم` or `كتاب` versus `هذا كتاب`
   - Ask which one was heard
   - This confirms that the learner is hearing not only the noun but also whether it appeared alone or inside a tiny line

Recognition items should:

- keep option count low
- reuse only known content
- make audio feel clear and trustworthy rather than tricky

# 9. Recall design

Recall must show that the learner can recover familiar content from sound, not only click the right answer after hearing it.

Required recall-bearing step:

1. Sound-only -> arrange a known line
   - Play `هذا قلم` or `هذا كتاب`
   - The learner must rebuild the heard line with `arrangeResponse`
   - The line should not be visible before the arrangement task begins

Recommended reduced-support retrieval:

2. Sound-only -> recover a known item after delay
   - Play one familiar audio item early
   - After one intervening task, prompt the learner to recover what they heard
   - Acceptable formats:
     - arrange `هذا كتاب` from chunks after hearing it
     - rebuild `قلم` from a tightly constrained word assembly if the runtime supports it smoothly

Recall must not be satisfied by:

- audio multiple choice only
- replaying and then reading the answer directly from the screen
- treating sound recognition as complete mastery without one recovery step

# 10. Output design

Output should give the learner a low-pressure success moment that connects hearing with saying.

Recommended output:

- one guided `speakResponse` after hearing a familiar short line such as `هذا كتاب` or `هذا قلم`

Purpose of output:

- reinforce that familiar Arabic can now be heard and echoed as one known chunk
- keep the learner's success visible without turning the lesson into pronunciation training
- make the lesson feel like real listening progress, not only quiz progress

Output boundary:

- do not grade fine pronunciation detail
- do not require spontaneous phrase creation
- keep output limited to one short familiar item after guided audio exposure

# 11. Completion design

Completion should feel like a clear listening milestone inside a very small safe content set.

The learner should complete the lesson only after demonstrating:

- they can identify known words from audio
- they can identify at least one known short line from audio
- they can recover at least one heard item through a recall-bearing step
- they can say one familiar item after hearing it

Completion message should make the gain visible:

- the learner can now catch some familiar Arabic by ear
- known words and short lines are becoming audible, not only readable
- the learner is ready to consolidate this small pack in Lesson 8

Completion should not claim:

- broad listening comprehension
- natural-speed listening ability
- conversation listening ability
- mastery of unseen audio content

# 12. Completion contract

## mastery_status

`mastered` only if the learner succeeds on audio-first recognition across both word-level and line-level known content and also completes at least one recall-bearing audio-to-recovery task.

`needs_review` if the learner succeeds mainly when text is revealed quickly, or if they can identify some items from audio but cannot recover even one familiar item after hearing it.

## learning_evidence

Minimum acceptable evidence:

- identified at least one known word from audio
- identified at least one known `هذا + noun` line from audio
- completed one recall-bearing recovery step from sound, such as arranging `هذا قلم` after hearing it
- completed one guided spoken response for a familiar heard item

Stronger evidence:

- distinguishes both word-only and line-level audio reliably
- handles a contrast such as `قلم` versus `هذا قلم`
- recovers a heard item after a short delay instead of immediately after the audio model

## review_seed_candidates

Priority candidates:

- `audio_word_pack_kitab_bab_qalam`
- `audio_line_hadha_kitab`
- `audio_line_hadha_qalam`
- `audio_contrast_word_vs_line`

Fallback candidate if audio recovery is weak:

- `audio_to_arrange_support_known_line`

## next_home_action

If `mastered`:

- continue to Lesson 8, where the learner consolidates the first usable Arabic pack across reading, listening, recall, and short output

If `needs_review`:

- schedule a short audio-review pass on the unstable known items before Lesson 8

# 13. Review seed logic

Seed 1: `audio_word_pack_kitab_bab_qalam`

- Trigger when the learner confuses `كتاب`, `باب`, and `قلم` in audio-only recognition
- Purpose: stabilize the core known-word audio pack before broader consolidation

Seed 2: `audio_line_hadha_kitab`

- Trigger when the learner misses or hesitates on `هذا كتاب`
- Purpose: strengthen one known line as a stable heard chunk

Seed 3: `audio_line_hadha_qalam`

- Trigger when the learner misses or hesitates on `هذا قلم`
- Purpose: help the learner hear a recently learned noun inside a familiar fixed frame

Seed 4: `audio_contrast_word_vs_line`

- Trigger when the learner hears the noun correctly but misses whether it appeared alone or inside `هذا + noun`
- Purpose: stabilize the difference between hearing a known word and hearing a known short line

Seed priority rule:

- prioritize audio recovery weakness first
- then word-pack confusions
- then line-level instability
- then word-versus-line contrast weakness

Review boundary:

- review should stay inside the small familiar pack
- do not expand into new listening material or broad listening drills

# 14. Paid-boundary note

This free lesson should feel substantial because it gives the learner a real first listening gain: familiar Arabic is becoming audible, not only visible.

Paid expansion value remains intact because later content can still deepen:

- larger listening libraries
- more voices and speech variation
- broader phrase and scene listening
- natural-speed comprehension growth
- longer audio chains and richer listening review

Free value here is: "I can already hear some Arabic that I know."
Paid value later is: "I can grow that into broader, more natural listening ability."

# 15. Implementation notes

- Keep exactly one formal lesson objective: recognize already known beginner Arabic content directly from audio before relying on visible text.
- Do not introduce any new lexical item or new structural target.
- Keep the audio pack deliberately small: `كتاب`, `باب`, `قلم`, `هذا كتاب`, `هذا قلم`, with optional low-stakes `هذا باب` only if needed for transfer.
- Preferred V2 flow:
  - Input
  - Recognition from audio at word level
  - Recognition from audio at line level
  - Recall via audio-to-recovery task
  - Output
  - Completion
- Ensure at least one required recall-bearing item converts heard audio into a recovered answer, not just a multiple-choice click.
- Use clean, slow, consistent audio with replay available.
- Hide text on first audio exposure whenever practical, then reveal after response or feedback.
- Keep choice sets at 2-3 options maximum.
- Avoid large contrast sets, long clips, or multiple new speakers.
- Completion UI should visibly mark the new capability: the learner can now hear familiar Arabic more directly.
