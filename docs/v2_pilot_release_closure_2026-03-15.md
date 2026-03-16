# V2 样板段上线收口文档

日期：2026-03-15

## 结论

基于当前仓库状态，V2 首页主入口、推荐决策、样板复习回流、完成页反馈和中英文表层文案已经形成一条可运行的 pilot loop，但它还不等于一个可正式上线的 V2 学习样板段。

如果把“首个可上线版本”定义为“首页可进入、状态可流转、回到首页能刷新推荐的技术样板”，当前工程已经接近发布准备。

如果把“首个可上线版本”定义为“用户能真实听、看、做并获得有效学习证据的 V2 样板课”，当前还存在明确阻塞，主要集中在微课运行时体验过于占位化。

## 1. 已完成能力

### 1.1 首页已接入 V2 样板主线

- 首页会在完成首轮 onboarding 且字母阶段完成后切换到 V2 主卡，入口判断在 [lib/pages/home_page.dart](lib/pages/home_page.dart) 内完成。
- V2 主卡已能根据快照状态给出 start lesson、continue lesson、start review、start consolidation、start next phase、no action 六类主动作，文案和按钮状态已经落地，见 [lib/pages/home_page.dart](lib/pages/home_page.dart)。
- 首页 secondary action 已能稳定回到学习路径页，相关稳定性已有 widget test 覆盖，见 [test/home_v2_micro_lesson_flow_test.dart](test/home_v2_micro_lesson_flow_test.dart)。

### 1.2 V2 推荐与状态决策已集中到独立服务

- V2 当前阶段、课状态、推荐课程、推荐动作、到期复习项，已经由 [lib/services/v2_learning_snapshot_service.dart](lib/services/v2_learning_snapshot_service.dart) 统一构建。
- 该服务已支持三条核心判断：新用户推荐首课、已有 due review 时 review first、已有 in-progress lesson 时 continue first，见 [test/v2_learning_snapshot_service_test.dart](test/v2_learning_snapshot_service_test.dart)。
- lesson 完成后如何生成 objective 结果、review seed、下一步推荐，已经收敛到 [lib/services/v2_micro_lesson_completion_orchestrator.dart](lib/services/v2_micro_lesson_completion_orchestrator.dart)。

### 1.3 V2 样板复习链路已打通

- V2 due review 项会被过滤成样板复习会话，入口页和会话构建分别位于 [lib/pages/v2_review_entry_page.dart](lib/pages/v2_review_entry_page.dart) 和 [lib/services/v2_review_flow_service.dart](lib/services/v2_review_flow_service.dart)。
- Pilot Review 会清理 legacy next lesson exit，只保留 V2 主线真正阻塞的 due items，见 [test/v2_review_flow_service_test.dart](test/v2_review_flow_service_test.dart)。
- review 完成后首页会重新加载并切回主线推荐，这一行为已有集成测试覆盖，见 [test/home_v2_micro_lesson_flow_test.dart](test/home_v2_micro_lesson_flow_test.dart)。

### 1.4 V2 微课完成页与推荐刷新已落地

- 微课完成后会进入独立完成页，展示当前已达成目标、待回看点、复习结果和下一步建议，见 [lib/pages/v2_micro_lesson_completion_page.dart](lib/pages/v2_micro_lesson_completion_page.dart)。
- 返回首页后，推荐课程会从已完成课切换到下一课，这一点已经由 [test/home_v2_micro_lesson_flow_test.dart](test/home_v2_micro_lesson_flow_test.dart) 和 [test/v2_micro_lesson_completion_orchestrator_test.dart](test/v2_micro_lesson_completion_orchestrator_test.dart) 覆盖。

### 1.5 当前样板课程集已可支撑最小 runnable loop

- 当前样板课目录固定为 7 节：V2-ALPHA-CL-01、V2-BRIDGE-01、V2-U1-01 至 V2-U1-05，定义在 [lib/data/v2_micro_lessons.dart](lib/data/v2_micro_lessons.dart)。
- 每节课都具备 objectives、contentItems、practiceItems、completionRule、reviewSeedRules 和 nextActionHints，目录完整性由 [test/v2_micro_lesson_catalog_test.dart](test/v2_micro_lesson_catalog_test.dart) 校验。
- 现有文档也把这批内容定义为“current runnable pilot loop”而不是完整课程发布，见 [docs/v2_main_loop_acceptance_2026-03-15.md](docs/v2_main_loop_acceptance_2026-03-15.md) 和 [docs/v2_pilot_content_acceptance_2026-03-15.md](docs/v2_pilot_content_acceptance_2026-03-15.md)。

### 1.6 文档与静态状态整体可作为验收候选基础

- Step 1 到 Step 4 文档都显示对应工作流已验证完成，见 [docs/step1_alphabet_mainline_validation_2026-03-15.md](docs/step1_alphabet_mainline_validation_2026-03-15.md)、[docs/step2_home_review_routing_validation_2026-03-15.md](docs/step2_home_review_routing_validation_2026-03-15.md)、[docs/step3_audio_pipeline_validation_2026-03-15.md](docs/step3_audio_pipeline_validation_2026-03-15.md)、[docs/step4_copy_and_smoke_validation_2026-03-15.md](docs/step4_copy_and_smoke_validation_2026-03-15.md)。
- 当前编辑器静态错误为 0。

## 2. 阻塞项

### 2.1 V2 微课页面仍是占位式运行时，不是可正式上线的真实学习页

阻塞原因：当前微课页只展示 lesson goal、current task、阿文文本和两个自评按钮，未把课程数据里定义的 contentItems 和不同 practice type 渲染成真实学习交互。

证据：

- [lib/models/v2_micro_lesson.dart](lib/models/v2_micro_lesson.dart) 已定义 goal、input、explanation、modeling、contrast、recall、feedback 等内容块，以及 listenTap、speakResponse、arrangeResponse、recallPrompt、contrastChoice、comprehensionCheck 等练习类型。
- [lib/data/v2_micro_lessons.dart](lib/data/v2_micro_lessons.dart) 已为每节课配置 contentItems、audioQueryText、meaning、expectedAnswer 等结构化数据。
- 但 [lib/pages/v2_micro_lesson_page.dart](lib/pages/v2_micro_lesson_page.dart) 当前并未渲染 contentItems，也没有根据不同 practice type 切出不同 UI，只是把所有练习统一折叠成“我做到了 / 这里还不稳”。
- [docs/v2_course_design_standard_2026-03-15.md](docs/v2_course_design_standard_2026-03-15.md) 明确要求 lesson 结构应覆盖 intro、input、explain、practice、recap，这与当前运行时实现不一致。

结论：如果目标是首个“真正可学”的 V2 样板段，这一项是 P0 阻塞。

### 2.2 V2 微课当前没有接入音频播放能力，和听辨型课程目标不一致

阻塞原因：当前样板课的目标大量是“听清”“听出”“先听懂”，但微课页没有音频入口，也未接入统一音频服务。

证据：

- [lib/data/v2_micro_lessons.dart](lib/data/v2_micro_lessons.dart) 中多节课明确写的是听辨目标，并提供了 arabicText 和 audioQueryText。
- [lib/pages/v2_micro_lesson_page.dart](lib/pages/v2_micro_lesson_page.dart) 没有引入 audio service，也没有类似播放按钮或 ArabicTextWithAudio 的能力。
- 当前 Step 3 音频文档证明的是全局音频管线可用，见 [docs/step3_audio_pipeline_validation_2026-03-15.md](docs/step3_audio_pipeline_validation_2026-03-15.md)，但并不能证明 V2 微课页本身已经接线。

结论：对阿语学习样板段而言，这不是体验优化项，而是主能力缺口。

### 2.3 当前 V2 完成与达标证据仍依赖用户自报，不是有效学习证据

阻塞原因：不同练习类型目前都通过同一对按钮直接记为 passed 或 failed，缺少最小可验证交互。

证据：

- [lib/pages/v2_micro_lesson_page.dart](lib/pages/v2_micro_lesson_page.dart) 中所有题型最后都调用同一个 _recordOutcome 布尔入口。
- 页面没有 listen tap 选择、arrange response 排序、contrast choice 对比、comprehension check 判定等分型组件。
- [lib/services/v2_micro_lesson_completion_orchestrator.dart](lib/services/v2_micro_lesson_completion_orchestrator.dart) 虽然会计算 objective accuracy，但输入数据来自页面侧统一自报结果，因此证据质量不够支撑正式上线。

结论：如果首版上线定义包含“达标判定可信”，这一项也是 P0 阻塞。

### 2.4 发布准备门禁还未真正关闭

阻塞原因：仓库文档中定义了 release gate，但当前工作区仍有未提交改动，尚不能直接视为 ready for release prep。

证据：

- [docs/release_gate_checklist_2026-03-15.md](docs/release_gate_checklist_2026-03-15.md) 的 Build Gate 明确要求工作区干净、候选 tag 明确、关键静态检查无阻断错误。
- 当前静态错误已清零，但工作区存在未提交改动。

结论：这是发布准备阻塞，不是产品能力阻塞。

## 3. 可延期项

### 3.1 专用 V2 consolidation shell

- 当前 consolidation 仍复用通用 review 入口，这是已知缺口，见 [docs/v2_main_loop_acceptance_2026-03-15.md](docs/v2_main_loop_acceptance_2026-03-15.md)。
- 只要 review-first 能稳定回流主线，这一项可以延期到首版之后做体验专化。

### 3.2 深层 V2 内容体的完整英文化

- 英文表层文案、课名、目标摘要、review-first surface 已经完成，见 [docs/v2_main_loop_acceptance_2026-03-15.md](docs/v2_main_loop_acceptance_2026-03-15.md) 和 [lib/l10n/v2_micro_lesson_localizer.dart](lib/l10n/v2_micro_lesson_localizer.dart)。
- 深层 content body 仍主要在数据层中文案里，这在当前微课页未完整暴露时可以延期。

### 3.3 样板课目录扩展到完整 U1 试点包

- 当前代码只落地到 V2-U1-05，见 [lib/data/v2_micro_lessons.dart](lib/data/v2_micro_lessons.dart)。
- 迁移包规划到 V2-U1-11，见 [docs/v2_u1_pilot_migration_pack_2026-03-15.md](docs/v2_u1_pilot_migration_pack_2026-03-15.md)。
- 对“样板段上线”来说，7 节课足以证明主环路；对“完整 U1 试点上线”来说，这一项才会转成范围缺口。

### 3.4 音频正式资源覆盖度的剩余债务

- 音频管线逻辑本身已验证通过，见 [docs/step3_audio_pipeline_validation_2026-03-15.md](docs/step3_audio_pipeline_validation_2026-03-15.md)。
- 但全仓仍存在正式音频覆盖缺口和少量孤儿资源，见 [docs/audio_experience_fix_report_2026-03-14.md](docs/audio_experience_fix_report_2026-03-14.md)。
- 只要 V2 首版使用统一 fallback 且关键样板内容有可播能力，这些可作为后续资源补齐项。

## 4. 推荐开发顺序

### 顺序一：把 V2 微课从技术壳补成最小可学运行时

- 先补 contentItems 渲染。
- 再按 practice type 拆出最小交互，不要求一版做复杂识别，但至少不能所有题都退化成统一自报按钮。
- 同步把音频入口接进 V2 微课页，优先保证 input、modeling、listenTap 类节点可播放。

这是最优先，因为它决定首版到底是“可演示”还是“可上线学习”。

### 顺序二：补齐最小可信证据闭环

- 让 listenTap、comprehensionCheck、contrastChoice 至少有可判定输入。
- 让 speakResponse 和 recallPrompt 在首版可以先保留轻量自评，但要和自动判定题型分开处理。
- 确保 orchestrator 的 objective accuracy 来自真实交互结果，而不是统一手动打点。

### 顺序三：关闭发布准备门禁

- 清理工作区，收敛候选版本。
- 固化候选 tag 和回放点。
- 按 release gate 重新执行 targeted regression、audio targeted regression、smoke and copy regression。

### 顺序四：再做非阻断优化

- V2 consolidation shell 专化。
- 深层英文化。
- U1 样板目录扩展到 U1-06 之后。
- 资源覆盖补录和音频体验精修。

## 5. 最小上线回归清单

### 5.1 首页与推荐

- 新用户未完成字母阶段时，不误进 V2 主卡。
- 字母阶段完成后，首页切到 V2 主卡。
- V2 主卡能正确区分 start lesson、continue lesson、start review 三类主状态。
- review 完成返回首页后，推荐会刷新，不残留旧 CTA。

关键参考：

- [test/home_v2_micro_lesson_flow_test.dart](test/home_v2_micro_lesson_flow_test.dart)
- [test/home_today_learning_flow_test.dart](test/home_today_learning_flow_test.dart)

### 5.2 V2 微课运行时

- 进入微课后能看到完整的最小 lesson 结构，不只是单题壳。
- 听辨题存在真实音频入口。
- 至少一种自动判定题型能稳定记录结果。
- 完成页能展示 learned outcome、review result、next step。

关键参考：

- [lib/pages/v2_micro_lesson_page.dart](lib/pages/v2_micro_lesson_page.dart)
- [lib/pages/v2_micro_lesson_completion_page.dart](lib/pages/v2_micro_lesson_completion_page.dart)

### 5.3 复习回流

- due review 时首页优先推荐样板复习。
- Pilot Review 只保留真正阻塞 V2 主线的 task。
- review 完成后能回到首页并切回主线学习。

关键参考：

- [lib/pages/v2_review_entry_page.dart](lib/pages/v2_review_entry_page.dart)
- [lib/services/v2_review_flow_service.dart](lib/services/v2_review_flow_service.dart)
- [test/v2_review_flow_service_test.dart](test/v2_review_flow_service_test.dart)

### 5.4 持久化与状态正确性

- lesson start、lesson complete、due review、review cleared 后的推荐切换正确。
- 刷新首页后状态不丢失。
- 弱项复习清掉后，课程状态能从 dueForReview 回到 coreCompleted 或继续推进。

关键参考：

- [test/v2_learning_snapshot_service_test.dart](test/v2_learning_snapshot_service_test.dart)
- [test/v2_micro_lesson_completion_orchestrator_test.dart](test/v2_micro_lesson_completion_orchestrator_test.dart)

### 5.5 文案与语言模式

- 英文模式下 V2 首页、微课页、完成页、复习入口无明显中文残留。
- 中文模式下主标题、按钮、完成页术语保持一致。

关键参考：

- [lib/l10n/v2_micro_lesson_localizer.dart](lib/l10n/v2_micro_lesson_localizer.dart)
- [docs/step4_copy_and_smoke_validation_2026-03-15.md](docs/step4_copy_and_smoke_validation_2026-03-15.md)

## 建议的发布判断

当前不建议直接把 V2 样板段定义为“可正式上线学习体验”。

更准确的判断是：

- 首页路由、状态编排、review 回流、完成页反馈，已经达到 acceptance candidate 水位。
- V2 lesson runtime 仍停留在技术样板阶段，还差最小真实学习交互、音频接线和可用证据采集。

因此，离首个可上线版本还差的核心不是更多路由修补，而是把 V2 微课页补成真正的课。