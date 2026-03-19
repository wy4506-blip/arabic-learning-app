# Release Candidate Notes 2026-03-19

## Scope

This candidate bundles the V2 Home/review/mainline loop stabilization work, the V2 micro-lesson completion/runtime coverage updates, and the release-gate regression cleanup needed to prepare for release prep.

## Candidate Change Set

### Product/runtime changes

- Stabilize Home refresh after review or lesson completion.
- Prevent stale async Home loads from overriding newer snapshot state.
- Add a unified V2 home entry state so the main card renders from one state source.
- Make V2 micro-lesson completion return explicitly to Home with a completed result.
- Expand V2 micro-lesson runtime coverage for typed-response and arrange-response flows.

### Test and regression changes

- Update the Home/V2 review-flow acceptance tests to use the stabilized V2 helpers.
- Add direct micro-lesson page structure coverage inside the stable Home/V2 acceptance path.
- Move critical audio routing checks into the stable `test/content_loading_test.dart` path.
- Merge the Chinese smoke assertions into `test/english_pages_smoke_test.dart` so smoke/copy regression runs in one stable file.
- Remove legacy standalone flaky test files that are no longer part of the stable regression set.

### Documentation changes

- Update the release gate checklist to reflect the current verified regression set.
- Update the V2 closure and content-acceptance notes so they match the current runtime and regression status.

## Files To Keep In The Candidate

- `lib/pages/home_page.dart`
- `lib/pages/v2_micro_lesson_page.dart`
- `lib/pages/v2_review_entry_page.dart`
- `lib/services/alphabet_service.dart`
- `lib/services/lesson_service.dart`
- `lib/services/v2_learning_snapshot_service.dart`
- `lib/services/v2_review_flow_service.dart`
- `test/content_loading_test.dart`
- `test/english_pages_smoke_test.dart`
- `test/home_due_review_priority_test.dart`
- `test/home_skip_review_flow_test.dart`
- `test/home_today_learning_flow_test.dart`
- `test/home_v2_entry_completion_test.dart`
- `test/home_v2_review_flow_test.dart`
- `test/test_helpers.dart`
- `test/v2_home_flow_test_helpers.dart`
- `docs/release_gate_checklist_2026-03-15.md`
- `docs/v2_pilot_content_acceptance_2026-03-15.md`
- `docs/v2_pilot_release_closure_2026-03-15.md`

## Files Intentionally Removed From The Candidate

- `test/chinese_pages_smoke_test.dart`
- `test/v2_micro_lesson_page_test.dart`
- tracked `.tmp_*` output files that were only used during debugging/regression collection

## Stable Regression Set

- `flutter test test/content_loading_test.dart -r expanded`
- `flutter test test/english_pages_smoke_test.dart -r expanded`
- `flutter test test/home_v2_review_flow_test.dart -r expanded`
- `flutter test test/home_v2_entry_completion_test.dart -r expanded`
- `flutter test test/home_v2_surface_stability_test.dart -r expanded`

## Suggested Commit Message

- `Stabilize V2 home/review loop and fold regression coverage into stable test paths`

## Remaining Before Release Prep

- Confirm the remaining tracked deletions/changes are intended and stage them as one candidate set.
- Create a candidate commit.
- Create a rollback point or tag from that candidate.
- Re-check the release checklist after the worktree is clean.

## 2026-03-20 Candidate Freeze Update

### Frozen baseline

- Candidate commit: f0274f7
- Candidate commit message: Refine V2 review-first boundaries and completion surfaces
- Rollback tags:
  - acceptance-candidate-2026-03-19
  - acceptance-candidate-2026-03-19-r2

### What changed after the first candidate

- Tighten the V2 review-first boundary so Home only blocks on V2-relevant due review.
- Keep pilot review focused on the due items that actually block the V2 mainline, with fallback tasks for missing today-plan coverage.
- Align the formal review completion surface so Pilot Review does not present itself as Today's Review.
- Clean up the V2 micro-lesson completion surface and keep the completion summary/next-step messaging in one stable implementation.

### Current release reading

- The worktree is now clean.
- The candidate is now frozen and tagged.
- The remaining release-prep work is manual acceptance and release coordination, not candidate assembly.
