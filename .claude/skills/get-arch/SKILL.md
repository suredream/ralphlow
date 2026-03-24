---
name: get-arch
description: Generate or revise specs/ARCH.md from specs/SPEC.md. Use when the spec exists and the system needs an explicit architecture, component model, boundaries, trade-offs, or integration plan.
---

# SPEC to ARCH

Convert `specs/SPEC.md` into a focused `specs/ARCH.md`.

## Goal

Produce an architecture document that explains:

- major components
- responsibilities
- interactions and data flow
- system boundaries
- critical design decisions
- trade-offs and rejected options

## Inputs

Required:

- `specs/SPEC.md`

Optional if present:

- `init_idea.md`
- `specs/ARCH.md`
- current codebase
- `specs/TASKS.md`

## Output

- `specs/ARCH.md`

## What ARCH.md must contain

Use this structure unless there is a strong reason not to:

```md
# ARCH

## Title

## Summary

## Architectural Goals

## System Context

## Core Components

## Responsibilities by Component

## Key Flows

## Data Model / State Model (high level)

## Interfaces and Boundaries

## Key Decisions

## Trade-offs

## Rejected Options

## Failure Modes and Recovery Notes

## Observability / Validation Considerations

## Future Extension Notes
````

## Rules

* Base the architecture on `specs/SPEC.md`, not on random implementation convenience.
* Keep architecture at the structural level.
* Do not turn `ARCH.md` into a sprint task list.
* Do not over-specify internals too early.
* Name boundaries clearly.
* Call out decisions that affect future extensibility or validation.
* Prefer one responsibility per component.
* Mention async/sync decisions when they matter.
* If architecture has changed from an existing version, preserve rationale.

## Workflow

1. Read `specs/SPEC.md`.
2. Read existing `specs/ARCH.md` if present.
3. Identify the minimum viable architecture needed to satisfy the spec.
4. Break the system into coherent components.
5. Define data flow and control flow.
6. Write down major decisions and trade-offs.
7. List rejected options that are realistic and informative.
8. Write or revise `specs/ARCH.md`.

## Anti-patterns

Do not:

* mirror the code directory tree unless it actually matches architecture
* fill the doc with generic buzzwords
* skip trade-offs
* mix acceptance criteria into architecture
* write tasks like "Step 1 create DB, Step 2 build API"

## Example trigger phrases

* "generate architecture from spec"
* "write ARCH.md"
* "turn this spec into system design"
* "update architecture after spec changes"

## Completion checklist

Before finishing, verify:

* `specs/ARCH.md` exists
* components and responsibilities are explicit
* key flows are described
* trade-offs and rejected options are included
* architecture does not collapse into implementation tasking
