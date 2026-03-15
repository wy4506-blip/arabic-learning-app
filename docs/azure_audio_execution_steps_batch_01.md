# Azure 首轮试听执行步骤 Batch 01

本步骤用于执行首轮试听样本的 Azure 音频重生成，对应文档：

- [docs/audio_regeneration_pilot_plan_batch_01.md](docs/audio_regeneration_pilot_plan_batch_01.md)
- [docs/azure_audio_generation_commands_batch_01.md](docs/azure_audio_generation_commands_batch_01.md)

目标：

- 先只生成首轮试听的 13 个文件
- 先确认音色、语速、自然度和工程内播放效果
- 样本达标后，再扩展到第一优先级 30 条任务

## 1. 生成前准备

确认本机已经具备以下条件：

- 已配置 Azure Speech 资源
- 已拿到 `AZURE_SPEECH_KEY`
- 已拿到 `AZURE_SPEECH_REGION`
- 当前工程可正常运行 Dart 脚本

PowerShell 设置环境变量示例：

```powershell
$env:AZURE_SPEECH_KEY = "你的 Azure Speech Key"
$env:AZURE_SPEECH_REGION = "你的 Azure Region"
```

## 2. 先做文本与文件校对

在真正生成前，先用以下文档人工核对：

- [docs/audio_pilot_sample_batch_01.md](docs/audio_pilot_sample_batch_01.md)
- [docs/audio_regeneration_pilot_plan_batch_01.md](docs/audio_regeneration_pilot_plan_batch_01.md)
- [docs/azure_audio_generation_commands_batch_01.md](docs/azure_audio_generation_commands_batch_01.md)

重点确认：

- 阿拉伯语文本完全一致
- 文件名完全一致
- 路径完全一致
- slow / normal 区分正确

## 3. 先生成 slow 样本

建议先只生成 slow 版本，不要一开始就把 normal 全部做完。

建议首批 slow 文件：

- alphabet_soft_ay_slow.mp3
- grammar_harakat_fatha_ba_slow.mp3
- grammar_demonstrative_hatha_slow.mp3
- u1l3_word_book_class_example_slow.mp3
- u1l4_word_board_class_example_slow.mp3
- grammar_nominal_i_student_slow.mp3
- grammar_question_are_you_student_slow.mp3
- u4l4_word_coat_weather_example_slow.mp3

执行原则：

- 统一使用男性、沉稳、平缓、清楚自然的风格
- 统一先采用 slow 参数
- 句子以教学跟读友好为第一优先级

## 4. slow 首轮试听

生成后，不要立刻扩展，先试听这 8 条 slow 样本。

试听时重点判断：

- 是否仍有读错或漏读
- 是否存在文本与页面不一致
- 是否仍然偏快
- 是否仍有明显机器感
- 是否适合零基础用户跟读

建议使用文档：

- [docs/audio_pilot_review_scorecard_batch_01.md](docs/audio_pilot_review_scorecard_batch_01.md)

## 5. slow 达标后再生成 normal

若 slow 已经达到预期，再生成以下 normal 文件：

- u1l3_word_book_class_example_normal.mp3
- u1l4_word_board_class_example_normal.mp3
- grammar_nominal_i_student_normal.mp3
- grammar_question_are_you_student_normal.mp3
- u4l4_word_coat_weather_example_normal.mp3

说明：

- normal 不是为了更快，而是为了补充更自然的听感
- normal 仍然必须保持平稳，不允许恢复成旧版那种急促风格

## 6. 放入工程并验证播放

把 13 个文件按既定命名和路径放入工程后，进入 App 实测。

重点验证：

- 工程能否正确命中这些音频
- 点击播放时是否优先走正式资源而不是 TTS
- slow 与 normal 是否都能正常播放
- 页面展示文本与实际播报内容是否完全一致

## 7. 验收通过标准

只有同时满足以下条件，才允许进入 30 条任务批量重生成：

- 发音正确
- 文本与页面完全对应
- 节奏平缓，不急促
- 初学者容易跟读
- 工程内可正常播放
- 文件命名和路径完全匹配

## 8. 不通过时的处理方式

如果 slow 样本中出现以下任一问题，就先不要扩展：

- 读错
- 漏读
- 机器感仍然明显
- 阴性词、问句、长句被读糊
- 句尾收束过快
- 工程命中失败

应先回调参数并重试：

- 优先继续放慢 slow 的 rate
- 如声音太紧，可进一步下调 pitch
- 如问句太生硬，只微调语气，不要做夸张播报

## 9. 扩展到 30 条的建议顺序

试听通过后，按这个顺序扩展：

1. 先补完剩余第一优先级字母和短词 slow
2. 再补剩余课程例句 slow
3. 再补核心语法句子 slow + normal
4. 最后统一做工程回归试听