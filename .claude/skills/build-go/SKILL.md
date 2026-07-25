---
name: build-go
description: 顺序串联 build 工作流的全部步骤：spec → arch → tasks → current → review，并在每步前检查文件是否已存在以决定跳过或执行。执行完毕后停下，等待 Ralph 运行。
---

# Build-Go：build 工作流串联器

按顺序执行 build 工作流的所有步骤，并在 review 完成后停下。

---

## 执行前：状态检测

在运行任何步骤之前，先检查以下文件是否存在：

| 文件 | 对应步骤 |
|------|---------|
| `specs/SPEC.md` | build-spec |
| `specs/ARCH.md` | build-arch |
| `specs/TASKS.md` | build-tasks |
| `specs/CURRENT.md` | build-current |
| `specs/REVIEW.json` | build-review |

**跳过规则：**

- 若 `specs/SPEC.md`、`specs/ARCH.md`、`specs/TASKS.md` 全部存在 → 跳过前三步，从 **Step 4（build-current）** 开始。
- 若某文件已存在但内容明显过时或与上游文件冲突 → 不跳过，重新生成。
- 若 `specs/CURRENT.md` 已存在且内容仍然有效 → 可跳过 Step 4，直接执行 Step 5（build-review）。
- `specs/REVIEW.json` 每次 build-go 运行都必须重新生成，不可跳过。

---

## 执行步骤

### Step 1 — build-spec（如未跳过）

**条件：** `specs/SPEC.md` 不存在，或存在但与 `init_idea.md` 明显不一致。

执行 `/build-spec` skill 的完整流程：

1. 读取 `init_idea.md`
2. 读取已有 `specs/SPEC.md`（若存在）
3. 生成或更新 `specs/SPEC.md`

完成后输出：
```
✓ Step 1 完成：specs/SPEC.md 已生成/更新
```

---

### Step 2 — build-arch（如未跳过）

**条件：** `specs/ARCH.md` 不存在，或存在但与当前 `specs/SPEC.md` 明显不一致。

执行 `/build-arch` skill 的完整流程：

1. 读取 `specs/SPEC.md`
2. 读取已有 `specs/ARCH.md`（若存在）
3. 生成或更新 `specs/ARCH.md`

完成后输出：
```
✓ Step 2 完成：specs/ARCH.md 已生成/更新
```

---

### Step 3 — build-tasks（如未跳过）

**条件：** `specs/TASKS.md` 不存在，或存在但与当前 SPEC/ARCH 明显不一致。

执行 `/build-tasks` skill 的完整流程：

1. 读取 `specs/SPEC.md` 和 `specs/ARCH.md`
2. 读取已有 `specs/TASKS.md`（若存在）
3. 生成或更新 `specs/TASKS.md`

完成后输出：
```
✓ Step 3 完成：specs/TASKS.md 已生成/更新
```

---

### Step 4 — build-current

**条件：** 每次均执行，除非 `specs/CURRENT.md` 已存在且有效（见跳过规则）。

执行 `/build-current` skill 的完整流程：

1. 读取 `specs/TASKS.md`
2. 读取 `specs/RULES.md`
3. 读取当前仓库状态（可选）
4. 选定最小可验证的下一个切片
5. 生成或更新 `specs/CURRENT.md`

完成后输出：
```
✓ Step 4 完成：specs/CURRENT.md 已生成/更新
```

---

### Step 5 — build-review（必须执行）

**条件：** 每次 build-go 均必须执行，不可跳过。

执行 `/build-review` skill 的完整流程：

1. 读取所有 spec 文件（SPEC, ARCH, TASKS, CURRENT, RULES）
2. 输出人类可读的审查报告（chat 中）
3. 写入 `specs/REVIEW.json`

完成后输出：
```
✓ Step 5 完成：specs/REVIEW.json 已生成
```

---

## 执行完毕后：停下

**在 build-review 完成后，必须停下。**

不要：
- 自动触发 Ralph
- 自动 push 代码
- 自动开始实现

输出最终摘要：

```
══════════════════════════════════
build-go 完成
══════════════════════════════════
跳过步骤：[列出跳过的步骤及原因]
已执行步骤：[列出已执行的步骤]
REVIEW 决策：[approve / needs_attention / reject]
下一步：根据 REVIEW.json 的 decision 决定是否可以让 Ralph 开始执行。
══════════════════════════════════
```

---

## 反模式

不要：

- 跳过 build-review
- 在 review 之后自动继续执行
- 因为文件存在就跳过明显过时的内容
- 在任意步骤失败后强行继续

---

## 触发示例

- `/build-go`
- "运行完整的 build 流程"
- "从头到 review 走一遍"
- "build 全流程"
