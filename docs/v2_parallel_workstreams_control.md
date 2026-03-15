# V2 Parallel Workstreams Control

## Objective
在并行推进多个 session 的情况下，确保任务边界清晰、合并顺序可控、验证状态可追踪，避免重复修改、文件冲突和未验证即合并。

---

## Current Workstreams

| Workstream | Goal | Main Scope | Current Status | Risk | Verified | Merged | Notes |
|---|---|---|---|---|---|---|---|
| A - Alphabet Core Flow | 打通字母主学习闭环 | `home_page.dart` / `alphabet_*` / `alphabet_progress_service.dart` | In Progress | High | No | No | 重点解决首页入口、组进度、自动跳转、组完成反馈、练习题量 |
| B - Review & Recommendation | 收口复习触发与首页推荐动作 | `review_service.dart` / `progress_service.dart` / `learning_path_view_models.dart` / `home_page.dart` | In Progress | High | No | No | 重点解决何时复习、推荐继续学习还是先复习、复习完成后如何回流 |
| C - Audio Pipeline | 稳定音频资源与播放链路 | `audio_service.dart` / `audio_manifest_service.dart` / `assets/audio/**` / `pubspec.yaml` | In Progress | Medium | No | No | 重点解决真人/AI/TTS 优先级、manifest 映射、首批录音验证 |
| D - i18n & Copy Cleanup | 清理国际化、文案和局部 UI 表达 | `lib/l10n/**` / `generated/**` / `app_strings.dart` / 非主链路页面 | In Progress | Low | No | No | 重点解决英文模式残留中文、术语不统一、页面表达不够克制 |

---

## Shared File Alert

这些文件存在潜在冲突，合并前必须人工复核：

| File | Potential Conflict Workstreams | Risk Note |
|---|---|---|
| `lib/pages/home_page.dart` | A / B | 首页既涉及字母继续学习入口，也涉及推荐动作 |
| `lib/services/progress_service.dart` | A / B | 若 A 触碰总体进度聚合，可能与 B 的推荐逻辑冲突 |
| `lib/view_models/learning_path_view_models.dart` | B | 原则上由 B 独占，避免 A 顺手改动 |
| `lib/services/review_service.dart` | B | 原则上由 B 独占 |
| `lib/services/audio_service.dart` | C | 原则上由 C 独占 |
| `lib/services/audio_manifest_service.dart` | C | 原则上由 C 独占 |
| `lib/constants/app_strings.dart` | D | 原则上由 D 独占 |
| `lib/l10n/**` | D | 原则上由 D 独占 |

---

## Merge Order Suggestion

建议按以下顺序合并，不要四条线谁先出结果就先合：

1. **A - Alphabet Core Flow**  
   原因：这是当前最核心的主学习链路，用户感知最强，且很多后续验证都依赖它。

2. **B - Review & Recommendation**  
   原因：推荐与复习要建立在相对稳定的主学习路径上，否则容易反复调整。

3. **C - Audio Pipeline**  
   原因：音频体验重要，但对主业务状态依赖较弱，可在主链路相对稳定后接入。

4. **D - i18n & Copy Cleanup**  
   原因：清理类工作放在最后更稳，避免前面逻辑改动后又新增文案返工。

---

## Status Definition

| Status | Meaning |
|---|---|
| Not Started | 尚未开始 |
| In Progress | 正在执行，未产出稳定结果 |
| Done, Pending Validation | 已完成改动，但尚未验证 |
| Validated | 已按手动路径验证通过，待合并 |
| Merged | 已合并进主分支 |
| Blocked | 因依赖、冲突或结果不稳定而暂时阻塞 |

---

## Verification Rule

每个 workstream 完成后，至少补充以下内容再允许进入合并判断：

### A - Alphabet Core Flow
- 首页“继续字母学习”是否可直达当前学习点
- 分组状态是否清晰区分未开始 / 进行中 / 已完成
- 单字母完成后是否自动跳转到下一个字母或组完成反馈
- 练习题量是否明显收敛
- 是否出现导航死循环、返回异常或状态不刷新

### B - Review & Recommendation
- 学习完成后是否真实产出 review seeds
- 首页是否能正确区分“继续学习”和“先复习”
- 复习完成后是否能自然回到主学习链路
- 推荐逻辑是否来自统一状态源，而不是页面硬编码

### C - Audio Pipeline
- 真人音频存在时是否优先播放真人
- 真人缺失时是否正确回退 AI
- AI 缺失时是否回退 TTS
- 缺失资源时是否有日志，不是静默失败
- 首批录音样本是否能在工程内真实验证

### D - i18n & Copy Cleanup
- 英文模式是否仍有中文残留
- 核心术语是否前后一致
- 非主链路页面是否明显更清晰、更克制
- 是否误改业务逻辑或引入文案 key 缺失

---

## Workstream Update Template

每次一个 session 给出结果后，按这个格式更新对应 Notes：

### Update Record
- Date:
- Workstream:
- Result:
- Modified Files:
- Validation Status:
- Merge Readiness:
- Risk / Conflict:
- Next Action:

---

## Decision Rules

1. **完成不等于可合并**  
   必须先手动验证，再把 `Verified` 改为 `Yes`。

2. **有共享文件冲突时，不直接合并**  
   先比较 diff，再决定谁保留、谁重做。

3. **禁止跨边界顺手修改**  
   若某个 session 改了不属于自己范围的文件，要在 Notes 标记。

4. **主链路优先**  
   如果 A 和 B 的结果冲突，优先保住 A 的稳定性，再回调 B。

5. **清理类任务后置**  
   D 不得覆盖 A/B/C 的业务改动。

---

## Recommended Next Control Actions

- A/B 结果一出来，先检查是否同时改了 `home_page.dart`
- C 完成后，单独做一次首批音频样本回归
- D 合并前，再切一遍英文模式检查中文残留
- 每完成一个 workstream，就立刻更新本文件，不要等到最后一起补

---

## Quick Snapshot

| Workstream | Owner | Priority | Blocking Dependency |
|---|---|---|---|
| A - Alphabet Core Flow | Active Session | P0 | None |
| B - Review & Recommendation | Active Session | P0 | 建议参考 A 稳定后的入口行为 |
| C - Audio Pipeline | Active Session | P1 | None |
| D - i18n & Copy Cleanup | Active Session | P2 | 建议后置合并 |

---

## Manual Notes

- 当前最关键冲突点：`home_page.dart`
- 当前最关键体验目标：让用户在字母阶段真正“顺着学下去”
- 当前最容易被忽略的问题：session 声称完成，但没有真实手动验证
