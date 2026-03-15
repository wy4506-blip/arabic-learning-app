# V2 状态与复习字段草案

日期：2026-03-15

## 1. 目标

本草案用于定义 V2 lesson 的最小进度、达标和复习挂接字段，便于后续在代码中落地。

目标不是一次性重做整个内容模型，而是先补出一个可以和现有 lesson 数据并行存在的 progress sidecar。

## 2. 设计原则

### 2.1 不直接推翻现有 Lesson 内容模型

当前 [lib/models/lesson.dart](lib/models/lesson.dart) 已经承载内容字段。

V2 第一阶段更适合：

- 保留 Lesson 作为内容模型
- 新增 progress / mastery / review 侧边模型
- 先把状态逻辑与 lesson 内容解耦

### 2.2 区分四类状态

V2 运行时至少要区分：

- 课程可访问状态
- 学习进行状态
- 达标状态
- 复习状态

### 2.3 与现有 review_loop 保持兼容

根据仓库当前 review loop 记忆，已有关键点包括：

- review item 有 LearningStage 状态机
- review task 已区分 objectType 和 actionType
- lesson completion 会 seed 若干 review state

因此 V2 草案不另起一套完全脱节的状态命名，而是保留映射关系。

## 3. 建议的运行时实体

### 3.1 CoursePhaseProgress

用于描述一个阶段整体推进情况。

建议字段：

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| phaseId | String | 如 phase_3_basic_expression |
| status | enum | not_started / active / consolidation / completed |
| unlockedLessonIds | List<String> | 当前已解锁 lesson |
| completedLessonCount | int | 已完成 lesson 数 |
| masteredLessonCount | int | 已稳定 lesson 数 |
| weakLessonIds | List<String> | 当前需回练的 lesson |
| reviewDueCount | int | 当前阶段到期复习数 |

### 3.2 LessonProgressRecord

用于描述单课的真实学习状态。

建议字段：

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| lessonId | String | 对应 V2 lesson |
| sourceLessonIds | List<String> | 若来自旧课拆分，记录来源 |
| status | enum | locked / available / in_progress / core_completed / completed / mastered / due_for_review |
| attemptCount | int | 进入并开始的次数 |
| lastStartedAt | DateTime? | 最近开始时间 |
| lastCompletedAt | DateTime? | 最近完成时间 |
| lastMasteredAt | DateTime? | 最近稳定达标时间 |
| currentScore | double? | 当前综合分，可选 |
| targetReached | bool | 是否达到本课最低达标标准 |
| weakObjectiveIds | List<String> | 本课薄弱目标 |
| seededReviewIds | List<String> | 本课生成的 review seed |
| nextRecommendedLessonId | String? | 下一推荐课 |

### 3.3 ObjectiveProgressRecord

用于描述单课目标层的结果。

建议字段：

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| lessonId | String | 所属 lesson |
| objectiveId | String | 如 g1_listen_greeting |
| status | enum | not_started / attempted / reached / weak / stable |
| accuracy | double? | 正确率 |
| evidenceCount | int | 证据题数量 |
| threshold | double? | 达标阈值 |
| lastEvaluatedAt | DateTime? | 最近判定时间 |

### 3.4 ReviewSeedRecord

用于把 lesson 结果挂接到 review 系统。

建议字段：

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| reviewId | String | review item id |
| lessonId | String | 来源 lesson |
| objectType | enum | word_reading / sentence_pattern / letter_sound 等 |
| actionType | enum | listen / repeat / distinguish / read / choose |
| itemRefId | String | 对应词、句、字母或规则 |
| initialStage | enum | new / learning / weak / review_due / stable / mastered |
| dueAt | DateTime | 首次到期时间 |

## 4. 建议枚举

### 4.1 LessonStatus

```text
locked
available
in_progress
core_completed
completed
mastered
due_for_review
```

说明：

- core_completed：核心流程走完，但未必达标
- completed：已达到最低可用能力
- mastered：经过后续验证后稳定
- due_for_review：当前不一定退回未完成，但需要优先复习

### 4.2 ObjectiveStatus

```text
not_started
attempted
reached
weak
stable
```

### 4.3 PhaseStatus

```text
not_started
active
consolidation
completed
```

### 4.4 ItemLearningStage

优先与现有 review loop 对齐：

```text
new
learning
weak
review_due
stable
mastered
```

## 5. 最小 JSON 草案

```json
{
  "lessonId": "V2-U1-05",
  "status": "completed",
  "attemptCount": 2,
  "targetReached": true,
  "weakObjectiveIds": [],
  "objectiveResults": [
    {
      "objectiveId": "g1_identity_sentence",
      "status": "reached",
      "accuracy": 1.0,
      "evidenceCount": 3,
      "threshold": 0.75
    },
    {
      "objectiveId": "g2_gender_pair_intro",
      "status": "reached",
      "accuracy": 1.0,
      "evidenceCount": 2,
      "threshold": 1.0
    }
  ],
  "seededReviewIds": [
    "rv_identity_sentence_talib",
    "rv_gender_pair_talib_taliba"
  ],
  "nextRecommendedLessonId": "V2-U1-06"
}
```

## 6. 与现有数据结构的关系

### 6.1 第一阶段不改 Lesson 主体字段

建议先不往 Lesson 内容对象硬塞以下运行时信息：

- status
- mastery
- reviewDue
- weakObjectives

原因：

- 这些字段本质上属于用户态，不属于内容静态数据
- 放在内容模型里会让缓存、资产和用户进度混在一起

### 6.2 优先新增独立 progress service

建议未来新增：

- LessonProgressService
- PhaseProgressService
- LessonCompletionEvaluator
- LessonReviewSeeder

职责拆分：

- LessonProgressService：读写单课进度
- LessonCompletionEvaluator：根据 block 和 objective 结果判定状态
- LessonReviewSeeder：完成 lesson 后生成 review seed

## 7. 目标判定最小规则

每节 V2 lesson 的判定至少经过三步：

### 7.1 核心路径完成

需要记录：

- requiredBlockIds
- completedBlockIds

若核心 block 未完成：

- status 最高只能到 in_progress

### 7.2 关键目标达标

每个 objective 保存：

- threshold
- accuracy
- evidenceCount

若所有 required objective 都过线：

- targetReached = true
- status 至少可到 completed

### 7.3 再确认与纠错

建议为 lesson 增加：

- confirmationPassed
- correctionLoopPassed

若目标接近达标但关键确认失败：

- status 留在 core_completed 或 completed with weak flag

## 8. 复习挂接规则草案

### 8.1 lesson 完成后必须 seed review

不是所有 lesson 都生成大量 review item，但至少要生成本课最关键的 1 到 3 个。

示例：

- V2-U1-01：问候识别 → greeting_opening / greeting_closing
- V2-U1-05：我是学生 → identity_sentence / gender_pair
- V2-U1-09：هذا / هذه 初识 → demonstrative_pair / gender_match

### 8.2 seed 时就带 objectType 和 actionType

这样可直接复用现有 review loop 的任务模型。

示例：

| review objectType | actionType | 来源 lesson |
| --- | --- | --- |
| sentence_pattern | listen | V2-U1-01 |
| dialogue_reply | choose | V2-U1-02 |
| template_use | repeat | V2-U1-03 |
| noun_form_intro | distinguish | V2-U1-05 |
| classroom_command | listen | V2-U1-06 |
| demonstrative_pair | distinguish | V2-U1-09 |

### 8.3 due_for_review 不等于退回未学

当 lesson 的种子 item 进入 weak 或 review_due 时：

- lessonStatus 可以显示为 due_for_review
- 但 completed 历史不应被抹掉

## 9. 首页推荐逻辑最小草案

首页推荐优先级建议：

1. formal 回顾课到期
2. due_for_review 的 lesson
3. 当前 in_progress 的 lesson
4. 下一个 available lesson
5. 可选 bridge / consolidation lesson

这可以避免首页重新退化成纯 lesson 列表。

## 10. 与测试和实现的落地顺序

### 第一阶段

- 先把 V2-U1 试点课接入 LessonProgressRecord
- 先只支持 lessonStatus、objectiveResults、seededReviewIds

### 第二阶段

- 再接 due_for_review 与 weakObjectiveIds
- 再让首页读新的推荐优先级

### 第三阶段

- 再接 formal 阶段回顾课和 phase consolidation 逻辑

## 11. 验收问题

1. lesson 是否已经能区分 available、completed、mastered、due_for_review
2. 用户是否不会因为复习到期而被误判成“没学过”
3. objective 层是否已经能留下最小证据
4. review seed 是否已能直接复用现有 review loop 的 objectType 和 actionType
5. 运行时状态是否与内容模型解耦，避免后续继续绑死在 sample lesson 资产上