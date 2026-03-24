---
name: write-logic
description: Improve logical flow and argument clarity
---

# Refine Logic

Improve the draft's logical coherence.

## Resolve Project

Determine `<project>` using this priority order:
1. Explicit argument passed when invoking this skill (e.g. `/write-logic startup-essay`)
2. Project declared in the current conversation (e.g. `project: startup-essay` or `项目：startup-essay`)
3. If neither is available, ask the user to specify the project name before proceeding.

## Improve

- transitions
- argument coherence
- cause-effect clarity

## Focus

- does each paragraph logically lead to next?
- are assumptions explicit?
- are arguments tight?

## Output

Update:

- `content/<project>/DRAFT.md`

## Anti-patterns

- rewriting everything blindly
- adding new ideas instead of improving logic
