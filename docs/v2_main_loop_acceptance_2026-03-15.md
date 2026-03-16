# V2 Main Loop Acceptance 2026-03-15

## Scope

- Home V2 primary card
- V2 micro-lesson entry
- V2 completion page
- V2 review-first entry shell
- Review completion back to home recommendation refresh

## Acceptance Result

- Pass: home can send the learner directly into the current V2 action
- Pass: review-first returns to home and the recommendation switches back to the mainline
- Pass: the existing V2 micro-lesson happy path remains intact
- Pass: V2 pilot copy is now localized for English at the lesson title, lesson outcome, objective summary, and review-first surface level

## Copy Closure

- Unified the English naming for the V2 pilot path:
  - V2 Pilot Path
  - Pilot Review
  - Start This V2 Lesson
  - Start Pilot Review
- Removed mixed-language lesson titles on English surfaces
- Removed the incorrect singular form "1 items due"

## Remaining Gaps

- Consolidation still reuses the generic review entry instead of a dedicated V2 consolidation shell
- Some deep V2 content bodies still live in data and may need full localization when those surfaces are exposed later
- This acceptance pass focuses on the current runnable pilot loop, not the full future lesson catalog