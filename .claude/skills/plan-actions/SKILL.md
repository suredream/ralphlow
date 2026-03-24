---
name: plan-actions
description: Convert feasibility insights into concrete actions and blockers
---

# Feasibility to Actions

You must convert feasibility into:

- actionable steps
- explicit blockers

## Resolve Project

Determine `<project>` using this priority order:
1. Explicit argument passed when invoking this skill (e.g. `/plan-actions alpha`)
2. Project declared in the current conversation (e.g. "working on: alpha")
3. If neither is available, ask the user to specify the project name before proceeding.

## Output

Update:

- `specs/<project>/BLOCKERS.md`
- `specs/<project>/ACTIONS.md`

---

## BLOCKERS

Each blocker must include:

- Type (data / tech / org / decision / market)
- Description
- Impact
- Status

---

## ACTIONS

Each action must include:

- Goal
- Expected outcome
- Related blocker (if any)

---

## Rules

- Every action must reduce uncertainty
- Avoid vague actions
- Prefer small, testable steps

## Anti-patterns

- "do research"
- "explore options"
- actions without clear outcome
