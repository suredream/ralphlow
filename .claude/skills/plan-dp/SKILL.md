name: plan-dp
description: Convert execution readiness assessment into a concrete execution decision with strict constraints.
---

# Decide Execution Mode

You must convert the execution readiness assessment into a **final, enforceable execution decision**.

This step is REQUIRED before any transition into execution workflows (code-builder or content-writer).

---

## Inputs

Read:

- specs/EXECUTION_READINESS.md
- specs/PROJECT.md
- specs/FEASIBILITY.md
- specs/BLOCKERS.md
- specs/ACTIONS.md

---

## Output

Write:

```text
specs/EXECUTION_DECISION.md
````

Overwrite if exists.

---

## Goal

Transform a **recommendation** into a **decision with constraints**.

---

## Allowed Modes

You must choose exactly one:

* not_ready
* poc
* build

---

## Required Structure

```md
# EXECUTION DECISION

## Project

## Final Decision
not_ready | poc | build

## Rationale

## Why NOT Other Modes

### Why NOT build
### Why NOT poc
### Why NOT not_ready

## Execution Scope

### In Scope
- strictly allowed actions

### Out of Scope
- explicitly forbidden work

---

## Constraints

- scope constraints
- resource constraints
- time constraints
- dependency assumptions

---

## Success Criteria

Define what counts as success for THIS execution mode.

Must be:
- observable
- specific
- minimal

---

## Failure Criteria

Define when this execution attempt should stop or pivot.

---

## First Slice Guidance

Define:

- what the FIRST loop should do
- what CURRENT.md should likely focus on

---

## Risk Notes

- known risks
- acceptable vs unacceptable risks

---

## Decision Owner Notes

- any context for future review
```

---

## Decision Rules

### If readiness = not_ready

```text
Final Decision = not_ready
```

* DO NOT allow export
* MUST define what needs to be resolved first
* MUST define next planning action

---

### If readiness = ready_for_poc

```text
Final Decision = poc
```

* Scope MUST be minimal
* MUST target 1–2 uncertainties only
* MUST NOT evolve into full system
* MUST restrict future expansion

---

### If readiness = ready_for_build

```text
Final Decision = build
```

* Scope can be broader but still bounded
* Dependencies must be mostly resolved
* Must still define first slice as small

---

## Constraint Rules (Critical)

You MUST:

* explicitly restrict scope
* explicitly forbid overbuild
* explicitly define what NOT to do

---

## Anti-Patterns

Do NOT:

* copy EXECUTION_READINESS.md
* leave scope ambiguous
* say "start building" without constraints
* allow unlimited scope
* skip “Why NOT Other Modes”
* produce vague success criteria

---

## Completion Checklist

Before finishing:

* exactly one mode selected
* scope is tightly bounded
* constraints are explicit
* success criteria is concrete
* first slice is small and actionable
