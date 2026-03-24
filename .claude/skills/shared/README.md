# Shared Skills

本目录存放跨 workflow 通用的 skills，由安装器（`ralphlow-install.sh`）随任意 workflow 一起安装到目标项目的 `.claude/skills/shared/` 下。

## 定义

Shared skill 是满足以下条件的 skill：

- **跨 workflow 通用**：对 `builder`、`planner`、`writer` 三种 workflow 均有意义，不与任何单一领域绑定。
- **无领域特化**：不包含特定于软件工程、战略规划或内容创作的领域知识。
- **辅助性**：通常是工具性、流程性的辅助操作，而非核心工作流步骤。

## 命名规范

与 builder/planner/writer 保持一致，遵循 `<verb>-<domain>` 格式：

```
<动词>-<领域>
```

示例（假设未来添加）：
- `summarize-context` — 汇总当前上下文
- `format-report` — 格式化报告输出

不允许使用通用名称（如 `help`、`util`、`common`）。

## 判断标准

将 skill 放入 `shared/` 需同时满足：

1. 该 skill 在至少两种 workflow 中有实际使用需求。
2. 该 skill 的 prompt 内容不需要针对不同 workflow 做实质性修改。
3. 在 `builder/`、`planner/`、`writer/` 中分别维护一份会导致内容漂移或不一致。

如果 skill 只在一种 workflow 中使用，放入对应 workflow 目录，不放 shared/。

## v1 状态

当前版本（v1）`shared/` 目录为空，不包含任何实际 skill。

本目录作为结构占位存在，确保安装器可以正常复制 `shared/` 到目标项目。后续版本可根据实际复用需求逐步添加 shared skills。
