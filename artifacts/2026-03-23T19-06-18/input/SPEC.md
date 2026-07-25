# SPEC

## Title

ralphlow — Ralph Loop Workflow 安装框架

## Goal

提供一个可安装的框架，将结构化的、由规格驱动的 AI 工作流（"Ralph loop"）引入任意目标项目目录。操作者在安装时选择一种 workflow 类型——`builder`、`planner` 或 `writer`——框架随即安装该领域对应的 skills 和 scripts。

## Problem Statement

Ralph loop 工作流（spec → arch → tasks → current → execution）目前锁定在单一仓库中。没有标准方式将其应用于不同类型的项目——软件工程、战略规划或内容创作——而这些项目各有不同的控制文档结构和技能集合。

缺少可移植、可安装的系统导致：
- 操作者在仓库之间手动复制 skills。
- Skill 命名不一致，领域职责边界模糊。
- `builder`、`planner`、`writer` 各自的职责范围不清晰。

## Intended Users / Operators

- **操作者**（主要）：希望在新项目目录中快速引入 AI 辅助工作流的工程师或创作者。
- **AI 代理**（次要）：在已安装 workflow 中运行的 Ralph 或 Claude Code，执行对应 skill 集合下的任务。

> ralphlow 本身是一个 `builder`-workflow 项目——它既是产品，也是自身的第一个消费者。

## User or System Flow

### 安装流程

1. 操作者在目标目录中执行 `ralphlow-install.sh <workflow>`（例如 `ralphlow-install.sh builder`）。
2. 安装器将对应的 `.claude/skills/<workflow>/` 目录和共享 skills 复制到目标项目。
3. 安装器生成或更新项目的 `CLAUDE.md`，注明已安装的 workflow 类型。
4. Workflow 类型被记录，安装后不可更改。

### 执行流程（各 workflow）

安装完成后，操作者（或 AI 代理）使用已安装的 skills 运行循环：

- **builder**：`get-spec` → `get-arch` → `get-tasks` → `get-current` → `review-spec` → 实现
- **planner**：`to-project` → `to-feasibility` → `to-actions` → `review-project` → `decide-execution-mode`
- **writer**：`to-concept-spec` → `to-structure` → `write-draft` → `refine-logic` → `review-content`

### Builder Ralph Loop 脚本流程

`builder` workflow 通过一组 shell 脚本将 specs 文件与 Ralph 代理串联成可重复执行的循环：

```
[准备阶段]
  scripts/apply_review_gate.sh     ← 读取 specs/REVIEW.json，若 decision=reject 则阻断执行；
                                      否则生成 specs/REVIEW_CONSTRAINTS.md 注入约束
  scripts/suggest_current_patch.sh ← 若 REVIEW.json 建议缩小切片，生成 specs/CURRENT_PATCH.md

[执行阶段]
  scripts/sync_to_ralph.sh         ← 读取 specs/ 下所有控制文档，调用 apply_review_gate.sh，
                                      生成 .ralph/input/current_prompt.md，初始化 artifacts/<loop_id>/，
                                      可选直接调用 ralph 执行
  [Ralph 代理运行，实现 CURRENT.md 定义的切片]

[验证阶段]
  scripts/collect_artifacts.sh     ← 收集执行后的 git 状态、diff、变更文件列表，
                                      快照最终 specs/ 文件到 artifacts/<loop_id>/
  scripts/verify.sh                ← 运行验证命令（来自 scripts/verify.commands 或自动检测），
                                      输出 artifacts/<loop_id>/verify/verify_summary.json

[复审阶段]
  scripts/review.sh                ← 对比 CURRENT.md 的 Allowed Paths 与实际变更文件，
                                      检查 scope drift、diff 体量、验证状态，
                                      输出 artifacts/<loop_id>/review/review.json（decision: approve / needs_attention / reject）
```

每次 loop 的产物均保存在 `artifacts/<loop_id>/` 下，包含输入快照、执行日志、验证报告和复审报告，以供追溯。

### Workflow 职责对照

| Workflow  | 核心问题     | 输入文档                                     | 输出                                  | 项目范围       |
|-----------|------------|----------------------------------------------|---------------------------------------|--------------|
| `planner` | 做什么？     | PROJECT, FEASIBILITY, BLOCKERS, ACTIONS      | EXECUTION_DECISION, EXECUTION_BRIEF   | 多个子项目     |
| `builder` | 如何构建？   | SPEC, ARCH, TASKS, CURRENT                   | 代码 / API / 基础设施                  | 单一项目       |
| `writer`  | 如何表达？   | CONCEPT, STRUCTURE, DRAFT, CURRENT           | 文章 / 帖子 / 文案                     | 多个子项目     |

`planner` 是 `builder` 和 `writer` 的上游。`builder` 每次限定于单一项目；`planner` 和 `writer` 可在一个已安装目录下管理多个子项目。

## In Scope

- 一个接受 workflow 类型参数的安装脚本（`ralphlow-install.sh`）。
- 三种独立的 workflow 包：`builder`、`planner`、`writer`。
- 对所有 workflow 通用的 `shared/` skills 目录。
- 每种 workflow 拥有固定、有文档记录的 skill 集合，命名遵循 `<verb>-<domain>` 规范。
- 安装锁定 workflow 类型（安装后不可更改）。
- 安装后的结构完全自包含于 `.claude/skills/` 下。
- `builder` workflow 还会安装用于 Ralph 执行循环的 `scripts/` 目录，包含六个脚本：`sync_to_ralph.sh`、`apply_review_gate.sh`、`suggest_current_patch.sh`、`collect_artifacts.sh`、`verify.sh`、`review.sh`，共同构成准备 → 执行 → 验证 → 复审的完整 loop。
- 每个已安装的 workflow 生成一份 `CLAUDE.md`，包含该 workflow 专属的强制阅读顺序和操作规则，以及可用 skill 命令列表。

## Out of Scope

- 在单一目标目录中动态安装多种 workflow。
- 用于管理 workflow 的 UI 或 Web 界面。
- 自动执行或定时调度 skills。
- 迁移工具（安装后更改 workflow 类型）。
- 将 ralphlow 打包为 package 或二进制文件进行分发。

## Functional Requirements

1. **FR-1 安装器**：`ralphlow-install.sh <workflow>` 将正确的 skill 集合复制到 `<target>/.claude/skills/`。
2. **FR-2 Workflow 锁定**：安装完成后，workflow 类型记录在目标目录中，不可更改。
3. **FR-3 Skill 命名规范**：所有 skill 遵循 `<verb>-<domain>` 命名模式（如 `review-project`、`review-spec`、`review-content`）。不允许使用通用名称（`review`、`build`、`current`）。
4. **FR-4 共享 skills**：`ralphlow` 内存在 `shared/` 目录，随选定 workflow 一起安装。
5. **FR-5 Builder workflow**：提供 skills：`get-spec`、`get-arch`、`get-tasks`、`get-current`、`review-spec`。同时安装 `scripts/` 目录，包含构成完整 Ralph loop 的六个脚本：
   - `sync_to_ralph.sh`：准备 Ralph 执行所需的 prompt bundle，初始化 artifacts 目录，可选触发 Ralph。
   - `apply_review_gate.sh`：执行前读取 `specs/REVIEW.json`，若 `decision=reject` 则阻断执行，否则生成约束文件 `specs/REVIEW_CONSTRAINTS.md`。
   - `suggest_current_patch.sh`：根据 `REVIEW.json` 中的建议生成 `specs/CURRENT_PATCH.md`，辅助操作者缩小切片。
   - `collect_artifacts.sh`：收集执行后的 git 状态、diff 和 specs 快照到 `artifacts/<loop_id>/`。
   - `verify.sh`：运行项目验证命令，输出机器可读的 `verify_summary.json`。
   - `review.sh`：规则驱动的复审，比对实际变更与 `CURRENT.md` 的 Allowed Paths，输出 `review.json`（decision: approve / needs_attention / reject）。
6. **FR-6 Planner workflow**：提供 skills：`to-project`、`to-feasibility`、`to-actions`、`review-project`、`execution-readiness-check`、`decide-execution-mode`。支持在已安装目录下管理多个子项目。
7. **FR-7 Writer workflow**：提供 skills：`to-concept-spec`、`to-structure`、`write-draft`、`refine-logic`、`review-content`。支持在已安装目录下管理多个子项目。
8. **FR-8 CLAUDE.md 生成**：安装器在目标目录中写入或更新 `CLAUDE.md`，包含已安装的 workflow 类型、控制文档列表以及对应的强制阅读顺序。
9. **FR-9 命令规范**：每个 workflow 必须在其 `CLAUDE.md` 中声明可用的 skill 命令列表，供操作者快速查阅，无需进入 `.claude/skills/` 目录查找。

## Non-Functional Requirements

- **NFR-1 幂等性**：对同一目录以相同 workflow 类型运行两次安装器，不得破坏已安装的状态。
- **NFR-2 可移植性**：安装器必须在任意 POSIX shell 环境中运行，无需额外依赖。
- **NFR-3 可读性**：每个已安装的 skill 顶部必须有一行清晰的单句用途注释。

## Acceptance Criteria

- [ ] 在空目录中运行 `ralphlow-install.sh builder`，创建 `.claude/skills/builder/`、`.claude/skills/shared/` 和 `scripts/`，并写入标识 workflow 为 `builder` 的 `CLAUDE.md`；`scripts/` 目录包含且仅包含六个脚本：`sync_to_ralph.sh`、`apply_review_gate.sh`、`suggest_current_patch.sh`、`collect_artifacts.sh`、`verify.sh`、`review.sh`。
- [ ] 运行 `ralphlow-install.sh planner` 仅安装 planner skills（不含 builder 或 writer skills），不创建 `scripts/` 目录。
- [ ] 运行 `ralphlow-install.sh writer` 仅安装 writer skills（不含 builder 或 planner skills），不创建 `scripts/` 目录。
- [ ] 所有已安装的 skill 文件名遵循 `<verb>-<domain>` 模式，不存在通用名称（`review`、`build`、`current`）。
- [ ] 使用相同命令第二次运行安装器，结果与第一次相同（幂等）。
- [ ] 已安装的 `CLAUDE.md` 包含 workflow 类型、对应的强制阅读顺序及可用 skill 命令列表。
- [ ] 一种 workflow 的 skills 不会出现在另一种 workflow 的安装结果中。
- [ ] Workflow 类型被持久化，以不同类型再次安装时失败或给出明确警告。

## Assumptions

- 每个目标目录是单一用途项目；每个目录一种 workflow 类型已足够。
- 操作者具有目标目录的 shell 访问权限。
- `ralphlow` 本身是一个 `builder`-workflow 项目——它使用自身安装的 skills 和 scripts。
- `planner` → `builder`/`writer` 的上游关系在 v1 中仅作文档记录，不由自动化强制执行。
- `planner` 和 `writer` 目录可包含各子项目的命名子目录；子项目的具体结构由各 workflow 自行定义，而非由 ralphlow 统一规定。
- `planner` 和 `writer` 的活跃切片文档沿用 `CURRENT.md` 命名（与 `builder` 一致），除非各 workflow 的 skill 文档另有说明。

## Open Questions

- **OQ-1**：`ralphlow-install.sh` 应在目标目录内运行，还是接受目标路径作为参数？
- **OQ-2**：如果 ralphlow skills 在安装后更新，版本管理应如何处理——是否需要升级路径？
- **OQ-3**：`shared/` skills 中是否应包含类似 `sync_to_ralph.sh` 的脚本，还是仅限 builder？
- **OQ-4**：FR-9 命令规范应自动生成到 `CLAUDE.md`，还是由操作者手动维护？
