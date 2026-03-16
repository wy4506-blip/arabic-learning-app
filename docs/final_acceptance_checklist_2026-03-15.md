# Final Acceptance Checklist

## Goal

在 acceptance-candidate-2026-03-15 基础上，用最少的验收动作确认主学习路径、音频路径和关键边缘页都符合预期。

## Acceptance Baseline

- Candidate tag: `acceptance-candidate-2026-03-15`
- Step 1 tag: `step1-validated-2026-03-15`
- Step 2 tag: `step2-validated-2026-03-15`
- Step 3 tag: `step3-validated-2026-03-15`

---

## A. Home And Alphabet Mainline

### Scenario A1 - New learner enters alphabet mainline

Precondition:

- clean local progress or fresh install state

Expected:

- Home 主卡优先引导字母学习
- 点击主按钮后，不进入 portal 式总入口兜圈
- 能直接进入当前应学字母点

Pass / Fail:

- [ ] Pass
- [ ] Fail
- Note:

### Scenario A2 - Finish one letter and continue naturally

Precondition:

- 进入某个未完成字母

Expected:

- 完成该字母听读主线后，自动续到本组下一个未完成字母
- 不出现重复 push / pop
- 不出现返回后状态不刷新

Pass / Fail:

- [ ] Pass
- [ ] Fail
- Note:

### Scenario A3 - Finish last incomplete letter in a group

Precondition:

- 当前组只剩最后一个未完成字母

Expected:

- 完成后回到组完成态
- 页面展示下一组或继续练习的后续动作
- 不会错误继续打开同一个字母

Pass / Fail:

- [ ] Pass
- [ ] Fail
- Note:

---

## B. Home Recommendation And Review Return Flow

### Scenario B1 - Due review takes priority over lesson continuation

Precondition:

- 已完成字母阶段
- 存在 due review 内容

Expected:

- Home 主卡优先推荐今日复习
- 不错误推荐继续 lesson mainline

Pass / Fail:

- [ ] Pass
- [ ] Fail
- Note:

### Scenario B2 - Warm-up path before continuing lesson

Precondition:

- 无正式 due review
- 有轻量热身或阶段补强内容

Expected:

- Home 主卡出现 warm-up 导向
- 完成热身后可自然进入下一课

Pass / Fail:

- [ ] Pass
- [ ] Fail
- Note:

### Scenario B3 - Continue learning path remains stable

Precondition:

- 字母阶段已完成
- 无复习优先级压力

Expected:

- Home 主卡推荐继续学习
- 进入 lesson 后，完成回流符合预期
- 不会被 review 错误打断

Pass / Fail:

- [ ] Pass
- [ ] Fail
- Note:

### Scenario B4 - Post-lesson return flow

Precondition:

- 从 Home today 主入口进入某课

Expected:

- lesson 完成后回流决策与当前 routing policy 一致
- 有 next lesson 时能继续
- 无 next lesson 时保持稳定回退

Pass / Fail:

- [ ] Pass
- [ ] Fail
- Note:

---

## C. Audio Pipeline

### Scenario C1 - Human audio preferred when available

Expected:

- 存在真人资源时，优先播放真人资源

Pass / Fail:

- [ ] Pass
- [ ] Fail
- Note:

### Scenario C2 - Explicit asset fallback remains available

Expected:

- manifest 未命中时，显式 asset 仍可正常播放

Pass / Fail:

- [ ] Pass
- [ ] Fail
- Note:

### Scenario C3 - TTS only as last fallback

Expected:

- 仅在所有 asset fallback 都不可用时才触发 TTS

Pass / Fail:

- [ ] Pass
- [ ] Fail
- Note:

---

## D. Copy And Smoke

### Scenario D1 - English UI terminology consistency

Expected:

- Feedback / Review / Grammar 等术语与当前候选版一致
- 无明显残留旧文案

Pass / Fail:

- [ ] Pass
- [ ] Fail
- Note:

### Scenario D2 - Chinese UI terminology consistency

Expected:

- 中文反馈、复习、说明类页面用词统一
- 无明显违和或过度营销语气

Pass / Fail:

- [ ] Pass
- [ ] Fail
- Note:

---

## Final Decision

- [ ] Accept candidate for release preparation
- [ ] Reject and reopen issues

## Reopen Rule

- 如果失败属于主路径行为错误，按 A/B/C 对应 step 回滚定位
- 如果失败只是边缘页文案问题，按 D 线单独修正
