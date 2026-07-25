# ARCH

## Title

ralphlow — 系统架构

## Summary

ralphlow 是一个文件系统级的分发机制，将"Ralph loop"工作流打包为三种可选的 workflow bundle（`builder`、`planner`、`writer`），通过一个安装脚本复制到任意目标目录。系统无运行时进程，无网络服务，无数据库。一切状态均以文件形式存在——安装时产生的目录结构、skills、scripts 和配置文件。

## Architectural Goals

- **无运行时依赖**：安装后的 workflow 完全自包含，只需 POSIX shell 和 Claude Code / Ralph。
- **单一职责**：每种 workflow 对应一个内聚的文件集合，不同 workflow 之间无共享运行时状态。
- **幂等安装**：重复运行安装脚本不破坏已有状态。
- **可追溯执行**：builder workflow 的每次 Ralph loop 产物均按 loop_id 归档，支持事后审查。
- **约束前置**：review gate 在 Ralph 执行前介入，而非事后审查失败再报错。

## System Context

```
┌─────────────────────────────────────────────────────┐
│  ralphlow 仓库（source of truth）                    │
│                                                     │
│  .claude/skills/builder/   ← builder skill 模板     │
│  .claude/skills/planner/   ← planner skill 模板     │
│  .claude/skills/writer/    ← writer skill 模板      │
│  .claude/skills/shared/    ← 跨 workflow 共享 skills │
│  scripts/                  ← builder loop 脚本模板   │
│  ralphlow-install.sh       ← 安装入口               │
└──────────────────┬──────────────────────────────────┘
                   │ 安装（文件复制）
                   ▼
┌─────────────────────────────────────────────────────┐
│  目标项目目录（安装后自包含）                          │
│                                                     │
│  CLAUDE.md                 ← workflow 类型 + 命令规范 │
│  .ralph-workflow            ← workflow 类型锁定文件   │
│  .claude/skills/<workflow>/ ← 已安装 skills          │
│  .claude/skills/shared/     ← 已安装共享 skills       │
│  scripts/                   ← (builder-only) loop 脚本│
│  specs/                     ← 控制文档（操作者维护）   │
│  artifacts/                 ← (builder-only) 执行产物  │
└─────────────────────────────────────────────────────┘
                   │ 执行
                   ▼
         Ralph / Claude Code 代理
```

## Core Components

### 1. 安装器（ralphlow-install.sh）

接受 `<workflow>` 参数，执行文件复制和配置写入。是系统唯一的"部署"入口。

### 2. Workflow Bundle

三种相互独立的文件集合，各自包含：
- 固定的 skill 集合（Markdown prompt 文件）
- `CLAUDE.md` 模板（含强制阅读顺序和命令规范）

| Bundle    | 核心问题     | Skill 集合                                                                              |
|-----------|------------|----------------------------------------------------------------------------------------|
| `builder` | 如何构建？   | `get-spec`, `get-arch`, `get-tasks`, `get-current`, `review-spec`                      |
| `planner` | 做什么？     | `to-project`, `to-feasibility`, `to-actions`, `review-project`, `execution-readiness-check`, `decide-execution-mode` |
| `writer`  | 如何表达？   | `to-concept-spec`, `to-structure`, `write-draft`, `refine-logic`, `review-content`     |

### 3. Shared Skills

放置在 `shared/` 的 skills，随任意 workflow 一起安装。负责跨 workflow 的通用辅助逻辑（具体内容待定义）。

### 4. Builder Loop 脚本（scripts/，仅 builder）

六个 POSIX shell 脚本，协作构成"准备 → 执行 → 验证 → 复审"的有状态循环。详见 Key Flows。

### 5. Workflow 锁文件（.ralph-workflow）

安装时写入目标目录，记录已选择的 workflow 类型。防止二次安装时更换类型。

### 6. CLAUDE.md（目标目录）

安装器生成的配置文件，告知 Claude Code：当前 workflow 类型、控制文档读取顺序、可用 skill 命令列表。

## Responsibilities by Component

| 组件                     | 职责                                           | 不负责                                      |
|--------------------------|-----------------------------------------------|---------------------------------------------|
| `ralphlow-install.sh`    | 选择 bundle、复制文件、写锁文件、生成 CLAUDE.md | 执行 skills、管理 specs 内容                 |
| Workflow Bundle          | 定义可用 skills 的 prompt 内容                  | 驱动执行、存储状态                           |
| `sync_to_ralph.sh`       | 生成 prompt bundle，触发 Ralph，初始化 artifacts | 验证结果、写入 review                       |
| `apply_review_gate.sh`   | 前置拦截（读 REVIEW.json，输出约束或阻断）       | 执行代码、生成报告                           |
| `suggest_current_patch.sh` | 根据 REVIEW.json 生成切片缩减建议文件           | 自动修改 CURRENT.md                         |
| `collect_artifacts.sh`   | 收集执行后的 git 状态和 specs 快照              | 判断质量、决定是否通过                       |
| `verify.sh`              | 运行验证命令，输出结构化结果                    | 决定是否允许合并                             |
| `review.sh`              | 规则驱动复审，检查 scope drift 和 diff 体量     | 运行测试、访问网络                           |
| `.ralph-workflow`         | 持久化 workflow 类型选择                        | 存储任何运行时状态                           |
| `CLAUDE.md`（目标）       | 为 Claude Code 提供 workflow 上下文             | 业务逻辑                                    |

## Key Flows

### Flow 1：安装流程

```
operator
  └─ $ ralphlow-install.sh builder
        ├─ 检查 .ralph-workflow 是否已存在（存在则校验类型一致性）
        ├─ 复制 .claude/skills/builder/ → target/.claude/skills/builder/
        ├─ 复制 .claude/skills/shared/  → target/.claude/skills/shared/
        ├─ 复制 scripts/               → target/scripts/
        ├─ 写入 target/.ralph-workflow  = "builder"
        └─ 生成 target/CLAUDE.md（含 workflow 类型 + 读取顺序 + 命令列表）
```

### Flow 2：Builder Skill 循环（specs 准备）

```
operator / Claude Code
  └─ /get-spec   → 生成/更新 specs/SPEC.md
  └─ /get-arch   → 生成/更新 specs/ARCH.md
  └─ /get-tasks  → 生成/更新 specs/TASKS.md
  └─ /get-current → 生成/更新 specs/CURRENT.md（单一切片）
  └─ /review-spec → 生成 specs/REVIEW.json（含 decision 和 constraints）
```

### Flow 3：Builder Ralph Loop（执行循环）

```
[可选前置]
  $ scripts/suggest_current_patch.sh
    ├─ 读 specs/REVIEW.json
    └─ 若 should_shrink=true → 写 specs/CURRENT_PATCH.md

[准备]
  $ scripts/sync_to_ralph.sh [--run]
    ├─ 调用 apply_review_gate.sh
    │     ├─ 读 specs/REVIEW.json
    │     ├─ decision=reject → 退出，阻断执行
    │     └─ decision≠reject → 写 specs/REVIEW_CONSTRAINTS.md
    ├─ 生成 .ralph/input/current_prompt.md
    │     （包含控制文档内容 + REVIEW_CONSTRAINTS 注入）
    ├─ 初始化 artifacts/<loop_id>/input/（快照控制文档）
    ├─ 记录 git HEAD（执行前）
    └─ (--run) 调用 $RALPH_CMD

[执行]
  Ralph 代理读取 .ralph/input/current_prompt.md
  实现 specs/CURRENT.md 定义的切片

[收集]
  $ scripts/collect_artifacts.sh
    ├─ git status / diff → artifacts/<loop_id>/repo/
    └─ 快照最终 specs/ → artifacts/<loop_id>/final_specs/

[验证]
  $ scripts/verify.sh
    ├─ 读 scripts/verify.commands（或自动检测）
    ├─ 运行各命令，记录日志
    └─ 写 artifacts/<loop_id>/verify/verify_summary.json

[复审]
  $ scripts/review.sh
    ├─ 读 CURRENT.md 的 Allowed Paths
    ├─ 对比实际变更文件
    ├─ 检查 verify_summary.json 状态
    ├─ 检查 diff 体量
    └─ 写 artifacts/<loop_id>/review/review.json
          decision: approve | needs_attention | reject
```

### Flow 4：Planner / Writer 执行（无脚本）

```
operator / Claude Code
  └─ /to-project / /to-concept-spec ...
     直接调用 skills，输出控制文档
     无 scripts/ 介入，无 artifacts/ 目录
```

## Data Model / State Model（高层）

### ralphlow 仓库内（模板态）

```
.claude/skills/
  builder/    → 每个 skill 为一个 Markdown 文件（prompt）
  planner/
  writer/
  shared/
scripts/      → 六个 shell 脚本
ralphlow-install.sh
```

### 目标目录内（安装后运行态）

```
.ralph-workflow              → 纯文本，单行 workflow 类型
CLAUDE.md                   → Markdown，由安装器生成
specs/
  SPEC.md / ARCH.md / TASKS.md / RULES.md / CURRENT.md
  REVIEW.json               → review-spec skill 输出，含 decision + constraints
  REVIEW_CONSTRAINTS.md     → apply_review_gate.sh 输出，注入 prompt
  CURRENT_PATCH.md          → suggest_current_patch.sh 输出（可选）
.ralph/input/
  current_prompt.md         → sync_to_ralph.sh 输出，Ralph 的执行输入
artifacts/
  latest_loop_id            → 最新 loop_id（纯文本）
  latest -> <loop_id>/      → 符号链接
  <loop_id>/
    input/                  → 控制文档快照（执行前）
    final_specs/            → 控制文档快照（执行后）
    runtime/                → git HEAD、ralph 调用元数据
    repo/                   → git status、diff、changed-files
    verify/                 → 验证日志和 verify_summary.json
    review/                 → review.md 和 review.json
    execution_summary.md    → 人工填写的执行摘要模板
```

## Interfaces and Boundaries

### 边界 1：ralphlow → 目标目录（安装时）

- 接口：`ralphlow-install.sh <workflow>` shell 命令
- 输入：workflow 类型字符串
- 输出：文件系统变更（复制 + 写入）
- 约束：幂等，POSIX shell，无额外依赖

### 边界 2：Claude Code / 操作者 → Skills（运行时）

- 接口：`/<skill-name>` 斜杠命令（Claude Code skill 机制）
- 输入：对话上下文 + 控制文档文件
- 输出：写入 specs/ 下的 Markdown 文件
- 约束：skill 只是 prompt，执行由 Claude Code 完成

### 边界 3：Operator → Builder Loop 脚本（运行时）

- 接口：shell 命令调用各脚本
- 输入：specs/ 控制文档、`REVIEW.json`、`verify.commands`
- 输出：artifacts/<loop_id>/ 下的结构化产物
- 约束：需要 git、jq（apply_review_gate.sh 依赖）、bash

### 边界 4：Scripts → Ralph 代理（运行时）

- 接口：`sync_to_ralph.sh --run` 调用 `$RALPH_CMD`
- 输入：`.ralph/input/current_prompt.md`
- 输出：Ralph 对代码库的直接修改
- 约束：Ralph 不由 ralphlow 管理，`RALPH_CMD` 由环境变量配置

## Key Decisions

### D-1：文件复制而非符号链接或包引用

skills 和 scripts 在安装时**物理复制**到目标目录，而非引用 ralphlow 仓库。这使得目标目录完全自包含，与 ralphlow 版本脱耦，不依赖网络或包管理器。代价是安装后不能自动跟随 ralphlow 更新。

### D-2：Workflow 类型在安装时单次锁定

`.ralph-workflow` 文件在安装时写入且不可更改。这避免了同一目录混用多个 workflow 的混乱，但也意味着无迁移路径（v1 显式不支持）。

### D-3：Skills 以 Markdown prompt 文件实现

Skills 不是可执行程序，而是 Markdown 格式的 prompt，由 Claude Code 的 skill 机制加载执行。这将执行能力委托给 AI 代理，ralphlow 只管理"应该做什么"的定义。

### D-4：Review Gate 前置于 Ralph 执行

`apply_review_gate.sh` 在 `sync_to_ralph.sh` 内部、Ralph 执行**前**调用。这保证了 REVIEW.json 中的 reject 决定能在资源消耗（Ralph 运行时间和 token）之前生效。

### D-5：Artifacts 按 loop_id 隔离

每次 loop 在 `artifacts/<loop_id>/` 下存储独立产物，不覆盖历史。`latest` 符号链接指向最新 loop，同时保留全部历史以供回溯。

### D-6：Skill 命名约束（`<verb>-<domain>`）

强制 `<verb>-<domain>` 命名规范，禁止通用名称。这在文件层面就能区分 `review-spec`（builder）、`review-project`（planner）、`review-content`（writer），而非依赖目录结构推断。

## Trade-offs

| 决策                     | 收益                               | 代价                                       |
|--------------------------|------------------------------------|--------------------------------------------|
| 文件复制分发              | 自包含、无网络依赖、简单             | 安装后无法自动跟随 ralphlow 更新            |
| Workflow 单次锁定         | 防止混乱、简化安装逻辑              | 无迁移路径，需重新安装到新目录              |
| Skills 为 Markdown prompt | 无运行时依赖、易于人工阅读和修改     | 执行质量完全依赖 AI 代理能力               |
| POSIX shell 脚本          | 无额外依赖、跨平台                  | 复杂逻辑难以维护，错误提示不如现代工具友好  |
| 手动 artifacts 收集       | 操作者对流程有完全控制              | 需操作者在正确时机调用正确脚本              |

## Rejected Options

### 拒绝：package manager 分发（npm/pip/brew）

优点：易于版本管理和更新。拒绝原因：引入构建和发布流程，与"POSIX shell 无额外依赖"的目标冲突，且操作者环境不统一。

### 拒绝：符号链接安装

优点：目标目录始终引用最新 ralphlow 版本。拒绝原因：目标目录依赖 ralphlow 仓库路径，破坏了自包含原则，跨机器迁移会失效。

### 拒绝：多 workflow 同目录安装

优点：灵活性更高。拒绝原因：skill 命名冲突、CLAUDE.md 配置冲突、职责边界混乱，违背"一个目录一个用途"的原则。

### 拒绝：在 sync_to_ralph.sh 中内嵌 review gate 逻辑

优点：减少脚本数量。拒绝原因：`apply_review_gate.sh` 独立可测、可单独调用，嵌入会破坏单一职责并降低可调试性。

## Failure Modes and Recovery Notes

| 故障场景                           | 表现                                      | 恢复方式                                        |
|-----------------------------------|-------------------------------------------|-------------------------------------------------|
| 安装中断                           | 目标目录部分复制                           | 重新运行 `ralphlow-install.sh`（幂等）           |
| 以不同 workflow 类型重复安装        | 安装器报错或警告                           | 无法覆盖，需新建目录重新安装                     |
| `REVIEW.json` decision=reject      | `sync_to_ralph.sh` 退出，阻断 Ralph        | 修改 specs/CURRENT.md 缩小切片，重新运行 review-spec |
| verify.sh 找不到验证命令            | 输出 `no_commands`，不 fail                | 创建 `scripts/verify.commands` 声明验证命令      |
| review.sh decision=reject          | 脚本以 exit 1 退出                         | 查看 artifacts/<loop_id>/review/review.md，定位问题 |
| Ralph 修改了 Allowed Paths 外的文件 | review.sh 标记为 medium issue             | 操作者判断是否接受或回滚                         |
| artifacts/ 目录无 latest_loop_id   | collect/verify/review.sh 报错              | 传入 `--loop-id` 参数手动指定                   |

## Observability / Validation Considerations

- **每个 loop 产物完整归档**：`artifacts/<loop_id>/` 包含输入快照、执行元数据、git diff、验证结果和复审报告，具备完整追溯链。
- **机器可读输出**：`verify_summary.json` 和 `review.json` 使用结构化 JSON，支持脚本间传递和自动化判断。
- **review gate 是唯一的自动阻断点**：`apply_review_gate.sh` 是系统中唯一能在执行前自动阻断 Ralph 的机制，其他检查（verify、review）在执行后运行，作为质量反馈而非前置守门。
- **验证命令可配置**：`scripts/verify.commands` 允许各目标项目声明自己的验证方式，`verify.sh` 支持自动检测兜底，但明确配置优先。

## Future Extension Notes

- **upgrade 路径**（对应 OQ-2）：v1 不支持；未来可通过 `ralphlow-upgrade.sh` 拉取新版 skills 并选择性覆盖，需要版本标记机制。
- **planner/writer 的 Ralph loop 支持**：当前只有 builder 有完整的脚本 loop；planner 和 writer 未来可按需引入类似 loop，或设计更轻量的文档同步脚本。
- **shared/ skills 的具体内容**：当前 shared/ 结构存在但内容待定义，扩展时不影响安装机制。
- **FR-9 命令规范自动化**（对应 OQ-4）：当前 CLAUDE.md 中的命令列表由安装器静态写入；未来可读取 `.claude/skills/<workflow>/` 目录自动生成，避免手动维护漂移。
- **planner → builder/writer 自动化联动**：v1 仅文档约定；未来可通过 `EXECUTION_BRIEF` 文件格式标准化，使 builder/writer 能直接读取 planner 输出作为输入。
