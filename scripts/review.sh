#!/usr/bin/env bash
set -Eeuo pipefail

# review.sh
#
# Purpose:
# - Perform lightweight rule-based review against specs/CURRENT.md and artifacts
# - Detect scope drift, unexpected spec edits, oversized change set, missing verification
#
# Usage:
#   scripts/review.sh
#   scripts/review.sh --loop-id LOOP_ID
#
# Environment variables:
#   ARTIFACTS_DIR            default: artifacts
#   SPECS_DIR                default: specs
#   MAX_CHANGED_FILES        default: 12
#   MAX_DIFF_LINES           default: 600

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ARTIFACTS_DIR="${ARTIFACTS_DIR:-artifacts}"
SPECS_DIR="${SPECS_DIR:-specs}"
MAX_CHANGED_FILES="${MAX_CHANGED_FILES:-12}"
MAX_DIFF_LINES="${MAX_DIFF_LINES:-600}"

LOOP_ID=""

usage() {
  cat <<'EOF'
Usage:
  scripts/review.sh [--loop-id LOOP_ID]

Behavior:
  - Reads artifacts/<loop_id>/repo/changed-files.txt if present
  - Otherwise computes changed files from git diff
  - Compares changed files with Allowed Paths in specs/CURRENT.md
  - Writes artifacts/<loop_id>/review/review.md and review.json
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --loop-id)
      LOOP_ID="${2:-}"
      [[ -n "$LOOP_ID" ]] || { echo "Error: --loop-id requires a value" >&2; exit 1; }
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$LOOP_ID" ]]; then
  if [[ -f "$ARTIFACTS_DIR/latest_loop_id" ]]; then
    LOOP_ID="$(cat "$ARTIFACTS_DIR/latest_loop_id")"
  else
    echo "Error: no loop id provided and artifacts/latest_loop_id not found" >&2
    exit 1
  fi
fi

CURRENT_FILE="$SPECS_DIR/CURRENT.md"
[[ -f "$CURRENT_FILE" ]] || { echo "Error: missing $CURRENT_FILE" >&2; exit 1; }

REVIEW_DIR="$ARTIFACTS_DIR/$LOOP_ID/review"
REPO_DIR="$ARTIFACTS_DIR/$LOOP_ID/repo"
VERIFY_DIR="$ARTIFACTS_DIR/$LOOP_ID/verify"
mkdir -p "$REVIEW_DIR" "$REPO_DIR"

CHANGED_FILES_FILE="$REPO_DIR/changed-files.txt"
DIFF_FILE="$REPO_DIR/git-diff.patch"

if [[ ! -f "$CHANGED_FILES_FILE" ]]; then
  git diff --name-only > "$CHANGED_FILES_FILE" || true
fi

if [[ ! -f "$DIFF_FILE" ]]; then
  git diff > "$DIFF_FILE" || true
fi

# Extract Allowed Paths from CURRENT.md
# Expected format:
#   ## Allowed Paths
#   - path/a
#   - path/b
extract_allowed_paths() {
  awk '
    BEGIN { in_section=0 }
    /^##[[:space:]]+Allowed Paths/ { in_section=1; next }
    /^##[[:space:]]+/ && in_section==1 { exit }
    in_section==1 {
      line=$0
      sub(/^[[:space:]]*-[[:space:]]*/, "", line)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", line)
      if (line != "") print line
    }
  ' "$CURRENT_FILE"
}

mapfile -t ALLOWED_PATHS < <(extract_allowed_paths)

is_allowed() {
  local file="$1"
  if [[ "${#ALLOWED_PATHS[@]}" -eq 0 ]]; then
    return 0
  fi

  for p in "${ALLOWED_PATHS[@]}"; do
    # Exact match
    if [[ "$file" == "$p" ]]; then
      return 0
    fi
    # Directory prefix match
    if [[ "$file" == "$p/"* ]]; then
      return 0
    fi
  done
  return 1
}

mapfile -t CHANGED_FILES < "$CHANGED_FILES_FILE"

critical=()
medium=()
minor=()

changed_count=0
unexpected_count=0

for f in "${CHANGED_FILES[@]}"; do
  [[ -z "$f" ]] && continue
  changed_count=$((changed_count+1))

  if ! is_allowed "$f"; then
    unexpected_count=$((unexpected_count+1))
    medium+=("Changed file outside Allowed Paths: $f")
  fi
done

# Spec modification checks
for spec_file in "$SPECS_DIR/SPEC.md" "$SPECS_DIR/ARCH.md" "$SPECS_DIR/TASKS.md" "$SPECS_DIR/RULES.md" "$SPECS_DIR/CURRENT.md"; do
  rel="${spec_file#$ROOT_DIR/}"
  if grep -qxF "$rel" "$CHANGED_FILES_FILE" 2>/dev/null; then
    critical+=("Spec file changed during execution: $rel")
  fi
done

# Verify status
verify_status="missing"
if [[ -f "$VERIFY_DIR/verify_summary.json" ]]; then
  if grep -q '"status": "pass"' "$VERIFY_DIR/verify_summary.json"; then
    verify_status="pass"
  elif grep -q '"status": "fail"' "$VERIFY_DIR/verify_summary.json"; then
    verify_status="fail"
  else
    verify_status="other"
  fi
fi

if [[ "$verify_status" == "fail" ]]; then
  critical+=("Verification failed.")
elif [[ "$verify_status" == "missing" ]]; then
  medium+=("Verification summary missing.")
fi

# Diff size check
diff_lines=0
if [[ -f "$DIFF_FILE" ]]; then
  diff_lines="$(wc -l < "$DIFF_FILE" | tr -d ' ')"
fi

if (( changed_count > MAX_CHANGED_FILES )); then
  medium+=("Changed file count too high: $changed_count > $MAX_CHANGED_FILES")
fi

if (( diff_lines > MAX_DIFF_LINES )); then
  medium+=("Diff too large: $diff_lines lines > $MAX_DIFF_LINES")
fi

if (( changed_count == 0 )); then
  minor+=("No changed files detected.")
fi

decision="approve"
if (( ${#critical[@]} > 0 )); then
  decision="reject"
elif (( ${#medium[@]} > 0 )); then
  decision="needs_attention"
fi

REPORT_MD="$REVIEW_DIR/review.md"
REPORT_JSON="$REVIEW_DIR/review.json"

{
  echo "# Review Report"
  echo
  echo "## Summary"
  echo
  echo "- loop_id: $LOOP_ID"
  echo "- decision: $decision"
  echo "- verify_status: $verify_status"
  echo "- changed_files: $changed_count"
  echo "- diff_lines: $diff_lines"
  echo

  echo "## Critical Issues"
  echo
  if (( ${#critical[@]} == 0 )); then
    echo "- None"
  else
    for item in "${critical[@]}"; do
      echo "- $item"
    done
  fi
  echo

  echo "## Medium Issues"
  echo
  if (( ${#medium[@]} == 0 )); then
    echo "- None"
  else
    for item in "${medium[@]}"; do
      echo "- $item"
    done
  fi
  echo

  echo "## Minor Issues"
  echo
  if (( ${#minor[@]} == 0 )); then
    echo "- None"
  else
    for item in "${minor[@]}"; do
      echo "- $item"
    done
  fi
  echo

  echo "## Allowed Paths"
  echo
  if (( ${#ALLOWED_PATHS[@]} == 0 )); then
    echo "- None declared"
  else
    for p in "${ALLOWED_PATHS[@]}"; do
      echo "- $p"
    done
  fi
} > "$REPORT_MD"

cat > "$REPORT_JSON" <<EOF
{
  "loop_id": "$LOOP_ID",
  "decision": "$decision",
  "verify_status": "$verify_status",
  "changed_files": $changed_count,
  "diff_lines": $diff_lines,
  "critical_count": ${#critical[@]},
  "medium_count": ${#medium[@]},
  "minor_count": ${#minor[@]}
}
EOF

echo "Review completed: $decision"
echo "Report: $REPORT_MD"

if [[ "$decision" == "reject" ]]; then
  exit 1
fi
