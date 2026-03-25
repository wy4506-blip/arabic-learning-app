# Lesson 07 Voiceover Script

- Status: final script normalized from existing repository content
- Review status: `pass`
- Review summary: The audio-first recognition lesson is ready once pack-list pacing is kept explicit in delivery notes.
- Batch: `Batch B`
- Stage: Stage B
- Lesson ID: `lesson_07_audio_first_known_content_recognition`
- Working title: Hear What You Already Know
- Estimated narration runtime: `01:20`
- Estimated Arabic asset runtime: `00:20`
- Generated at: `2026-03-21T12:48:18.960405Z`
- Canonical source policy: use the runtime `V2MicroLesson` object only; do not add new teaching copy.

## Recording Profile

- Audience: absolute beginners
- Baseline delivery: warm, calm, clear, and beginner-safe
- Arabic handling: keep every Arabic item intact, do not paraphrase, and leave one clean beat around short Arabic inserts
- Repeatability rule: short prompts and short Arabic models should sound easy to repeat once
- Review focus: Treat pack lines as clean, separate items rather than one run-on utterance.

## Canonical Sources

- `lib/data/generated_stage_b_preview_lessons.dart`
- `docs/generated_lessons/v2_b1_07_audio_first_known_content_recognition.md`
- `test/stage_b_preview_page_test.dart`

## Normalized Voiceover Segments

| segment_id | asset_stem | segment_name | segment_type | duration_target | export_state | delivery_notes | repeatable | native_review | source | text |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `L07_SEG_001` | `l07_ord_001` | `OPEN_TITLE` | `opening` | `00:02-00:04` | `ready` | Short open. Calm lift on the first words, then a clean stop. | `no` | `no` | `lesson.title` | Hear What You Already Know |
| `L07_SEG_002` | `l07_ord_002` | `OPEN_OUTCOME` | `opening` | `00:04-00:09` | `ready` | Steady overview line. Keep it calm, clear, and lightly encouraging. | `no` | `no` | `lesson.outcomeSummary` | After this lesson, you can catch familiar Arabic from audio across one word and one tiny line. |
| `L07_SEG_003` | `l07_ord_003` | `OPEN_OBJECTIVE_01` | `opening` | `00:04-00:08` | `ready` | Steady overview line. Keep it calm, clear, and lightly encouraging. | `no` | `no` | `objective:recognize_known_content_from_audio` | Recognize already known beginner Arabic content directly from audio before relying on print. |
| `L07_SEG_004` | `l07_ord_004` | `TEACH_HEADER_01` | `section_header` | `00:02-00:03` | `ready` | Short open. Calm lift on the first words, then a clean stop. | `no` | `no` | `content:goal_audio_known_pack.title` | Lesson Goal |
| `L07_SEG_005` | `l07_ord_005` | `TEACH_BODY_01` | `teaching_narration` | `00:03-00:06` | `ready` | Teaching line. Warm, calm, and conversational with one clear sentence boundary. | `no` | `no` | `content:goal_audio_known_pack.body` | Listen for content you already know before your eyes do the work. |
| `L07_SEG_006` | `l07_ord_006` | `TEACH_HEADER_02` | `section_header` | `00:02-00:04` | `ready` | Short open. Calm lift on the first words, then a clean stop. | `no` | `no` | `content:input_audio_known_words.title` | Listen To The Known Pack |
| `L07_SEG_007` | `l07_ord_007` | `TEACH_BODY_02` | `teaching_narration` | `00:03-00:09` | `ready` | Teaching line. Warm and clear. Slow slightly around the Arabic and return to the base pace after it. | `no` | `no` | `content:input_audio_known_words.body` | Nothing new is being added here. كتاب, باب, قلم, and tiny هذا lines are just becoming more audible. |
| `L07_SEG_008` | `l07_ord_008` | `TEACH_HEADER_03` | `section_header` | `00:02-00:03` | `ready` | Short open. Calm lift on the first words, then a clean stop. | `no` | `no` | `content:model_word_vs_line_audio.title` | Word Or Tiny Line? |
| `L07_SEG_009` | `l07_ord_009` | `TEACH_BODY_03` | `teaching_narration` | `00:03-00:07` | `ready` | Teaching line. Warm, calm, and conversational with one clear sentence boundary. | `no` | `no` | `content:model_word_vs_line_audio.body` | Listen for whether you heard the word alone or the tiny line that wraps it. |
| `L07_SEG_010` | `l07_ord_010` | `TEACH_HEADER_04` | `section_header` | `00:02-00:03` | `ready` | Short open. Calm lift on the first words, then a clean stop. | `no` | `no` | `content:support_audio_first.title` | Listen First |
| `L07_SEG_011` | `l07_ord_011` | `TEACH_BODY_04` | `teaching_narration` | `00:03-00:08` | `ready` | Teaching line. Warm, calm, and conversational with one clear sentence boundary. | `no` | `no` | `content:support_audio_first.body` | This is still a very small listening win. The goal is simply to hear what you already know more directly. |
| `L07_SEG_012` | `l07_ord_012` | `PROMPT_01` | `instruction_prompt` | `00:03-00:07` | `ready` | Instructional prompt. Keep the action verb crisp, leave one clean beat before the Arabic, and allow answer space at the end. | `yes` | `no` | `practice:hear_qalam_word_from_audio.prompt` | Listen first, then tap قلم. |
| `L07_SEG_013` | `l07_ord_013` | `PROMPT_02` | `instruction_prompt` | `00:03-00:07` | `ready` | Instructional prompt. Keep the action verb crisp, leave one clean beat before the Arabic, and allow answer space at the end. | `yes` | `no` | `practice:hear_hadha_kitab_line_from_audio.prompt` | Listen first, then tap هذا كتاب. |
| `L07_SEG_014` | `l07_ord_014` | `PROMPT_03` | `instruction_prompt` | `00:03-00:07` | `ready` | Instructional prompt. Keep the action verb crisp, leave one clean beat before the Arabic, and allow answer space at the end. | `yes` | `no` | `practice:hear_hadha_qalam_line_from_audio.prompt` | Listen first, then tap هذا قلم. |
| `L07_SEG_015` | `l07_ord_015` | `PROMPT_04` | `instruction_prompt` | `00:03-00:07` | `ready` | Instructional prompt. Keep the action verb crisp and allow a short answer pause at the end. | `yes` | `no` | `practice:contrast_qalam_word_vs_line.prompt` | Listen carefully. Did you hear the word alone or the full line? |
| `L07_SEG_016` | `l07_ord_016` | `PROMPT_05` | `instruction_prompt` | `00:03-00:06` | `ready` | Instructional prompt. Keep the action verb crisp and allow a short answer pause at the end. | `yes` | `no` | `practice:arrange_heard_hadha_qalam.prompt` | You just heard the line. Build it again. |
| `L07_SEG_017` | `l07_ord_017` | `PROMPT_06` | `instruction_prompt` | `00:03-00:07` | `ready` | Instructional prompt. Keep the action verb crisp and allow a short answer pause at the end. | `yes` | `no` | `practice:say_heard_hadha_qalam_once.prompt` | Hear it, say it once, then type the same line. |

## Normalized Arabic Model Bank

| bank_id | asset_stem | asset_name | asset_type | duration_target | export_state | delivery_notes | repeatable | native_review | source | spoken_text | display_text | transliteration | meaning | notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `L07_AR_001` | `l07_ar_001` | `AR_LIST_01` | `list` | `00:03-00:08` | `ready` | Arabic list, not a sentence. Give each item its own beat and keep the order clean. Preserve the source spoken-versus-display split exactly as written. Spoken text follows audioQueryText; display text preserves on-screen form. | `yes` | `no` | `content:input_audio_known_words` | كتاب باب قلم هذا كتاب هذا قلم | كتاب / باب / قلم / هذا كتاب / هذا قلم |  | known Stage B pack | Spoken text follows audioQueryText; display text preserves on-screen form. |
| `L07_AR_002` | `l07_ar_002` | `AR_LIST_02` | `list` | `00:03-00:06` | `ready` | Arabic list, not a sentence. Give each item its own beat and keep the order clean. | `yes` | `no` | `content:model_word_vs_line_audio` | قلم / هذا قلم | قلم / هذا قلم |  |  |  |
| `L07_AR_003` | `l07_ar_003` | `AR_WORD_01` | `word` | `00:02-00:03` | `ready` | Single Arabic word. Neutral model, one clean pronunciation, no extra sentence melody. | `yes` | `no` | `practice:hear_qalam_word_from_audio.arabicText` | قلم | قلم |  | pen |  |
| `L07_AR_004` | `l07_ar_004` | `AR_PHRASE_01` | `short_phrase` | `00:02-00:04` | `ready` | Short Arabic phrase. Keep the word boundary clear and easy to repeat once. | `yes` | `no` | `practice:hear_hadha_kitab_line_from_audio.arabicText` | هذا كتاب | هذا كتاب |  | this is a book |  |
| `L07_AR_005` | `l07_ar_005` | `AR_PHRASE_02` | `short_phrase` | `00:02-00:04` | `ready` | Short Arabic phrase. Keep the word boundary clear and easy to repeat once. | `yes` | `no` | `practice:hear_hadha_qalam_line_from_audio.arabicText` | هذا قلم | هذا قلم |  | this is a pen |  |

## Review Flags

- No line-level issues require manual revision or native review before export.

## Completeness Basis

Runtime lesson object plus generated markdown plus Stage B integration coverage.
