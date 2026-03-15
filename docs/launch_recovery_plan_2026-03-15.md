# Launch Recovery Plan

## Goal

用最短路径把当前工程从“并行改动失控”拉回到“可运行、可验证、可逐步上线”的状态。

本计划只关注三件事：

- 先恢复可运行基线
- 再控制 4 条工作流的边界和合并顺序
- 最后用明确的上线门禁判断是否可发版

---

## Current Assessment

当前不是单点小问题，而是典型的并行开发失控：

- B 线已经把核心业务文件改到编译失败
- A / B 同时改动首页与推荐路径，存在共享文件冲突
- D 线提前进入主工作区，增加了文案与 smoke test 噪音
- 当前“完成”与“已验证”没有严格区分

当前发布阻塞级别：P0

---

## Release Strategy

### Phase 0 - Stop The Bleeding

目标：停止继续制造不稳定状态。

执行要求：

- 暂停 4 条任务的新功能提交
- 不再让多个任务继续同时改同一个工作区
- 所有后续改动必须先明确归属到单一 workstream

完成标准：

- 代码不再继续扩散改动面
- 当前阻塞文件和共享文件已有责任归属

### Phase 1 - Restore Runnable Baseline

目标：恢复到能编译、能跑关键测试的状态。

优先级：只处理 P0 断点。

处理顺序：

1. 修复 review_service.dart 的编译断裂
2. 清理由断裂引发的次级静态错误
3. 恢复首页推荐链路的最小可验证行为

完成标准：

- `flutter analyze` 不存在阻断级错误
- 核心 home / review / alphabet 相关测试可跑通
- 应用可正常启动进入首页

### Phase 2 - Controlled Integration

目标：按顺序把 4 条线重新接回主线，而不是一起混。

建议集成顺序：

1. A - Alphabet Core Flow
2. B - Review & Recommendation
3. C - Audio Pipeline
4. D - i18n & Copy Cleanup

原因：

- A 决定主学习路径，是用户第一感知
- B 依赖 A 的主线稳定后再做推荐和复习切换
- C 依赖面相对小
- D 最容易返工，必须后置

### Phase 3 - Launch Gate

目标：不是“感觉差不多”，而是满足发版门禁。

只有同时满足以下条件，才允许进入上线准备：

- 工程可编译
- 关键测试集通过
- 关键手动路径通过
- 没有未决 P0 / P1 缺陷
- 文案和多语言没有明显破坏主流程

---

## Workstream Ownership

### A - Alphabet Core Flow

目标：打通字母阶段主学习闭环。

允许修改：

- `lib/services/alphabet_progress_service.dart`
- `lib/pages/alphabet_group_detail_page.dart`
- `lib/pages/alphabet_letter_home_page.dart`
- `lib/pages/alphabet_page.dart`
- 相关 alphabet tests

禁止顺手修改：

- `lib/services/review_service.dart`
- `lib/view_models/learning_path_view_models.dart`

验收标准：

- 首页字母入口可直达当前学习点
- 单字母完成后自然续到下一字母或组完成态
- 字母主线完成判断统一为 viewed + listenCompleted
- 不出现导航死循环、重复弹回、状态不刷新

### B - Review & Recommendation

目标：收口首页推荐、复习优先级、lesson 后回流。

允许修改：

- `lib/services/review_service.dart`
- `lib/services/progress_service.dart`
- `lib/view_models/learning_path_view_models.dart`
- `lib/services/learning_routing_policy.dart`
- `lib/services/learning_routing_models.dart`
- `lib/pages/home_page.dart`
- `lib/pages/lesson_detail_page.dart`
- 相关 home / review tests

禁止顺手修改：

- alphabet 详情页、字母组内流程
- i18n 全量文案清理

验收标准：

- 首页能正确区分字母主线、复习优先、热身、继续学习
- due review 时不会错误推荐 lesson mainline
- lesson 完成后回流逻辑符合统一 policy
- related tests 可稳定通过

### C - Audio Pipeline

目标：确保真人音频、AI 音频、TTS 的回退链路稳定。

允许修改：

- `lib/services/audio_manifest_service.dart`
- `lib/services/audio_service.dart`
- `pubspec.yaml`
- 音频相关 tests 和工具脚本

禁止顺手修改：

- 首页推荐
- review/session 流程
- 字母主学习流程

验收标准：

- manifest 命中时优先真人音频
- manifest 未命中时能正确回退到显式资源
- 资源缺失时才回退 TTS
- 首批样本回归可通过

### D - i18n & Copy Cleanup

目标：统一术语、降低噪音、修正 smoke tests。

允许修改：

- `lib/l10n/app_strings.dart`
- 小范围页面文案
- smoke / copy tests

禁止顺手修改：

- 业务路由逻辑
- 状态判断逻辑
- review 或 alphabet 的核心行为

验收标准：

- 英文模式无明显中文残留
- 核心术语前后一致
- smoke tests 与当前产品文案一致

---

## Shared File Control

以下文件必须单一 owner，禁止同时推进：

- `lib/pages/home_page.dart`: 当前归 B 线 owner
- `lib/services/review_service.dart`: 当前归 B 线 owner
- `lib/services/progress_service.dart`: 当前归 B 线 owner
- `lib/view_models/learning_path_view_models.dart`: 当前归 B 线 owner
- `lib/l10n/app_strings.dart`: 当前归 D 线 owner
- `pubspec.yaml`: 当前归 C 线 owner

如果 A 线需要触碰 `home_page.dart`，只能通过以下方式进行：

- 先提出接口需求
- 由 B 线统一落地入口适配
- A 线只消费接口，不直接重写首页判断

---

## Working Rules

### Branching Rule

每条工作流单独一个分支，禁止 4 条线共用同一未整理工作树。

推荐格式：

- `ws/a-alphabet-mainline`
- `ws/b-review-recommendation`
- `ws/c-audio-pipeline`
- `ws/d-i18n-copy`

如条件允许，建议每条线使用独立 worktree。

### Change Rule

每次提交前必须写清楚：

- 改了什么
- 为什么改
- 不包含什么
- 用什么验证

### Validation Rule

任何 workstream 都必须区分两种状态：

- Done, Pending Validation
- Validated

没有验证通过，不允许进入主分支候选。

---

## Daily Operating Rhythm

### Morning

- 更新 4 条工作流状态
- 确认是否出现共享文件冲突
- 确认当天只推进 1 个 P0 / P1 收口目标

### Midday

- 检查编译状态
- 检查关键测试是否仍可跑
- 如果某条线越界，立即回收边界

### End Of Day

- 记录每条线的 modified files
- 记录验证结果
- 标记是否具备 merge readiness

---

## Release Dashboard

建议每天按下面 5 个指标判断是否接近上线：

1. Build Health
   当前是否可编译、可启动

2. Core Flow Health
   首页 -> 字母 -> lesson -> review 主路径是否稳定

3. Test Health
   核心 targeted tests 是否稳定通过

4. Scope Control
   是否仍有任务越界、共享文件重复修改

5. Launch Risk
   是否仍存在 P0 / P1 未决问题

---

## Immediate Actions

今天起按下面顺序执行：

1. 冻结 A / C / D 的继续改动
2. 只让 B 线先恢复 runnable baseline
3. baseline 恢复后，再单独验证 A 线字母主线
4. A 验证通过后，重新接 B 的推荐与复习策略
5. C 在主流程稳定后单独回归
6. D 最后统一做文案与 smoke 收口

---

## Definition Of Shippable

满足以下全部条件，才叫“接近可上线”：

- 应用可启动并进入首页
- 首页主推荐行为稳定
- 字母主学习路径稳定
- 课程进入和课后回流稳定
- 复习页和 review session 稳定
- 音频主回退链路可用
- 中文 / 英文 smoke 基本通过
- 没有已知 P0 / P1 缺陷

如果以上任一条件不满足，就还处于“工程恢复期”，不是“上线准备期”。