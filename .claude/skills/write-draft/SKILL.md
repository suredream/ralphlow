---
name: write-draft
description: Generate initial draft based on structure
---

# Write Draft

Generate or extend the draft.

## Resolve Project

Determine `<project>` using this priority order:
1. Explicit argument passed when invoking this skill (e.g. `/write-draft startup-essay`)
2. Project declared in the current conversation (e.g. `project: startup-essay` or `项目：startup-essay`)
3. If neither is available, ask the user to specify the project name before proceeding.

## Input

- `content/<project>/STRUCTURE.md`

## Output

Update:

- `content/<project>/DRAFT.md`

## Rules

- follow STRUCTURE strictly
- write clearly and concretely
- do NOT over-expand
- keep paragraphs focused

## Anti-patterns

- long vague paragraphs
- repeating same idea
- deviating from structure
