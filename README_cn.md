# ralphlow

**ralphlow** 是一个针对 [Claude Code](https://claude.ai/code) + [Ralph](https://github.com/anthropics/ralph) 的工作流安装器。它为项目目录配置正确的 skills、CLAUDE.md 和 Ralph 初始化配置，支持三种工作模式：**build（构建）**、**plan（规划）**、**write（写作）**。

---

## 工作原理

每种工作流会将对应的 Claude Code skills 安装到 `.claude/skills/`，并将匹配的 `CLAUDE.md` 放入项目根目录。Ralph 随后在这些 skills 和文件的引导下运行执行循环。

```
install.sh <安装路径> [build|plan|write]
```

**默认模式：** `build`

---

## 工作流说明

### build（构建）

用于规格驱动的软件开发。Claude Code 维护一套 spec 控制文件，Ralph 每次只执行一个严格划定范围的切片。

**循环流程：**
```
init_idea.md
  → /build-spec       （生成 SPEC.md）
  → /build-arch       （生成 ARCH.md）
  → /build-tasks      （生成 TASKS.md）
  → /build-current    （选定当前执行切片 CURRENT.md）
  → /build-review     （生成 REVIEW.json，作为执行门控）
  → ralph             （执行当前切片）
  → 进入下一轮
```

**安装的 Skills：**

| Skill | 用途 |
|---|---|
| `/build-spec` | 从 `init_idea.md` 生成或修订 `specs/SPEC.md` |
| `/build-arch` | 从 `SPEC.md` 生成或修订 `specs/ARCH.md` |
| `/build-tasks` | 从 `SPEC.md` + `ARCH.md` 生成或修订 `specs/TASKS.md` |
| `/build-current` | 选定并范围化下一个执行切片，写入 `CURRENT.md` |
| `/build-review` | 检查所有 spec 文件，生成 `REVIEW.json` 作为执行门控 |

**核心文件（`specs/`）：**
- `SPEC.md` — 产品意图、范围、验收条件
- `ARCH.md` — 架构设计、边界、权衡
- `TASKS.md` — 可执行任务拆解
- `RULES.md` — 执行流程规则
- `CURRENT.md` — 当前唯一执行切片

---

### plan（规划）

用于项目可行性分析和决策支持。**不写代码**，目标是降低不确定性、厘清阻碍、明确可执行的下一步行动。

**循环流程：**
```
init_idea.md
  → /plan-spec        （生成 PROJECT.md）
  → /plan-eval        （生成 FEASIBILITY.md）
  → /plan-actions     （生成 ACTIONS.md、BLOCKERS.md）
  → /plan-focus       （生成 CURRENT_FOCUS.md）
  → /plan-ready       （执行就绪评估）
  → /plan-dp          （执行决策）
  → /plan-review      （生成 REVIEW.json）
  → 进入下一轮，或移交给 build 模式
```

**安装的 Skills：**

| Skill | 用途 |
|---|---|
| `/plan-spec` | 将初始想法转化为结构化的 `PROJECT.md` |
| `/plan-eval` | 评估项目可行性 |
| `/plan-actions` | 将可行性洞察转化为具体行动和阻碍 |
| `/plan-focus` | 确定下一轮迭代的焦点 |
| `/plan-ready` | 评估项目是否已就绪，可进入执行阶段 |
| `/plan-dp` | 以严格约束条件给出具体执行决策 |
| `/plan-review` | 评估当前项目状态，生成 `REVIEW.json` |

**核心文件：**
- `PROJECT.md` — 项目定义与范围
- `FEASIBILITY.md` — 可行性评估
- `BLOCKERS.md` — 当前阻碍
- `ACTIONS.md` — 下一步可执行行动
- `CURRENT_FOCUS.md` — 当前迭代焦点

---

### write（写作）

用于生成结构化书面内容（公众号文章、长文、观点输出等）。循环将一个核心想法打磨为完整草稿。

**循环流程：**
```
idea
  → /write-spec       （生成 CONTENT_SPEC.md）
  → /write-struct     （生成 STRUCTURE.md）
  → /write-draft      （生成 DRAFT.md）
  → /write-logic      （优化论证逻辑）
  → /write-review     （评估内容质量与完成度）
  → 进入下一轮
```

**安装的 Skills：**

| Skill | 用途 |
|---|---|
| `/write-spec` | 将想法转化为结构化内容规格 |
| `/write-struct` | 将内容规格转化为段落级大纲 |
| `/write-draft` | 基于大纲生成初稿 |
| `/write-logic` | 改善逻辑流程与论点清晰度 |
| `/write-review` | 评估内容质量与发布就绪度 |

**核心文件：**
- `CONTENT_SPEC.md` — 内容意图与约束
- `STRUCTURE.md` — 章节级结构
- `DRAFT.md` — 工作稿
- `CURRENT.md` — 当前聚焦点（段落或章节级）

---

## 安装使用

```bash
# 安装到新目录或已有目录
./install.sh ~/projects/my-app build
./install.sh ~/projects/my-plan plan
./install.sh ~/projects/my-article write
```

脚本执行以下步骤：
1. 若目标目录不存在则自动创建
2. 执行 `git init`（幂等）
3. 将对应模式的 `CLAUDE.md` 复制为项目根目录的 `CLAUDE.md`
4. 将该工作流的 skills 复制到 `.claude/skills/`
5. 执行 `ralph-enable` 完成 Ralph 配置

---

## 核心原则（所有模式通用）

- **每次只执行一个切片。** 不允许超出 `CURRENT.md`（或 `CURRENT_FOCUS.md`）范围。
- **先改规格，再改代码。** 需求变化时，先更新 spec 文件，再执行实现。
- **每一步都可验证。** 验收条件必须具体且可检查，不接受"看起来正确"。
- **禁止隐式扩展范围。** 所有偏差必须显式记录。
