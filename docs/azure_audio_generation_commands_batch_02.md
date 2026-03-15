# Azure 音频生成清单 Batch 02

本清单覆盖 [docs/audio_recording_task_batch_01.md](docs/audio_recording_task_batch_01.md) 中的全部 30 条任务，并严格沿用当前已确认通过试听的 Azure 参数基线，不再重新设计音色或风格。根据版本规则，本批共包含 30 个逻辑任务、41 个实际输出文件。

## 本批次统一生成基线

- 当前采用的 Azure voice：ar-SA-HamedNeural
- 统一音色方向：男性、自然、温和、平缓、清楚
- 适合阿拉伯语初学者
- 不急促，不明显机器感
- 当前已确认试听基线：rate=-22%，pitch=+0st
- slow 参数标准：rate=-22%，pitch=+0st
- normal 参数标准：rate=-22%，pitch=+0st
- 句子类 slow 版本：在 prosody 内句首加入 `<break time="100ms"/>`，增强学习跟读节奏
- 句子类 normal 版本：不加句首 break，保持更自然的整句连贯感
- 字母与语法短项：仅生成 slow
- 课程例句：生成 slow + normal
- 语法完整例句：生成 slow + normal

## 通用 SSML 模板

### 1. 字母 / 语法短项 slow

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st">ARABIC_TEXT</prosody>
  </voice>
</speak>
```

### 2. 句子 slow

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st"><break time="100ms"/>ARABIC_TEXT</prosody>
  </voice>
</speak>
```

### 3. 句子 normal

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st">ARABIC_TEXT</prosody>
  </voice>
</speak>
```

## 生成任务明细

### 1. ALP-B01-001

- 唯一ID：ALP-B01-001
- 分类：字母
- 阿拉伯语文本：أَيْ
- 中文释义：软音 ay

版本输出：

- 生成版本：slow
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-22%
- 建议 pitch：+0st
- 输出文件名：alphabet_soft_ay_slow.mp3
- 输出路径：assets/audio/alphabet/pronunciation/alphabet_soft_ay_slow.mp3
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st">أَيْ</prosody>
  </voice>
</speak>
```

### 2. LES-B01-001

- 唯一ID：LES-B01-001
- 分类：课程例句
- 阿拉伯语文本：هٰذَا كِتَابٌ جَدِيدٌ.
- 中文释义：这是一本新书。

版本输出：

- 生成版本：slow
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-22%
- 建议 pitch：+0st
- 输出文件名：u1l3_word_book_class_example_slow.mp3
- 输出路径：assets/audio/lesson_03/sentence/u1l3_word_book_class_example_slow.mp3
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st"><break time="100ms"/>هٰذَا كِتَابٌ جَدِيدٌ.</prosody>
  </voice>
</speak>
```

- 生成版本：normal
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-22%
- 建议 pitch：+0st
- 输出文件名：u1l3_word_book_class_example_normal.mp3
- 输出路径：assets/audio/lesson_03/sentence/u1l3_word_book_class_example_normal.mp3
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st">هٰذَا كِتَابٌ جَدِيدٌ.</prosody>
  </voice>
</speak>
```

### 3. LES-B01-002

- 唯一ID：LES-B01-002
- 分类：课程例句
- 阿拉伯语文本：هٰذَا مُعَلِّمٌ جَيِّدٌ.
- 中文释义：这是一位好老师。

版本输出：

- 生成版本：slow
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-22%
- 建议 pitch：+0st
- 输出文件名：u1l3_word_teacher_class_example_slow.mp3
- 输出路径：assets/audio/lesson_03/sentence/u1l3_word_teacher_class_example_slow.mp3
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st"><break time="100ms"/>هٰذَا مُعَلِّمٌ جَيِّدٌ.</prosody>
  </voice>
</speak>
```

- 生成版本：normal
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-22%
- 建议 pitch：+0st
- 输出文件名：u1l3_word_teacher_class_example_normal.mp3
- 输出路径：assets/audio/lesson_03/sentence/u1l3_word_teacher_class_example_normal.mp3
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st">هٰذَا مُعَلِّمٌ جَيِّدٌ.</prosody>
  </voice>
</speak>
```

### 4. LES-B01-003

- 唯一ID：LES-B01-003
- 分类：课程例句
- 阿拉伯语文本：هٰذَا قَلَمٌ أَخْضَرُ.
- 中文释义：这是一支绿色的笔。

版本输出：

- 生成版本：slow
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-22%
- 建议 pitch：+0st
- 输出文件名：u1l4_word_pen_class_example_slow.mp3
- 输出路径：assets/audio/lesson_04/sentence/u1l4_word_pen_class_example_slow.mp3
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st"><break time="100ms"/>هٰذَا قَلَمٌ أَخْضَرُ.</prosody>
  </voice>
</speak>
```

- 生成版本：normal
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-22%
- 建议 pitch：+0st
- 输出文件名：u1l4_word_pen_class_example_normal.mp3
- 输出路径：assets/audio/lesson_04/sentence/u1l4_word_pen_class_example_normal.mp3
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st">هٰذَا قَلَمٌ أَخْضَرُ.</prosody>
  </voice>
</speak>
```

### 5. LES-B01-004

- 唯一ID：LES-B01-004
- 分类：课程例句
- 阿拉伯语文本：هٰذِهِ سَبُّورَةٌ كَبِيرَةٌ.
- 中文释义：这是一块大黑板。

版本输出：

- 生成版本：slow
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-22%
- 建议 pitch：+0st
- 输出文件名：u1l4_word_board_class_example_slow.mp3
- 输出路径：assets/audio/lesson_04/sentence/u1l4_word_board_class_example_slow.mp3
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st"><break time="100ms"/>هٰذِهِ سَبُّورَةٌ كَبِيرَةٌ.</prosody>
  </voice>
</speak>
```

- 生成版本：normal
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-22%
- 建议 pitch：+0st
- 输出文件名：u1l4_word_board_class_example_normal.mp3
- 输出路径：assets/audio/lesson_04/sentence/u1l4_word_board_class_example_normal.mp3
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st">هٰذِهِ سَبُّورَةٌ كَبِيرَةٌ.</prosody>
  </voice>
</speak>
```

### 6. LES-B01-005

- 唯一ID：LES-B01-005
- 分类：课程例句
- 阿拉伯语文本：لِي أَخٌ وَاحِدٌ.
- 中文释义：我有一个兄弟。

版本输出：

- 生成版本：slow
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-22%
- 建议 pitch：+0st
- 输出文件名：u2l1_word_brother_family_example_slow.mp3
- 输出路径：assets/audio/lesson_05/sentence/u2l1_word_brother_family_example_slow.mp3
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st"><break time="100ms"/>لِي أَخٌ وَاحِدٌ.</prosody>
  </voice>
</speak>
```

- 生成版本：normal
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-22%
- 建议 pitch：+0st
- 输出文件名：u2l1_word_brother_family_example_normal.mp3
- 输出路径：assets/audio/lesson_05/sentence/u2l1_word_brother_family_example_normal.mp3
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st">لِي أَخٌ وَاحِدٌ.</prosody>
  </voice>
</speak>
```

### 7. LES-B01-006

- 唯一ID：LES-B01-006
- 分类：课程例句
- 阿拉伯语文本：أَبِي مُدَرِّسٌ.
- 中文释义：我爸爸是老师。

版本输出：

- 生成版本：slow
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-22%
- 建议 pitch：+0st
- 输出文件名：u2l2_word_teacher_job_example_slow.mp3
- 输出路径：assets/audio/lesson_06/sentence/u2l2_word_teacher_job_example_slow.mp3
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st"><break time="100ms"/>أَبِي مُدَرِّسٌ.</prosody>
  </voice>
</speak>
```

- 生成版本：normal
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-22%
- 建议 pitch：+0st
- 输出文件名：u2l2_word_teacher_job_example_normal.mp3
- 输出路径：assets/audio/lesson_06/sentence/u2l2_word_teacher_job_example_normal.mp3
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st">أَبِي مُدَرِّسٌ.</prosody>
  </voice>
</speak>
```

### 8. LES-B01-007

- 唯一ID：LES-B01-007
- 分类：课程例句
- 阿拉伯语文本：السِّعْرُ مُنَاسِبٌ.
- 中文释义：这个价格合适。

版本输出：

- 生成版本：slow
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-22%
- 建议 pitch：+0st
- 输出文件名：u4l2_word_price_shop_example_slow.mp3
- 输出路径：assets/audio/lesson_14/sentence/u4l2_word_price_shop_example_slow.mp3
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st"><break time="100ms"/>السِّعْرُ مُنَاسِبٌ.</prosody>
  </voice>
</speak>
```

- 生成版本：normal
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-22%
- 建议 pitch：+0st
- 输出文件名：u4l2_word_price_shop_example_normal.mp3
- 输出路径：assets/audio/lesson_14/sentence/u4l2_word_price_shop_example_normal.mp3
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st">السِّعْرُ مُنَاسِبٌ.</prosody>
  </voice>
</speak>
```

### 9. LES-B01-008

- 唯一ID：LES-B01-008
- 分类：课程例句
- 阿拉伯语文本：هٰذَا شَارِعٌ وَاسِعٌ.
- 中文释义：这是一条宽街道。

版本输出：

- 生成版本：slow
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-22%
- 建议 pitch：+0st
- 输出文件名：u4l3_word_street_route_example_slow.mp3
- 输出路径：assets/audio/lesson_15/sentence/u4l3_word_street_route_example_slow.mp3
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st"><break time="100ms"/>هٰذَا شَارِعٌ وَاسِعٌ.</prosody>
  </voice>
</speak>
```

- 生成版本：normal
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-22%
- 建议 pitch：+0st
- 输出文件名：u4l3_word_street_route_example_normal.mp3
- 输出路径：assets/audio/lesson_15/sentence/u4l3_word_street_route_example_normal.mp3
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st">هٰذَا شَارِعٌ وَاسِعٌ.</prosody>
  </voice>
</speak>
```

### 10. LES-B01-009

- 唯一ID：LES-B01-009
- 分类：课程例句
- 阿拉伯语文本：أَلْبَسُ مِعْطَفًا فِي الشِّتَاءِ.
- 中文释义：我冬天穿外套。

版本输出：

- 生成版本：slow
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-22%
- 建议 pitch：+0st
- 输出文件名：u4l4_word_coat_weather_example_slow.mp3
- 输出路径：assets/audio/lesson_16/sentence/u4l4_word_coat_weather_example_slow.mp3
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st"><break time="100ms"/>أَلْبَسُ مِعْطَفًا فِي الشِّتَاءِ.</prosody>
  </voice>
</speak>
```

- 生成版本：normal
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-22%
- 建议 pitch：+0st
- 输出文件名：u4l4_word_coat_weather_example_normal.mp3
- 输出路径：assets/audio/lesson_16/sentence/u4l4_word_coat_weather_example_normal.mp3
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st">أَلْبَسُ مِعْطَفًا فِي الشِّتَاءِ.</prosody>
  </voice>
</speak>
```

### 11. GRM-B01-001

- 唯一ID：GRM-B01-001
- 分类：语法短项
- 阿拉伯语文本：بَ
- 中文释义：发 a

版本输出：

- 生成版本：slow
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-22%
- 建议 pitch：+0st
- 输出文件名：grammar_harakat_fatha_ba_slow.mp3
- 输出路径：assets/audio/grammar/harakat_rules/grammar_harakat_fatha_ba_slow.mp3
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st">بَ</prosody>
  </voice>
</speak>
```

### 12. GRM-B01-002

- 唯一ID：GRM-B01-002
- 分类：语法短项
- 阿拉伯语文本：بِ
- 中文释义：发 i

版本输出：

- 生成版本：slow
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-22%
- 建议 pitch：+0st
- 输出文件名：grammar_harakat_kasra_bi_slow.mp3
- 输出路径：assets/audio/grammar/harakat_rules/grammar_harakat_kasra_bi_slow.mp3
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st">بِ</prosody>
  </voice>
</speak>
```

### 13. GRM-B01-003

- 唯一ID：GRM-B01-003
- 分类：语法短项
- 阿拉伯语文本：بُ
- 中文释义：发 u

版本输出：

- 生成版本：slow
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-22%
- 建议 pitch：+0st
- 输出文件名：grammar_harakat_damma_bu_slow.mp3
- 输出路径：assets/audio/grammar/harakat_rules/grammar_harakat_damma_bu_slow.mp3
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st">بُ</prosody>
  </voice>
</speak>
```

### 14. GRM-B01-004

- 唯一ID：GRM-B01-004
- 分类：语法短项
- 阿拉伯语文本：بْ
- 中文释义：无元音

版本输出：

- 生成版本：slow
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-22%
- 建议 pitch：+0st
- 输出文件名：grammar_harakat_sukun_b_slow.mp3
- 输出路径：assets/audio/grammar/harakat_rules/grammar_harakat_sukun_b_slow.mp3
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st">بْ</prosody>
  </voice>
</speak>
```

### 15. GRM-B01-005

- 唯一ID：GRM-B01-005
- 分类：语法短项
- 阿拉伯语文本：بَّ
- 中文释义：双辅音

版本输出：

- 生成版本：slow
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-22%
- 建议 pitch：+0st
- 输出文件名：grammar_harakat_shadda_bba_slow.mp3
- 输出路径：assets/audio/grammar/harakat_rules/grammar_harakat_shadda_bba_slow.mp3
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st">بَّ</prosody>
  </voice>
</speak>
```

### 16. GRM-B01-006

- 唯一ID：GRM-B01-006
- 分类：语法短项
- 阿拉伯语文本：أنا
- 中文释义：我

版本输出：

- 生成版本：slow
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-22%
- 建议 pitch：+0st
- 输出文件名：grammar_pronoun_ana_slow.mp3
- 输出路径：assets/audio/grammar/personal_pronouns/grammar_pronoun_ana_slow.mp3
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st">أنا</prosody>
  </voice>
</speak>
```

### 17. GRM-B01-007

- 唯一ID：GRM-B01-007
- 分类：语法短项
- 阿拉伯语文本：أَنْتَ
- 中文释义：你（男）

版本输出：

- 生成版本：slow
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-22%
- 建议 pitch：+0st
- 输出文件名：grammar_pronoun_anta_slow.mp3
- 输出路径：assets/audio/grammar/personal_pronouns/grammar_pronoun_anta_slow.mp3
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st">أَنْتَ</prosody>
  </voice>
</speak>
```

### 18. GRM-B01-008

- 唯一ID：GRM-B01-008
- 分类：语法短项
- 阿拉伯语文本：أَنْتِ
- 中文释义：你（女）

版本输出：

- 生成版本：slow
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-22%
- 建议 pitch：+0st
- 输出文件名：grammar_pronoun_anti_slow.mp3
- 输出路径：assets/audio/grammar/personal_pronouns/grammar_pronoun_anti_slow.mp3
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st">أَنْتِ</prosody>
  </voice>
</speak>
```

### 19. GRM-B01-009

- 唯一ID：GRM-B01-009
- 分类：语法短项
- 阿拉伯语文本：هُوَ
- 中文释义：他

版本输出：

- 生成版本：slow
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-22%
- 建议 pitch：+0st
- 输出文件名：grammar_pronoun_huwa_slow.mp3
- 输出路径：assets/audio/grammar/personal_pronouns/grammar_pronoun_huwa_slow.mp3
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st">هُوَ</prosody>
  </voice>
</speak>
```

### 20. GRM-B01-010

- 唯一ID：GRM-B01-010
- 分类：语法短项
- 阿拉伯语文本：هِيَ
- 中文释义：她

版本输出：

- 生成版本：slow
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-22%
- 建议 pitch：+0st
- 输出文件名：grammar_pronoun_hiya_slow.mp3
- 输出路径：assets/audio/grammar/personal_pronouns/grammar_pronoun_hiya_slow.mp3
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st">هِيَ</prosody>
  </voice>
</speak>
```

### 21. GRM-B01-011

- 唯一ID：GRM-B01-011
- 分类：语法短项
- 阿拉伯语文本：هذا
- 中文释义：这个（阳）

版本输出：

- 生成版本：slow
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-22%
- 建议 pitch：+0st
- 输出文件名：grammar_demonstrative_hatha_slow.mp3
- 输出路径：assets/audio/grammar/demonstratives/grammar_demonstrative_hatha_slow.mp3
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st">هذا</prosody>
  </voice>
</speak>
```

### 22. GRM-B01-012

- 唯一ID：GRM-B01-012
- 分类：语法短项
- 阿拉伯语文本：هذه
- 中文释义：这个（阴）

版本输出：

- 生成版本：slow
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-22%
- 建议 pitch：+0st
- 输出文件名：grammar_demonstrative_hadhihi_slow.mp3
- 输出路径：assets/audio/grammar/demonstratives/grammar_demonstrative_hadhihi_slow.mp3
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st">هذه</prosody>
  </voice>
</speak>
```

### 23. GRM-B01-013

- 唯一ID：GRM-B01-013
- 分类：语法短项
- 阿拉伯语文本：ما
- 中文释义：什么

版本输出：

- 生成版本：slow
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-22%
- 建议 pitch：+0st
- 输出文件名：grammar_question_ma_slow.mp3
- 输出路径：assets/audio/grammar/question_words/grammar_question_ma_slow.mp3
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st">ما</prosody>
  </voice>
</speak>
```

### 24. GRM-B01-014

- 唯一ID：GRM-B01-014
- 分类：语法短项
- 阿拉伯语文本：من
- 中文释义：谁

版本输出：

- 生成版本：slow
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-22%
- 建议 pitch：+0st
- 输出文件名：grammar_question_man_slow.mp3
- 输出路径：assets/audio/grammar/question_words/grammar_question_man_slow.mp3
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st">من</prosody>
  </voice>
</speak>
```

### 25. GRM-B01-015

- 唯一ID：GRM-B01-015
- 分类：语法短项
- 阿拉伯语文本：أين
- 中文释义：哪里

版本输出：

- 生成版本：slow
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-22%
- 建议 pitch：+0st
- 输出文件名：grammar_question_ayna_slow.mp3
- 输出路径：assets/audio/grammar/question_words/grammar_question_ayna_slow.mp3
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st">أين</prosody>
  </voice>
</speak>
```

### 26. GRM-B01-016

- 唯一ID：GRM-B01-016
- 分类：语法短项
- 阿拉伯语文本：كيف
- 中文释义：怎么 / 如何

版本输出：

- 生成版本：slow
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-22%
- 建议 pitch：+0st
- 输出文件名：grammar_question_kayfa_slow.mp3
- 输出路径：assets/audio/grammar/question_words/grammar_question_kayfa_slow.mp3
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st">كيف</prosody>
  </voice>
</speak>
```

### 27. GRM-B01-017

- 唯一ID：GRM-B01-017
- 分类：语法短项
- 阿拉伯语文本：لَيْسَ
- 中文释义：不是……

版本输出：

- 生成版本：slow
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-22%
- 建议 pitch：+0st
- 输出文件名：grammar_negation_laysa_slow.mp3
- 输出路径：assets/audio/grammar/negation/grammar_negation_laysa_slow.mp3
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st">لَيْسَ</prosody>
  </voice>
</speak>
```

### 28. GRM-B01-018

- 唯一ID：GRM-B01-018
- 分类：语法短项
- 阿拉伯语文本：لا
- 中文释义：不 / 不会 / 没有

版本输出：

- 生成版本：slow
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-22%
- 建议 pitch：+0st
- 输出文件名：grammar_negation_la_slow.mp3
- 输出路径：assets/audio/grammar/negation/grammar_negation_la_slow.mp3
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st">لا</prosody>
  </voice>
</speak>
```

### 29. GRM-B01-019

- 唯一ID：GRM-B01-019
- 分类：语法完整例句
- 阿拉伯语文本：أَنَا طَالِبٌ
- 中文释义：我是学生。

版本输出：

- 生成版本：slow
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-22%
- 建议 pitch：+0st
- 输出文件名：grammar_nominal_i_student_slow.mp3
- 输出路径：assets/audio/grammar/nominal_sentence/grammar_nominal_i_student_slow.mp3
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st"><break time="100ms"/>أَنَا طَالِبٌ</prosody>
  </voice>
</speak>
```

- 生成版本：normal
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-22%
- 建议 pitch：+0st
- 输出文件名：grammar_nominal_i_student_normal.mp3
- 输出路径：assets/audio/grammar/nominal_sentence/grammar_nominal_i_student_normal.mp3
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st">أَنَا طَالِبٌ</prosody>
  </voice>
</speak>
```

### 30. GRM-B01-020

- 唯一ID：GRM-B01-020
- 分类：语法完整例句
- 阿拉伯语文本：هَلْ أَنْتَ طَالِبٌ؟
- 中文释义：你是学生吗？

版本输出：

- 生成版本：slow
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-22%
- 建议 pitch：+0st
- 输出文件名：grammar_question_are_you_student_slow.mp3
- 输出路径：assets/audio/grammar/question_sentence/grammar_question_are_you_student_slow.mp3
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st"><break time="100ms"/>هَلْ أَنْتَ طَالِبٌ؟</prosody>
  </voice>
</speak>
```

- 生成版本：normal
- 建议 voice：ar-SA-HamedNeural
- 建议 rate：-22%
- 建议 pitch：+0st
- 输出文件名：grammar_question_are_you_student_normal.mp3
- 输出路径：assets/audio/grammar/question_sentence/grammar_question_are_you_student_normal.mp3
- 对应 SSML 示例：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xml:lang="ar-SA">
  <voice name="ar-SA-HamedNeural">
    <prosody rate="-22%" pitch="+0st">هَلْ أَنْتَ طَالِبٌ؟</prosody>
  </voice>
</speak>
```

## 生成后导入检查清单

- 文本是否匹配
- 文件名是否匹配
- 路径是否匹配
- manifest 是否同步
- 工程内是否正常播放
- 是否达到首轮试听确认过的标准