# Foundation Pilot Minimal Integration Plan 2026-03-21

## Goal

Move the accepted 12-lesson foundation path from `preview-only` into a controlled pilot path with the smallest possible product and engineering risk.

This step does **not** mean replacing the current Home mainline immediately.
It means making `Stage A -> Stage B -> Stage C` runnable as one real pilot path with formal lesson progress and review evidence, behind a controlled entry.

## Current State

### What already exists

- `Stage A`, `Stage B`, and `Stage C` each have runnable preview lessons and chapter pages.
- There is already a unified overview entry at [v2_foundation_preview_page.dart](d:/APP/arabic_learning_app/lib/pages/v2_foundation_preview_page.dart).
- The preview lesson runtime in [v2_micro_lesson_page.dart](d:/APP/arabic_learning_app/lib/pages/v2_micro_lesson_page.dart) is already good enough for product review.
- The accepted foundation curriculum and lesson specs already exist in `docs/curriculum` and `docs/generated_lessons`.

### What is still blocking formal pilot use

The blocker is not the chapter UI.
The blocker is that the accepted foundation lessons still live outside the formal V2 lesson registry and formal V2 progression logic.

Today:

- preview lessons are launched via `widget.lesson`
- preview completion goes through `completePreviewLesson`
- preview completion does not write into live lesson progress
- preview completion does not write into live learning states / review seeds
- the formal lesson lookup still assumes `v2PilotMicroLessons`
- the formal snapshot and recommendation logic still assume `v2PilotMicroLessons`

So the real gap is:

`preview content exists` -> `formal lesson catalog + formal progression + controlled entry do not exist yet`

## Minimal Product Target

The smallest worthwhile target is:

1. Add one controlled entry for `Foundation Pilot`
2. Make Lessons `1-12` resolvable as formal V2 lessons by `lessonId`
3. Let completion write real lesson progress and review seeds
4. Keep the current Home mainline unchanged unless the pilot flag is explicitly enabled

This gives us a real pilot path without forcing the existing Home recommendation loop to switch over on day one.

## Recommended Implementation Shape

### Phase 1: Formal lesson registry

Create one canonical lesson catalog that can resolve:

- existing `v2PilotMicroLessons`
- accepted foundation candidate lessons (`Stage A`, `Stage B`, `Stage C`)

Recommended new file:

- [v2_micro_lesson_catalog.dart](d:/APP/arabic_learning_app/lib/data/v2_micro_lesson_catalog.dart)

Recommended responsibilities:

- export `allRegisteredV2MicroLessons`
- export `foundationPilotMicroLessons`
- provide `v2MicroLessonById(String lessonId)`
- provide `containsV2MicroLesson(String lessonId)`

This lets us stop hardcoding `v2PilotMicroLessons.firstWhere(...)` in multiple places.

### Phase 2: Formal completion path for foundation lessons

Update the formal completion path so it can operate on any registered V2 micro-lesson, not only the current 7-lesson pilot list.

Primary files:

- [v2_micro_lesson_page.dart](d:/APP/arabic_learning_app/lib/pages/v2_micro_lesson_page.dart)
- [v2_micro_lesson_completion_orchestrator.dart](d:/APP/arabic_learning_app/lib/services/v2_micro_lesson_completion_orchestrator.dart)
- [v2_micro_lesson_completion_page.dart](d:/APP/arabic_learning_app/lib/pages/v2_micro_lesson_completion_page.dart)

Required changes:

- resolve lessons via catalog helper instead of only `v2PilotMicroLessons`
- let formal completion build status against the correct lesson set
- keep preview mode intact for review use
- let completion copy and next-step messaging recognize foundation pilot lessons

Important boundary:

- do not break existing preview mode
- do not refactor unrelated lesson UI

### Phase 3: Controlled pilot entry

Add one clearly scoped entry such as:

- `Profile -> About -> Foundation Pilot Candidate`

This entry should:

- launch the same `Foundation` overview flow
- use formal lesson ids instead of preview lesson overrides
- write real progress
- remain obviously separate from the live Home recommendation until explicitly promoted

Likely file:

- [profile_page.dart](d:/APP/arabic_learning_app/lib/pages/profile_page.dart)

Optional new page:

- `v2_foundation_pilot_page.dart`

This page can reuse most of the structure from [v2_foundation_preview_page.dart](d:/APP/arabic_learning_app/lib/pages/v2_foundation_preview_page.dart), but should not be labeled `preview-only`.

### Phase 4: Controlled Home promotion

Only after Phase 1-3 are stable should we let Home use the new foundation path.

This should be behind one explicit switch, for example:

- local feature flag
- developer-only setting
- hardcoded pilot toggle while validating

Primary files:

- [home_page.dart](d:/APP/arabic_learning_app/lib/pages/home_page.dart)
- [v2_learning_snapshot_service.dart](d:/APP/arabic_learning_app/lib/services/v2_learning_snapshot_service.dart)
- possibly [app_settings.dart](d:/APP/arabic_learning_app/lib/models/app_settings.dart) and settings storage if the toggle needs persistence

Important rule:

- do not point Home at the 12-lesson foundation path until the controlled pilot entry has already been validated end to end

## Why This Order Is Lowest Risk

This order isolates the highest-value proof first:

- first prove the 12 lessons can behave like real lessons
- then prove the 12 lessons can behave like one real path
- only then connect Home recommendation

If we try to start from Home instead:

- we mix content validation with recommendation migration
- failures become harder to isolate
- rollback becomes messier

## Smallest Acceptable Acceptance Pass

Before any Home integration, the controlled pilot entry should pass this checklist:

### A. Lesson runtime

- Lesson 1 starts and completes as a formal lesson
- Lesson 8 completes with real review seeds attached
- Lesson 12 completes with a real end-of-stage milestone surface

### B. Path continuity

- completion from one lesson can move to the next lesson in sequence
- leaving and re-entering the foundation pilot resumes the correct current lesson
- the foundation pilot does not reset back to Lesson 1 after completion is written

### C. Review evidence

- weak or due content from foundation lessons appears in learning state
- the generated review seeds stay tied to the correct lesson ids
- the pilot path can surface a review-first state if due review is intentionally created

### D. Isolation

- existing preview entry still works
- existing live Home recommendation flow remains unchanged when the pilot flag is off

## Minimal Test Plan

Add only the smallest required new tests.

Recommended first layer:

- catalog resolution test
- controlled pilot chapter navigation test
- one completion persistence test for a foundation lesson
- one snapshot/progression test for the foundation lesson set

Likely files:

- `test/v2_micro_lesson_catalog_test.dart`
- `test/foundation_pilot_page_test.dart`
- `test/foundation_pilot_completion_test.dart`
- `test/v2_learning_snapshot_service_test.dart`

## Risks

### Risk 1: mixing foundation progress with current live pilot progress

Reason:

- both flows use the same progress and learning-state services

Mitigation:

- keep the first formal foundation entry outside Home
- clearly label it as candidate/pilot
- only promote to Home after the path feels stable

### Risk 2: completion messaging is still partly hardcoded by lesson id

Reason:

- completion copy in [v2_micro_lesson_completion_page.dart](d:/APP/arabic_learning_app/lib/pages/v2_micro_lesson_completion_page.dart) already contains stage-specific manual branches

Mitigation:

- extend only the branches needed for foundation pilot lessons
- avoid big localization cleanup in the same pass

### Risk 3: snapshot service remains coupled to one lesson list

Reason:

- [v2_learning_snapshot_service.dart](d:/APP/arabic_learning_app/lib/services/v2_learning_snapshot_service.dart) currently defaults to `v2PilotMicroLessons`

Mitigation:

- add lesson-list injection first
- keep the default behavior unchanged for current Home

## Recommended Next Coding Task

The best next implementation task is:

`Phase 1 + Phase 2a`

That means:

- add a canonical V2 lesson catalog
- update lesson lookup so foundation lessons can run in formal mode by `lessonId`
- keep Home unchanged for now

This gives the project the highest-value technical unlock with the smallest product risk.

## Decision

Do not start Stage D.
Do not replace the Home mainline yet.
Do not refactor preview infrastructure broadly.

The right next move is to formalize the foundation lesson registry first, then open one controlled pilot entry on top of it.
