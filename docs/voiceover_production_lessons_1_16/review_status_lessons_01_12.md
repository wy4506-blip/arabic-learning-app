# Lessons 01-12 Voiceover Review Status

- Generated at: `2026-03-21T12:48:18.960405Z`
- Pass: `6` lessons
- Revise: `1` lessons
- Needs native review: `5` lessons
- Lessons 13-16 remain placeholder-only and were not moved into final-script status.

## Lesson Status

| Lesson | Batch | Status | Segment runtime | Arabic asset runtime | Summary |
| --- | --- | --- | --- | --- | --- |
| `01` | `Batch A` | `pass` | `01:27` | `00:03` | Single-word entry anchor is natural, beginner-safe, and ready after normalization. |
| `02` | `Batch A` | `pass` | `01:23` | `00:08` | The first owned word script is short, stable, and ready after normalization. |
| `03` | `Batch A` | `revise` | `01:32` | `00:13` | The lesson word itself is fine, but connection-path build artifacts should not be sent into blind TTS export as normal speech. |
| `04` | `Batch A` | `needs_native_review` | `01:44` | `00:13` | The lesson is structurally sound, but the vowelled support items should be checked by a native speaker before export. |
| `05` | `Batch B` | `pass` | `01:20` | `00:08` | The new-word script for قلم is clean, short, and export-ready after normalization. |
| `06` | `Batch B` | `pass` | `01:19` | `00:12` | The first fixed-expression script is clear and beginner-suitable after normalization. |
| `07` | `Batch B` | `pass` | `01:20` | `00:20` | The audio-first recognition lesson is ready once pack-list pacing is kept explicit in delivery notes. |
| `08` | `Batch B` | `pass` | `01:21` | `00:20` | The Stage B pack lesson is ready after normalization and consistent pacing notes. |
| `09` | `Batch C` | `needs_native_review` | `01:22` | `00:11` | The lesson is ready at the script level, but the supported-display version of بيت should be checked before export. |
| `10` | `Batch C` | `needs_native_review` | `01:37` | `00:16` | The lesson concept is clear, but isolated ة references and clue-building artifacts should not be blindly exported. |
| `11` | `Batch C` | `needs_native_review` | `01:26` | `00:17` | The one-versus-more lesson is beginner-safe, but the سيارة / سيارات contrast should be checked for export clarity. |
| `12` | `Batch C` | `needs_native_review` | `01:23` | `00:18` | The Stage C payoff lesson is structurally ready, but clue-sensitive lines and the tiny-card list should be checked before export. |

## Flagged Lines

### Lesson 03 - One Word, Connected Shape

| source_ref | current_id | asset_stem | export_state | native_review | reason | text |
| --- | --- | --- | --- | --- | --- | --- |
| `practice:recall_repeated_family_in_bab.expectedAnswer` | `L03_AR_003` | `l03_ar_003` | `hold` | `check` | The repeated-family cue is an orthographic fragment rather than a self-evident spoken target. | ب |
| `practice:build_bab_from_connection.expectedAnswer` | `L03_AR_004` | `l03_ar_004` | `hold` | `no` | The connection path بـ ا ـب is a UI build artifact, not natural continuous Arabic speech. | بـ ا ـب |

### Lesson 04 - Reading Support For Real Words

| source_ref | current_id | asset_stem | export_state | native_review | reason | text |
| --- | --- | --- | --- | --- | --- | --- |
| `content:input_kitab_supported` | `L04_AR_001` | `l04_ar_001` | `review` | `check` | The vowelled support form كِتاب should be confirmed for beginner-safe pronunciation and pacing. | كِتاب |
| `content:input_bab_supported` | `L04_AR_002` | `l04_ar_002` | `review` | `check` | The vowelled support form بَاب should be confirmed for beginner-safe pronunciation and pacing. | بَاب |
| `content:tiny_usage_glimpse` | `L04_AR_004` | `l04_ar_004` | `review` | `check` | The spoken/display split around the tiny usage glimpse should be confirmed before export. | هذا كِتاب |

### Lesson 09 - بيت Means House

| source_ref | current_id | asset_stem | export_state | native_review | reason | text |
| --- | --- | --- | --- | --- | --- | --- |
| `content:input_bayt_word` | `L09_AR_001` | `l09_ar_001` | `review` | `check` | The source preserves a spoken/display split for بيت / بَيْت that should be confirmed before export. | بيت |

### Lesson 10 - Arabic Gives You a Clue: ة

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

### Lesson 11 - One Or More? A Tiny Arabic Clue

| source_ref | current_id | asset_stem | export_state | native_review | reason | text |
| --- | --- | --- | --- | --- | --- | --- |
| `content:input_main_pair_sayyara` | `L11_AR_001` | `l11_ar_001` | `review` | `check` | The main pair needs a native-checked pause and contrast pattern so سيارة and سيارات do not blur together. | سيارة سيارات |
| `content:contrast_support_pair` | `L11_AR_002` | `l11_ar_002` | `review` | `check` | The support pair كلمة / كلمات also needs clear plural contrast in audio delivery. | كلمة كلمات |

### Lesson 12 - You Can Read a Tiny Arabic Card

| source_ref | current_id | asset_stem | export_state | native_review | reason | text |
| --- | --- | --- | --- | --- | --- | --- |
| `content:input_tiny_supported_card` | `L12_AR_001` | `l12_ar_001` | `review` | `check` | The five-item tiny-card sequence needs controlled pauses so the list stays readable and contrastive. | كتاب قلم بيت سيارة سيارات |
| `practice:spot_clue_item_on_tiny_card.prompt` | `L12_SEG_014` | `l12_ord_014` | `review` | `check` | The prompt includes an isolated ة clue inside English narration and should be checked before TTS export. | Which item on the card shows the ة clue? |
| `practice:rebuild_tiny_card_order.expectedAnswer` | `L12_AR_005` | `l12_ar_005` | `review` | `check` | The rebuilt card sequence is exportable only if list pacing is explicitly preserved in the spoken output. | كتاب قلم بيت سيارة سيارات |

