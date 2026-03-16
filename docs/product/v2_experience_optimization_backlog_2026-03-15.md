# V2 Experience Optimization Backlog

## Objective

在不偏离 V2 设计逻辑的前提下，持续把产品从“功能可用”推进到“学习阻力更低、结构更清晰、行为更统一”的状态。

## Product Principles

- Home 只回答现在最值得做什么
- Lessons 只回答接下来学哪一块
- Review 只回答现在该复习什么
- 同一个内容块只保留一个主音频入口
- 课程内容尽量可播放，但不要让播放按钮夺走主任务注意力

## Architecture Principles

- 业务决策继续收敛在 shared helpers / view models / policy
- 视觉与交互规则通过共享组件沉淀，而不是在页面局部重复实现
- 页面只负责映射状态，不重复发明入口策略

## Active Optimization Tracks

### Track 1 - Learning Audio Affordance Unification

Goal:

- 所有学习内容保持可播放覆盖
- 同一内容块不出现重复播放入口
- 训练题与复习页避免按钮噪音

Execution slices:

1. lesson detail 词汇卡去重
2. alphabet group 页面去重
3. review task 页面收敛到单一主入口
4. quiz scaffold 收敛 prompt / option 音频策略
5. alphabet listen/read 页面移除重复 example word 播放入口

### Track 2 - Alphabet Subpages Visual Convergence

Goal:

- 让 alphabet 子页面更接近 V2 主视觉
- 保持主线轻量，减少旧视觉残留

Execution slices:

1. group page 已完成主入口收敛
2. letter home / listen-read / detail 页继续统一
3. 控件层统一圆角、边框、层级感

### Track 3 - Learning Surface Density Control

Goal:

- 一屏只解决一个学习问题
- 降低同时出现的次级控件数量

Execution slices:

1. review task 页减少重复 CTA
2. quiz 页减少选项级噪音
3. lesson 详情页继续压缩非主任务按钮

## Current Priority Order

1. quiz scaffold 音频策略收敛
2. alphabet listen-read 页面重复播放入口收敛
3. alphabet detail 页面音频层级微调
4. 补充关键 widget regression

## Definition Of Done

- 可播放内容没有明显缺口
- 高密度学习页面中，同一内容块只保留一个主音频入口
- 关键回归测试通过
- 页面结构仍符合 V2 guardrails