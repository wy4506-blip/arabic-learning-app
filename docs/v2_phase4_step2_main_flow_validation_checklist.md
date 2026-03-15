# V2 Phase 4 Step 2 Main Flow Validation Checklist

## Goal
Validate the golden learning path after unified routing and real home-today context wiring.

## Checkpoints
- home primary CTA opens the expected lesson
- lesson entered from home carries real home-today context
- after lesson completion, post-lesson route matches expected rule
- review-first does not interrupt normal progression too aggressively
- home-today flow can advance naturally to next lesson when target is reached
- fallback behavior remains stable when no next lesson exists

## Manual Scenarios
1. onboarding incomplete -> home should recommend alphabet
2. normal learning with recommended lesson -> home should recommend start lesson
3. review pressure high -> home should recommend review
4. lesson completed but coreCompleted/dueForReview -> should recommend review
5. lesson completed from homeTodayPlan and target reached with next lesson -> should continue next lesson
6. lesson completed with no next lesson -> should return to lesson detail

## Validation Notes
- record any mismatch between expected route and actual UI
- do not change routing rules before confirming the mismatch is real
