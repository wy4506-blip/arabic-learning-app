# Recording Export Summary For Lessons 01-12

- Generated at: `2026-03-21T12:48:18.960405Z`
- Recording task sheet: `recording_task_sheet_lessons_01_12.csv`
- Review queue: `review_queue_lessons_01_12.csv`
- Summary scope: Lessons 1-12 only; Lessons 13-16 remain placeholder-only and are excluded from recording exports.
- Review status cross-check with markdown report: `MATCH`

## Counts By Production Status

| Production status | Lesson count | Row count |
| --- | --- | --- |
| `RECORDING_READY` | `6` | `119` |
| `REVISE_REQUIRED` | `1` | `21` |
| `NATIVE_REVIEW_REQUIRED` | `5` | `115` |

## Counts By Batch

| Batch | Lesson counts | Row counts | Review queue rows |
| --- | --- | --- | --- |
| `BATCH_A` | RECORDING_READY=2 ; REVISE_REQUIRED=1 ; NATIVE_REVIEW_REQUIRED=1 | RECORDING_READY=37 ; REVISE_REQUIRED=21 ; NATIVE_REVIEW_REQUIRED=26 | `5` |
| `BATCH_B` | RECORDING_READY=4 ; REVISE_REQUIRED=0 ; NATIVE_REVIEW_REQUIRED=0 | RECORDING_READY=82 ; REVISE_REQUIRED=0 ; NATIVE_REVIEW_REQUIRED=0 | `0` |
| `BATCH_C` | RECORDING_READY=0 ; REVISE_REQUIRED=0 ; NATIVE_REVIEW_REQUIRED=4 | RECORDING_READY=0 ; REVISE_REQUIRED=0 ; NATIVE_REVIEW_REQUIRED=89 | `15` |

## Export Totals

- Task sheet rows: `255`
- Review queue rows: `20`
- Ready batches: `BATCH_B` is fully `RECORDING_READY`; `BATCH_A` is mixed; `BATCH_C` remains fully review-gated.

## Production Rules Applied

- `pass` lessons map to `RECORDING_READY`.
- Lesson 3 maps to `REVISE_REQUIRED`.
- Lessons 4, 9, 10, 11, 12 map to `NATIVE_REVIEW_REQUIRED`.
- Lessons 13-16 stay `PLACEHOLDER_ONLY` and do not enter recording exports.
