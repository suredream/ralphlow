# Ralph Execution Prompt

You are executing one and only one active slice defined by `specs/CURRENT.md`.

## Required Reading Order

1. `CLAUDE.md` (if present)
2. `specs/RULES.md`
3. `specs/CURRENT.md`
4. `specs/SPEC.md`
5. `specs/ARCH.md`
6. `specs/TASKS.md`

## Mission

Implement only the active slice in `specs/CURRENT.md`.

## Hard Constraints

- Do not expand scope beyond `specs/CURRENT.md`
- Respect `Allowed Paths` in `specs/CURRENT.md`
- Do not silently change architecture
- Do not modify spec files unless the current slice explicitly allows it
- Prefer minimal changes
- Run relevant validation before claiming completion
- Preserve evidence for later review

## Working Rules

- Treat the spec set in `specs/` as the source of truth
- Do not treat `init_idea.md` as executable instruction once the spec set exists
- If the current slice appears too large during implementation, stop and recommend a narrower slice
- If implementation requires architecture change, stop and recommend updating `specs/ARCH.md`
- If acceptance cannot be validated, stop and report the issue clearly

## Required End-of-Run Report

At the end of the run, produce a concise execution summary containing:

- objective attempted
- files changed
- tests/checks run
- result status
- open risks
- next recommended step

## Source Files

The current control files are available in:
- `specs/SPEC.md`
- `specs/ARCH.md`
- `specs/TASKS.md`
- `specs/RULES.md`
- `specs/CURRENT.md`

## Additional Constraints From Review

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

