# Arabic Learning App Design Guardrails

Source of truth: [阿语学习App_产品设计规范与组件规范_正式版.docx](d:/APP/abaaba/阿语学习App_产品设计规范与组件规范_正式版.docx)

## Product Priority

- The app must reduce learning friction, not increase it.
- Every primary page should answer one question first:
  - `Home`: what should I do now
  - `Lessons`: what lesson should I take next
  - `Review`: what should I review now
  - `Profile`: what is my learning state and current access
- Locking and purchase messaging must stay weaker than learning guidance.

## Structural Rules

- One card solves one problem.
- One section has one clear theme.
- Do not turn core tabs into portal pages.
- Prefer a light, complete learning loop over dense information blocks.
- Small-screen learnability is more important than desktop visual flourish.

## Required Page Order

- `Home`: greeting -> main learning card -> quick actions -> free-trial banner -> optional light info
- `Lessons`: page intro -> current learning card -> free-trial progress -> filter tabs -> current unit -> other units -> unlock banner
- `Profile`: learning overview -> current plan -> language/text -> appearance/reminder -> content/purchase -> help/feedback -> about

## Component Rules

- Use explicit business names such as `LearningOverviewCard`, `CurrentPlanCard`, `UnitSectionCard`, `LessonCard`, `ReviewTaskCard`.
- Settings items should stay within three patterns:
  - nav: title + subtitle + chevron
  - switch: title + subtitle + switch
  - value: title + value + subtitle + chevron
- Each business component should be ready for default, empty, completed, and error states.

## Code Rules

- Business decisions must not be scattered in widget trees.
- Recommended lesson, trial status, current unit, pending review, and access state should be computed in shared helpers/view models.
- UI widgets should mainly map prepared state to layout and interaction.
- When a new page or section is added, first verify its structure against this file and the original design doc before implementation.

## Quick Regression Check

- If `Home` feels like a portal, it drifted.
- If `Lessons` feels like a raw catalog, it drifted.
- If `Review` feels like an exam system, it drifted.
- If `Profile` feels like a loose settings dump, it drifted.
- If locking is louder than learning, it drifted.
