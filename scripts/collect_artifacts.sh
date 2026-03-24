#!/usr/bin/env bash
set -Eeuo pipefail

# collect_artifacts.sh
#
# Purpose:
# - Collect repo state and evidence after a Ralph run
# - Save changed files, git diff, status, logs pointers, summary placeholders
#
# Usage:
#   scripts/collect_artifacts.sh
#   scripts/collect_artifacts.sh --loop-id LOOP_ID
#
# Environment variables:
#   ARTIFACTS_DIR            default: artifacts
#   SPECS_DIR                default: specs

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ARTIFACTS_DIR="${ARTIFACTS_DIR:-artifacts}"
SPECS_DIR="${SPECS_DIR:-specs}"
LOOP_ID=""

usage() {
  cat <<'EOF'
Usage:
  scripts/collect_artifacts.sh [--loop-id LOOP_ID]

Behavior:
  - Uses latest loop id if none provided
  - Writes artifacts/<loop_id>/repo/*
  - Copies current spec files into artifacts/<loop_id>/final_specs/
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

LOOP_DIR="$ARTIFACTS_DIR/$LOOP_ID"
REPO_DIR="$LOOP_DIR/repo"
FINAL_SPECS_DIR="$LOOP_DIR/final_specs"
RUNTIME_DIR="$LOOP_DIR/runtime"

mkdir -p "$REPO_DIR" "$FINAL_SPECS_DIR" "$RUNTIME_DIR"

# Repo state
git status --short > "$REPO_DIR/git-status.txt" || true
git diff --name-only > "$REPO_DIR/changed-files.txt" || true
git diff > "$REPO_DIR/git-diff.patch" || true
git rev-parse HEAD > "$REPO_DIR/git-head-after.txt" || true

# Optional staged diff
git diff --cached > "$REPO_DIR/git-diff-staged.patch" || true

# File count summary
changed_count="$(grep -c '.' "$REPO_DIR/changed-files.txt" 2>/dev/null || echo 0)"
diff_lines="$(wc -l < "$REPO_DIR/git-diff.patch" | tr -d ' ' || echo 0)"

cat > "$REPO_DIR/repo-summary.txt" <<EOF
loop_id=$LOOP_ID
timestamp=$(date -Iseconds)
changed_files=$changed_count
diff_lines=$diff_lines
EOF

# Final spec snapshot
for f in SPEC.md ARCH.md TASKS.md RULES.md CURRENT.md; do
  if [[ -f "$SPECS_DIR/$f" ]]; then
    cp "$SPECS_DIR/$f" "$FINAL_SPECS_DIR/$f"
  fi
done

if [[ -f "CLAUDE.md" ]]; then
  cp "CLAUDE.md" "$FINAL_SPECS_DIR/CLAUDE.md"
fi

# Create an execution summary template if none exists
SUMMARY_FILE="$LOOP_DIR/execution_summary.md"
if [[ ! -f "$SUMMARY_FILE" ]]; then
  cat > "$SUMMARY_FILE" <<EOF
# Execution Summary

## Loop
- id: $LOOP_ID
- timestamp: $(date -Iseconds)

## Objective Attempted
- Fill this in after execution

## Files Changed
- See repo/changed-files.txt

## Validation
- See verify/ directory

## Review
- See review/ directory

## Open Risks
- Fill this in

## Next Recommended Step
- Fill this in
EOF
fi

echo "Artifacts collected for loop: $LOOP_ID"
echo "Repo evidence: $REPO_DIR"
echo "Final specs snapshot: $FINAL_SPECS_DIR"
