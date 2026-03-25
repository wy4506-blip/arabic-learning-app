# Lesson 03 Flagged Review Items

- Packet type: `REVISE`
- Review status: `revise`
- Batch: `BATCH_A`
- Lesson ID: `V2-A1-03-PREVIEW`
- Lesson title: `One Word, Connected Shape`
- Review summary: The lesson word itself is fine, but connection-path build artifacts should not be sent into blind TTS export as normal speech.
- Review focus: Record the core word content normally, but keep connection-path artifacts out of the first export pass.
- Flagged item count: `2`
- Full current script copy: `lesson_03_current_script.md`
- Review sheet: `lesson_03_review_sheet.csv`

## 01. `L03_AR_003`

- Row kind: `ARABIC_ASSET`
- Segment type: `fragment`
- Asset stem: `l03_ar_003`
- Source ref: `practice:recall_repeated_family_in_bab.expectedAnswer`
- Export state: `HOLD`
- Native review flag: `REQUIRED`
- Planned audio filename: `l03_ar_003_normal.mp3`
- Logical asset path: `lesson_03/voiceover/l03_ar_003_normal.mp3`
- Risk reason: The repeated-family cue is an orthographic fragment rather than a self-evident spoken target.
- Delivery note: Orthographic fragment. Keep it isolated and do not improvise its spoken treatment. Hold from export until this line is manually cleared. The repeated-family cue is an orthographic fragment rather than a self-evident spoken target.

Current line text:
```text
ب
```

Support reference:
```text
display=ب
```

Reviewer comment:
`<fill in>`

Suggested revision:
`<fill in>`

Decision:
`<fill in>`

Final resolution:
`<fill in>`

## 02. `L03_AR_004`

- Row kind: `ARABIC_ASSET`
- Segment type: `build_artifact`
- Asset stem: `l03_ar_004`
- Source ref: `practice:build_bab_from_connection.expectedAnswer`
- Export state: `HOLD`
- Native review flag: `NOT_REQUIRED`
- Planned audio filename: `l03_ar_004_normal.mp3`
- Logical asset path: `lesson_03/voiceover/l03_ar_004_normal.mp3`
- Risk reason: The connection path بـ ا ـب is a UI build artifact, not natural continuous Arabic speech.
- Delivery note: Build artifact, not natural continuous speech. Keep it out of blind TTS export until confirmed. Hold from export until this line is manually cleared. The connection path بـ ا ـب is a UI build artifact, not natural continuous Arabic speech.

Current line text:
```text
بـ ا ـب
```

Support reference:
```text
display=بـ ا ـب
```

Reviewer comment:
`<fill in>`

Suggested revision:
`<fill in>`

Decision:
`<fill in>`

Final resolution:
`<fill in>`

