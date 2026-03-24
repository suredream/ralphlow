# README.write — Content Writer Workflow

## 1. 系统概述

**write-writer** 是一种 AI 辅助的内容创作工作流模式，安装后将目标目录配置为纯写作用途。

它的核心职责是：

- 将想法转化为结构化内容规格
- 构建清晰的文章结构和论点流
- 生成并迭代优化草稿
- 评估内容质量和发布就绪度

**它不做的事：**

- 不分析项目可行性
- 不编写代码
- 不替代 plan 或 builder workflow

**上下游关系：**

```
想法/原始素材
     ↓
write-writer workflow   ← 本文档描述的系统
     ↓
REVIEW.json             ← 内容质量评审
     ↓
发布（公众号、长文、报告等）
```

write-writer 也可以接收来自 plan-planner 的执行决策（EXECUTION_DECISION.md），在明确的范围约束下执行写作任务。

---

## 2. 目录结构规范

```
<project-root>/
  CLAUDE.md             ← write-writer 模式配置（由 ralphlow 安装）
  content/
    RULES.md            ← workflow 级操作规则，所有项目共享
    PROJECTS.md         ← 活跃项目索引
    <project-name>/     ← 每个内容项目一个子目录
      CONTENT_SPEC.md       内容定义（核心观点、受众、论点）
      STRUCTURE.md          文章结构（各节标题、目的、过渡逻辑）
      DRAFT.md              正在写的草稿
      REVIEW.json           内容质量评审
    archive/            ← 归档目录
      <project-name>/   ← 已归档项目，完整保留可查阅
```

### 文件职责说明

| 文件 | 层级 | 职责 | 更新频率 |
|------|------|------|----------|
| `RULES.md` | workflow | 操作约束和写作原则 | 极少改动 |
| `PROJECTS.md` | workflow | 所有项目的状态索引 | 创建/归档项目时 |
| `CONTENT_SPEC.md` | 项目 | 核心观点、目标受众、论点、基调 | 初始化时，方向调整时 |
| `STRUCTURE.md` | 项目 | 文章结构（各节的目的和过渡） | 结构调整时 |
| `DRAFT.md` | 项目 | 实际写作内容 | 每个 loop |
| `REVIEW.json` | 项目 | approve/needs_attention/reject 决策 | `/write-review` 后 |

---

## 3. Skill 说明

### 完整流程

```
/write-spec → /write-struct → /write-draft → /write-logic → /write-review
                                    ↑________________↓
                                    （迭代优化）
```

### Skill 详情

#### `/write-spec [project]`

**用途**：将原始想法转化为结构化的内容规格。

**输入**：原始想法（对话中提供）

**输出**：`content/<project>/CONTENT_SPEC.md`

**包含**：核心观点（一句话）、目标受众、预期影响、关键论点（3-5个）、差异化角度、基调、约束条件

---

#### `/write-struct [project]`

**用途**：从内容规格生成文章结构大纲。

**输入**：`content/<project>/CONTENT_SPEC.md`

**输出**：`content/<project>/STRUCTURE.md`

**包含**：开篇/钩子、问题框架、分析章节（3-5节）、关键洞察/转折、结论。每节包含目的、核心论点、过渡逻辑。

---

#### `/write-draft [project]`

**用途**：根据结构生成或扩展草稿。

**输入**：`content/<project>/STRUCTURE.md`

**输出**：`content/<project>/DRAFT.md`

**规则**：严格按结构写作，段落聚焦，不过度展开。

---

#### `/write-logic [project]`

**用途**：优化草稿的逻辑流和论点连贯性。

**输入**：`content/<project>/DRAFT.md`（读取）

**输出**：`content/<project>/DRAFT.md`（更新）

**关注点**：段落之间的逻辑衔接、假设是否显式、论点是否紧凑。

**注意**：只改善逻辑，不添加新想法，不重写全文。

---

#### `/write-review [project]`

**用途**：综合评估内容质量，输出结构化审查结果。

**输入**：`content/<project>/` 下所有文件

**输出**：`content/<project>/REVIEW.json`

**决策**：`approve`（观点清晰、流畅）/ `needs_attention`（有待改进）/ `reject`（根本不清晰）

---

## 4. 多项目工作流程示例

### 项目声明规范

在每次对话开始时声明当前项目：

```
project: startup-essay      # 英文格式
项目：startup-essay          # 中文格式
```

**项目名命名规范：**
- 小写字母、数字、连字符（`a-z0-9-`），不含空格
- 不超过 32 个字符
- 不得使用 `archive`（保留关键字）
- 示例：`ai-agents-2025`、`startup-essay`、`product-launch`

### 场景 A：新建项目

```
# 1. 在 content/PROJECTS.md 中添加项目记录
# 2. 开始对话，声明项目
用户："project: startup-essay，想写一篇关于创业如何面对不确定性的文章"

# 3. 定义内容规格
/write-spec

# 4. 生成文章结构
/write-struct

# 5. 写初稿
/write-draft

# 6. 优化逻辑（可多次）
/write-logic

# 7. 评审内容质量
/write-review
```

### 场景 B：切换到另一个项目

每次对话只处理一个项目。切换项目只需在新对话中声明：

```
用户："project: product-launch，继续写产品发布文章的草稿"
/write-draft
# skill 从对话上下文读取 "product-launch"，操作 content/product-launch/
```

### 场景 C：多个 agent 并行处理不同项目

Agent 1 对话：
```
用户："project: startup-essay，优化逻辑"
/write-logic
# 操作 content/startup-essay/DRAFT.md
```

Agent 2 对话（同时进行）：
```
用户："project: product-launch，评审内容"
/write-review
# 操作 content/product-launch/REVIEW.json
```

两个 agent 操作不同子目录，无需协调，天然隔离。

### 场景 D：显式传参（临时查看非声明项目）

```
# 当前对话处理 startup-essay，但想快速评审 product-launch
/write-review product-launch
# 直接操作 content/product-launch/，不影响 startup-essay 的对话上下文
```

---

## 5. Archive 机制

### 何时归档

| 情况 | Archive Reason |
|------|----------------|
| 内容已发布 | `published` |
| 项目放弃，不再需要 | `abandoned` |
| 超过 30 天无活动且无恢复计划 | `inactive` |
| 被合并入另一项目 | `merged` |

**不应归档**：暂时搁置等待灵感或外部素材的项目（应保持 active，在 CONTENT_SPEC.md 注明原因）。

### 如何归档（两步操作）

```bash
# 步骤 1：物理移动目录
mv content/startup-essay/ content/archive/startup-essay/

# 步骤 2：更新 PROJECTS.md 索引
# 将 startup-essay 从 Active 表格移到 Archive 表格，填写归档日期和原因
```

### 查阅已归档项目

归档后的文件完整保留，可随时查阅：

```
用户："查看 startup-essay 当时的内容规格"
# 直接读取 content/archive/startup-essay/CONTENT_SPEC.md
```

注意：默认的 Reading Order 不包含 `content/archive/`，AI 不会主动读取已归档内容。

---

## 安装

通过 ralphlow 安装 write-writer workflow：

```bash
./install.sh <target-directory> write
```

安装后，目标目录获得：
- `CLAUDE.md`（write-writer 模式配置）
- `.claude/skills/write-*/SKILL.md`（5 个 skill）
- `content/RULES.md`
- `content/PROJECTS.md`（空模板）
