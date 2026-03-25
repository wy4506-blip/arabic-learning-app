# Lesson 12 Current Script Copy

- Packet type: `NATIVE_REVIEW`
- Review status: `needs_native_review`
- Batch: `BATCH_C`
- Lesson ID: `lesson_12_you_can_read_a_tiny_arabic_card`
- Lesson title: `You Can Read a Tiny Arabic Card`
- Review summary: The Stage C payoff lesson is structurally ready, but clue-sensitive lines and the tiny-card list should be checked before export.
- Review focus: Keep the tiny card readable as a paced list and do not let clue lines rely on unreviewed isolated glyph handling.
- Source script: `docs/voiceover_production_lessons_1_16/scripts/final/lesson_12_you_can_read_a_tiny_arabic_card.md`
- Source data: `docs/voiceover_production_lessons_1_16/data/lesson_12_you_can_read_a_tiny_arabic_card.json`
- Estimated narration runtime: `01:23`
- Estimated Arabic asset runtime: `00:18`

Use this copy as read-only context. Put reviewer comments and decisions in the lesson review sheet, not in this file.

---

# Lesson 12 Voiceover Script

- Status: final script normalized from existing repository content
- Review status: `needs_native_review`
- Review summary: The Stage C payoff lesson is structurally ready, but clue-sensitive lines and the tiny-card list should be checked before export.
- Batch: `Batch C`
- Stage: Stage C
- Lesson ID: `lesson_12_you_can_read_a_tiny_arabic_card`
- Working title: You Can Read a Tiny Arabic Card
- Estimated narration runtime: `01:23`
- Estimated Arabic asset runtime: `00:18`
- Generated at: `2026-03-21T12:48:18.960405Z`
- Canonical source policy: use the runtime `V2MicroLesson` object only; do not add new teaching copy.

## Recording Profile

- Audience: absolute beginners
- Baseline delivery: warm, calm, clear, and beginner-safe
- Arabic handling: keep every Arabic item intact, do not paraphrase, and leave one clean beat around short Arabic inserts
- Repeatability rule: short prompts and short Arabic models should sound easy to repeat once
- Review focus: Keep the tiny card readable as a paced list and do not let clue lines rely on unreviewed isolated glyph handling.

## Canonical Sources

- `lib/data/generated_stage_c_preview_lessons.dart`
- `test/lesson_12_you_can_read_a_tiny_arabic_card_test.dart`

## Normalized Voiceover Segments

| segment_id | asset_stem | segment_name | segment_type | duration_target | export_state | delivery_notes | repeatable | native_review | source | text |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `L12_SEG_001` | `l12_ord_001` | `OPEN_TITLE` | `opening` | `00:02-00:04` | `ready` | Short open. Calm lift on the first words, then a clean stop. | `no` | `no` | `lesson.title` | You Can Read a Tiny Arabic Card |
| `L12_SEG_002` | `l12_ord_002` | `OPEN_OUTCOME` | `opening` | `00:04-00:09` | `ready` | Steady overview line. Keep it calm, clear, and lightly encouraging. | `no` | `no` | `lesson.outcomeSummary` | After this lesson, you can get through one tiny Arabic card using known words and the first Stage C clues. |
| `L12_SEG_003` | `l12_ord_003` | `OPEN_OBJECTIVE_01` | `opening` | `00:04-00:08` | `ready` | Steady overview line. Keep it calm, clear, and lightly encouraging. | `no` | `no` | `objective:process_tiny_supported_arabic_card` | Process one tiny supported Arabic card using known words and early Stage C clues. |
| `L12_SEG_004` | `l12_ord_004` | `TEACH_HEADER_01` | `section_header` | `00:02-00:03` | `ready` | Short open. Calm lift on the first words, then a clean stop. | `no` | `no` | `content:goal_tiny_supported_card.title` | Lesson Goal |
| `L12_SEG_005` | `l12_ord_005` | `TEACH_BODY_01` | `teaching_narration` | `00:03-00:07` | `ready` | Teaching line. Warm, calm, and conversational with one clear sentence boundary. | `no` | `no` | `content:goal_tiny_supported_card.body` | Use what you already know to finish Stage C with one tiny Arabic card. |
| `L12_SEG_006` | `l12_ord_006` | `TEACH_HEADER_02` | `section_header` | `00:02-00:03` | `ready` | Short open. Calm lift on the first words, then a clean stop. | `no` | `no` | `content:input_tiny_supported_card.title` | Tiny Arabic Card |
| `L12_SEG_007` | `l12_ord_007` | `TEACH_BODY_02` | `teaching_narration` | `00:03-00:08` | `ready` | Teaching line. Warm, calm, and conversational with one clear sentence boundary. | `no` | `no` | `content:input_tiny_supported_card.body` | This is one small Arabic card you can actually get through by leaning on known words and two helpful clues. |
| `L12_SEG_008` | `l12_ord_008` | `TEACH_HEADER_03` | `section_header` | `00:02-00:03` | `ready` | Short open. Calm lift on the first words, then a clean stop. | `no` | `no` | `content:model_tiny_card_strategy.title` | Use Known Words First |
| `L12_SEG_009` | `l12_ord_009` | `TEACH_BODY_03` | `teaching_narration` | `00:03-00:09` | `ready` | Teaching line. Warm and clear. Slow slightly around the Arabic and return to the base pace after it. | `no` | `no` | `content:model_tiny_card_strategy.body` | Anchor on كتاب and قلم first, catch بيت, then use سيارة and سيارات to finish the card. |
| `L12_SEG_010` | `l12_ord_010` | `TEACH_HEADER_04` | `section_header` | `00:02-00:04` | `ready` | Short open. Calm lift on the first words, then a clean stop. | `no` | `no` | `content:explain_tiny_card_clues.title` | The Card Still Gives Clues |
| `L12_SEG_011` | `l12_ord_011` | `TEACH_BODY_04` | `teaching_narration` | `00:03-00:10` | `ready` | Teaching line. Warm, calm, and conversational with one clear sentence boundary. | `no` | `no` | `content:explain_tiny_card_clues.body` | This card is the Stage C payoff. You are not learning a new system here. You are proving you can handle a small piece of Arabic. |
| `L12_SEG_012` | `l12_ord_012` | `PROMPT_01` | `instruction_prompt` | `00:03-00:07` | `ready` | Instructional prompt. Keep the action verb crisp, leave one clean beat before the Arabic, and allow answer space at the end. | `yes` | `no` | `practice:hear_bayt_on_tiny_card.prompt` | Listen, then tap بيت on the tiny card. |
| `L12_SEG_013` | `l12_ord_013` | `PROMPT_02` | `instruction_prompt` | `00:03-00:06` | `ready` | Instructional prompt. Keep the action verb crisp and allow a short answer pause at the end. | `yes` | `no` | `practice:main_meaning_house_on_tiny_card.prompt` | Which item on the card means house? |
| `L12_SEG_014` | `l12_ord_014` | `PROMPT_03` | `instruction_prompt` | `00:03-00:08` | `review` | Instructional prompt. Keep the action verb crisp, leave one clean beat before the Arabic, and allow answer space at the end. Review before export. The prompt includes an isolated ة clue inside English narration and should be checked before TTS export. | `yes` | `check` | `practice:spot_clue_item_on_tiny_card.prompt` | Which item on the card shows the ة clue? |
| `L12_SEG_015` | `l12_ord_015` | `PROMPT_04` | `instruction_prompt` | `00:03-00:07` | `ready` | Instructional prompt. Keep the action verb crisp and allow a short answer pause at the end. | `yes` | `no` | `practice:spot_more_than_one_on_tiny_card.prompt` | Which item on the card shows more than one? |
| `L12_SEG_016` | `l12_ord_016` | `PROMPT_05` | `instruction_prompt` | `00:03-00:07` | `ready` | Instructional prompt. Keep the action verb crisp and allow a short answer pause at the end. | `yes` | `no` | `practice:rebuild_tiny_card_order.prompt` | Build the tiny card back in the same order. |
| `L12_SEG_017` | `l12_ord_017` | `PROMPT_06` | `instruction_prompt` | `00:03-00:07` | `ready` | Instructional prompt. Keep the action verb crisp and allow a short answer pause at the end. | `yes` | `no` | `practice:recall_house_from_tiny_card.prompt` | From the tiny card, recall the Arabic word for house. |

## Normalized Arabic Model Bank

| bank_id | asset_stem | asset_name | asset_type | duration_target | export_state | delivery_notes | repeatable | native_review | source | spoken_text | display_text | transliteration | meaning | notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `L12_AR_001` | `l12_ar_001` | `AR_LIST_01` | `list` | `00:03-00:08` | `review` | Arabic list, not a sentence. Give each item its own beat and keep the order clean. Preserve the source spoken-versus-display split exactly as written. Spoken text follows audioQueryText; display text preserves on-screen form. Review before export. The five-item tiny-card sequence needs controlled pauses so the list stays readable and contrastive. | `yes` | `check` | `content:input_tiny_supported_card` | كتاب قلم بيت سيارة سيارات | كتاب<br>قلم<br>بيت<br>سيارة<br>سيارات |  | book / pen / house / car / cars | Spoken text follows audioQueryText; display text preserves on-screen form. |
| `L12_AR_002` | `l12_ar_002` | `AR_WORD_01` | `word` | `00:02-00:03` | `ready` | Single Arabic word. Neutral model, one clean pronunciation, no extra sentence melody. | `yes` | `no` | `practice:hear_bayt_on_tiny_card.arabicText` | بيت | بيت |  | house |  |
| `L12_AR_003` | `l12_ar_003` | `AR_WORD_02` | `word` | `00:02-00:03` | `ready` | Single Arabic word. Neutral model, one clean pronunciation, no extra sentence melody. | `yes` | `no` | `practice:spot_clue_item_on_tiny_card.arabicText` | سيارة | سيارة |  | clue-bearing item |  |
| `L12_AR_004` | `l12_ar_004` | `AR_WORD_03` | `word` | `00:02-00:03` | `ready` | Single Arabic word. Neutral model, one clean pronunciation, no extra sentence melody. | `yes` | `no` | `practice:spot_more_than_one_on_tiny_card.arabicText` | سيارات | سيارات |  | cars / more than one |  |
| `L12_AR_005` | `l12_ar_005` | `AR_BUILD_01` | `build_artifact` | `00:02-00:04` | `review` | Build artifact, not natural continuous speech. Keep it out of blind TTS export until confirmed. Review before export. The rebuilt card sequence is exportable only if list pacing is explicitly preserved in the spoken output. | `no` | `check` | `practice:rebuild_tiny_card_order.expectedAnswer` | كتاب قلم بيت سيارة سيارات | كتاب قلم بيت سيارة سيارات |  |  |  |

## Review Flags

| source_ref | current_id | asset_stem | export_state | native_review | reason | text |
| --- | --- | --- | --- | --- | --- | --- |
| `content:input_tiny_supported_card` | `L12_AR_001` | `l12_ar_001` | `review` | `check` | The five-item tiny-card sequence needs controlled pauses so the list stays readable and contrastive. | كتاب قلم بيت سيارة سيارات |
| `practice:spot_clue_item_on_tiny_card.prompt` | `L12_SEG_014` | `l12_ord_014` | `review` | `check` | The prompt includes an isolated ة clue inside English narration and should be checked before TTS export. | Which item on the card shows the ة clue? |
| `practice:rebuild_tiny_card_order.expectedAnswer` | `L12_AR_005` | `l12_ar_005` | `review` | `check` | The rebuilt card sequence is exportable only if list pacing is explicitly preserved in the spoken output. | كتاب قلم بيت سيارة سيارات |

## Completeness Basis

Runtime lesson object plus dedicated test; runtime object is canonical because generated markdown is missing.

## Source Caveat

- Lesson 12 has no generated markdown spec in docs/generated_lessons. This framework follows the runtime lesson object and dedicated test only.
