---
name: plan-review
description: Evaluate current project state and produce REVIEW.json
---

# Review Project

You must evaluate the current state of the project.

## Resolve Project

Determine `<project>` using this priority order:
1. Explicit argument passed when invoking this skill (e.g. `/plan-review alpha`)
2. Project declared in the current conversation (e.g. "working on: alpha")
3. If neither is available, ask the user to specify the project name before proceeding.

## Inputs

- `specs/<project>/PROJECT.md`
- `specs/<project>/FEASIBILITY.md`
- `specs/<project>/BLOCKERS.md`
- `specs/<project>/ACTIONS.md`
- `specs/<project>/CURRENT_FOCUS.md`

---

## Output → specs/\<project\>/REVIEW.json

```json
{
  "decision": "approve | needs_attention | reject",
  "summary": "",
  "critical": [],
  "medium": [],
  "minor": [],
  "recommendations": []
}
```

---

## Evaluation Criteria

### Critical

* no clear objective
* no actionable next step
* major blockers ignored

### Medium

* unclear feasibility
* weak actions
* scope too broad

### Minor

* wording
* redundancy

---

## Decision Rules

approve:

* clear direction
* actionable plan

needs_attention:

* some gaps

reject:

* no usable direction

---

## Rules

* Be strict but fair
* Do NOT approve weak plans
* Focus on clarity and actionability
