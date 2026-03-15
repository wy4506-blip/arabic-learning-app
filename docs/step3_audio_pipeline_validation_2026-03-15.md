# Step 3 Audio Pipeline Validation

## Goal

确认真人音频、显式资源和 TTS 回退链路满足 Step 3 退出条件，并作为进入 D 线前的稳定输入。

## Included Scope

- manifest 命中时优先使用真人音频候选
- manifest 无匹配时回退到显式 asset 路径
- 所有 asset 候选都不可用时再回退 TTS
- flutter 资源声明收敛为统一的 assets/audio/ 入口

## Not Included

- 不包含首页推荐或 review/session 行为改动
- 不包含音频资源内容本身的人工抽检
- 不包含 D 线术语与 smoke 清理

## Validation Result

- targeted audio regression: 5 passed / 0 failed
- audio manifest static diagnostics: clean
- 当前结果满足 Step 3 退出条件

## Evidence

- human manifest candidate outranks explicit ai asset path
- explicit asset remains available as fallback when manifest misses
- TTS is used only after bundled asset fallbacks are exhausted
- asset declaration now covers the full audio tree without per-folder drift

## Exit Decision

Step 3 已验证，可进入 Step 4 文案与 smoke 收口。