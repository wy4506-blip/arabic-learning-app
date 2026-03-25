# Lesson Voiceover Production Framework 1-16

This package builds a reusable voiceover production framework for Foundation lessons 1-16 while enforcing two non-negotiable rules:

1. only lessons with final repository content receive final voiceover scripts
2. no lesson is cleared for blind TTS export before normalized review metadata exists

Generated at: `2026-03-21T12:48:18.960405Z`

## Included Outputs

- `voiceover_manifest.json`: top-level lesson status manifest
- `scripts/final/`: normalized final voiceover scripts for completed lessons already in the repo
- `scripts/placeholders/`: stable placeholder files for unfinished lessons
- `data/`: machine-readable per-lesson manifests for recording or synthesis tooling
- `review_status_lessons_01_12.md`: per-lesson pass / revise / needs-native-review summary
- `recording_batch_plan_lessons_01_12.md`: proposed recording batches for Lessons 1-12
- `audio_filename_convention_spec.md`: stable filename convention for human recording and TTS export
- `templates/lesson_voiceover_script_template.md`: normalized template for future lesson script generation
- `missing_content_report.md`: explicit blocker report for Lessons 13-16

## Source-of-Truth Policy

1. Runtime `V2MicroLesson` objects are canonical whenever they exist.
2. Generated lesson markdown is referenced only when it already exists in the repository.
3. Planning-only lessons stay placeholder-only. No final prompt text, Arabic targets, or narration is inferred from planning summaries.
4. Review-ready normalization may add delivery notes, duration targets, export-state flags, and native-review flags, but it does not invent final lesson content.

## Current Status

- Final scripts normalized: Lessons 1-12
- Placeholder only: Lessons 13-16
- Review summary: `6` pass, `1` revise, `5` needs native review

## Regeneration

```powershell
dart run tool/generate_lesson_voiceover_framework.dart
```

## Export Guidance

- Use `asset_stem` as the canonical logical stem for future recording and TTS work.
- Treat `review_status_lessons_01_12.md` and the per-script `Review Flags` section as export gates.
- Preserve placeholder-only state for Lessons 13-16 until runtime lesson content exists.
