---
name: write-spec
description: Convert an idea into a structured content specification
---

# Idea to Content Spec

Transform the idea into a structured content definition.

## Resolve Project

Determine `<project>` using this priority order:
1. Explicit argument passed when invoking this skill (e.g. `/write-spec startup-essay`)
2. Project declared in the current conversation (e.g. `project: startup-essay` or `项目：startup-essay`)
3. If neither is available, ask the user to specify the project name before proceeding.

Create `content/<project>/` directory if it does not exist.

## Output → content/\<project\>/CONTENT_SPEC.md

Include:

- Core Idea (one sentence)
- Target Audience
- Intended Impact (what should change in reader)
- Key Arguments (3–5)
- Contrarian / Insight Angle
- Tone (e.g. analytical, narrative, sharp)
- Constraints (length, style)

## Rules

- Be explicit
- Avoid vague themes
- Ensure idea is arguable

## Anti-patterns

- multiple core ideas
- no clear audience
- generic insights
