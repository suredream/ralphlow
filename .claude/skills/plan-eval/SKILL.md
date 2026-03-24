---
name: plan-eval
description: Evaluate feasibility of the project
---

# Project to Feasibility

You must analyze the feasibility of the project.

## Resolve Project

Determine `<project>` using this priority order:
1. Explicit argument passed when invoking this skill (e.g. `/plan-eval alpha`)
2. Project declared in the current conversation (e.g. "working on: alpha")
3. If neither is available, ask the user to specify the project name before proceeding.

## Input

- `specs/<project>/PROJECT.md`

## Output → specs/\<project\>/FEASIBILITY.md

## Structure

- Overall Assessment
- Product Feasibility
- Technical Feasibility
- Resource Feasibility
- Distribution / GTM Feasibility
- Main Unknowns
- Key Risks
- Recommendation (explore / validate / not_ready)

## Rules

- Be explicit about uncertainty
- Identify assumptions clearly
- Separate facts from guesses

## Anti-patterns

- overconfidence
- missing unknowns
- ignoring constraints
