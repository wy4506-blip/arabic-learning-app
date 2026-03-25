# Lesson 03 Voiceover Script

- Status: final script normalized from existing repository content
- Review status: `revise`
- Review summary: The lesson word itself is fine, but connection-path build artifacts should not be sent into blind TTS export as normal speech.
- Batch: `Batch A`
- Stage: Stage A
- Lesson ID: `V2-A1-03-PREVIEW`
- Working title: One Word, Connected Shape
- Estimated narration runtime: `01:32`
- Estimated Arabic asset runtime: `00:13`
- Generated at: `2026-03-21T12:48:18.960405Z`
- Canonical source policy: use the runtime `V2MicroLesson` object only; do not add new teaching copy.

## Recording Profile

- Audience: absolute beginners
- Baseline delivery: warm, calm, clear, and beginner-safe
- Arabic handling: keep every Arabic item intact, do not paraphrase, and leave one clean beat around short Arabic inserts
- Repeatability rule: short prompts and short Arabic models should sound easy to repeat once
- Review focus: Record the core word content normally, but keep connection-path artifacts out of the first export pass.

## Canonical Sources

- `lib/data/generated_stage_a_preview_lessons.dart`
- `docs/generated_lessons/v2_a1_03_same_letter_new_shape.md`
- `test/stage_a_preview_page_test.dart`

## Normalized Voiceover Segments

| segment_id | asset_stem | segment_name | segment_type | duration_target | export_state | delivery_notes | repeatable | native_review | source | text |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `L03_SEG_001` | `l03_ord_001` | `OPEN_TITLE` | `opening` | `00:02-00:03` | `ready` | Short open. Calm lift on the first words, then a clean stop. | `no` | `no` | `lesson.title` | One Word, Connected Shape |
| `L03_SEG_002` | `l03_ord_002` | `OPEN_OUTCOME` | `opening` | `00:04-00:13` | `ready` | Steady overview line. Keep the English flowing and slow slightly around Arabic inserts. | `no` | `no` | `lesson.outcomeSummary` | You can recognize and recall باب as the Arabic word for door, giving you two real words in Stage A while noticing how the same ب family changes shape inside the word. |
| `L03_SEG_003` | `l03_ord_003` | `OPEN_OBJECTIVE_01` | `opening` | `00:04-00:10` | `ready` | Steady overview line. Keep the English flowing and slow slightly around Arabic inserts. | `no` | `no` | `objective:recognize_recall_bab_connected_word` | Recognize and recall باب as a real connected word while noticing how the repeated ب family changes position inside it. |
| `L03_SEG_004` | `l03_ord_004` | `TEACH_HEADER_01` | `section_header` | `00:02-00:03` | `ready` | Short open. Calm lift on the first words, then a clean stop. | `no` | `no` | `content:goal_bab_word.title` | Lesson Goal |
| `L03_SEG_005` | `l03_ord_005` | `TEACH_BODY_01` | `teaching_narration` | `00:03-00:09` | `ready` | Teaching line. Warm, calm, and conversational with one clear sentence boundary. | `no` | `no` | `content:goal_bab_word.body` | Learn one new real word and notice how Arabic connection works inside it without turning the lesson into isolated letter drill. |
| `L03_SEG_006` | `l03_ord_006` | `TEACH_HEADER_02` | `section_header` | `00:02-00:03` | `ready` | Short open. Calm lift on the first words, then a clean stop. | `no` | `no` | `content:input_bab_word.title` | Whole Word First |
| `L03_SEG_007` | `l03_ord_007` | `TEACH_BODY_02` | `teaching_narration` | `00:03-00:10` | `ready` | Teaching line. Warm and clear. Slow slightly around the Arabic and return to the base pace after it. | `no` | `no` | `content:input_bab_word.body` | Meet باب as a whole word meaning door. Learn the word first, then let the script behavior become visible inside it. |
| `L03_SEG_008` | `l03_ord_008` | `TEACH_HEADER_03` | `section_header` | `00:02-00:03` | `ready` | Short open. Calm lift on the first words, then a clean stop. | `no` | `no` | `content:connection_note_inside_word.title` | Connection Inside One Word |
| `L03_SEG_009` | `l03_ord_009` | `TEACH_BODY_03` | `teaching_narration` | `00:03-00:12` | `ready` | Teaching line. Warm and clear. Slow slightly around the Arabic and return to the base pace after it. | `no` | `no` | `content:connection_note_inside_word.body` | In باب, the same ب family appears at the beginning and end of a real word. The shape changes with position, but the word still stays one meaningful item. |
| `L03_SEG_010` | `l03_ord_010` | `TEACH_HEADER_04` | `section_header` | `00:02-00:03` | `ready` | Short open. Calm lift on the first words, then a clean stop. | `no` | `no` | `content:contrast_known_words.title` | Compare Whole Words |
| `L03_SEG_011` | `l03_ord_011` | `TEACH_BODY_04` | `teaching_narration` | `00:03-00:09` | `ready` | Teaching line. Warm and clear. Slow slightly around the Arabic and return to the base pace after it. | `no` | `no` | `content:contrast_known_words.body` | Use whole-word contrast here. The learner should see باب as door, not as a pile of isolated letters. |
| `L03_SEG_012` | `l03_ord_012` | `PROMPT_01` | `instruction_prompt` | `00:03-00:07` | `ready` | Instructional prompt. Keep the action verb crisp, leave one clean beat before the Arabic, and allow answer space at the end. | `yes` | `no` | `practice:hear_bab_pick_word.prompt` | Hear the word, then tap باب. |
| `L03_SEG_013` | `l03_ord_013` | `PROMPT_02` | `instruction_prompt` | `00:03-00:06` | `ready` | Instructional prompt. Keep the action verb crisp, leave one clean beat before the Arabic, and allow answer space at the end. | `yes` | `no` | `practice:see_bab_pick_meaning.prompt` | What does باب mean? |
| `L03_SEG_014` | `l03_ord_014` | `PROMPT_03` | `instruction_prompt` | `00:03-00:08` | `ready` | Instructional prompt. Keep the action verb crisp, leave one clean beat before the Arabic, and allow answer space at the end. | `yes` | `no` | `practice:recognize_b_family_inside_bab.prompt` | Inside باب, which family shows up at both ends? |
| `L03_SEG_015` | `l03_ord_015` | `PROMPT_04` | `instruction_prompt` | `00:03-00:08` | `ready` | Instructional prompt. Keep the action verb crisp and allow a short answer pause at the end. | `yes` | `no` | `practice:recall_bab_from_meaning.prompt` | The meaning prompt is all you get now. Type the Arabic word for door. |
| `L03_SEG_016` | `l03_ord_016` | `PROMPT_05` | `instruction_prompt` | `00:03-00:09` | `ready` | Instructional prompt. Keep the action verb crisp, leave one clean beat before the Arabic, and allow answer space at the end. | `yes` | `no` | `practice:recall_repeated_family_in_bab.prompt` | Look at باب. Type the family that repeats at the beginning and end. |
| `L03_SEG_017` | `l03_ord_017` | `PROMPT_06` | `instruction_prompt` | `00:03-00:08` | `ready` | Instructional prompt. Keep the action verb crisp, leave one clean beat before the Arabic, and allow answer space at the end. | `yes` | `no` | `practice:build_bab_from_connection.prompt` | Build the connected word path for باب from beginning to end. |

## Normalized Arabic Model Bank

| bank_id | asset_stem | asset_name | asset_type | duration_target | export_state | delivery_notes | repeatable | native_review | source | spoken_text | display_text | transliteration | meaning | notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `L03_AR_001` | `l03_ar_001` | `AR_WORD_01` | `word` | `00:02-00:03` | `ready` | Single Arabic word. Neutral model, one clean pronunciation, no extra sentence melody. | `yes` | `no` | `content:input_bab_word` | باب | باب | baab | door |  |
| `L03_AR_002` | `l03_ar_002` | `AR_LIST_01` | `list` | `00:03-00:06` | `ready` | Arabic list, not a sentence. Give each item its own beat and keep the order clean. | `yes` | `no` | `content:contrast_known_words` | باب / كتاب / بيت | باب / كتاب / بيت |  |  |  |
| `L03_AR_003` | `l03_ar_003` | `AR_FRAGMENT_01` | `fragment` | `00:01-00:02` | `hold` | Orthographic fragment. Keep it isolated and do not improvise its spoken treatment. Hold from export until this line is manually cleared. The repeated-family cue is an orthographic fragment rather than a self-evident spoken target. | `no` | `check` | `practice:recall_repeated_family_in_bab.expectedAnswer` | ب | ب |  |  |  |
| `L03_AR_004` | `l03_ar_004` | `AR_BUILD_01` | `build_artifact` | `00:02-00:04` | `hold` | Build artifact, not natural continuous speech. Keep it out of blind TTS export until confirmed. Hold from export until this line is manually cleared. The connection path بـ ا ـب is a UI build artifact, not natural continuous Arabic speech. | `no` | `no` | `practice:build_bab_from_connection.expectedAnswer` | بـ ا ـب | بـ ا ـب |  |  |  |

## Review Flags

| source_ref | current_id | asset_stem | export_state | native_review | reason | text |
| --- | --- | --- | --- | --- | --- | --- |
| `practice:recall_repeated_family_in_bab.expectedAnswer` | `L03_AR_003` | `l03_ar_003` | `hold` | `check` | The repeated-family cue is an orthographic fragment rather than a self-evident spoken target. | ب |
| `practice:build_bab_from_connection.expectedAnswer` | `L03_AR_004` | `l03_ar_004` | `hold` | `no` | The connection path بـ ا ـب is a UI build artifact, not natural continuous Arabic speech. | بـ ا ـب |

## Completeness Basis

Runtime lesson object plus generated markdown plus Stage A integration coverage.
