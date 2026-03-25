# Lesson 12 Flagged Review Items

- Packet type: `NATIVE_REVIEW`
- Review status: `needs_native_review`
- Batch: `BATCH_C`
- Lesson ID: `lesson_12_you_can_read_a_tiny_arabic_card`
- Lesson title: `You Can Read a Tiny Arabic Card`
- Review summary: The Stage C payoff lesson is structurally ready, but clue-sensitive lines and the tiny-card list should be checked before export.
- Review focus: Keep the tiny card readable as a paced list and do not let clue lines rely on unreviewed isolated glyph handling.
- Flagged item count: `3`
- Full current script copy: `lesson_12_current_script.md`
- Review sheet: `lesson_12_review_sheet.csv`

## 01. `L12_SEG_014`

- Row kind: `NARRATION_SEGMENT`
- Segment type: `instruction_prompt`
- Asset stem: `l12_ord_014`
- Source ref: `practice:spot_clue_item_on_tiny_card.prompt`
- Export state: `REVIEW`
- Native review flag: `REQUIRED`
- Planned audio filename: `l12_ord_014_normal.mp3`
- Logical asset path: `lesson_12/voiceover/l12_ord_014_normal.mp3`
- Risk reason: The prompt includes an isolated ة clue inside English narration and should be checked before TTS export.
- Delivery note: Instructional prompt. Keep the action verb crisp, leave one clean beat before the Arabic, and allow answer space at the end. Review before export. The prompt includes an isolated ة clue inside English narration and should be checked before TTS export.

Current line text:
```text
Which item on the card shows the ة clue?
```

Support reference:
```text
ة
```

Reviewer comment:
`<fill in>`

Suggested revision:
`<fill in>`

Decision:
`<fill in>`

Final resolution:
`<fill in>`

## 02. `L12_AR_001`

- Row kind: `ARABIC_ASSET`
- Segment type: `list`
- Asset stem: `l12_ar_001`
- Source ref: `content:input_tiny_supported_card`
- Export state: `REVIEW`
- Native review flag: `REQUIRED`
- Planned audio filename: `l12_ar_001_normal.mp3`
- Logical asset path: `lesson_12/voiceover/l12_ar_001_normal.mp3`
- Risk reason: The five-item tiny-card sequence needs controlled pauses so the list stays readable and contrastive.
- Delivery note: Arabic list, not a sentence. Give each item its own beat and keep the order clean. Preserve the source spoken-versus-display split exactly as written. Spoken text follows audioQueryText; display text preserves on-screen form. Review before export. The five-item tiny-card sequence needs controlled pauses so the list stays readable and contrastive.

Current line text:
```text
كتاب قلم بيت سيارة سيارات
```

Support reference:
```text
display=كتاب
قلم
بيت
سيارة
سيارات ; meaning=book / pen / house / car / cars ; notes=Spoken text follows audioQueryText; display text preserves on-screen form.
```

Reviewer comment:
`<fill in>`

Suggested revision:
`<fill in>`

Decision:
`<fill in>`

Final resolution:
`<fill in>`

## 03. `L12_AR_005`

- Row kind: `ARABIC_ASSET`
- Segment type: `build_artifact`
- Asset stem: `l12_ar_005`
- Source ref: `practice:rebuild_tiny_card_order.expectedAnswer`
- Export state: `REVIEW`
- Native review flag: `REQUIRED`
- Planned audio filename: `l12_ar_005_normal.mp3`
- Logical asset path: `lesson_12/voiceover/l12_ar_005_normal.mp3`
- Risk reason: The rebuilt card sequence is exportable only if list pacing is explicitly preserved in the spoken output.
- Delivery note: Build artifact, not natural continuous speech. Keep it out of blind TTS export until confirmed. Review before export. The rebuilt card sequence is exportable only if list pacing is explicitly preserved in the spoken output.

Current line text:
```text
كتاب قلم بيت سيارة سيارات
```

Support reference:
```text
display=كتاب قلم بيت سيارة سيارات
```

Reviewer comment:
`<fill in>`

Suggested revision:
`<fill in>`

Decision:
`<fill in>`

Final resolution:
`<fill in>`

