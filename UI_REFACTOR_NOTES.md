# UI Refactor Notes

This version refactors the app toward the uploaded Hi-Fi UI direction:

- Added floating bottom tab shell: Home / Lessons / Review / Profile
- Updated design tokens to a milk-white + mint palette with large radii and light shadows
- Rebuilt Home around: continue learning, learned/review metrics, 2x2 quick entry grid
- Rebuilt Lessons into grouped unit sections with progress summary and filter chips
- Rebuilt Lesson Detail around hero summary, calm module cards, Arabic text display modes, and wordbook save action
- Rebuilt Review to a low-pressure card-based experience
- Rebuilt Wordbook to support search and simple filtering
- Added Profile / Settings page with text mode, theme mode, reminder toggle, and purchase section placeholders
- Added persisted settings and lightweight progress tracking

Known limits:

- Reminder time is stored, but no local notification scheduling is wired yet
- Purchase flow is still placeholder-level and reuses the current local unlock logic
- Alphabet sub-pages still mostly use the old visual language
- Because Flutter SDK is not available in this environment, this package was updated with best-effort static compatibility, but not locally compiled here
