# Recorder Workpack For Lessons 01, 02, 05, 06, 07, 08

- Generated from: `docs/voiceover_production_lessons_1_16/recording_task_sheet_lessons_01_12.csv`
- Source summary: `docs/voiceover_production_lessons_1_16/recording_export_summary_lessons_01_12.md`
- Source summary generated at: `2026-03-21T12:48:18.960405Z`
- Scope: only `RECORDING_READY` lessons are included in this package.
- Included lessons: Lesson 01: Arabic Starts Here ; Lesson 02: First Real Word Success ; Lesson 05: One More Real Word: قلم ; Lesson 06: This Is... Your First Fixed Expression ; Lesson 07: Hear What You Already Know ; Lesson 08: Your First Usable Arabic Pack
- Excluded by rule: Lesson 03 (`REVISE_REQUIRED`), Lessons 04/09/10/11/12 (`NATIVE_REVIEW_REQUIRED`), Lessons 13-16 (`PLACEHOLDER_ONLY`)
- Total included rows: `119`

## Folder Structure

- `BATCH_A/`: Lessons 01-02
- `BATCH_B/`: Lessons 05-08
- `recorder_master_checklist.csv`: all included rows with recorder workflow status
- `workpack_manifest.json`: machine-readable package manifest for reproducible rebuilds

## Batch Totals

- `BATCH_A`: `37` rows across Lesson 01, Lesson 02
- `BATCH_B`: `82` rows across Lesson 05, Lesson 06, Lesson 07, Lesson 08

## Naming Convention

Use the planned logical filename from the task sheet as the source of truth, for example `l01_ord_012_normal.mp3`.

- Logical asset path stays `lesson_{NN}/voiceover/{asset_stem}_normal.mp3`
- Preferred human master export is `{asset_stem}_normal__human__20260321-batch-x.wav`
- Final human import variant can be `{asset_stem}_normal__human__20260321-batch-x.mp3`
- Do not rename the `asset_stem`, even if you need a new take

## Retake Convention

If a segment needs another pass:

- Change the checklist status from `RECORDED` to `RETAKE`
- Keep the same logical stem
- Put the retake identifier in the revision token, for example `l01_ord_012_normal__human__20260321-batch-a-retake02.wav`
- Once the retake is approved, the import-ready filename should go back to the clean revision form without the temporary retake suffix if you are only delivering the final chosen take

## Pace And Pause Expectations

- Treat the per-segment `delivery_note` as the first source of truth
- Keep pacing beginner-safe: calm, clear, and not theatrical
- Leave clean answer space where prompts ask for a pause
- Keep Arabic model assets neutral and isolated unless the segment note says otherwise
- Record one file per segment only; do not merge adjacent lines

## Export Format Expectations

- Preferred delivery master: mono `.wav`
- Current import pipeline also accepts `.wav`, `.mp3`, `.m4a`, and `.aac` when needed
- Planned logical filenames in the package remain `.mp3` because they point at the stable app-facing asset slot
- Avoid clipping consonants or trimming the tail so tightly that the ending sounds rushed

## Recorder Workflow Statuses

- `TO_RECORD`: not captured yet
- `RECORDED`: a clean take exists and is waiting for QC
- `RETAKE`: another take is required before acceptance
- `QC_PASS`: accepted for import and packaging
