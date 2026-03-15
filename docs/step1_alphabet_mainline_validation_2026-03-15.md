# Step 1 Alphabet Mainline Validation

## Goal

确认 A 线字母主学习闭环已经满足执行计划中的 Step 1 退出条件，并把当前可回放状态固化为检查点。

## Included Scope

- 字母主线完成判断统一为 viewed + listenCompleted
- 首页字母入口直达当前学习点
- 组内完成一个字母后自然续到下一个未完成字母
- 完成本组最后一个未完成字母后回到组完成态
- A 线依赖的首页入口与 review/home 基线行为一并做集成校验

## Not Included

- 不包含 C 线音频回退链路验收
- 不包含 D 线文案与 smoke 全量收口
- 不把 review 页与 profile 页的文案整理视为 Step 1 完成条件

## Design Checks

- Home 继续只回答“我现在该学什么”
- 字母主线不再把用户扔回 portal 式入口
- 主线判断集中在共享 progress service，不在页面各算各的

## Validation Result

- targeted alphabet regression: 6 passed / 0 failed
- integrated baseline regression: 25 passed / 0 failed
- 当前核对结果满足 Step 1 退出条件

## Files Validated In This Freeze

- lib/services/alphabet_progress_service.dart
- lib/pages/alphabet_group_detail_page.dart
- lib/pages/alphabet_letter_home_page.dart
- lib/pages/alphabet_page.dart
- lib/pages/home_page.dart
- lib/view_models/learning_path_view_models.dart
- lib/services/learning_routing_policy.dart
- lib/services/progress_service.dart
- lib/services/review_service.dart
- lib/pages/lesson_detail_page.dart
- lib/pages/review_session_page.dart
- 相关 alphabet / home / review targeted tests

## Exit Decision

Step 1 已验证，可作为 Step 2 的稳定输入继续推进。