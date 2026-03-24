#!/usr/bin/env bash
set -Eeuo pipefail

# suggest_current_patch.sh
#
# Purpose:
# - Generate specs/CURRENT_PATCH.md based on REVIEW.json
# - Provide human-readable guidance to shrink CURRENT.md

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

REVIEW_JSON="specs/REVIEW.json"
PATCH_FILE="specs/CURRENT_PATCH.md"

if [[ ! -f "$REVIEW_JSON" ]]; then
  echo "Missing specs/REVIEW.json" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq required" >&2
  exit 1
fi

should_shrink="$(jq -r '.current_patch.should_shrink // false' "$REVIEW_JSON")"

if [[ "$should_shrink" != "true" ]]; then
  echo "No CURRENT patch needed."
  exit 0
fi

{
  echo "# CURRENT PATCH SUGGESTION"
  echo
  echo "## Reason"
  jq -r '.current_patch.reason // "No reason provided."' "$REVIEW_JSON"
  echo

  echo "## Suggested In Scope"
  jq -r '.current_patch.suggested_in_scope[]? | "- \(.)"' "$REVIEW_JSON"
  echo

  echo "## Suggested Out of Scope"
  jq -r '.current_patch.suggested_out_of_scope[]? | "- \(.)"' "$REVIEW_JSON"
  echo

  echo "## Suggested Allowed Paths"
  jq -r '.current_patch.suggested_allowed_paths[]? | "- \(.)"' "$REVIEW_JSON"
} > "$PATCH_FILE"

echo "📝 Generated: $PATCH_FILE"
