# Human Audio Import Pipeline

这个文档对应当前已经在执行的 Excel 录制任务流程，目标是：

1. 不改老师交付命名。
2. 不改老师交付目录结构。
3. 开发侧拿到材料后可以直接导入。
4. 允许老师交付 `m4a / wav / mp3 / aac`。
5. App 运行时保留 `AI + human` 两种变体，继续支持配音偏好切换。

## 核心原则

老师交付目录继续遵循 Excel 中约定的 `assets/audio/...` 结构。

例如：

```text
阶段01_字母组1_ا_ب_ت_ث/
  02_老师交付音频/
    assets/audio/alphabet/letter/alpha_l_001_normal.m4a
    assets/audio/alphabet/pronunciation/alpha_p_001_normal.m4a
```

导入脚本会把它们转换成工程可直接使用的 human 变体：

```text
assets/audio/alphabet/letter/alpha_l_001_normal__human__20260314-stage01.mp3
assets/audio/alphabet/pronunciation/alpha_p_001_normal__human__20260314-stage01.mp3
```

这样做的好处：

1. 老师的命名合同不变。
2. AI 文件不被覆盖。
3. manifest 可以同时保留 `ai` 和 `human` 两条记录。
4. App 内的配音偏好可以继续工作。

## 推荐工作流

### 1. 老师按阶段交付

保持 Excel 约定的目录结构，不需要让老师改名。

### 2. 导入前先做 dry run

```powershell
dart run tool/import_human_audio.dart `
  --delivery-root="C:/Users/yujingtao/Desktop/app音频文件管理/正式/配音录制任务_分阶段交付/阶段01_字母组1_ا_ب_ت_ث/02_老师交付音频" `
  --revision=20260314-stage01 `
  --dry-run
```

### 3. 正式导入

```powershell
dart run tool/import_human_audio.dart `
  --delivery-root="C:/Users/yujingtao/Desktop/app音频文件管理/正式/配音录制任务_分阶段交付/阶段01_字母组1_ا_ب_ت_ث/02_老师交付音频" `
  --revision=20260314-stage01
```

### 4. 查看报告

默认会写出：

```text
build/audio/human_import_report.json
```

里面会列出：

1. 哪些文件成功导入。
2. 哪些文件没有匹配到 manifest。
3. 哪些文件因为已经导入而被跳过。

## ffmpeg 说明

如果老师交付的是 `m4a / wav / aac`，脚本会自动调用 `ffmpeg` 转成 mp3。

建议先确认本机可执行：

```powershell
ffmpeg -version
```

如果命令不在 PATH 里，可以显式传入：

```powershell
dart run tool/import_human_audio.dart `
  --delivery-root="..." `
  --revision=20260314-stage01 `
  --ffmpeg="C:/ffmpeg/bin/ffmpeg.exe"
```

## 包体积建议

当前脚本是“共存模式”：

1. AI 文件保留。
2. human 文件作为新变体导入。

这最适合测试和阶段性上线，但会增加包体积。

建议发布策略：

1. 只导入已经准备上线的阶段，不一次性导入全部 800 条 human。
2. 每次导入后先走内部验收。
3. 等后续需要进一步压包体，再升级到“下载 human 语音包”的方案。

## manifest 元数据

导入后每条 human 记录会补充这些字段：

1. `logicalId`
2. `voiceType`
3. `source`
4. `sourceFileName`
5. `sourceFormat`
6. `revision`
7. `importedAt`

这些字段的目标是让后续增删改、回滚、核对来源都能自动化，而不是靠人工记忆。