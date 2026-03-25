# Human Import Handoff Summary

- Generated at: `2026-03-21T15:08:47.894091Z`
- Task sheet: `docs/voiceover_production_lessons_1_16/recording_task_sheet_lessons_01_12.csv`
- Intake manifest: `not provided (task-sheet mode)`
- Filter mode: `lesson-level review (RECORDING_READY + READY)`
- Output: `docs/voiceover_production_lessons_1_16/human_import_handoff_sheet.csv`

## Totals

| Metric | Count |
| --- | --- |
| Total handoff rows | `118` |
| Narration segments | `101` |
| Arabic audio assets | `17` |

## Import Status Breakdown

| Import status | Count |
| --- | --- |
| `READY_FOR_IMPORT` | `118` |
| `HOLD` | `0` |
| `BLOCKED` | `0` |
| `IMPORTED` | `0` |

## Rows By Batch

| Batch | Count |
| --- | --- |
| `BATCH_A` | `37` |
| `BATCH_B` | `81` |

## Rows By Lesson

| Lesson ID | Count |
| --- | --- |
| `V2-A1-01-PREVIEW` | `18` |
| `V2-A1-02-PREVIEW` | `19` |
| `lesson_05_qalam_first_real_word_extension` | `18` |
| `lesson_06_hadha_first_fixed_expression` | `20` |
| `lesson_07_audio_first_known_content_recognition` | `22` |
| `lesson_08_first_usable_arabic_pack` | `21` |

## Exclusion Rules Applied

The following rows were excluded from this handoff:

- Lessons with `production_status=REVISE_REQUIRED` (Lesson 03: the connected-shape lesson returns for revision first).
- Lessons with `production_status=NATIVE_REVIEW_REQUIRED` (Lessons 04, 09, 10, 11, 12: native speaker review gating).
- Lessons 13-16: placeholder only, not yet scripted or approved.
- Segments with `export_state=HOLD`: held orthographic fragments and build artifacts not suitable for recording or TTS export.

## How To Update This Handoff

Re-run the export tool to regenerate this file from the latest data:

```powershell
dart run tool/export_human_import_handoff.dart
```

To apply actual QC results after recordings are returned and checked:

```powershell
dart run tool/export_human_import_handoff.dart \
  --intake-manifest=docs/voiceover_production_lessons_1_16/recording_intake_qc_outputs/completed_segments_report.csv
```
