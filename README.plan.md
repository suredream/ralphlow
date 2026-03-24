# README.plan — Plan-Planner Workflow

## 1. 系统概述

**plan-planner** 是一种 AI 辅助的项目规划工作流模式，安装后将目标目录配置为纯规划用途。

它的核心职责是：

- 分析项目可行性
- 识别并持续追踪阻碍（blockers）
- 定义可执行的下一步行动
- 支持 go / no-go / pivot 决策

**它不做的事：**

- 不生成代码
- 不写实现方案
- 不替代 builder 或 writer workflow

**上下游关系：**

```
init_idea.md
     ↓
plan-planner workflow   ← 本文档描述的系统
     ↓
EXECUTION_DECISION.md   ← 决定是否进入执行
     ↓
builder / writer workflow（由 ralphlow 安装的另一 workflow）
```

一个项目经过 plan-planner 完整流程后，输出一份带约束的执行决策，再由执行 workflow 接手。

---

## 2. 目录结构规范

```
<project-root>/
  CLAUDE.md             ← plan-planner 模式配置（由 ralphlow 安装）
  init_idea.md          ← 原始想法输入（用户自己维护）
  specs/
    RULES.md            ← workflow 级操作规则，所有项目共享
    PROJECTS.md         ← 活跃项目索引
    <project-name>/     ← 每个项目一个子目录
      PROJECT.md            项目定义（目标、背景、成功标准）
      FEASIBILITY.md        可行性评估
      BLOCKERS.md           阻碍列表
      ACTIONS.md            可执行行动列表
      CURRENT_FOCUS.md      当前迭代焦点
      REVIEW.json           综合状态评审
      EXECUTION_READINESS.md  执行就绪判断
      EXECUTION_DECISION.md   最终执行决策（带约束）
    archive/            ← 归档目录
      <project-name>/   ← 已归档项目，完整保留可查阅
```

### 文件职责说明

| 文件 | 层级 | 职责 | 更新频率 |
|------|------|------|----------|
| `RULES.md` | workflow | 操作约束和反模式规则 | 极少改动 |
| `PROJECTS.md` | workflow | 所有项目的状态索引 | 创建/归档项目时 |
| `PROJECT.md` | 项目 | 项目定义、目标、成功标准 | 初始化时，范围变化时 |
| `FEASIBILITY.md` | 项目 | 可行性评估（多维度） | 每次重大信息更新后 |
| `BLOCKERS.md` | 项目 | 阻碍列表（类型/状态/影响） | 每个 loop |
| `ACTIONS.md` | 项目 | 下一步行动（与 blocker 关联） | 每个 loop |
| `CURRENT_FOCUS.md` | 项目 | 当前 loop 的单一目标 | 每个 loop 开始时 |
| `REVIEW.json` | 项目 | approve/needs_attention/reject 决策 | `/plan-review` 后 |
| `EXECUTION_READINESS.md` | 项目 | 6 维度执行就绪评估 | `/plan-ready` 后 |
| `EXECUTION_DECISION.md` | 项目 | 最终执行模式决定 + 约束 | `/plan-dp` 后 |

---

## 3. Skill 说明

### 完整流程

```
/plan-spec → /plan-eval → /plan-actions → /plan-focus
                                ↓
                          (迭代多次)
                                ↓
                        /plan-review → /plan-ready → /plan-dp
```

### Skill 详情

#### `/plan-spec [project]`

**用途**：将 `init_idea.md` 转化为结构化的项目定义。

**输入**：`init_idea.md`

**输出**：`specs/<project>/PROJECT.md`

**包含**：标题、目标（一句话）、背景、问题定义、目标用户、成功标准、当前阶段、备注

**注意**：如果 `specs/<project>/` 目录不存在，会自动创建。

---

#### `/plan-eval [project]`

**用途**：多维度分析项目可行性，得出探索/验证/不可行的建议。

**输入**：`specs/<project>/PROJECT.md`

**输出**：`specs/<project>/FEASIBILITY.md`

**评估维度**：产品可行性、技术可行性、资源可行性、分发/GTM 可行性、主要未知项、关键风险

---

#### `/plan-actions [project]`

**用途**：将可行性分析转化为具体的阻碍和行动。

**输入**：`specs/<project>/FEASIBILITY.md`

**输出**：
- `specs/<project>/BLOCKERS.md`（每条含类型/描述/影响/状态）
- `specs/<project>/ACTIONS.md`（每条含目标/预期结果/关联 blocker）

**规则**：每个行动必须能降低不确定性，不允许模糊行动（如"调研一下"）。

---

#### `/plan-focus [project]`

**用途**：为下一个 loop 定义单一清晰的焦点。

**输入**：`BLOCKERS.md`、`ACTIONS.md`

**输出**：`specs/<project>/CURRENT_FOCUS.md`

**结构**：目标（单一问题）、在范围内（3-5 项）、不在范围内（明确排除）、预期输出

---

#### `/plan-review [project]`

**用途**：综合评估项目当前状态，输出结构化审查结果。

**输入**：`specs/<project>/` 下所有文件

**输出**：`specs/<project>/REVIEW.json`

**决策**：`approve`（方向清晰可执行）/ `needs_attention`（有待改进）/ `reject`（无可用方向）

---

#### `/plan-ready [project]`

**用途**：判断项目是否已准备好进入执行 workflow。

**输入**：`specs/<project>/` 下所有文件

**输出**：`specs/<project>/EXECUTION_READINESS.md`

**6 个评估维度**（每项 green/yellow/red）：
1. 问题清晰度
2. 范围稳定性
3. 依赖就绪度
4. 可行性信心
5. Blocker 严重程度
6. 现在执行的价值

**决策**：`not_ready` / `ready_for_poc` / `ready_for_build`

---

#### `/plan-dp [project]`

**用途**：将就绪判断转化为带严格约束的最终执行决策。

**输入**：`specs/<project>/EXECUTION_READINESS.md` 及其他项目文件

**输出**：`specs/<project>/EXECUTION_DECISION.md`

**必须包含**：最终模式（not_ready/poc/build）、执行范围（In/Out）、约束、成功标准、失败标准、第一个 slice 指导

---

## 4. 多项目工作流程示例

### 场景 A：新建项目

```
# 1. 在 specs/PROJECTS.md 中添加项目记录
# 2. 开始对话，声明项目
用户："我要开始规划 alpha 项目"

# 3. 初始化项目定义（需要已有 init_idea.md）
/plan-spec alpha

# 4. 评估可行性
/plan-eval alpha

# 5. 定义阻碍和行动
/plan-actions alpha

# 6. 设置当前 loop 焦点
/plan-focus alpha

# 7. （多次循环后）综合评审
/plan-review alpha

# 8. 执行就绪判断
/plan-ready alpha

# 9. 输出最终执行决策
/plan-dp alpha
```

### 场景 B：切换到另一个项目

每次对话只处理一个项目。切换项目只需要在新对话中声明：

```
用户："今天处理 beta 项目，继续评估可行性"
/plan-eval
# skill 从对话上下文读取 "beta"，操作 specs/beta/
```

### 场景 C：多个 agent 并行处理不同项目

Agent 1 对话：
```
用户："处理 alpha 项目的 blocker 分析"
/plan-actions
# 操作 specs/alpha/BLOCKERS.md 和 specs/alpha/ACTIONS.md
```

Agent 2 对话（同时进行）：
```
用户："对 beta 项目做可行性评估"
/plan-eval
# 操作 specs/beta/FEASIBILITY.md
```

两个 agent 操作不同子目录，无需协调，天然隔离。

### 场景 D：显式传参（临时查看非声明项目）

```
# 当前对话处理 alpha 项目，但想快速查看 gamma 的状态
/plan-review gamma
# 直接操作 specs/gamma/，不影响 alpha 的对话上下文
```

---

## 5. Archive 机制

### 何时归档

以下情况应将项目归档：

| 情况 | Archive Reason |
|------|----------------|
| 项目完成交付，Success Criteria 达成 | `completed` |
| 明确放弃，no-go 决策已做 | `abandoned` |
| 超过 30 天无活动且无恢复计划 | `inactive` |
| 被合并入另一项目 | `merged` |

**不应归档**：暂时等待外部依赖的项目（应保持 active，在 `CURRENT_FOCUS.md` 注明原因）。

### 如何归档（两步操作）

```bash
# 步骤 1：物理移动目录
mv specs/alpha/ specs/archive/alpha/

# 步骤 2：更新 PROJECTS.md 索引
# 将 alpha 从 Active 表格移到 Archive 表格，填写归档日期和原因
```

### 查阅已归档项目

归档后的文件完整保留，可随时查阅：

```
用户："查看 alpha 项目当时的执行决策"
# 直接读取 specs/archive/alpha/EXECUTION_DECISION.md
```

注意：默认的 Reading Order 不包含 `specs/archive/`，AI 不会主动读取已归档内容。

### archive 目录结构

```
specs/archive/
  alpha/          ← 已归档，内容完整
    PROJECT.md
    FEASIBILITY.md
    ...
    EXECUTION_DECISION.md
  gamma/          ← 已归档
    ...
```

---

## 安装

通过 ralphlow 安装 plan-planner workflow：

```bash
./install.sh <target-directory> plan
```

安装后，目标目录获得：
- `CLAUDE.md`（plan-planner 模式配置）
- `.claude/skills/plan-*/SKILL.md`（7 个 skill）
- `specs/RULES.md`
- `specs/PROJECTS.md`（空模板）
