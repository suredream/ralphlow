ralphlow: 将 ralpha loop 的流程引入不同的 workflows

- builder
- planner
- writer

其中除了 builder 是对于当前项目进行操作以外，
planner 和 writer 都支持多个子项目的操作


每个项目要有命令规范

# 三、每个 workflow 的职责（必须清晰）

---

## 1️⃣ `planner`（最高层）

**职责：决定做什么**

```text
PROJECT
FEASIBILITY
BLOCKERS
ACTIONS
CURRENT_FOCUS
```

输出：

```text
EXECUTION_DECISION
EXECUTION_BRIEF
```

👉 是整个系统的“大脑”

---

## 2️⃣ `builder`

**职责：把决策变成系统**

```text
SPEC
ARCH
TASKS
CURRENT
```

输出：

```text
code / api / infra
```

👉 是“执行器（engineering）”

---

## 3️⃣ `writer`

**职责：把思考变成表达**

```text
CONCEPT
STRUCTURE
DRAFT
CURRENT
```

输出：

```text
公众号 / 文章 / 文案
```

👉 是“表达层”

---

# 四、三者关系（非常关键）

```text
plan-planner
  ↓
决定做什么

      ↓↓↓

code-builder        content-writer
（做系统）          （写内容）
```

👉 planner 是上游
👉 builder / writer 是执行分支

---

# 五、skills 命名（必须统一）

---

## `.claude/skills/` 最佳结构

```text
skills/
  shared/

planner/
    to-project
    to-feasibility
    to-actions
    review-project
    execution-readiness-check
    decide-execution-mode

builder/
    get-spec
    get-arch
    get-tasks
    get-current
    review-spec

writer/
    to-concept-spec
    to-structure
    write-draft
    refine-logic
    review-content
```

---

## 命名规则（关键）

👉 不要再用：

```text
review
current
build
```

👉 必须带 domain：

```text
review-project
review-specs
review-content
```

否则你以后会混乱。

---

# 六、入口命令

ralphlow 引入一个具体的 目录时（称之为安装），必须选择一个特定的 workflow: builder | planner | writer，由此来决定引入的skill/scripts，设定以后也不能变更，如下

<target-path>/
raphlow-install.sh builder
