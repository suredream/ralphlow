---
name: plan-review
description: Evaluate current project state and produce REVIEW.json
---

# Review Project

You must evaluate the current state of the project.

## Inputs

- PROJECT.md
- FEASIBILITY.md
- BLOCKERS.md
- ACTIONS.md
- CURRENT_FOCUS.md

---

## Output → specs/REVIEW.json

```json
{
  "decision": "approve | needs_attention | reject",
  "summary": "",
  "critical": [],
  "medium": [],
  "minor": [],
  "recommendations": []
}
````

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