# 首轮试听生成计划 Batch 01

本计划用于替换此前存在读错、文本不对应、语速急促、机器感强的问题音频，先只处理首轮试听样本，不直接扩展到全部 30 条任务。目标不是追求统一播报速度，而是优先得到更适合阿拉伯语初学者教学的音频结果：男性声线、自然清楚、平缓稳定、适合跟读和模仿。

这轮只选 8 条试听内容，已经足够覆盖首轮判断所需的关键类型：

- 字母
- 单词 / 短词
- 陈述句
- 问句
- 较完整生活例句

只要这 8 条达标，就可以用同一套标准扩展到 [docs/audio_recording_task_batch_01.md](docs/audio_recording_task_batch_01.md) 的 30 条第一优先级任务。

## 统一生成标准

- 最高优先级：适合初学者
- 发音贴近现代标准阿拉伯语教学语境
- 长短音、元音、基础音值尽量明确
- 字母、单词、句子边界清楚
- 不赶读，不吞音，不要尾音过快收束
- 不要新闻播报腔、导航播报腔、明显机器腔

## Azure 语音建议

- 建议主音色：Azure 男声，自然、清楚、calm、beginner-friendly
- 建议优先试用：ar-SA-HamedNeural
- 直接采用的 SSML 基线：
- 字母 / 单词：rate=-26%，pitch=+1st
- 句子 slow：rate=-18%，pitch=+1st，并在句首加入 100ms break
- 句子 normal：rate=-8%，pitch=+1st
- 语气要求：
- 字母和短词：克制、稳定、边界清楚
- 陈述句：自然下收，不要太硬，不要播音腔
- 问句：末尾轻微语气变化即可，不要夸张上扬
- 生活句：保持自然口语感，但节奏仍以教学清楚为先

## 生成前校验

每条在生成前都必须检查：

- 阿拉伯语文本与任务清单完全一致
- 文件名与任务清单完全一致
- 存放路径与现有资源管线一致
- 不允许文本错配后仍继续生成

## 样本来源

- 试听样本清单：[docs/audio_pilot_sample_batch_01.md](docs/audio_pilot_sample_batch_01.md)
- 第一优先级总任务：[docs/audio_recording_task_batch_01.md](docs/audio_recording_task_batch_01.md)

## 本轮生成范围

本轮基于 8 条试听内容，共生成 13 个试听文件：

- 字母：1 个 slow
- 单词 / 短词：2 个 slow
- 句子：3 条 slow + normal 双版本，共 6 个
- 生活例句：1 条 slow + normal，共 2 个
- 总计：13 个文件

## 首轮试听生成项

| 唯一ID | 文本 | 分类 | 生成版本 | 建议文件名 | 建议路径 |
| --- | --- | --- | --- | --- | --- |
| ALP-B01-001 | أَيْ | 字母 | slow | alphabet_soft_ay_slow.mp3 | assets/audio/alphabet/pronunciation/ |
| GRM-B01-001 | بَ | 单词 / 短词 | slow | grammar_harakat_fatha_ba_slow.mp3 | assets/audio/grammar/harakat_rules/ |
| GRM-B01-011 | هذا | 单词 / 短词 | slow | grammar_demonstrative_hatha_slow.mp3 | assets/audio/grammar/demonstratives/ |
| LES-B01-001-S | هٰذَا كِتَابٌ جَدِيدٌ. | 陈述句 | slow | u1l3_word_book_class_example_slow.mp3 | assets/audio/lesson_03/sentence/ |
| LES-B01-001-N | هٰذَا كِتَابٌ جَدِيدٌ. | 陈述句 | normal | u1l3_word_book_class_example_normal.mp3 | assets/audio/lesson_03/sentence/ |
| LES-B01-004-S | هٰذِهِ سَبُّورَةٌ كَبِيرَةٌ. | 陈述句 | slow | u1l4_word_board_class_example_slow.mp3 | assets/audio/lesson_04/sentence/ |
| LES-B01-004-N | هٰذِهِ سَبُّورَةٌ كَبِيرَةٌ. | 陈述句 | normal | u1l4_word_board_class_example_normal.mp3 | assets/audio/lesson_04/sentence/ |
| GRM-B01-019-S | أَنَا طَالِبٌ | 陈述句 | slow | grammar_nominal_i_student_slow.mp3 | assets/audio/grammar/nominal_sentence/ |
| GRM-B01-019-N | أَنَا طَالِبٌ | 陈述句 | normal | grammar_nominal_i_student_normal.mp3 | assets/audio/grammar/nominal_sentence/ |
| GRM-B01-020-S | هَلْ أَنْتَ طَالِبٌ؟ | 问句 | slow | grammar_question_are_you_student_slow.mp3 | assets/audio/grammar/question_sentence/ |
| GRM-B01-020-N | هَلْ أَنْتَ طَالِبٌ؟ | 问句 | normal | grammar_question_are_you_student_normal.mp3 | assets/audio/grammar/question_sentence/ |
| LES-B01-009-S | أَلْبَسُ مِعْطَفًا فِي الشِّتَاءِ. | 较完整生活例句 | slow | u4l4_word_coat_weather_example_slow.mp3 | assets/audio/lesson_16/sentence/ |
| LES-B01-009-N | أَلْبَسُ مِعْطَفًا فِي الشِّتَاءِ. | 较完整生活例句 | normal | u4l4_word_coat_weather_example_normal.mp3 | assets/audio/lesson_16/sentence/ |

## 为什么选这 8 条

- ALP-B01-001：专门检查单个音值是否读准，是否容易和相近音混淆
- GRM-B01-001：检查最短元音样本是否清楚、是否过快
- GRM-B01-011：检查高频功能词在短词级别是否自然、稳定
- GRM-B01-019：检查基础名词句是否适合用于教学跟读
- LES-B01-001：检查基础课堂陈述句是否适合初学者跟读
- LES-B01-004：检查阴性指示代词相关句子是否会被读糊
- GRM-B01-020：检查问句语气是否自然，不过度夸张
- LES-B01-009：检查较完整生活句在慢速下是否仍自然、不僵硬

## 建议执行顺序

1. 先生成全部 slow 版本
2. 先试听并筛掉明显不达标的音色和语速
3. 在 slow 达标后，再生成对应 normal 版本
4. 把 13 个文件放入建议路径，进入工程内实测

## 首轮试听重点

- 是否仍有读错、漏读、文本错配
- slow 是否明显慢于旧版本，且不拖沓
- 男声是否自然清楚，没有过深音色、没有播报腔
- 句子是否具备适度语气变化，而不是一条直线式机器播报
- 问句是否自然，生活句是否不僵硬

## 验收闸门

只有全部满足以下条件，才允许从 8 条扩展到 30 条：

- 发音正确
- 文本与页面完全对应
- 节奏平缓，不急促
- 初学者容易跟读
- 工程内可正常播放
- 命名和路径完全匹配

## 扩展条件

若首轮试听达标，下一步按以下顺序扩展：

1. 先补完 [docs/audio_recording_task_batch_01.md](docs/audio_recording_task_batch_01.md) 里剩余 22 条未进入试听的第一优先级内容
2. 句子类继续保持 slow + normal 双版本
3. 字母、单词、短词先保 slow，必要时再补 normal