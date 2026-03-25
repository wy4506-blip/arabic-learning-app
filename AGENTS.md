# AGENTS.md

## Mission
Generate V2 Arabic lessons for absolute beginners.

The goal is real learning, not superficial completion.
Each lesson must help the learner truly understand, recall, and begin using the target knowledge.

## Hard rules
- Exactly one core learning objective per lesson.
- Keep cognitive load low.
- Follow: Input -> Recognition -> Recall -> Output -> Completion.
- Include at least one real recall-bearing step.
- If phrase/sentence structure is taught, include `arrangeResponse`.
- Only use `speakResponse` after enough guided input.
- Completion must return:
  - `mastery_status`
  - `learning_evidence`
  - `review_seed_candidates`
  - `next_home_action`
- Weak items must be eligible for review.
- Never confuse page traversal with mastery.
- Never generate lessons that are mainly passable by guessing.
- Preserve Completion -> Review -> Home consistency.

## Arabic-specific rules
- Respect Arabic spelling, diacritics, and text-audio consistency.
- Support diacritics-aware content.
- Keep future compatibility with undiacritized display.
- Introduce morphology only when it supports the lesson objective.

## Required output
When generating a lesson, always return:
1. lesson design summary
2. stage-by-stage design
3. structured lesson content
4. completion contract
5. review seed logic
6. home progression result
7. self-check against the rules above
