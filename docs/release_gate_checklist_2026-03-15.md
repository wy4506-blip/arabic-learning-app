# Release Gate Checklist

## Goal

把“可以验收”进一步收敛成“可以进入发布准备”的最小门禁。

## Build Gate

- [ ] 工作区干净，无未提交临时改动
- [ ] 当前候选 tag 明确可回放
- [ ] 关键静态检查无阻断错误

## Core Flow Gate

- [ ] Home 主卡只回答当前最值得做的下一步
- [ ] 字母主学习路径稳定
- [ ] lesson 进入与课后回流稳定
- [ ] review-first / warm-up / continue learning 三类路径稳定

## Audio Gate

- [ ] 真人音频优先逻辑稳定
- [ ] explicit asset fallback 稳定
- [ ] TTS 只作为最后回退

## Copy Gate

- [ ] English smoke 页面无明显中文残留
- [ ] 中文说明页与反馈页术语一致
- [ ] 文案调整未改变主逻辑

## Regression Gate

- [ ] A/B 集成回归通过
- [ ] audio targeted regression 通过
- [ ] smoke and copy regression 通过

## Risk Gate

- [ ] 无已知 P0
- [ ] 无已知 P1 主路径阻塞
- [ ] 剩余问题均可归类为非阻断优化项

## Release Decision

- [ ] Ready for release prep
- [ ] Hold and reopen fixes

## Candidate Reference

- acceptance-candidate-2026-03-15
