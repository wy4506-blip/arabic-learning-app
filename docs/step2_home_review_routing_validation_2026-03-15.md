# Step 2 Home Review Routing Validation

## Goal

确认首页推荐、review 优先级和 lesson 后回流已经满足 Step 2 退出条件，并作为进入 C 线前的稳定输入。

## Included Scope

- 首页区分字母主线、复习优先、热身、继续学习
- due review 存在时优先推荐 review，不错误回到 lesson mainline
- home today 进入 lesson 的上下文能够继续传递到后续回流判断
- lesson 完成后的回流与统一 routing policy 保持一致

## Not Included

- 不包含音频 manifest / explicit / TTS 回退验收
- 不包含 review 页与 profile 页的全量文案收口
- 不把 smoke 与 i18n 清理视为 Step 2 完成条件

## Validation Result

- targeted step2 regression: 25 passed / 0 failed
- 关键路由与 progress 语义静态检查通过
- 当前结果满足 Step 2 退出条件

## Evidence

- alphabet mainline still stable after home integration
- review-first path verified
- warm-up path verified
- continue-learning handoff verified
- post-lesson route policy verified

## Exit Decision

Step 2 已验证，可进入 Step 3 音频管线回归。