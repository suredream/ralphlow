---
name: write-review
description: Evaluate content quality and readiness
---

# Review Content

Evaluate the current draft.

## Resolve Project

Determine `<project>` using this priority order:
1. Explicit argument passed when invoking this skill (e.g. `/write-review startup-essay`)
2. Project declared in the current conversation (e.g. `project: startup-essay` or `项目：startup-essay`)
3. If neither is available, ask the user to specify the project name before proceeding.

## Inputs

- `content/<project>/CONTENT_SPEC.md`
- `content/<project>/STRUCTURE.md`
- `content/<project>/DRAFT.md`

## Output → content/\<project\>/REVIEW.json

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
