---
name: plan-ready
description: Evaluate whether a project is ready to move from planning into execution, and produce a structured readiness assessment.
---

# Execution Readiness Check

You must evaluate whether the current project is ready to move from **plan-planner mode** into an **execution workflow** such as code-builder or content-writer.

This skill does NOT generate implementation specs directly.
Its job is to decide whether execution should begin, and under what mode.

---

## Resolve Project

Determine `<project>` using this priority order:
1. Explicit argument passed when invoking this skill (e.g. `/plan-ready alpha`)
2. Project declared in the current conversation (e.g. "working on: alpha")
3. If neither is available, ask the user to specify the project name before proceeding.

---

## Inputs

Read the following files if present:

- `specs/<project>/PROJECT.md`
- `specs/<project>/FEASIBILITY.md`
- `specs/<project>/BLOCKERS.md`
- `specs/<project>/ACTIONS.md`
- `specs/<project>/CURRENT_FOCUS.md`
- `specs/RULES.md`
- `specs/<project>/REVIEW.json`

You may also read `init_idea.md` for original context, but do NOT treat it as the current source of truth.

---

## Output

Write:

```text
specs/<project>/EXECUTION_READINESS.md
```

If it already exists, update it in place.

---

## Goal

Determine whether the project is:

* `not_ready`
* `ready_for_poc`
* `ready_for_build`

And explain why.

---

## Required Structure

Use this structure unless there is a strong reason not to:

```md
# EXECUTION READINESS

## Project

## Overall Decision
not_ready | ready_for_poc | ready_for_build

## Summary

## Readiness Dimensions

### 1. Problem Clarity
- Status:
- Notes:

### 2. Scope Stability
- Status:
- Notes:

### 3. Dependency Readiness
- Status:
- Notes:

### 4. Feasibility Confidence
- Status:
- Notes:

### 5. Blocker Severity
- Status:
- Notes:

### 6. Execution Value Now
- Status:
- Notes:

## Key Missing Preconditions

## Why Not Ready Yet (if applicable)

## Why POC Is Appropriate (if applicable)

## Why Full Build Is Appropriate (if applicable)

## Recommended Execution Mode
not_ready | poc | build

## Recommended Next Step

## Notes for Handoff
```

---

## Evaluation Dimensions

You must explicitly evaluate these six dimensions:

### 1. Problem Clarity

Is the problem definition clear enough that execution would target a real, stable objective?

### 2. Scope Stability

Is the intended scope stable enough to execute without immediate churn?

### 3. Dependency Readiness

Are key dependencies sufficiently available?
Examples:

* data access
* stakeholder decisions
* partnerships
* input materials
* distribution assumptions

### 4. Feasibility Confidence

Is there enough evidence that the project can work?
This includes technical, operational, product, and business feasibility as appropriate.

### 5. Blocker Severity

Are remaining blockers manageable, or are they still execution-blocking?

### 6. Execution Value Now

Would moving into execution reduce uncertainty efficiently, or is further planning still the better next move?

---

## Status Labels

For each readiness dimension, use one of:

* `green`
* `yellow`
* `red`

Interpretation:

* `green` = good enough for execution
* `yellow` = partially ready, manageable uncertainty remains
* `red` = not ready, major unresolved issue

---

## Decision Rules

### Decision = `not_ready`

Use this when:

* one or more critical dimensions are red
* blockers remain fundamentally unresolved
* execution would mostly produce confusion rather than clarity
* the project still needs planning, alignment, or evidence

### Decision = `ready_for_poc`

Use this when:

* the project is promising but still uncertain
* execution should be used to validate one or two key assumptions
* a small, tightly bounded experiment is the correct next move
* full build would be premature

### Decision = `ready_for_build`

Use this when:

* the project objective is clear
* scope is stable enough
* dependencies are mostly ready
* blockers are manageable
* execution can now deliver value rather than just reduce uncertainty

---

## Output Quality Rules

* Be explicit, not diplomatic
* Do not force readiness if the project is not ready
* Do not confuse "interesting" with "execution-ready"
* Separate unresolved uncertainty from acceptable risk
* If the correct answer is `not_ready`, say so directly
* If the correct answer is `ready_for_poc`, define what uncertainty the POC should reduce
* If the correct answer is `ready_for_build`, explain why the project has crossed that threshold

---

## Recommended Next Step Rules

Your `Recommended Next Step` must be one of these categories:

* continue planning
* run a small POC
* prepare execution brief
* export to execution workflow
* resolve blocker first

Do NOT give generic next steps like "keep exploring" unless you specify exactly what must be explored.

---

## Notes for Handoff

In `Notes for Handoff`, include only the information needed by the next stage.

Examples:

* what has been decided
* what remains intentionally out of scope
* what execution mode should be used
* what the first slice should probably focus on

Do NOT write a full implementation plan here.

---

## Anti-Patterns

Do not:

* approve execution just because the project sounds exciting
* recommend build when blocker resolution is still the main job
* confuse POC with partial build
* give vague recommendations without saying what uncertainty remains
* repeat the contents of FEASIBILITY.md without making a decision

---

## Completion Checklist

Before finishing, verify:

* `specs/<project>/EXECUTION_READINESS.md` exists
* the decision is one of: `not_ready`, `ready_for_poc`, `ready_for_build`
* all six readiness dimensions were evaluated
* the reasoning is explicit
* the next step is concrete
* the document is useful for a later execution-handoff skill
