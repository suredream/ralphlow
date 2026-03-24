# CLAUDE.md — Content Writer Mode

## Purpose

This workflow converts structured ideas into high-quality written content (e.g., 公众号文章、长文、观点表达).

The goal is NOT to brainstorm endlessly, but to:

- express a clear core idea
- build a logical argument flow
- produce readable, structured content
- iteratively improve clarity and impact

---

## Multi-Project Structure

This directory manages multiple content projects under `content/`:

```
content/
  RULES.md              ← workflow-level rules, shared across all projects
  PROJECTS.md           ← active project index
  <project-name>/       ← one subdirectory per content project
    CONTENT_SPEC.md
    STRUCTURE.md
    DRAFT.md
    REVIEW.json
  archive/              ← archived projects (published or abandoned)
    <project-name>/
```

---

## Active Project

There is no global state file. The current project is determined per conversation.

### Declaring the active project

At the start of a conversation, declare which project you are working on:

- English: `project: <name>` (e.g. `project: startup-essay`)
- 中文：`项目：<name>`（如 `项目：startup-essay`）

Skills use this declaration automatically for the rest of the conversation.

### Project naming rules

- Allowed characters: lowercase letters, digits, hyphens (`a-z0-9-`)
- No spaces, no uppercase
- Max 32 characters
- Reserved: `archive` (cannot be used as a project name)
- Examples: `ai-agents-2025`, `startup-essay`, `product-launch`

### Skill resolution priority

1. **Explicit parameter**: `/write-draft startup-essay` → uses `startup-essay`, overrides declaration
2. **Conversation declaration**: uses the project declared at conversation start
3. **Fallback**: if neither is present, the skill must ask the user — do NOT assume

### Multiple agents

Each agent conversation declares its own project independently — no coordination needed. Two agents declaring different projects operate on different subdirectories with no conflict.

---

## Reading Order

Before doing meaningful work, read in this order:

### Workflow-level (always)
1. `CLAUDE.md`
2. `content/RULES.md`
3. `content/PROJECTS.md` ← identify active projects; confirm which project you are working on

### Project-level (substituting `<project>` with the active project name)
4. `content/<project>/CONTENT_SPEC.md`
5. `content/<project>/STRUCTURE.md`
6. `content/<project>/DRAFT.md`

Do NOT read files under `content/archive/` unless explicitly asked.

---

## Mode Constraints

- Do NOT switch into planning or coding behavior
- Do NOT expand scope beyond defined structure
- Do NOT introduce new ideas not aligned with CONTENT_SPEC
- Do NOT overwrite entire draft unless explicitly required
- Do NOT operate on multiple projects in one loop unless explicitly instructed

---

## Core Objective

Each loop must improve ONE of:

- clarity of core idea
- logical flow
- readability
- structure coherence
- persuasive strength

---

## Execution Discipline

If EXECUTION_DECISION.md exists:

- STRICTLY follow mode (poc / build)
- obey scope constraints
- do not over-expand

---

## Anti-Patterns

- writing generic content
- repeating ideas with no new value
- introducing unrelated concepts
- overly long paragraphs with weak structure
- "AI-style" filler language

---

## Writing Principles

- one paragraph = one idea
- each section must have a purpose
- prefer concrete over abstract
- remove redundancy aggressively
- clarity > cleverness

---

## Archive Policy

Archive a project when:
- the content is published
- the project is abandoned
- it has had no activity for 30+ days with no recovery plan

To archive:
1. `mv content/<name>/ content/archive/<name>/`
2. Update `content/PROJECTS.md`: move the entry from Active to Archive, add reason and date.

---

## Available Commands

```
/write-spec [project]    — define content spec → CONTENT_SPEC.md
/write-struct [project]  — generate article structure → STRUCTURE.md
/write-draft [project]   — write or extend draft → DRAFT.md
/write-logic [project]   — refine logical flow → DRAFT.md
/write-review [project]  — evaluate content quality → REVIEW.json
```

`[project]` is optional. If omitted, the skill uses the project declared in the current conversation.

---

## Stop Conditions

Stop and refocus if:

- multiple ideas are mixed
- structure is unclear
- draft becomes too long without clarity
- CURRENT scope is violated
- active project is ambiguous
