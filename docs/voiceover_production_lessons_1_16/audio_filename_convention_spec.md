# Audio Filename Convention Spec

Generated at: `2026-03-21T12:48:18.960405Z`

## Goal

Use one stable logical stem per script segment or Arabic model asset, while still allowing multiple concrete outputs from human recording or TTS.

## Stable Base Rule

- Use the script `asset_stem` as the canonical logical stem.
- Never derive filenames from the lesson title or free-text segment name.
- Keep the logical filename stable even if the concrete source switches from TTS to human recording later.

## Logical Asset Path

```text
lesson_{NN}/voiceover/{asset_stem}_{speed}.{ext}
```

Examples:

- `lesson_01/voiceover/l01_ord_012_normal.mp3`
- `lesson_06/voiceover/l06_ar_002_normal.mp3`
- `lesson_10/voiceover/l10_ord_014_normal.mp3`

## Concrete Produced Asset Path

```text
lesson_{NN}/voiceover/{asset_stem}_{speed}__{source}__{stamp}.{ext}
```

Where:

- `{source}` = `human` or `tts-{provider}-{voice_slug}`
- `{stamp}` = `YYYYMMDD-{batch_or_run}`
- `{ext}` = `.wav` for masters, `.mp3` for bundled app assets unless a different delivery format is required

Examples:

- `lesson_01/voiceover/l01_ord_012_normal__human__20260321-batch-a.wav`
- `lesson_01/voiceover/l01_ord_012_normal__human__20260321-batch-a.mp3`
- `lesson_10/voiceover/l10_ord_014_normal__tts-azure-ar-saana__20260321-batch-c.wav`
- `lesson_10/voiceover/l10_ar_004_normal__tts-azure-ar-saana__20260321-batch-c.wav`

## Token Rules

- `lesson_{NN}` uses zero-padded lesson numbers, for example `lesson_03`.
- `asset_stem` must come directly from the normalized script or Arabic model bank, for example `l03_ord_015` or `l10_ar_004`.
- `speed` should stay explicit even for the default speed. Use `normal` unless the batch explicitly creates a `slow` variant.
- `ord` stems are narration or prompt segments.
- `ar` stems are Arabic model assets.

## Manifest Rule

- Content references should point at the logical filename.
- The audio manifest may redirect that logical request to a concrete human or TTS-produced file with suffixes such as `__human__20260321-batch-a`.
- This matches the current audio-service pattern where a stable logical request can resolve to a more specific concrete asset at runtime.

## Export Safety Rules

1. One segment or one Arabic model asset per file.
2. Do not bundle multiple script segments into one audio file.
3. Do not rename an existing `asset_stem` just because delivery notes changed.
4. Keep `hold` items out of automatic TTS export until the flagged review step is complete.
