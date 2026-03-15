# Execution Plan 1-2-3-4

## Objective

按固定顺序推进 4 条工作流，并在每一步内部自动收敛、自动核对、自动回归，直到进入最终验收。

本计划的原则是：

- 不并行扩散高风险业务文件
- 每一步都严格对照设计文档和控制文档
- 每一步都先完成自检，再进入下一步
- 最终只把“可验收状态”交给你

---

## Source Documents

执行时必须同时服从以下文档：

1. `docs/launch_recovery_plan_2026-03-15.md`
   作用：定义恢复基线、集成顺序、上线门禁

2. `docs/v2_parallel_workstreams_control.md`
   作用：定义 4 条工作流边界、共享文件 owner、验证标准

3. `docs/design_guardrails.md`
   作用：定义产品结构、页面优先级、业务决策不散落在 widget tree 的约束

4. `UI_REFACTOR_NOTES.md`
   作用：定义当前 UI 重构方向和已知限制，避免在本轮偏离既有视觉结构

---

## Step 1 - A 线字母主学习闭环

### Goal

把字母阶段黄金主线打成稳定的“可发布候选”。

### Allowed Scope

- `lib/services/alphabet_progress_service.dart`
- `lib/pages/alphabet_group_detail_page.dart`
- `lib/pages/alphabet_letter_home_page.dart`
- `lib/pages/alphabet_page.dart`
- alphabet 相关 tests

### Not Included

- 不改 `lib/services/review_service.dart`
- 不改 `lib/view_models/learning_path_view_models.dart`
- 不扩展 i18n 全量清理

### Design Checks

执行中必须核对：

- 首页主卡只回答“我现在该学什么”
- 字母主线必须降低学习摩擦，不能把用户再扔回 portal 式入口
- 主线完成判断必须统一，不能页面各算各的

### Auto-Convergence Rules

- 如果发现需要首页入口适配，只提出接口需求，不直接改首页推荐逻辑
- 如果发现 review 触发问题，记录为 Step 2 输入，不在 Step 1 顺手处理
- 如果发现只是文案问题，延后到 Step 4

### Validation Before Exit

- 首页字母入口直达当前学习点
- 单字母完成后自然续学或回到组完成态
- 不出现导航死循环、重复 push/pop、状态不刷新
- 相关 targeted tests 通过

### Exit Condition

Step 1 通过后，字母主学习路径可视为稳定输入，才能进入 Step 2。

---

## Step 2 - B 线推荐与复习回流收口

### Goal

把首页推荐、review 优先级、lesson 后回流统一到共享 policy 和 shared helpers。

### Allowed Scope

- `lib/services/review_service.dart`
- `lib/services/progress_service.dart`
- `lib/view_models/learning_path_view_models.dart`
- `lib/services/learning_routing_policy.dart`
- `lib/services/learning_routing_models.dart`
- `lib/pages/home_page.dart`
- `lib/pages/lesson_detail_page.dart`
- home / review 相关 tests

### Not Included

- 不改 alphabet 详情页和组内续学逻辑
- 不做文案全量整理
- 不做音频链路重构

### Design Checks

执行中必须核对：

- `Home` 只回答“现在最值得做的下一步”
- 业务决策必须集中在 policy / view model，不能散落 widget tree
- 锁定和购买信息不能压过学习引导

### Auto-Convergence Rules

- 如与 Step 1 冲突，优先保留 Step 1 已验证主线
- 所有首页推荐分支必须回归到共享 routing policy
- 所有行为必须先通过 targeted tests 再考虑 UI 微调

### Validation Before Exit

- 首页能正确区分字母主线、复习优先、热身、继续学习
- due review 时不错误推荐 lesson mainline
- lesson 完成后回流与 PostLessonRoute 一致
- home / review / routing 关键测试通过

### Exit Condition

Step 2 通过后，主学习路径与复习路径之间的切换规则稳定。

---

## Step 3 - C 线音频管线回归

### Goal

把真人音频、AI 音频、TTS 回退链路做成可验证、可发布状态。

### Allowed Scope

- `lib/services/audio_manifest_service.dart`
- `lib/services/audio_service.dart`
- `pubspec.yaml`
- 音频相关 tests 和工具脚本

### Not Included

- 不碰首页推荐
- 不碰 review/session 主逻辑
- 不重写字母学习路径

### Design Checks

执行中必须核对：

- 音频能力服务于学习闭环，而不是制造额外选择成本
- 回退逻辑必须可预测，不能静默失败

### Auto-Convergence Rules

- 先修 manifest / explicit / TTS 回退顺序，再做样本层验证
- 若发现缺失资源问题，记录为资源问题，不把业务逻辑一起改动

### Validation Before Exit

- manifest 命中时优先真人音频
- manifest 未命中时回退显式资源
- 全部缺失时再回退 TTS
- 音频关键测试与样本回归通过

### Exit Condition

Step 3 通过后，音频主路径可用于发版候选。

---

## Step 4 - D 线文案与 smoke 收口

### Goal

最后统一术语、修复 smoke tests、清理不影响主逻辑但影响验收观感的噪音。

### Allowed Scope

- `lib/l10n/app_strings.dart`
- 小范围页面文案
- smoke / copy tests

### Not Included

- 不改业务路由逻辑
- 不改状态判断逻辑
- 不改音频回退逻辑

### Design Checks

执行中必须核对：

- 页面必须维持既有结构，不把 Home 改成 portal
- 用词要克制，学习引导优先于营销和说明
- 中英文术语必须前后一致

### Auto-Convergence Rules

- 所有文案改动只在主逻辑稳定后进行
- 如果某处 smoke 失败本质是行为问题，则退回前一阶段处理，不在 Step 4 掩盖

### Validation Before Exit

- 英文模式无明显中文残留
- 关键 smoke tests 通过
- 反馈、review、profile、grammar 等边缘页用词统一

### Exit Condition

Step 4 通过后，工程进入最终验收候选状态。

---

## Global Execution Rules

### Rule 1 - Single Active Step

任何时刻只允许 1 个高优先级 step 处于实现状态。

### Rule 2 - Automatic Self-Check

每个 step 完成前必须自动执行：

- 相关文件静态检查
- 相关 targeted tests
- 与 source documents 的范围核对

### Rule 3 - No Cross-Step Leakage

发现问题后按以下规则处理：

- 属于当前 step 的，当前收口
- 不属于当前 step 的，记为下一 step 输入
- 如属 P0 编译问题，立即中断当前 step 先止血

### Rule 4 - Acceptance-Ready Handoff

交给你验收前，输出必须包含：

- 已完成内容
- 未纳入内容
- 验证结果
- 剩余风险

---

## PM Operating Model

我将按以下方式推进，而不是等你逐项提醒：

1. 先按 step 顺序推进，不乱跳
2. 每一轮先收集上下文，再做最小修改
3. 修改后立即做对应回归
4. 若发现越界风险，主动收缩，不扩展范围
5. 只有达到该 step 的 exit condition，才进入下一步

---

## Current Order

当前执行顺序固定为：

1. Step 1 - A 线字母主学习闭环
2. Step 2 - B 线推荐与复习回流收口
3. Step 3 - C 线音频管线回归
4. Step 4 - D 线文案与 smoke 收口

本顺序除非出现新的 P0 阻塞，否则不调整。