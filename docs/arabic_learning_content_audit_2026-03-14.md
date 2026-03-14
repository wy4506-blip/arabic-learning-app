# 全项目学习型阿语内容盘点

盘点日期: 2026-03-14

## 统计口径

- 覆盖范围: `alphabet` / `lesson` / `grammar` / `vocab` / `dialogue` / `review` / `quiz`
- 判断规则: 凡是用户需要学习、理解、记忆、模仿、复习的阿语内容，默认按学习资产计入
- 排除规则: 仅排除明确属于 UI 标题、按钮、系统提示、导航文案的内容
- `needsAudio`: 默认 `true`
- `已有音频`: 仅统计当前项目内已有的专用音频资源或 `audio_manifest` 可命中的音频，不把 TTS fallback 计作“已有音频”
- `无播放入口`: 按当前模块页面或流程内是否存在直接点击播放入口统计，不等同于“项目别处可播”
- 总数口径: 按模块统计，不跨模块去重；`review` 与 `quiz` 为派生模块，会与源内容重复计数

## 实际生效的数据源

### Alphabet

- `assets/data/alphabets.json` 当前为空
- 实际 fallback 数据: `lib/data/sample_alphabet_data.dart`
- 入口与播放页:
  - `lib/pages/alphabet_letter_home_page.dart`
  - `lib/pages/alphabet_listen_read_page.dart`

### Lesson / Vocab / Dialogue / Lesson Quiz

- `assets/data/lessons.json` 当前为空
- 实际 fallback 数据: `lib/data/sample_lessons.dart`
- lesson 播放与 quiz 入口:
  - `lib/pages/lesson_detail_page.dart`
  - `lib/pages/lesson_quiz_page.dart`
- lesson quiz runtime 拼题:
  - `lib/services/lesson_practice_service.dart`

### Grammar

- 主页面内容: `assets/grammar/pages.json`
- 首页策展元数据: `lib/data/grammar_home_curated_data.dart`
- quick reference 数据: `lib/data/grammar_quick_reference_data.dart`
- 页面组件:
  - `lib/widgets/grammar_widgets.dart`
  - `lib/widgets/grammar_quick_reference_card.dart`

### Review

- 派生来源:
  - `lib/services/review_planner.dart`
  - `lib/services/review_service.dart`
- 当前会话页面:
  - `lib/pages/review_session_page.dart`

### Quiz

- alphabet quiz JSON: `assets/data/alphabet_quiz.json`
- alphabet quiz fallback 生成逻辑: `lib/services/quiz_service.dart`
- alphabet quiz 数据生成: `lib/data/sample_alphabet_data.dart`
- 通用 quiz 页: `lib/pages/generic_quiz_page.dart`

### 音频清单

- `assets/data/audio_manifest.json`

## 汇总结果

| 模块 | 学习资产数 | 已有音频 | 缺失音频 | 无播放入口 |
| --- | ---: | ---: | ---: | ---: |
| alphabet | 560 | 420 | 140 | 112 |
| lesson | 48 | 48 | 0 | 0 |
| grammar | 191 | 0 | 191 | 175 |
| vocab | 127 | 64 | 63 | 127 |
| dialogue | 64 | 64 | 0 | 0 |
| review | 159 | 140 | 19 | 159 |
| quiz | 251 | 104 | 147 | 147 |
| 合计 | 1400 | 840 | 560 | 720 |

补充说明:

- 如果只看项目内可命中的独立专用音频源，`audio_manifest` 当前共 `596` 条
- 明细为:
  - `64 lesson_vocabulary`
  - `48 lesson_pattern`
  - `64 lesson_dialogue`
  - `28 alphabet_letter`
  - `364 alphabet_pronunciation`
  - `28 alphabet_example_word`

## 各模块拆解

### Alphabet

资产构成:

- 28 个字母本体
- 28 个阿语字母名称
- 364 个发音形态
- 28 个示例词
- 112 个书写形态位

缺失项清单:

- 缺失专用音频
  - 28 个字母名称
  - 112 个书写形态位
- 无播放入口
  - 112 个书写形态位

说明:

- 字母名称当前有 TTS 朗读入口，但没有专用音频资源
- 书写形态位当前仅视觉展示，无音频、无播放入口

### Lesson

资产构成:

- 48 条 lesson sentence pattern

缺失项清单:

- 当前未发现缺失音频
- 当前未发现缺失播放入口

### Grammar

资产构成:

- `pages.json`
  - 134 个表格阿语单元格
  - 5 个规则符号
  - 16 个页面例句
  - 4 个 compare 阿语值
- quick reference
  - 8 个 `arabicTerm`
  - 8 个 `arabicPreview`
  - 16 个 quick reference 例句

缺失项清单:

- 缺失专用音频
  - 134 个表格阿语单元格
  - 5 个规则符号
  - 16 个页面例句
  - 4 个 compare 阿语值
  - 8 个 quick reference term
  - 8 个 quick reference preview
  - 16 个 quick reference 例句
- 无播放入口
  - 134 个表格阿语单元格
  - 5 个规则符号
  - 4 个 compare 阿语值
  - 8 个 quick reference term
  - 8 个 quick reference preview
  - 16 个 quick reference 例句

说明:

- 页面例句当前有播放按钮，但依赖 TTS fallback，不存在预置专用音频
- quick reference 卡片当前完全没有播放入口

### Vocab

资产构成:

- 64 个核心词条
- 30 个复数词形
- 15 个阴性词形
- 2 个阳性词形
- 16 个词汇例句

缺失项清单:

- 缺失专用音频
  - 30 个复数词形
  - 15 个阴性词形
  - 2 个阳性词形
  - 16 个词汇例句
- 无播放入口
  - 64 个核心词条
  - 30 个复数词形
  - 15 个阴性词形
  - 2 个阳性词形
  - 16 个词汇例句

说明:

- 64 个核心词条在 lesson 页面有音频，但在 `vocab` 模块自己的词本页没有播放入口

### Dialogue

资产构成:

- 64 条对话行

缺失项清单:

- 当前未发现缺失音频
- 当前未发现缺失播放入口

### Review

资产构成:

- 64 个 word review item
- 48 个 sentence review item
- 19 个 grammar review item
- 28 个 alphabet review item

缺失项清单:

- 缺失专用音频
  - 19 个 grammar review item
- 无播放入口
  - 64 个 word review item
  - 48 个 sentence review item
  - 19 个 grammar review item
  - 28 个 alphabet review item

结构性缺口:

- 64 条 lesson dialogue 当前没有进入 review 内容池

说明:

- `review` 模块本身没有播放按钮
- 其中 140 个 item 在源模块已有可复用音频，但在 review 流程中没有播放入口

### Quiz

资产构成:

- lesson quiz
  - 64 个 authored exercise
  - 16 个 pattern 听音题
  - 32 个 word 听音题或听写题
  - 8 个 gender 词形配对题
  - 13 个 plural 词形题
  - 14 个例句选形题
- alphabet quiz
  - 28 个 recognition question
  - 20 个 compare question
  - 28 个 sound question
  - 28 个 pronunciation question

缺失项清单:

- 缺失专用音频
  - 64 个 lesson authored exercise
  - 8 个 gender 词形配对题
  - 13 个 plural 词形题
  - 14 个例句选形题
  - 28 个 alphabet recognition question
  - 20 个 alphabet compare question
- 无播放入口
  - 64 个 lesson authored exercise
  - 8 个 gender 词形配对题
  - 13 个 plural 词形题
  - 14 个例句选形题
  - 28 个 alphabet recognition question
  - 20 个 alphabet compare question

说明:

- `alphabet_quiz.json` 当前为空，但运行时会 fallback 生成 104 道 alphabet quiz
- lesson quiz 当前真实题量不是 64，而是 147，因为会叠加 runtime 生成题

## Grammar 模块专项缺失清单

页面级缺失:

- `alphabet_table`: table cell 21
- `letter_forms`: table cell 45
- `letter_joining_rules`: table cell 6
- `harakat_rules`: rule symbol 5, example 5
- `personal_pronouns`: table cell 8
- `demonstratives`: table cell 3, example 2
- `question_words`: table cell 6
- `gender`: compare value 4
- `number_forms`: table cell 9
- `adjective_agreement`: example 2
- `past_tense`: table cell 6
- `present_tense`: table cell 6
- `nominal_sentence`: example 2
- `verbal_sentence`: example 2
- `negation`: table cell 3, example 1
- `question_sentence`: example 2
- `common_patterns`: table cell 5
- `prepositions`: table cell 5
- `numbers_basic`: table cell 11

quick reference 级缺失:

- `personal_pronouns`: term 1, preview 1, example 2
- `gender`: term 1, preview 1, example 2
- `number`: term 1, preview 1, example 2
- `definite_article`: term 1, preview 1, example 2
- `question_words`: term 1, preview 1, example 2
- `basic_sentence_patterns`: term 1, preview 1, example 2
- `common_prepositions`: term 1, preview 1, example 2
- `verb_basics`: term 1, preview 1, example 2

专项判断:

- `grammar` 是当前全项目音频缺口最大的单模块
- `letter_forms` 与 `alphabet_table` 是当前 grammar 内缺口最大的两个页面
- grammar quick reference 是“既无专用音频，也无播放入口”的完整缺口带

## 待人工确认项

- 是否需要把 `highlightParts` 视作独立学习资产
  - 当前未计入，避免把例句中的拆解提示重复计数
- 是否需要把 `vocab` 页中的 `plainArabic` 视作独立学习资产
  - 当前未计入，按同一词条的展示形态处理
- 是否需要把 onboarding `first experience` 中的字母、示例、mini quiz 并入正式盘点
  - 当前未并入主统计，建议作为独立 onboarding 学习资产处理
- 是否需要把 dialogue line 自动纳入 review 内容池
  - 当前逻辑没有覆盖，建议确认为产品意图
- 是否需要把 grammar 首页 shortcut 或 preview 中出现的阿语短语算作正式学习资产
  - 当前按“导航性 UI 或策展文案”排除

## 结论

- 当前项目的核心问题不在 UI，而在内容资产与音频覆盖的不完整对齐
- 最大缺口集中在 `grammar`、`vocab`、`review`、`quiz`
- 如果后续进入补音频阶段，建议优先顺序:
  - `grammar`
  - `vocab`
  - `review` 播放入口
  - `quiz` 非音频题型的朗读支持
