---
name: plan-focus
description: Define the next iteration focus
---

# Make Current Focus

You must define the next loop's focus.

## Resolve Project

Determine `<project>` using this priority order:
1. Explicit argument passed when invoking this skill (e.g. `/plan-focus alpha`)
2. Project declared in the current conversation (e.g. "working on: alpha")
3. If neither is available, ask the user to specify the project name before proceeding.

## Output → specs/\<project\>/CURRENT_FOCUS.md

---

## Requirements

- ONE clear objective
- Limited scope
- Directly tied to blockers or feasibility

---

## Structure

## Objective
Single clear question or goal

## In Scope
3–5 items max

## Out of Scope
Explicit exclusions

## Required Output
Concrete expected updates

---

## Rules

- Keep it small
- Must be solvable in one loop
- Must reduce uncertainty

## Anti-patterns

- multiple objectives
- vague focus
- too broad scope
