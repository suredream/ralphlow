---
name: write-struct
description: Convert content spec into structured outline
---

# Spec to Structure

Create a logical structure from the content spec.

## Resolve Project

Determine `<project>` using this priority order:
1. Explicit argument passed when invoking this skill (e.g. `/write-struct startup-essay`)
2. Project declared in the current conversation (e.g. `project: startup-essay` or `项目：startup-essay`)
3. If neither is available, ask the user to specify the project name before proceeding.

## Input

- `content/<project>/CONTENT_SPEC.md`

## Output → content/\<project\>/STRUCTURE.md

Structure format:

- Hook / Opening
- Problem Framing
- Analysis Sections (3–5 parts)
- Key Insight / Turning Point
- Conclusion

Each section must include:

- purpose
- key point
- transition logic

## Rules

- ensure logical progression
- each section must build on previous

## Anti-patterns

- flat list of points
- no narrative flow
