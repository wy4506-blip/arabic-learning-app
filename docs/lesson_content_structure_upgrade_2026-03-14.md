# Lesson Content Structure Upgrade

日期：2026-03-14

## 本次目标

在尽量兼容现有代码的前提下，把课程内容从“页面直接拼散字段”整理为“模型层提供结构化访问”，优先支撑：

- 带音符文本 / 去音符文本
- 中文释义 / 预留英文释义
- 音频引用
- 词性 / 性数 / 构词说明
- 单复数 / 阴阳性扩展字段
- 例句与复习系统接入

## 新旧字段变化说明

### 1. `LessonWord`

旧字段仍保留：

- `arabic`
- `plainArabic`
- `chinese`
- `wordType`
- `gender`
- `number`
- `pluralFormVocalized`
- `pluralFormPlain`
- `feminineFormVocalized`
- `feminineFormPlain`
- `masculineFormVocalized`
- `masculineFormPlain`
- `patternNote`
- `exampleSentenceVocalized`
- `exampleSentencePlain`
- `exampleTranslationZh`
- `audio`

新增兼容字段：

- `english`
- `exampleTranslationEn`
- `exampleAudio`

新增结构化访问：

- `word.text`
  - `vocalized`
  - `plain`
- `word.meaning`
  - `zh`
  - `en`
- `word.metadata`
  - `partOfSpeech`
  - `gender`
  - `number`
  - `morphology`
  - `patternNote`
- `word.forms`
  - `plural`
  - `feminine`
  - `masculine`
- `word.example`
  - `text`
  - `meaning`
  - `audio`
- `word.audioRef`

### 2. `LessonPattern`

旧字段仍保留：

- `arabic`
- `transliteration`
- `chinese`
- `audio`

新增兼容字段：

- `plainArabic`
- `english`

新增结构化访问：

- `pattern.text`
- `pattern.meaning`
- `pattern.audioRef`
- `pattern.content`

### 3. `DialogueLine`

旧字段仍保留：

- `speaker`
- `arabic`
- `transliteration`
- `chinese`
- `audio`

新增兼容字段：

- `plainArabic`
- `english`

新增结构化访问：

- `line.text`
- `line.meaning`
- `line.audioRef`
- `line.content`

### 4. `Lesson`

旧字段仍保留：

- `titleCn`
- `titleAr`
- `grammarTitle`
- `grammarExplanation`

新增兼容字段：

- `titleEn`
- `grammarTitleEn`
- `grammarExplanationEn`

新增结构化访问：

- `lesson.title`
  - `zh`
  - `ar`
  - `en`
- `lesson.grammar`
  - `titleZh`
  - `explanationZh`
  - `titleEn`
  - `explanationEn`
- `lesson.hasGrammar`

### 5. `WordItem`

为兼容复习 / 词本链路，也补了同口径 accessor：

- `wordItem.text`
- `wordItem.metadata`
- `wordItem.pluralForm`
- `wordItem.feminineForm`
- `wordItem.masculineForm`
- `wordItem.example`

## JSON 兼容策略

当前模型同时支持两种写法：

### 旧写法

继续支持平铺字段，例如：

```json
{
  "arabic": "مَرْحَبًا",
  "plainArabic": "مرحبا",
  "chinese": "你好",
  "wordType": "expression",
  "audio": "lesson_01/word/l01_w_001_normal.mp3"
}
```

### 新写法

推荐逐步迁移到嵌套结构，例如：

```json
{
  "text": {
    "vocalized": "مُدَرِّسَةٌ",
    "plain": "مدرسة"
  },
  "meaning": {
    "zh": "女老师",
    "en": "female teacher"
  },
  "grammar": {
    "partOfSpeech": "noun",
    "gender": "feminine",
    "number": "singular",
    "morphology": "职业名词",
    "patternNote": "和阳性形式一起记忆"
  },
  "forms": {
    "plural": {
      "vocalized": "مُدَرِّسَاتٌ",
      "plain": "مدرسات"
    }
  },
  "example": {
    "text": {
      "vocalized": "هٰذِهِ مُدَرِّسَةٌ.",
      "plain": "هذه مدرسة."
    },
    "meaning": {
      "zh": "这是一位女老师。",
      "en": "This is a female teacher."
    },
    "audio": {
      "asset": "lesson_09/word/w1_example.mp3"
    }
  },
  "media": {
    "audio": "lesson_09/word/w1.mp3"
  }
}
```

## 已兼容页面与链路

直接改到结构化 accessor 的页面 / 服务：

- `LessonDetailPage`
- `ReviewPlanner`
- `ReviewService`
- `LessonPracticeService`

保持兼容、无需修改即可继续工作的页面：

- `CourseListPage`
- `HomePage`
- 其余仅依赖 `titleCn` / `titleAr` / 旧 flat 字段的页面

已具备同口径 accessor、但本轮未改渲染代码的页面：

- `VocabBookPage`

## 扩课录入规范建议

### 推荐统一口径

- 所有阿语正文都同时录入 `vocalized` 和 `plain`
- 所有释义优先录 `zh`，有英文时补 `en`
- 音频统一进入 `media.audio` 或 `example.audio.asset`
- 不要把词性、性数、构词说明混在释义文案里
- 单复数、阴阳性统一进 `forms`
- 例句统一进 `example.text` + `example.meaning`

### 字段命名建议

- 文本层：`text.vocalized` / `text.plain`
- 释义层：`meaning.zh` / `meaning.en`
- 语法层：`grammar.partOfSpeech` / `grammar.gender` / `grammar.number`
- 词形层：`forms.plural` / `forms.feminine` / `forms.masculine`
- 媒体层：`media.audio` / `media.image`

### 录入时尽量避免

- 同时维护两套互相不一致的 flat / nested 数据
- 直接把“中文说明 + 语法标签 + 词性”塞到一个字段里
- 只有带音符文本，没有 plain 文本
- 只有页面文案，没有内容级音频引用

## 验证结果

已补充并通过：

- `test/lesson_model_structure_test.dart`
- `test/content_loading_test.dart`
- `test/chinese_pages_smoke_test.dart`
- `test/english_pages_smoke_test.dart`
- `test/review_service_test.dart`
