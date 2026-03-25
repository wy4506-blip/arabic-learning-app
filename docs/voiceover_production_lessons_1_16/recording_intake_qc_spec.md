# Recording Intake And QC Spec

## Purpose

This layer sits between the existing recorder workpack and the existing human-audio import flow.

It does four things:

1. receives returned recorder files against stable planned filenames
2. records whether each expected segment was received, still missing, or failed QC
3. updates the recorder-facing workflow status in a reproducible way
4. produces import-ready and retake-ready reports without changing lesson content

This layer only works on lessons already present in the recorder workpack. It does not pull in blocked lessons or placeholder lessons 13-16.

## Upstream Inputs

The intake/QC layer depends on artifacts that already exist in the pipeline:

- normalized lesson scripts under `docs/voiceover_production_lessons_1_16/scripts/final/`
- recording task sheet under `docs/voiceover_production_lessons_1_16/recording_task_sheet_lessons_01_12.csv`
- recorder workpack under `docs/voiceover_production_lessons_1_16/recorder_workpack_lessons_01_02_05_06_07_08/`
- the current workpack manifest and recorder master checklist
- the stable filename convention under `docs/voiceover_production_lessons_1_16/audio_filename_convention_spec.md`
- the existing human import flow in `tool/import_human_audio.dart`

## Canonical Matching Key

Every returned recording row must match an expected workpack row by this stable triple:

- `lesson_id`
- `segment_id`
- `planned_audio_filename`

Use `planned_audio_filename` as the logical target slot.
Do not rename the logical target just because the concrete human delivery file has a suffix such as `__human__20260321-batch-a.wav`.

## Status Model

### Receive Status Enum

Use one of these values in `receive_status`:

- `TO_RECORD`: nothing has been returned yet
- `RECEIVED`: a file was returned for this planned segment
- `MISSING`: the segment was expected in the return batch but no file was delivered

### QC Status Enum

Use one of these values in `qc_status`:

- `TO_RECORD`: QC has not cleared the segment yet
- `QC_PASS`: accepted for import and downstream packaging
- `RETAKE_REQUIRED`: received, checked, and rejected for another pass

### Derived Recorder Workflow Mapping

The intake/QC script maps receive and QC state back onto the existing recorder workpack workflow field:

- `TO_RECORD` if nothing has been received or the row is still open
- `RECORDED` if `receive_status=RECEIVED` and QC has not passed or failed yet
- `RETAKE` if `qc_status=RETAKE_REQUIRED`
- `QC_PASS` if `qc_status=QC_PASS`

This keeps the new layer aligned with the current recorder workpack outputs instead of inventing a second unrelated workflow field.

## Required Row Fields

Every intake/QC row must support at least these fields:

- `lesson_id`
- `segment_id`
- `planned_audio_filename`
- `received_filename`
- `receive_status`
- `qc_status`
- `qc_notes`
- `retake_reason`
- `final_resolution`

The reusable templates in this package include those fields plus batch and lesson metadata from the workpack.

## File Templates

This package includes three reusable CSV templates:

- `recording_return_manifest_template.csv`
- `retake_queue_template.csv`
- `completed_segments_report_template.csv`

These files define the stable column contract only.

For a workpack-specific manifest that is already seeded with current lessons and planned filenames, run:

```powershell
 dart run tool/update_recording_status_from_intake.dart
```

That command emits `recording_return_manifest_seed.csv` from the current recorder workpack.

## Processing Rules

### Return Manifest Rules

- `received_filename` must stay blank unless `receive_status=RECEIVED`
- if `qc_status=QC_PASS`, then `receive_status` must be `RECEIVED`
- if `qc_status=RETAKE_REQUIRED`, then `receive_status` must be `RECEIVED`
- `retake_reason` is required when `qc_status=RETAKE_REQUIRED`
- if `final_resolution` is blank, the updater fills a default derived value

### Default Final Resolution Values

If `final_resolution` is blank, the updater derives one of these values:

- `OPEN`
- `QC_PENDING`
- `READY_FOR_IMPORT`
- `WAITING_ON_RETAKE`
- `NOT_RETURNED`

Teams may replace the default with a more specific note if needed.

## Script Outputs

`tool/update_recording_status_from_intake.dart` produces these derived artifacts:

- `recording_return_manifest_seed.csv`: current workpack rows with intake/QC columns prefilled to default values
- `recorder_master_checklist_updated.csv`: existing workpack checklist plus receive/QC fields and derived workflow state
- `retake_queue.csv`: rows that are either missing or explicitly marked `RETAKE_REQUIRED`
- `completed_segments_report.csv`: rows that passed QC and are ready for downstream import
- `recording_status_summary.md`: counts and validation summary

By default the script writes to:

- `docs/voiceover_production_lessons_1_16/recording_intake_qc_outputs/`

## How This Feeds The Existing Import Pipeline

This intake/QC layer does not import audio by itself.
It prepares the operational truth set for the import stage.

The downstream handoff rule is simple:

- only rows with `qc_status=QC_PASS` should move forward to human import
- `received_filename` should preserve the real returned file name from the recorder delivery batch
- the logical app target still comes from `planned_audio_filename` and `planned_audio_asset_path`
- actual import and variant naming remain the job of `tool/import_human_audio.dart`

## Scope Guardrails

- do not add recording-ready lessons that are not already in the current recorder workpack
- do not add revise or native-review blocked lessons to this layer unless they later become recording-ready and enter a recorder workpack
- do not touch placeholder lessons 13-16
- do not invent new lesson content or new logical asset stems
