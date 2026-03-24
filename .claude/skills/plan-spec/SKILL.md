---
name: plan-spec
description: Convert an initial idea into a structured PROJECT.md
---

# Idea to Project

You must transform `init_idea.md` into a structured project definition.

## Resolve Project

Determine `<project>` using this priority order:
1. Explicit argument passed when invoking this skill (e.g. `/plan-spec alpha`)
2. Project declared in the current conversation (e.g. "working on: alpha")
3. If neither is available, ask the user to specify the project name before proceeding.

Create `specs/<project>/` directory if it does not exist.

## Output → specs/\<project\>/PROJECT.md

Include:

- Title
- Goal (one sentence)
- Background
- Problem Definition
- Target Users
- Success Criteria
- Current Stage (default: exploring)
- Notes

## Rules

- Be concise and structured
- Do NOT assume feasibility yet
- Do NOT design solutions
- Focus on problem clarity

## Anti-patterns

- jumping into implementation
- vague goals
- missing success criteria
