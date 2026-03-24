#!/usr/bin/env bash
set -Eeuo pipefail

# apply_review_gate.sh
#
# Purpose:
# - Read specs/REVIEW.json
# - Fail fast if decision=reject
# - Generate specs/REVIEW_CONSTRAINTS.md for execution
#
# Usage:
#   scripts/apply_review_gate.sh

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

REVIEW_JSON="specs/REVIEW.json"
REVIEW_CONSTRAINTS="specs/REVIEW_CONSTRAINTS.md"

if [[ ! -f "$REVIEW_JSON" ]]; then
  echo "No specs/REVIEW.json found. Skipping review gate."
  exit 0
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required for apply_review_gate.sh" >&2
  exit 1
fi

decision="$(jq -r '.decision // "approve"' "$REVIEW_JSON")"

echo "Review decision: $decision"

if [[ "$decision" == "reject" ]]; then
  echo "❌ Review gate blocked execution (decision=reject)"
  jq -r '.summary // "No summary provided."' "$REVIEW_JSON"
  exit 1
fi

# Extract constraints
strict_scope="$(jq -r '.constraints.strict_scope // true' "$REVIEW_JSON")"
max_files="$(jq -r '.constraints.max_files // 9999' "$REVIEW_JSON")"
max_diff_lines="$(jq -r '.constraints.max_diff_lines // 99999' "$REVIEW_JSON")"

{
  echo "# REVIEW CONSTRAINTS"
  echo
  echo "## Decision"
  echo "$decision"
  echo
  echo "## Execution Constraints"
  echo "- Strict scope mode: $strict_scope"
  echo "- Max files changed: $max_files"
  echo "- Max diff lines: $max_diff_lines"

  if jq -e '.constraints.forbidden_paths | length > 0' "$REVIEW_JSON" >/dev/null; then
    echo "- Forbidden paths:"
    jq -r '.constraints.forbidden_paths[] | "  - \(.)"' "$REVIEW_JSON"
  fi

  if jq -e '.constraints.extra_required_checks | length > 0' "$REVIEW_JSON" >/dev/null; then
    echo
    echo "## Extra Required Checks"
    jq -r '.constraints.extra_required_checks[] | "- \(.)"' "$REVIEW_JSON"
  fi

  if jq -e '.constraints.notes | length > 0' "$REVIEW_JSON" >/dev/null; then
    echo
    echo "## Risk Notes"
    jq -r '.constraints.notes[] | "- \(.)"' "$REVIEW_JSON"
  fi

  if jq -e '.current_patch.should_shrink == true' "$REVIEW_JSON" >/dev/null; then
    echo
    echo "## Current Slice Adjustment"
    jq -r '.current_patch.reason | "- Reason: \(.)"' "$REVIEW_JSON"

    if jq -e '.current_patch.suggested_in_scope | length > 0' "$REVIEW_JSON" >/dev/null; then
      echo "- Effective in-scope:"
      jq -r '.current_patch.suggested_in_scope[] | "  - \(.)"' "$REVIEW_JSON"
    fi

    if jq -e '.current_patch.suggested_out_of_scope | length > 0' "$REVIEW_JSON" >/dev/null; then
      echo "- Effective out-of-scope:"
      jq -r '.current_patch.suggested_out_of_scope[] | "  - \(.)"' "$REVIEW_JSON"
    fi

    if jq -e '.current_patch.suggested_allowed_paths | length > 0' "$REVIEW_JSON" >/dev/null; then
      echo "- Effective allowed paths:"
      jq -r '.current_patch.suggested_allowed_paths[] | "  - \(.)"' "$REVIEW_JSON"
    fi
  fi
} > "$REVIEW_CONSTRAINTS"

echo "✅ Review constraints generated: $REVIEW_CONSTRAINTS"
