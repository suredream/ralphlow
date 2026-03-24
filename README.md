# AI-Native Spec-Driven Development Workflow（基于 Claude Code + Ralph）

本仓库实现了一套 **以 Spec 为核心驱动、结合 Claude Code Skills 与 Ralph 执行循环的 AI-native 开发流程**。
目标是将「想法 → 系统设计 → 可执行代码」转化为**可控、可验证、可回溯**的工程过程。

---

# 🧭 核心理念

本系统基于以下原则：

* **Spec 是唯一事实来源（Source of Truth）**
* **开发按最小切片推进（CURRENT）**
* **执行与决策分离（Claude Code vs Ralph vs Review）**
* **每一步都可验证、可回放、可审计**

---

# 🏗️ 系统整体架构

```text
ChatGPT（构思）
  ↓
init_idea.md

Claude Code（Specs 生成与维护）
  ↓
specs/
  SPEC.md
  ARCH.md
  TASKS.md
  RULES.md
  CURRENT.md

Scripts（控制与同步）
  ↓
sync_to_ralph.sh

Ralph（执行循环）
  ↓
代码变更 + artifacts

验证 / 评审（verify.sh / review.sh）
  ↓
决策是否进入下一轮
```

---

# 📁 目录结构说明

```text
repo/
  CLAUDE.md              # Claude Code 全局行为规则
  init_idea.md           # ChatGPT 讨论沉淀

  specs/                 # 控制面（Control Plane）
    SPEC.md              # 目标与验收
    ARCH.md              # 架构设计
    TASKS.md             # 任务拆解
    RULES.md             # 执行规则
    CURRENT.md           # 当前切片

  .claude/skills/        # Claude Code Skills
    init-idea-to-spec/
    spec-to-arch/
    arch-to-tasks/
    make-current/
    review-specs/

  scripts/               # 执行与审计脚本
    sync_to_ralph.sh：把当前 specs 同步成 Ralph 可执行输入，并可选直接启动 Ralph
    verify.sh：执行验证命令并保存结果
    review.sh：做静态规则检查 + 产出 review 结论
    collect_artifacts.sh：收集本轮执行证据

  artifacts/             # 每轮执行证据
  logs/                  # 运行日志
```

---

# 🔁 标准开发流程

## Step 1：构思（ChatGPT）

在 ChatGPT 中讨论需求，并将结果整理为：

```text
init_idea.md
```

内容可以包括：

* 问题背景
* 用户流程
* 特殊规则
* 初步方案
* 风险与假设

⚠️ 注意：
`init_idea.md` 不是最终执行依据，只是原始材料。

---

## Step 2：生成 Spec（Claude Code Skills）

进入 Claude Code，在 repo 中运行：

```text
/init-idea-to-spec
/spec-to-arch
/arch-to-tasks
/make-current
```

生成：

* `specs/SPEC.md`
* `specs/ARCH.md`
* `specs/TASKS.md`
* `specs/CURRENT.md`

`RULES.md` 一般为项目初始化时创建，后续少量修改。

---

## Step 3：检查控制文件（可选但推荐）

运行：

```text
/review-spec
```

用于检查：

* spec 是否一致
* 架构是否合理
* task 是否过大
* CURRENT 是否过宽

---

## Step 4：同步到 Ralph

执行：

```bash
scripts/sync_to_ralph.sh
```

该脚本负责：

* 读取 `CURRENT.md` + `RULES.md`
* 生成 Ralph 执行输入
* 初始化本轮 artifacts
* 启动 `ralph` 执行循环

---

## Step 5：Ralph 执行开发

```bash
ralph
```

Ralph 将：

* 基于当前切片进行代码实现
* 多轮调用 Claude Code
* 推进当前 slice 的完成

---

## Step 6：验证与评审

执行：

```bash
scripts/verify.sh
scripts/review.sh
scripts/collect_artifacts.sh
```

分别用于：

### verify.sh

* 测试（unit / integration）
* lint / typecheck
* build 检查

### review.sh

* 是否符合 SPEC / ARCH
* 是否越界修改
* 是否 scope 漂移
* 是否存在“投机性实现”

### collect_artifacts.sh

收集：

```text
artifacts/<loop_id>/
  prompt.txt
  current.md
  changed-files.txt
  git diff
  test output
  review.md
```

---

## Step 7：决策下一步

根据验证与评审结果：

### ✅ 通过

* 更新 `TASKS.md` 状态
* 生成新的 `CURRENT.md`
* 进入下一轮

### ❌ 不通过

* 修正 `CURRENT.md`
* 或修正 `TASKS.md / ARCH.md`
* 或回到 SPEC 层

---

# 🔄 需求变更流程

当需求发生变化时：

❌ 不要直接改代码
✅ 应该：

1. 更新 `init_idea.md` 或新增补充说明
2. 使用 Claude Code skills 更新：

```text
/init-idea-to-spec
/spec-to-arch
/arch-to-tasks
```

3. 重新生成：

```text
/make-current
```

4. 再进入 Ralph 执行

---

# 🧩 Skills 说明

| Skill             | 作用          |
| ----------------- | ----------- |
| init-idea-to-spec | 从想法生成 SPEC  |
| spec-to-arch      | 从 SPEC 生成架构 |
| arch-to-tasks     | 拆分任务        |
| make-current      | 生成当前最小切片    |
| review-specs      | 检查 spec 一致性 |

---

# ⚠️ 关键规则（必须遵守）

### 1. 永远只执行 CURRENT.md

* 不允许多任务并行
* 不允许顺手做“下一个任务”

### 2. Spec 优先于代码

* 需求变化 → 改 SPEC
* 架构变化 → 改 ARCH

### 3. 小步推进

* CURRENT 必须是最小可验证切片

### 4. 不允许“作弊”

* 不删除测试让 CI 通过
* 不隐藏失败
* 不虚报完成

### 5. 所有工作必须可回溯

* 必须保留 artifacts
* 必须记录变更与验证

---

# 🚫 常见错误

### ❌ 直接从 init_idea 写代码

→ 应先生成 SPEC

### ❌ CURRENT 过大

→ 应拆分 slice

### ❌ TASKS 过粗

→ 应细化为可验证任务

### ❌ ARCH 写成 TASKS

→ 应只写结构与决策

### ❌ 跳过 review

→ 会导致 spec drift

---

# 🎯 适用场景

本系统特别适用于：

* AI-native 产品开发
* 多 agent 协作开发
* 复杂系统设计到落地
* 需要强可控性与审计能力的项目
* 快速迭代但不能失控的工程

---

# 🧠 一句话总结

> **用 ChatGPT 想清楚问题，用 Claude Code 写清楚规则，用 Ralph 执行代码，用验证与评审守住边界。**

---

如果你是第一次使用，建议：

1. 从一个小项目开始
2. 保持 CURRENT 很小
3. 强制执行验证与 review
4. 逐步优化 skills 与 scripts

这套系统的价值不在“更快写代码”，
而在**让 AI 参与开发变得可控、可信、可复用**。



# 四、content-writer 的 loop

```text
idea
  ↓
idea-to-content-spec
  ↓
spec-to-structure
  ↓
write-draft
  ↓
CURRENT（段落级 focus）
  ↓
refine-logic / compress / add-hooks
  ↓
review-content
  ↓
next iteration


# planer loop

init_idea.md
  ↓
/idea-to-project
  ↓
/project-to-feasibility
  ↓
/feasibility-to-actions
  ↓
/make-current-focus
  ↓
/review-project
  ↓
sync_to_ralph.sh
  ↓
(更新 specs)
  ↓
下一轮