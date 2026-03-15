# Azure 音频生成清单 Batch 01

本清单仅覆盖 [docs/audio_regeneration_pilot_plan_batch_01.md](docs/audio_regeneration_pilot_plan_batch_01.md) 中首轮试听的 13 个文件，目标是先用一套更适合阿拉伯语初学者的男性语音参数，重新生成小范围样本，再决定是否扩展到第一优先级 30 条任务。

统一生成风格：

- 男性
- calm、beginner-friendly
- 平缓
- 清楚自然
- 不急促
- 适合跟读和模仿
- 词边界清楚

统一建议音色：

- voice：ar-SA-HamedNeural

统一参数基线：

- 字母 / 单词：rate=-26%，pitch=+1st
- 句子 slow：rate=-18%，pitch=+1st，句首加入 100ms break
- 句子 normal：rate=-8%，pitch=+1st

建议使用原则：

- 字母、短词：控制更稳，避免拖腔
- 陈述句：自然下收，保持句子边界清楚
- 问句：末尾仅轻微上扬，不要夸张
- 生活句：自然口语感优先，但仍以教学清楚为前提

## 通用 SSML 模板

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="RATE_VALUE" pitch="PITCH_VALUE">
      SSML_BODY
    </prosody>
  </voice>
</speak>
```

直接可用的 SSML 基线：

1. 字母 / 单词

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-26%" pitch="+1st">
      مَرْحَبًا
    </prosody>
  </voice>
</speak>
```

2. 句子 slow

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-18%" pitch="+1st">
      <break time="100ms"/>
      أَيْنَ الْمَدْرَسَةُ؟
    </prosody>
  </voice>
</speak>
```

3. 句子 normal

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-8%" pitch="+1st">
      كِتَابِي عَلَى الطَّاوِلَةِ
    </prosody>
  </voice>
</speak>
```

## 生成清单

### 1. ALP-B01-001

- 唯一ID：ALP-B01-001
- 分类：字母
- 阿拉伯语文本：أَيْ
- 版本：slow
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-24%
- 建议 pitch：-2st
- 输出文件名：alphabet_soft_ay_slow.mp3
- 输出路径：assets/audio/alphabet/pronunciation/
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-24%" pitch="-2st">
      أَيْ
    </prosody>
  </voice>
</speak>
```

### 2. GRM-B01-001

- 唯一ID：GRM-B01-001
- 分类：单词 / 短词
- 阿拉伯语文本：بَ
- 版本：slow
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-24%
- 建议 pitch：-2st
- 输出文件名：grammar_harakat_fatha_ba_slow.mp3
- 输出路径：assets/audio/grammar/harakat_rules/
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-24%" pitch="-2st">
      بَ
    </prosody>
  </voice>
</speak>
```

### 3. GRM-B01-011

- 唯一ID：GRM-B01-011
- 分类：单词 / 短词
- 阿拉伯语文本：هذا
- 版本：slow
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-24%
- 建议 pitch：-2st
- 输出文件名：grammar_demonstrative_hatha_slow.mp3
- 输出路径：assets/audio/grammar/demonstratives/
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-24%" pitch="-2st">
      هذا
    </prosody>
  </voice>
</speak>
```

### 4. LES-B01-001-S

- 唯一ID：LES-B01-001-S
- 分类：陈述句
- 阿拉伯语文本：هٰذَا كِتَابٌ جَدِيدٌ.
- 版本：slow
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-24%
- 建议 pitch：-2st
- 输出文件名：u1l3_word_book_class_example_slow.mp3
- 输出路径：assets/audio/lesson_03/sentence/
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-24%" pitch="-2st">
      هٰذَا كِتَابٌ جَدِيدٌ.
    </prosody>
  </voice>
</speak>
```

### 5. LES-B01-001-N

- 唯一ID：LES-B01-001-N
- 分类：陈述句
- 阿拉伯语文本：هٰذَا كِتَابٌ جَدِيدٌ.
- 版本：normal
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-10%
- 建议 pitch：-1st
- 输出文件名：u1l3_word_book_class_example_normal.mp3
- 输出路径：assets/audio/lesson_03/sentence/
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-10%" pitch="-1st">
      هٰذَا كِتَابٌ جَدِيدٌ.
    </prosody>
  </voice>
</speak>
```

### 6. LES-B01-004-S

- 唯一ID：LES-B01-004-S
- 分类：陈述句
- 阿拉伯语文本：هٰذِهِ سَبُّورَةٌ كَبِيرَةٌ.
- 版本：slow
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-24%
- 建议 pitch：-2st
- 输出文件名：u1l4_word_board_class_example_slow.mp3
- 输出路径：assets/audio/lesson_04/sentence/
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-24%" pitch="-2st">
      هٰذِهِ سَبُّورَةٌ كَبِيرَةٌ.
    </prosody>
  </voice>
</speak>
```

### 7. LES-B01-004-N

- 唯一ID：LES-B01-004-N
- 分类：陈述句
- 阿拉伯语文本：هٰذِهِ سَبُّورَةٌ كَبِيرَةٌ.
- 版本：normal
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-10%
- 建议 pitch：-1st
- 输出文件名：u1l4_word_board_class_example_normal.mp3
- 输出路径：assets/audio/lesson_04/sentence/
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-10%" pitch="-1st">
      هٰذِهِ سَبُّورَةٌ كَبِيرَةٌ.
    </prosody>
  </voice>
</speak>
```

### 8. GRM-B01-019-S

- 唯一ID：GRM-B01-019-S
- 分类：陈述句
- 阿拉伯语文本：أَنَا طَالِبٌ
- 版本：slow
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-24%
- 建议 pitch：-2st
- 输出文件名：grammar_nominal_i_student_slow.mp3
- 输出路径：assets/audio/grammar/nominal_sentence/
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-24%" pitch="-2st">
      أَنَا طَالِبٌ
    </prosody>
  </voice>
</speak>
```

### 9. GRM-B01-019-N

- 唯一ID：GRM-B01-019-N
- 分类：陈述句
- 阿拉伯语文本：أَنَا طَالِبٌ
- 版本：normal
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-10%
- 建议 pitch：-1st
- 输出文件名：grammar_nominal_i_student_normal.mp3
- 输出路径：assets/audio/grammar/nominal_sentence/
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-10%" pitch="-1st">
      أَنَا طَالِبٌ
    </prosody>
  </voice>
</speak>
```

### 10. GRM-B01-020-S

- 唯一ID：GRM-B01-020-S
- 分类：问句
- 阿拉伯语文本：هَلْ أَنْتَ طَالِبٌ؟
- 版本：slow
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-24%
- 建议 pitch：-2st
- 输出文件名：grammar_question_are_you_student_slow.mp3
- 输出路径：assets/audio/grammar/question_sentence/
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-24%" pitch="-2st">
      هَلْ أَنْتَ طَالِبٌ؟
    </prosody>
  </voice>
</speak>
```

### 11. GRM-B01-020-N

- 唯一ID：GRM-B01-020-N
- 分类：问句
- 阿拉伯语文本：هَلْ أَنْتَ طَالِبٌ؟
- 版本：normal
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-10%
- 建议 pitch：-1st
- 输出文件名：grammar_question_are_you_student_normal.mp3
- 输出路径：assets/audio/grammar/question_sentence/
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-10%" pitch="-1st">
      هَلْ أَنْتَ طَالِبٌ؟
    </prosody>
  </voice>
</speak>
```

### 12. LES-B01-009-S

- 唯一ID：LES-B01-009-S
- 分类：较完整生活例句
- 阿拉伯语文本：أَلْبَسُ مِعْطَفًا فِي الشِّتَاءِ.
- 版本：slow
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-24%
- 建议 pitch：-2st
- 输出文件名：u4l4_word_coat_weather_example_slow.mp3
- 输出路径：assets/audio/lesson_16/sentence/
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-24%" pitch="-2st">
      أَلْبَسُ مِعْطَفًا فِي الشِّتَاءِ.
    </prosody>
  </voice>
</speak>
```

### 13. LES-B01-009-N

- 唯一ID：LES-B01-009-N
- 分类：较完整生活例句
- 阿拉伯语文本：أَلْبَسُ مِعْطَفًا فِي الشِّتَاءِ.
- 版本：normal
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-10%
- 建议 pitch：-1st
- 输出文件名：u4l4_word_coat_weather_example_normal.mp3
- 输出路径：assets/audio/lesson_16/sentence/
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-10%" pitch="-1st">
      أَلْبَسُ مِعْطَفًا فِي الشِّتَاءِ.
    </prosody>
  </voice>
</speak>
```

## slow 与 normal 的参数区分

| 版本 | 用途 | 建议 rate | 建议 pitch | 说明 |
| --- | --- | --- | --- | --- |
| slow | 教学、跟读、首轮验收主版本 | -24% | -2st | 明显放慢，边界清楚，优先服务零基础用户 |
| normal | 自然听感补充版本 | -10% | -1st | 保持自然但仍偏稳，不允许回到旧版那种急促感 |

## 生成后检查清单

- 文本是否匹配：生成音频所用阿拉伯语文本必须与任务清单完全一致
- 文件名是否匹配：实际输出文件名必须与本清单一致
- 路径是否匹配：文件必须落在本清单指定路径下
- 工程内是否可播放：导入后在 App 内可被正确命中并正常播放
- 是否达到试听验收标准：发音正确、节奏平缓、不急促、适合初学者跟读、没有明显机器感