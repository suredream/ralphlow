# TASKS

## Tasking Principles

- 每个任务只有一个主要目的，可独立验收。
- 按照"安装器先行 → builder bundle 完善 → planner bundle → writer bundle → shared"的顺序推进。
- Builder bundle 和 scripts/ 已基本存在，优先补全缺口；planner/writer 从零开始。
- 任务大小：可在一次 Ralph loop 内完成，变更文件数 ≤ 10，diff ≤ 400 行。
- 验收以可执行的检查为准，不接受"看起来正确"。

---

## Task List

### T1 - 实现安装器脚本 ralphlow-install.sh

- **Goal**：创建 `ralphlow-install.sh`，支持 `builder`、`planner`、`writer` 三种 workflow 的安装。
- **Why it exists**：这是系统的唯一部署入口，当前完全缺失。
- **Scope**：
  - 新建 `ralphlow-install.sh`（POSIX sh）
  - 支持参数：`<workflow>`，可选 `--target <dir>`（默认为当前目录，对应 OQ-1 的选择）
  - 根据 workflow 类型复制对应的 `.claude/skills/<workflow>/` 和 `.claude/skills/shared/`
  - builder 时额外复制 `scripts/`
  - 写入 `.ralph-workflow`（单行 workflow 类型）
  - 生成目标目录的 `CLAUDE.md`（从对应模板渲染）
  - 若 `.ralph-workflow` 已存在且类型不同，输出错误信息并退出（不覆盖）
  - 幂等：相同类型重复运行结果一致
- **Dependencies**：无（但 T2、T3、T4 的 bundle 内容需先存在才能完整验收）
- **Acceptance**：
  - `bash ralphlow-install.sh builder` 在空目录创建预期结构，`.ralph-workflow` 内容为 `builder`
  - `bash ralphlow-install.sh planner` 不创建 `scripts/`，`.ralph-workflow` 内容为 `planner`
  - 重复运行相同命令，目标目录状态不变（幂等）
  - 以不同 workflow 类型重复运行，脚本以非零状态退出并输出明确错误信息
  - `bash ralphlow-install.sh` 无参数时输出 usage 并退出
  - 脚本通过 `shellcheck` 检查（或等效静态检查）
- **Notes / Risks**：
  - 先决定 `--target` 参数方案（推荐支持，默认当前目录），以消除 OQ-1。
  - CLAUDE.md 模板暂可内联在脚本中，后续可提取为模板文件。

---

### T2 - 补全 builder workflow bundle 结构

- **Goal**：确认 `.claude/skills/builder/` 下的所有 skill 文件均符合规范，补全缺失项。
- **Why it exists**：当前 builder skills 存在但未按"每个 skill 一个目录含 SKILL.md"以外的格式审查，部分 skill 可能缺少单句用途注释（NFR-3）。
- **Scope**：
  - 检查 builder 下五个 skill（`get-spec`、`get-arch`、`get-tasks`、`get-current`、`review-spec`）是否均存在且有 `SKILL.md`
  - 每个 `SKILL.md` 顶部须有单句用途注释
  - 文件名严格为 `<verb>-<domain>` 格式，无通用名（`review`、`build`、`current`）
  - 新建 `CLAUDE.md` 模板供 builder 安装使用（含 workflow 类型、强制阅读顺序、命令列表）
- **Dependencies**：无（独立可验收）
- **Acceptance**：
  - `.claude/skills/builder/` 下恰好包含五个 skill 目录，各含 `SKILL.md`
  - 每个 `SKILL.md` 第一行或顶部 frontmatter 区域有单句用途注释
  - 无通用名称的 skill 文件或目录存在
  - builder 的 `CLAUDE.md` 模板文件存在，内含 workflow 类型标识和可用命令列表
- **Notes / Risks**：当前 `review-spec` skill 是否存在需核实（代码库搜索显示有该目录）。

---

### T3 - 创建 planner workflow bundle

- **Goal**：在 `.claude/skills/planner/` 下创建六个 planner skill 的 `SKILL.md`，以及 planner 的 `CLAUDE.md` 模板。
- **Why it exists**：planner bundle 当前完全不存在，T1 安装器安装 planner 时需要源文件。
- **Scope**：
  - 新建目录 `.claude/skills/planner/`
  - 六个 skill 目录各含 `SKILL.md`：`to-project`、`to-feasibility`、`to-actions`、`review-project`、`execution-readiness-check`、`decide-execution-mode`
  - 每个 `SKILL.md` 包含：单句用途注释 + 输入文档说明 + 输出格式说明 + 基本 prompt 内容
  - 新建 planner 的 `CLAUDE.md` 模板（含 workflow 类型、强制阅读顺序、命令列表）
- **Dependencies**：无（独立可创建，T1 安装器依赖此 bundle 完整才能端到端验收 planner）
- **Acceptance**：
  - `.claude/skills/planner/` 下恰好六个 skill 目录，各含 `SKILL.md`
  - 所有 skill 文件名符合 `<verb>-<domain>` 规范
  - planner 的 `CLAUDE.md` 模板存在，包含可用命令列表
  - 人工阅读各 `SKILL.md`，内容描述与 SPEC 中的 planner 职责一致
- **Notes / Risks**：planner skill 的具体 prompt 内容质量影响 AI 代理行为，应优先保证结构和职责清晰，细节可迭代。

---

### T4 - 创建 writer workflow bundle

- **Goal**：在 `.claude/skills/writer/` 下创建五个 writer skill 的 `SKILL.md`，以及 writer 的 `CLAUDE.md` 模板。
- **Why it exists**：writer bundle 当前完全不存在，T1 安装器安装 writer 时需要源文件。
- **Scope**：
  - 新建目录 `.claude/skills/writer/`
  - 五个 skill 目录各含 `SKILL.md`：`to-concept-spec`、`to-structure`、`write-draft`、`refine-logic`、`review-content`
  - 每个 `SKILL.md` 包含：单句用途注释 + 输入文档说明 + 输出格式说明 + 基本 prompt 内容
  - 新建 writer 的 `CLAUDE.md` 模板
- **Dependencies**：无（独立可创建）
- **Acceptance**：
  - `.claude/skills/writer/` 下恰好五个 skill 目录，各含 `SKILL.md`
  - 所有 skill 文件名符合 `<verb>-<domain>` 规范
  - writer 的 `CLAUDE.md` 模板存在，包含可用命令列表
  - 人工阅读各 `SKILL.md`，内容描述与 SPEC 中的 writer 职责一致
- **Notes / Risks**：与 T3 并行执行无冲突。

---

### T5 - 创建 shared skills 目录结构

- **Goal**：建立 `.claude/skills/shared/` 目录，明确其内容约定，即使 v1 内容为空也需要目录存在。
- **Why it exists**：安装器复制 shared/ 时需要源目录存在；shared/ 的内容约定需要文档化，否则后续添加时无基准。
- **Scope**：
  - 创建 `.claude/skills/shared/` 目录（含 `.gitkeep` 或说明文件）
  - 新建 `.claude/skills/shared/README.md`，说明 shared skills 的适用场景和命名规范
  - v1 不要求 shared/ 下有实际 skill，只需结构存在
- **Dependencies**：无
- **Acceptance**：
  - `.claude/skills/shared/` 目录存在且可被 `ralphlow-install.sh` 正常复制
  - 目录内有说明文件，描述 shared skills 的用途约定
- **Notes / Risks**：轻量任务，主要为 T1 安装器提供可用的源目录。

---

### T6 - 端到端安装验收（builder）

- **Goal**：在一个真实的空临时目录中运行 `ralphlow-install.sh builder`，验证安装结果与 SPEC Acceptance Criteria 完全一致。
- **Why it exists**：T1-T5 分别验收各组件，但端到端集成可能暴露脚本路径假设、权限、幂等性等问题。
- **Scope**：
  - 创建临时目录，运行安装脚本
  - 逐条核对 SPEC 中 builder 的 Acceptance Criteria
  - 记录实际结果（通过/失败/偏差）
  - 如有问题，修复 T1 或相关 bundle，不在此任务内扩大改动范围
- **Dependencies**：T1、T2、T5
- **Acceptance**：
  - SPEC 中 builder 相关的所有验收条件均通过
  - 安装脚本以 exit 0 结束
  - 生成的 `CLAUDE.md` 包含 workflow 类型标识和命令列表
  - 第二次运行相同命令，目录内容不变（幂等验证）
  - 以 `planner` 类型重复运行，脚本以非零状态退出
- **Notes / Risks**：此任务是 builder workflow 可用的最终验证门，应在 T1、T2、T5 完成后执行。

---

### T7 - 端到端安装验收（planner、writer）

- **Goal**：验证 `ralphlow-install.sh planner` 和 `ralphlow-install.sh writer` 的安装结果正确，且不包含 builder 或 scripts/ 内容。
- **Why it exists**：planner/writer 的 bundle 隔离是核心约束，需显式验证。
- **Scope**：
  - 各自在独立临时目录运行安装脚本
  - 验证 skills 隔离（无对方 workflow 的 skill）
  - 验证无 `scripts/` 目录
  - 验证 `.ralph-workflow` 内容正确
  - 验证 `CLAUDE.md` 内容对应正确的 workflow
- **Dependencies**：T1、T3、T4、T5
- **Acceptance**：
  - planner 安装结果不含 builder 或 writer 的 skill 目录
  - writer 安装结果不含 builder 或 planner 的 skill 目录
  - 两者均无 `scripts/` 目录
  - SPEC 中 planner/writer 相关的 Acceptance Criteria 均通过
- **Notes / Risks**：可与 T6 并行执行（目录独立）。

---

### T8 - 更新 ralphlow 自身的 CLAUDE.md 以反映安装后状态

- **Goal**：更新 ralphlow 仓库自身的 `CLAUDE.md`，补充安装器用法说明和 ralphlow 作为 builder-workflow 项目的操作指引。
- **Why it exists**：ralphlow 本身是 builder-workflow 的第一个消费者，其 `CLAUDE.md` 应体现完整的 builder 操作流程（含安装器的存在和 scripts/ 的用法），而非仅列出 CLAUDE.md 的强制阅读顺序。
- **Scope**：
  - 在现有 `CLAUDE.md` 中补充：安装器的简短说明、ralphlow 自身的 workflow 类型声明（builder）、可用 skill 命令列表
  - 不重写已有内容，只补充缺失部分
- **Dependencies**：T2（builder bundle 和模板定稿后才能确定命令列表）
- **Acceptance**：
  - `CLAUDE.md` 明确标注 ralphlow 使用的 workflow 类型为 `builder`
  - `CLAUDE.md` 列出 builder 的可用 skill 命令（与 T2 中模板一致）
  - `CLAUDE.md` 包含 `ralphlow-install.sh` 的简短说明
  - 现有强制阅读顺序等内容保持不变
- **Notes / Risks**：轻量变更，风险低。

---

## 任务顺序建议

```
T5 (shared 目录)
T2 (builder bundle 补全)    ─┐
T3 (planner bundle)          ├─ 并行
T4 (writer bundle)          ─┘
        ↓
T1 (安装器脚本)
        ↓
T6 (builder 端到端验收)    ─┐  并行
T7 (planner/writer 验收)  ─┘
        ↓
T8 (ralphlow CLAUDE.md 更新)
```
