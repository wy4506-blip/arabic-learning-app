# Lesson 10 Voiceover Script

- Status: final script normalized from existing repository content
- Review status: `needs_native_review`
- Review summary: The lesson concept is clear, but isolated ة references and clue-building artifacts should not be blindly exported.
- Batch: `Batch C`
- Stage: Stage C
- Lesson ID: `lesson_10_arabic_gives_you_a_clue_ta_marbuta`
- Working title: Arabic Gives You a Clue: ة
- Estimated narration runtime: `01:37`
- Estimated Arabic asset runtime: `00:16`
- Generated at: `2026-03-21T12:48:18.960405Z`
- Canonical source policy: use the runtime `V2MicroLesson` object only; do not add new teaching copy.

## Recording Profile

- Audience: absolute beginners
- Baseline delivery: warm, calm, clear, and beginner-safe
- Arabic handling: keep every Arabic item intact, do not paraphrase, and leave one clean beat around short Arabic inserts
- Repeatability rule: short prompts and short Arabic models should sound easy to repeat once
- Review focus: Decide how isolated ة should be spoken, if at all, before any human or TTS batch export.

## Canonical Sources

- `lib/data/generated_stage_c_preview_lessons.dart`
- `docs/generated_lessons/v2_c1_10_arabic_gives_you_a_clue_ta_marbuta.md`
- `test/lesson_10_arabic_gives_you_a_clue_ta_marbuta_test.dart`

## Normalized Voiceover Segments

| segment_id | asset_stem | segment_name | segment_type | duration_target | export_state | delivery_notes | repeatable | native_review | source | text |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `L10_SEG_001` | `l10_ord_001` | `OPEN_TITLE` | `opening` | `00:02-00:05` | `hold` | Short open. Calm lift on the first words, then a clean stop. Hold from export until this line is manually cleared. The title includes isolated ة, which needs a spoken-form decision before recording or TTS export. | `yes` | `check` | `lesson.title` | Arabic Gives You a Clue: ة |
| `L10_SEG_002` | `l10_ord_002` | `OPEN_OUTCOME` | `opening` | `00:04-00:10` | `review` | Steady overview line. Keep the English flowing and slow slightly around Arabic inserts. Review before export. The isolated ة inside an English sentence may be misread by TTS unless its spoken rendering is fixed first. | `no` | `check` | `lesson.outcomeSummary` | After this lesson, you can spot one helpful page clue, ة, in سيارة, with كلمة as a light confirmation. |
| `L10_SEG_003` | `l10_ord_003` | `OPEN_OBJECTIVE_01` | `opening` | `00:04-00:09` | `review` | Steady overview line. Keep the English flowing and slow slightly around Arabic inserts. Review before export. The isolated glyph should not be left to narrator or engine guesswork. | `no` | `check` | `objective:notice_ta_marbuta_clue` | Notice ة as a helpful clue on the page in one tiny controlled set. |
| `L10_SEG_004` | `l10_ord_004` | `TEACH_HEADER_01` | `section_header` | `00:02-00:03` | `ready` | Short open. Calm lift on the first words, then a clean stop. | `no` | `no` | `content:goal_ta_marbuta_clue.title` | Lesson Goal |
| `L10_SEG_005` | `l10_ord_005` | `TEACH_BODY_01` | `teaching_narration` | `00:03-00:09` | `review` | Teaching line. Warm and clear. Slow slightly around the Arabic and return to the base pace after it. Review before export. The isolated glyph inside the English narration needs a confirmed spoken treatment. | `no` | `check` | `content:goal_ta_marbuta_clue.body` | Look for one helpful page clue. In this lesson, Arabic gives you one small visible hint: ة. |
| `L10_SEG_006` | `l10_ord_006` | `TEACH_HEADER_02` | `section_header` | `00:02-00:03` | `ready` | Short open. Calm lift on the first words, then a clean stop. | `no` | `no` | `content:input_sayyara_clue.title` | Main Clue Word |
| `L10_SEG_007` | `l10_ord_007` | `TEACH_BODY_02` | `teaching_narration` | `00:03-00:09` | `ready` | Teaching line. Warm and clear. Slow slightly around the Arabic and return to the base pace after it. | `no` | `no` | `content:input_sayyara_clue.body` | Start with one real clue-carrier. سيارة is the main word that makes this clue feel useful and readable. |
| `L10_SEG_008` | `l10_ord_008` | `TEACH_HEADER_03` | `section_header` | `00:02-00:04` | `ready` | Short open. Calm lift on the first words, then a clean stop. | `no` | `no` | `content:explain_ta_marbuta_clue.title` | Arabic Gives You A Clue |
| `L10_SEG_009` | `l10_ord_009` | `TEACH_BODY_03` | `teaching_narration` | `00:03-00:10` | `review` | Teaching line. Warm and clear. Slow slightly around the Arabic and return to the base pace after it. Review before export. The isolated glyph inside the English narration needs a confirmed spoken treatment. | `no` | `check` | `content:explain_ta_marbuta_clue.body` | When you see ة in this tiny set, let it feel like a page clue. You are not memorizing a rule block. |
| `L10_SEG_010` | `l10_ord_010` | `TEACH_HEADER_04` | `section_header` | `00:02-00:03` | `ready` | Short open. Calm lift on the first words, then a clean stop. | `no` | `no` | `content:support_kalima_clue.title` | One Light Confirmation |
| `L10_SEG_011` | `l10_ord_011` | `TEACH_BODY_04` | `teaching_narration` | `00:03-00:09` | `ready` | Teaching line. Warm and clear. Slow slightly around the Arabic and return to the base pace after it. | `no` | `no` | `content:support_kalima_clue.body` | You see the same clue again in كلمة. This confirms the pattern, but سيارة stays the main anchor. |
| `L10_SEG_012` | `l10_ord_012` | `TEACH_HEADER_05` | `section_header` | `00:02-00:04` | `ready` | Short open. Calm lift on the first words, then a clean stop. | `no` | `no` | `content:contrast_no_clue_words.title` | See The Clue, See The Difference |
| `L10_SEG_013` | `l10_ord_013` | `TEACH_BODY_05` | `teaching_narration` | `00:03-00:08` | `ready` | Teaching line. Warm, calm, and conversational with one clear sentence boundary. | `no` | `no` | `content:contrast_no_clue_words.body` | Known words help you notice the difference between words that show the clue and words that do not. |
| `L10_SEG_014` | `l10_ord_014` | `PROMPT_01` | `instruction_prompt` | `00:03-00:08` | `review` | Instructional prompt. Keep the action verb crisp, leave one clean beat before the Arabic, and allow answer space at the end. Review before export. The prompt contains an isolated orthographic clue and should be reviewed before TTS export. | `yes` | `check` | `practice:spot_ta_marbuta_in_sayyara.prompt` | Which ending is the helpful page clue in سيارة? |
| `L10_SEG_015` | `l10_ord_015` | `PROMPT_02` | `instruction_prompt` | `00:03-00:08` | `ready` | Instructional prompt. Keep the action verb crisp, leave one clean beat before the Arabic, and allow answer space at the end. | `yes` | `no` | `practice:recognize_kalima_shares_clue.prompt` | Which other word in this lesson shows the same clue as سيارة? |
| `L10_SEG_016` | `l10_ord_016` | `PROMPT_03` | `instruction_prompt` | `00:03-00:07` | `ready` | Instructional prompt. Keep the action verb crisp and allow a short answer pause at the end. | `yes` | `no` | `practice:clue_vs_no_clue_contrast.prompt` | Which word in this tiny set shows the clue? |
| `L10_SEG_017` | `l10_ord_017` | `PROMPT_04` | `instruction_prompt` | `00:03-00:07` | `ready` | Instructional prompt. Keep the action verb crisp, leave one clean beat before the Arabic, and allow answer space at the end. | `yes` | `no` | `practice:recognize_sayyara_meaning.prompt` | In this clue lesson, سيارة means... |
| `L10_SEG_018` | `l10_ord_018` | `PROMPT_05` | `instruction_prompt` | `00:03-00:07` | `ready` | Instructional prompt. Keep the action verb crisp, leave one clean beat before the Arabic, and allow answer space at the end. | `yes` | `no` | `practice:restore_ta_marbuta_in_context.prompt` | Complete the clue word with reduced support: سيار_ |
| `L10_SEG_019` | `l10_ord_019` | `PROMPT_06` | `instruction_prompt` | `00:03-00:08` | `review` | Instructional prompt. Keep the action verb crisp, leave one clean beat before the Arabic, and allow answer space at the end. Review before export. The prompt mixes an orthographic build instruction with isolated ة and needs reviewed spoken handling. | `yes` | `check` | `practice:mark_ta_marbuta_output.prompt` | Build the clue-marking action in order: سيار then ة. |

## Normalized Arabic Model Bank

| bank_id | asset_stem | asset_name | asset_type | duration_target | export_state | delivery_notes | repeatable | native_review | source | spoken_text | display_text | transliteration | meaning | notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `L10_AR_001` | `l10_ar_001` | `AR_WORD_01` | `word` | `00:02-00:03` | `ready` | Single Arabic word. Neutral model, one clean pronunciation, no extra sentence melody. | `yes` | `no` | `content:input_sayyara_clue` | سيارة | سيارة | sayyara | car |  |
| `L10_AR_002` | `l10_ar_002` | `AR_WORD_02` | `word` | `00:02-00:03` | `ready` | Single Arabic word. Neutral model, one clean pronunciation, no extra sentence melody. | `yes` | `no` | `content:support_kalima_clue` | كلمة | كلمة | kalima | word |  |
| `L10_AR_003` | `l10_ar_003` | `AR_LIST_01` | `list` | `00:03-00:07` | `ready` | Arabic list, not a sentence. Give each item its own beat and keep the order clean. | `yes` | `no` | `content:contrast_no_clue_words` | سيارة / كلمة / كتاب / بيت | سيارة / كلمة / كتاب / بيت |  |  |  |
| `L10_AR_004` | `l10_ar_004` | `AR_FRAGMENT_01` | `fragment` | `00:01-00:02` | `hold` | Orthographic fragment. Keep it isolated and do not improvise its spoken treatment. Hold from export until this line is manually cleared. The standalone glyph ة is an orthographic clue, not a self-evident standalone spoken asset. | `no` | `check` | `practice:spot_ta_marbuta_in_sayyara.arabicText` | ة | ة |  | helpful ending clue |  |
| `L10_AR_005` | `l10_ar_005` | `AR_BUILD_01` | `build_artifact` | `00:02-00:04` | `hold` | Build artifact, not natural continuous speech. Keep it out of blind TTS export until confirmed. Hold from export until this line is manually cleared. The build artifact سيار ة is not natural continuous Arabic speech and should not enter blind export. | `no` | `check` | `practice:mark_ta_marbuta_output.expectedAnswer` | سيار ة | سيار ة |  |  |  |

## Review Flags

| source_ref | current_id | asset_stem | export_state | native_review | reason | text |
| --- | --- | --- | --- | --- | --- | --- |
| `lesson.title` | `L10_SEG_001` | `l10_ord_001` | `hold` | `check` | The title includes isolated ة, which needs a spoken-form decision before recording or TTS export. | Arabic Gives You a Clue: ة |
| `lesson.outcomeSummary` | `L10_SEG_002` | `l10_ord_002` | `review` | `check` | The isolated ة inside an English sentence may be misread by TTS unless its spoken rendering is fixed first. | After this lesson, you can spot one helpful page clue, ة, in سيارة, with كلمة as a light confirmation. |
| `objective:notice_ta_marbuta_clue` | `L10_SEG_003` | `l10_ord_003` | `review` | `check` | The isolated glyph should not be left to narrator or engine guesswork. | Notice ة as a helpful clue on the page in one tiny controlled set. |
| `content:goal_ta_marbuta_clue.body` | `L10_SEG_005` | `l10_ord_005` | `review` | `check` | The isolated glyph inside the English narration needs a confirmed spoken treatment. | Look for one helpful page clue. In this lesson, Arabic gives you one small visible hint: ة. |
| `content:explain_ta_marbuta_clue.body` | `L10_SEG_009` | `l10_ord_009` | `review` | `check` | The isolated glyph inside the English narration needs a confirmed spoken treatment. | When you see ة in this tiny set, let it feel like a page clue. You are not memorizing a rule block. |
| `practice:spot_ta_marbuta_in_sayyara.prompt` | `L10_SEG_014` | `l10_ord_014` | `review` | `check` | The prompt contains an isolated orthographic clue and should be reviewed before TTS export. | Which ending is the helpful page clue in سيارة? |
| `practice:mark_ta_marbuta_output.prompt` | `L10_SEG_019` | `l10_ord_019` | `review` | `check` | The prompt mixes an orthographic build instruction with isolated ة and needs reviewed spoken handling. | Build the clue-marking action in order: سيار then ة. |
| `practice:spot_ta_marbuta_in_sayyara.arabicText` | `L10_AR_004` | `l10_ar_004` | `hold` | `check` | The standalone glyph ة is an orthographic clue, not a self-evident standalone spoken asset. | ة |
| `practice:mark_ta_marbuta_output.expectedAnswer` | `L10_AR_005` | `l10_ar_005` | `hold` | `check` | The build artifact سيار ة is not natural continuous Arabic speech and should not enter blind export. | سيار ة |

## Completeness Basis

Runtime lesson object plus generated markdown plus dedicated test.
