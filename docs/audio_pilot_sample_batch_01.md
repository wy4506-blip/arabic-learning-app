# 首轮试听验证清单 Batch 01

这 8 条足够作为首轮试听验证样本，因为它们同时覆盖了 3 个关键维度：一是字母级发音，能快速判断单音是否清楚；二是课程例句，能判断完整句子的节奏、停顿和自然度；三是语法样本，能同时检验短元音、功能词、基础名词句和基础问句的可听性。用这 8 条先做一轮试听，已经足够判断当前配音或 AI 生成结果是否适合继续批量扩展。

## 试听样本明细

| 唯一ID | 分类 | 阿拉伯语文本 | 中文释义 | 建议语速 | 建议风格 | 建议文件名 | 建议路径 | 选它作为试听样本的原因 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ALP-B01-001 | 字母 | أَيْ | 软音 ay | slow | 温和、平缓、适合初学者 | alphabet_soft_ay_slow.mp3 | assets/audio/alphabet/pronunciation/ | 唯一的字母优先项，能直接验证单个标准发音是否清楚，尤其适合检查 ay 音边界是否明确、是否容易和 aw 混淆。 |
| LES-B01-001 | 课程例句 | هٰذَا كِتَابٌ جَدِيدٌ. | 这是一本新书。 | slow | 温和、平缓、适合初学者 | u1l3_word_book_class_example_slow.mp3 | assets/audio/lesson_03/sentence/ | 课堂场景高频句，结构简单，适合判断指示代词 + 名词 + 形容词的自然连读是否稳定。 |
| LES-B01-004 | 课程例句 | هٰذِهِ سَبُّورَةٌ كَبِيرَةٌ. | 这是一块大黑板。 | slow | 温和、平缓、适合初学者 | u1l4_word_board_class_example_slow.mp3 | assets/audio/lesson_04/sentence/ | 这条能验证阴性指示代词这类更容易读糊的词是否清楚，也能检查整句停顿是否自然。 |
| LES-B01-009 | 课程例句 | أَلْبَسُ مِعْطَفًا فِي الشِّتَاءِ. | 我冬天穿外套。 | slow | 温和、平缓、适合初学者 | u4l4_word_coat_weather_example_slow.mp3 | assets/audio/lesson_16/sentence/ | 这是一条较完整的生活表达句，适合检验较长句子的节奏、句中连贯性和句尾收束是否自然。 |
| GRM-B01-001 | 语法示例 | بَ | 发 a | slow | 温和、平缓、适合初学者 | grammar_harakat_fatha_ba_slow.mp3 | assets/audio/grammar/harakat_rules/ | 最基础的短元音样本，最适合判断单音录制是否干净、是否过快、是否有不自然的机械感。 |
| GRM-B01-011 | 语法示例 | هذا | 这个（阳） | slow | 温和、平缓、适合初学者 | grammar_demonstrative_hatha_slow.mp3 | assets/audio/grammar/demonstratives/ | 这是课程和语法页都会高频使用的功能词，适合判断短词级样本是否清楚、稳定、可复用。 |
| GRM-B01-019 | 语法示例 | أَنَا طَالِبٌ | 我是学生。 | slow | 温和、平缓、适合初学者 | grammar_nominal_i_student_slow.mp3 | assets/audio/grammar/nominal_sentence/ | 名词句入门核心句，适合验证“短句但不是单词”的朗读效果，尤其适合评估初学者是否容易跟读。 |
| GRM-B01-020 | 语法示例 | هَلْ أَنْتَ طَالِبٌ؟ | 你是学生吗？ | slow | 温和、平缓、适合初学者 | grammar_question_are_you_student_slow.mp3 | assets/audio/grammar/question_sentence/ | 这是最基础的问句模板，能很好地检验问句语气是否自然、句子边界是否清楚、整体是否不过快。 |

## 试听验收标准

- 发音自然，不僵硬，不生硬
- 节奏平缓，停顿自然
- 不过快，初学者能清楚听见每个核心音节
- 初学者容易跟读，不会因为吞音或连得太快而失去参照
- 工程内可正常播放，导入后能被现有播放链路正常命中
- 命名与路径匹配正确，文件名、目录和任务单保持一致