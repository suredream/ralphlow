---
name: write-review
description: Evaluate content quality and readiness
---

# Review Content

Evaluate the current draft.

## Output → REVIEW.json

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

## Criteria

### Critical

* no clear core idea
* broken logic
* structure missing

### Medium

* weak transitions
* redundancy
* unclear arguments

### Minor

* style issues
* wording

## Decision Rules

approve:

* clear idea, strong flow

needs_attention:

* some issues but fixable

reject:

* fundamentally unclear

## Rules

* be strict
* avoid shallow approval