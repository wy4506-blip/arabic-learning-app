# Azure Audio Generator

这个脚本用于批量为当前 `arabic_learning_app` 生成阿语音频资源，并输出统一 manifest：

- 课程词汇：`word`
- 课程句型与对话：`sentence`
- 字母本体：`letter`
- 字母 13 音位：`pronunciation`
- 字母示例词：`word`

## 1. 先决条件

你需要先准备：

1. Azure Speech 资源
2. `AZURE_SPEECH_KEY`
3. `AZURE_SPEECH_REGION`

PowerShell 示例：

```powershell
$env:AZURE_SPEECH_KEY = "your_key"
$env:AZURE_SPEECH_REGION = "eastus"
```

## 2. 先看清单，不生成音频

```powershell
dart run tool/generate_azure_audio.dart --dry-run
```

这一步会生成：

- `assets/data/audio_manifest.json`

## 3. 正式生成音频

```powershell
dart run tool/generate_azure_audio.dart --skip-existing
```

如果你只想先生成课程音频：

```powershell
dart run tool/generate_azure_audio.dart --only-lessons
```

如果你只想先生成字母音频：

```powershell
dart run tool/generate_azure_audio.dart --only-alphabet
```

## 4. 可选参数

```powershell
dart run tool/generate_azure_audio.dart `
  --voice=ar-SA-HamedNeural `
  --format=audio-24khz-48kbitrate-mono-mp3 `
  --manifest=assets/data/audio_manifest.json
```

## 5. 当前落地策略

为了兼顾体积和首版维护成本，脚本当前策略是：

- lesson word：`normal + slow`
- lesson sentence：`normal + slow`
- alphabet letter：`normal`
- alphabet pronunciation：`normal`
- alphabet example word：`normal + slow`

## 6. 关于 m4a / aac

你的规范里优先推荐 `m4a / aac`，但 Azure Speech REST 官方输出格式里更稳妥、通用的是 `mp3 / opus / pcm`。  
所以这版脚本默认生成 `mp3`，这是你规范里允许的备选格式，先保证能稳定批量生成和接入。

如果你后面一定要 `m4a`，建议在生成完成后再用 `ffmpeg` 做统一转码，不要把 Azure 请求层和转码层混在一起。
