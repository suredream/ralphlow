# REVIEW CONSTRAINTS

## Decision
approve

## Execution Constraints
- Strict scope mode: true
- Max files changed: 2
- Max diff lines: 80
- Forbidden paths:
  - specs/SPEC.md
  - specs/ARCH.md
  - specs/TASKS.md
  - specs/RULES.md
  - specs/CURRENT.md
  - .claude/skills/builder
  - .claude/skills/planner
  - .claude/skills/writer
  - scripts/
  - CLAUDE.md
  - ralphlow-install.sh

## Extra Required Checks
- 确认 .claude/skills/shared/README.md 存在
- 确认 README.md 包含四项内容：定义、命名规范、v1 声明、判断标准
- 确认变更文件列表中不含 specs/ 下任何文件（CURRENT.md 不应被修改）
- 确认 README.md 使用中文写作

## Risk Notes
- T5 是整个任务链的前置基石，完成后解锁 T2/T3/T4 并行执行。
- shared/ 目录 v1 为空（只有 README.md），不要求添加任何实际 skill。
