# Release Prep Checklist 2026-03-20

## Frozen Baseline

- Candidate commit: f0274f7
- Candidate message: Refine V2 review-first boundaries and completion surfaces
- Rollback tags:
  - acceptance-candidate-2026-03-19
  - acceptance-candidate-2026-03-19-r2

## Automated Checks Already Verified

- flutter test test/content_loading_test.dart -r expanded
- flutter test test/english_pages_smoke_test.dart -r expanded
- flutter test test/home_v2_review_flow_test.dart -r expanded
- flutter test test/home_v2_entry_completion_test.dart -r expanded
- flutter test test/home_v2_surface_stability_test.dart -r expanded

## Manual Acceptance

### A. Home three-state pass

- [ ] reviewFirst shows the review-first card and enters V2 review flow
- [ ] continueMainline shows the next V2 lesson card and enters the lesson directly
- [ ] completedForToday does not regress back to review-first and shows a correct finished state

### B. Review-first closed loop

- [ ] Home review-first -> start pilot review -> complete review -> return home -> continue mainline
- [ ] Home review-first -> complete review with no mainline remaining -> completed-for-today
- [ ] Non-completed review exit does not pretend review was cleared

### C. Micro-lesson closed loop

- [ ] Home -> V2 micro-lesson -> completion -> back home -> next mainline recommendation
- [ ] Completion page summary, review result, and next-step messaging match the lesson outcome
- [ ] Chinese completion copy is readable and consistent with Home/review wording

### D. Surface and smoke pass

- [ ] English surfaces do not expose Chinese core copy
- [ ] Chinese review-first flow keeps readable CTA and terminology
- [ ] Audio entry points work on the targeted supported nodes used in the pilot flow

## Release Coordination

- [ ] Confirm release note scope matches candidate f0274f7
- [ ] Confirm rollback tag to use if the release is held
- [ ] Mark either Ready for release prep or Hold and reopen fixes

## Suggested Decision Rule

- Mark Ready for release prep if all manual checks pass and no new P0/P1 blocker appears.
- Hold the candidate only if the issue breaks the Home/review/mainline loop, the micro-lesson completion loop, or the smoke/audio baseline already verified above.
