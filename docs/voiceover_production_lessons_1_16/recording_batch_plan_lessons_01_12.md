# Recording Batch Plan For Lessons 01-12

- Generated at: `2026-03-21T12:48:18.960405Z`
- Batch A: Lessons 1-4
- Batch B: Lessons 5-8
- Batch C: Lessons 9-12

Use this plan before any TTS export work. Record ready items first, keep `review` items behind native-speaker confirmation, and keep `hold` items out of the first export pass.

## Batch A

- Scope: `4` lessons
- Review mix: `2` pass, `1` revise, `1` needs native review
- Estimated narration runtime: `06:06`
- Estimated Arabic asset runtime: `00:37`

| Lesson | Status | Main focus |
| --- | --- | --- |
| `01` Arabic Starts Here | `pass` | Keep the orientation language calm and do not over-dramatize the first Arabic word. |
| `02` First Real Word Success | `pass` | Keep prompts clean and let كتاب stay the clear center of the lesson. |
| `03` One Word, Connected Shape | `revise` | Record the core word content normally, but keep connection-path artifacts out of the first export pass. |
| `04` Reading Support For Real Words | `needs_native_review` | Confirm first-pass pronunciation and spoken-versus-display handling for the supported forms. |

Recommended order:
1. Record all ready narration segments for the batch first.
2. Record ready Arabic word or phrase assets next.
3. Leave `review` and `hold` items until the batch-specific review gate is cleared.

QA focus:
- Keep early-stage Arabic words slow, steady, and low-pressure.
- Do not let Lesson 3 connection-path artifacts slip into the normal export batch.
- Confirm Lesson 4 supported forms with a native speaker before export.

Review-first or hold items:
- `L03_AR_003` `l03_ar_003` `hold` `check`: The repeated-family cue is an orthographic fragment rather than a self-evident spoken target.
- `L03_AR_004` `l03_ar_004` `hold` `no`: The connection path بـ ا ـب is a UI build artifact, not natural continuous Arabic speech.
- `L04_AR_001` `l04_ar_001` `review` `check`: The vowelled support form كِتاب should be confirmed for beginner-safe pronunciation and pacing.
- `L04_AR_002` `l04_ar_002` `review` `check`: The vowelled support form بَاب should be confirmed for beginner-safe pronunciation and pacing.
- `L04_AR_004` `l04_ar_004` `review` `check`: The spoken/display split around the tiny usage glimpse should be confirmed before export.

## Batch B

- Scope: `4` lessons
- Review mix: `4` pass, `0` revise, `0` needs native review
- Estimated narration runtime: `05:20`
- Estimated Arabic asset runtime: `01:00`

| Lesson | Status | Main focus |
| --- | --- | --- |
| `05` One More Real Word: قلم | `pass` | Keep the delivery grounded and let the known pack stay supportive rather than dominant. |
| `06` This Is... Your First Fixed Expression | `pass` | Keep هذا steady and avoid turning the line into a grammar lecture in performance. |
| `07` Hear What You Already Know | `pass` | Treat pack lines as clean, separate items rather than one run-on utterance. |
| `08` Your First Usable Arabic Pack | `pass` | Keep the pack compact and avoid blurring word-versus-line contrasts. |

Recommended order:
1. Record all ready narration segments for the batch first.
2. Record ready Arabic word or phrase assets next.
3. Leave `review` and `hold` items until the batch-specific review gate is cleared.

QA focus:
- Preserve the word-versus-line contrast in Lessons 6-8.
- Treat pack lists as clearly separated items, not as run-on sentences.
- Keep the overall tone encouraging rather than performative.

Review-first or hold items:
- None.

## Batch C

- Scope: `4` lessons
- Review mix: `0` pass, `0` revise, `4` needs native review
- Estimated narration runtime: `05:48`
- Estimated Arabic asset runtime: `01:02`

| Lesson | Status | Main focus |
| --- | --- | --- |
| `09` بيت Means House | `needs_native_review` | Confirm whether the first-pass support on بَيْت should influence recording or stay display-only. |
| `10` Arabic Gives You a Clue: ة | `needs_native_review` | Decide how isolated ة should be spoken, if at all, before any human or TTS batch export. |
| `11` One Or More? A Tiny Arabic Clue | `needs_native_review` | Make sure the plural ending remains clearly audible and not blurred in pair recordings. |
| `12` You Can Read a Tiny Arabic Card | `needs_native_review` | Keep the tiny card readable as a paced list and do not let clue lines rely on unreviewed isolated glyph handling. |

Recommended order:
1. Record all ready narration segments for the batch first.
2. Record ready Arabic word or phrase assets next.
3. Leave `review` and `hold` items until the batch-specific review gate is cleared.

QA focus:
- Stage C is clue-sensitive: do not let TTS guess isolated orthographic symbols.
- Preserve contrast between سيارة and سيارات with explicit pauses and clear plural endings.
- Keep the tiny-card list in Lesson 12 readable as a list, not as a sentence.

Review-first or hold items:
- `L09_AR_001` `l09_ar_001` `review` `check`: The source preserves a spoken/display split for بيت / بَيْت that should be confirmed before export.
- `L10_SEG_001` `l10_ord_001` `hold` `check`: The title includes isolated ة, which needs a spoken-form decision before recording or TTS export.
- `L10_SEG_002` `l10_ord_002` `review` `check`: The isolated ة inside an English sentence may be misread by TTS unless its spoken rendering is fixed first.
- `L10_SEG_003` `l10_ord_003` `review` `check`: The isolated glyph should not be left to narrator or engine guesswork.
- `L10_SEG_005` `l10_ord_005` `review` `check`: The isolated glyph inside the English narration needs a confirmed spoken treatment.
- `L10_SEG_009` `l10_ord_009` `review` `check`: The isolated glyph inside the English narration needs a confirmed spoken treatment.
- `L10_SEG_014` `l10_ord_014` `review` `check`: The prompt contains an isolated orthographic clue and should be reviewed before TTS export.
- `L10_SEG_019` `l10_ord_019` `review` `check`: The prompt mixes an orthographic build instruction with isolated ة and needs reviewed spoken handling.
- `L10_AR_004` `l10_ar_004` `hold` `check`: The standalone glyph ة is an orthographic clue, not a self-evident standalone spoken asset.
- `L10_AR_005` `l10_ar_005` `hold` `check`: The build artifact سيار ة is not natural continuous Arabic speech and should not enter blind export.
- `L11_AR_001` `l11_ar_001` `review` `check`: The main pair needs a native-checked pause and contrast pattern so سيارة and سيارات do not blur together.
- `L11_AR_002` `l11_ar_002` `review` `check`: The support pair كلمة / كلمات also needs clear plural contrast in audio delivery.
- `L12_AR_001` `l12_ar_001` `review` `check`: The five-item tiny-card sequence needs controlled pauses so the list stays readable and contrastive.
- `L12_SEG_014` `l12_ord_014` `review` `check`: The prompt includes an isolated ة clue inside English narration and should be checked before TTS export.
- `L12_AR_005` `l12_ar_005` `review` `check`: The rebuilt card sequence is exportable only if list pacing is explicitly preserved in the spoken output.

