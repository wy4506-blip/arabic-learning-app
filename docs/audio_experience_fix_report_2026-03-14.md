# 音频体验系统化修复报告

日期：2026-03-14

## 1. 本次修复目标

本次修复聚焦“阿拉伯语初学者在所有该听的地方，都能稳定、自然地听到发音”。

核心原则：

- 所有学习内容播放统一收口到 `AudioService.playLearningText(...)`
- 页面层不再自己拼路径、不再自己决定 fallback
- 播放顺序固定为 `human_slow > human_normal > ai_slow > ai_normal > tts`
- 资源缺失时不允许静默失败，必须继续 fallback 并输出完整 debug 日志

## 2. 统一后的播放逻辑

本次将音频播放主链路统一到以下中心层：

- `lib/services/audio_service.dart`
- `lib/services/audio_manifest_service.dart`

已统一的能力：

- 统一请求模型：`LearningAudioRequest`
- 统一播放入口：`AudioService.playLearningText(...)`
- 统一 manifest 候选检索：`AudioManifestService.findLearningCandidates(...)`
- 统一资源存在校验：优先检查真实可打包 asset，再决定是否尝试播放
- 统一扩展名兼容：支持 `.mp3 / .m4a / .wav / .ogg` 回退解析
- 统一 debug 日志：输出请求文本、命中资源类型、最终路径、fallback 过程、最终失败原因
- 统一测试注入能力：可在测试中模拟 manifest、asset 播放器和 TTS

## 3. 新增复用组件

新增组件：

- `lib/widgets/arabic_text_with_audio.dart`

包含：

- `ArabicTextWithAudio`
- `LearningAudioIconButton`

用途：

- 给阿语文本展示节点直接挂统一播放能力
- 避免页面重复写 `IconButton + AudioService + try/catch`

## 4. 已修改页面与组件

### 页面

- `lib/features/onboarding/pages/first_experience_flow_page.dart`
- `lib/pages/alphabet_detail_page.dart`
- `lib/pages/alphabet_group_detail_page.dart`
- `lib/pages/alphabet_letter_home_page.dart`
- `lib/pages/alphabet_listen_read_page.dart`
- `lib/pages/generic_quiz_page.dart`
- `lib/pages/grammar_detail_page.dart`
- `lib/pages/lesson_detail_page.dart`
- `lib/pages/lesson_quiz_page.dart`
- `lib/pages/quiz_scaffold.dart`
- `lib/pages/review_session_page.dart`
- `lib/pages/vocab_book_page.dart`

### 共享组件

- `lib/widgets/grammar_quick_reference_card.dart`
- `lib/widgets/grammar_widgets.dart`
- `lib/widgets/review/review_item_sections.dart`

## 5. 已补发音按钮的内容类型

本次已补齐或统一到可复用按钮组件的内容包括：

- 字母卡片与字母组展示
- 字母详情与听读页
- 生词本单词卡片
- 课程单词卡片
- 课程阿语题干与阿语选项
- 语法速查示例
- 语法表格中的阿语单元格
- 语法对比卡中的阿语值
- 语法示例卡
- 复习预览卡阿语题干
- 复习会话主题干

## 6. 开发期检查逻辑

新增脚本：

- `tool/check_audio_coverage.dart`

用途：

- 输出有 `textAr` 但没有音频映射的内容
- 输出 manifest 有记录但 asset 文件不存在的内容
- 输出 asset 文件存在但 manifest 未登记的内容

推荐运行方式：

- `dart run tool/check_audio_coverage.dart`

## 7. 基础测试

新增测试：

- `test/audio_service_test.dart`

已验证：

- 命中资源时优先播放 asset
- `human` 缺失时继续降级到 `ai`
- 所有 asset fallback 失败后才进入 TTS

## 8. 当前仍缺少正式音频资源的内容清单

运行 `dart run tool/check_audio_coverage.dart` 的结果：

- 预期学习内容：766
- manifest 条目：800
- 实际 asset 文件：804
- `textAr` 存在但无音频映射：113
- manifest 记录但文件不存在：0
- 文件存在但 manifest 未登记：4

### 8.1 字母内容缺口

- `alphabet/1/pronunciation/soft_ay` 对应 `أَيْ`

### 8.2 课程正式内容缺口

缺少正式音频的课程例句：

- `U1L3/word-example/word_book_class` `هٰذَا كِتَابٌ جَدِيدٌ.`
- `U1L3/word-example/word_teacher_class` `هٰذَا مُعَلِّمٌ جَيِّدٌ.`
- `U1L4/word-example/word_pen_class` `هٰذَا قَلَمٌ أَخْضَرُ.`
- `U1L4/word-example/word_board_class` `هٰذِهِ سَبُّورَةٌ كَبِيرَةٌ.`
- `U2L1/word-example/word_brother_family` `لِي أَخٌ وَاحِدٌ.`
- `U2L2/word-example/word_teacher_job` `أَبِي مُدَرِّسٌ.`
- `U4L2/word-example/word_price_shop` `السِّعْرُ مُنَاسِبٌ.`
- `U4L3/word-example/word_street_route` `هٰذَا شَارِعٌ وَاسِعٌ.`
- `U4L4/word-example/word_coat_weather` `أَلْبَسُ مِعْطَفًا فِي الشِّتَاءِ.`

### 8.3 语法正式内容缺口

当前缺口主要集中在语法页，共 103 项，主要包括：

- 字母位置变化表中的位置字形：`بـ / ـبـ / ـب / ...`
- `harakat_rules` 中的基础音符示例：`بَ / بِ / بُ / بْ / بَّ`
- `personal_pronouns` 中的代词项：如 `أنا / أنتَ / أنتِ / نحن / هم / هنّ`
- `demonstratives` 中的指示代词及示例句
- `question_words` 中的疑问词项
- `gender`、`number_forms` 中的词形对照项
- `past_tense`、`present_tense` 中的变位表项
- `nominal_sentence`、`verbal_sentence`、`negation`、`question_sentence` 中的示例句
- `common_patterns`、`prepositions`、`numbers_basic` 中的基础模式和词项

说明：

- 这些内容现在已经在 UI 中有统一发音按钮
- 即使没有正式资源，也会继续 fallback 到 TTS，不会静默失败
- 后续补真人/AI 录音时，优先建议先补“语法示例句”和“高频表格核心项”

### 8.4 孤儿资源

当前发现 4 个已存在但未登记到 manifest 的资源：

- `assets/audio/words/ana.ogg.ogg`
- `assets/audio/words/kitab.oga.oga`
- `assets/audio/words/la.ogg.ogg`
- `assets/audio/words/naam.ogg.ogg`

## 9. 后续建议

建议按以下优先级继续补资源：

1. 先补 9 条课程正式例句和 `soft_ay`，因为这部分最直接影响初学者主链路
2. 再补语法页中高频示例句与最常点击的表格核心项
3. 最后清理 `assets/audio/words/` 下 4 个孤儿资源，决定是登记还是删除