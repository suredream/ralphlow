---
name: build-review
description: Review all spec files and produce both human-readable analysis and a machine-readable specs/REVIEW.json for execution gating.
---

# Review Specs (Enhanced)

You must perform a full consistency and execution-readiness review of:

- init_idea.md (if present)
- specs/SPEC.md
- specs/ARCH.md
- specs/TASKS.md
- specs/RULES.md
- specs/CURRENT.md

---

## Output Requirements (MANDATORY)

You MUST produce:

1. Human-readable review (in chat)
2. Write a machine-readable file:

```text
specs/REVIEW.json
````

---

## REVIEW.json Schema

You MUST follow this structure:

```json
{
  "decision": "approve | needs_attention | reject",
  "summary": "",
  "critical": [],
  "medium": [],
  "minor": [],
  "constraints": {
    "strict_scope": true,
    "max_files": 8,
    "max_diff_lines": 400,
    "forbidden_paths": [],
    "extra_required_checks": [],
    "notes": []
  },
  "recommended_actions": [],
  "current_patch": {
    "should_shrink": false,
    "reason": "",
    "suggested_in_scope": [],
    "suggested_out_of_scope": [],
    "suggested_allowed_paths": []
  }
}
```

---

## Decision Rules

### decision = "reject"

Use when:

* CURRENT is not executable
* SPEC and ARCH conflict
* TASKS cannot be implemented

### decision = "needs_attention"

Use when:

* CURRENT is too large
* Allowed paths too broad
* Scope unclear

### decision = "approve"

Use when:

* CURRENT is small, clear, and executable

---

## Constraint Generation Rules

* If CURRENT is large → reduce max_files (e.g. 5–8)
* If risk exists → add forbidden_paths
* If validation weak → add extra_required_checks
* Always set strict_scope = true unless explicitly safe

---

## CURRENT Patch Rules

If CURRENT is too large:

```json
"current_patch": {
  "should_shrink": true
}
```

And include:

* minimal in-scope slice
* explicit out-of-scope
* narrow allowed paths

---

## Critical Thinking Requirements

You must:

* detect spec drift
* detect architecture violations
* detect oversized tasks
* detect unbounded CURRENT
* detect missing acceptance criteria

---

## Anti-Patterns (DO NOT DO)

* Do not skip JSON generation
* Do not output incomplete schema
* Do not mark approve if CURRENT is large
* Do not invent fake constraints without reasoning

---

## Execution Checklist

Before finishing:

* [ ] REVIEW.json created
* [ ] decision is valid
* [ ] constraints are meaningful
* [ ] CURRENT slice evaluated
* [ ] patch suggestions included if needed
