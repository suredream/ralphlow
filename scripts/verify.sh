#!/usr/bin/env bash
set -Eeuo pipefail

# verify.sh
#
# Purpose:
# - Run validation commands
# - Save machine-readable and human-readable outputs into artifacts
#
# Usage:
#   scripts/verify.sh
#   scripts/verify.sh --loop-id LOOP_ID
#
# Optional config file:
#   scripts/verify.commands
#
# Example scripts/verify.commands:
#   npm test
#   npm run lint
#   npm run typecheck
#
#   # or
#   pytest -q
#   ruff check .
#
# Environment variables:
#   ARTIFACTS_DIR            default: artifacts

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ARTIFACTS_DIR="${ARTIFACTS_DIR:-artifacts}"
LOOP_ID=""

usage() {
  cat <<'EOF'
Usage:
  scripts/verify.sh [--loop-id LOOP_ID]

Behavior:
  - Reads validation commands from scripts/verify.commands if present
  - Otherwise auto-detects common commands
  - Writes artifacts/<loop_id>/verify/
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

VERIFY_DIR="$ARTIFACTS_DIR/$LOOP_ID/verify"
mkdir -p "$VERIFY_DIR"

COMMANDS_FILE="scripts/verify.commands"
SUMMARY_FILE="$VERIFY_DIR/verify_summary.json"
TEXT_SUMMARY="$VERIFY_DIR/verify_summary.txt"

detect_commands() {
  local cmds=()

  if [[ -f "$COMMANDS_FILE" ]]; then
    while IFS= read -r line; do
      [[ -z "${line// }" ]] && continue
      [[ "$line" =~ ^[[:space:]]*# ]] && continue
      cmds+=("$line")
    done < "$COMMANDS_FILE"
  else
    # Lightweight auto-detection
    if [[ -f "package.json" ]]; then
      if grep -q '"test"' package.json; then cmds+=("npm test"); fi
      if grep -q '"lint"' package.json; then cmds+=("npm run lint"); fi
      if grep -q '"typecheck"' package.json; then cmds+=("npm run typecheck"); fi
      if grep -q '"build"' package.json; then cmds+=("npm run build"); fi
    fi

    if [[ -f "pytest.ini" || -d "tests" || -f "pyproject.toml" ]]; then
      if command -v pytest >/dev/null 2>&1; then cmds+=("pytest -q"); fi
      if command -v ruff >/dev/null 2>&1; then cmds+=("ruff check ."); fi
      if command -v mypy >/dev/null 2>&1; then cmds+=("mypy ."); fi
    fi

    if [[ -f "Cargo.toml" ]]; then
      cmds+=("cargo test")
      cmds+=("cargo check")
      if command -v cargo >/dev/null 2>&1; then
        cmds+=("cargo fmt --check")
      fi
    fi

    if [[ -f "go.mod" ]]; then
      cmds+=("go test ./...")
      cmds+=("go vet ./...")
    fi
  fi

  if [[ "${#cmds[@]}" -gt 0 ]]; then
    printf "%s\n" "${cmds[@]}"
  fi
}

COMMANDS=()
while IFS= read -r line; do
  [[ -n "$line" ]] && COMMANDS+=("$line")
done < <(detect_commands)

if [[ "${#COMMANDS[@]}" -eq 0 ]]; then
  cat > "$TEXT_SUMMARY" <<EOF
No verification commands found.

You can define them explicitly in:
  scripts/verify.commands
EOF

  cat > "$SUMMARY_FILE" <<EOF
{
  "status": "no_commands",
  "commands_run": [],
  "passed": 0,
  "failed": 0
}
EOF

  echo "No verification commands found."
  exit 0
fi

passed=0
failed=0

echo "Verification loop: $LOOP_ID" > "$TEXT_SUMMARY"
echo >> "$TEXT_SUMMARY"

for idx in "${!COMMANDS[@]}"; do
  cmd="${COMMANDS[$idx]}"
  out_file="$VERIFY_DIR/cmd_$((idx+1)).log"

  {
    echo "=== COMMAND $((idx+1)) ==="
    echo "$cmd"
    echo
  } | tee -a "$TEXT_SUMMARY"

  set +e
  bash -lc "$cmd" >"$out_file" 2>&1
  code=$?
  set -e

  if [[ $code -eq 0 ]]; then
    status="pass"
    passed=$((passed+1))
  else
    status="fail"
    failed=$((failed+1))
  fi

  {
    echo "status=$status exit_code=$code"
    echo "log_file=$(basename "$out_file")"
    echo
  } | tee -a "$TEXT_SUMMARY"
done

overall_status="pass"
if [[ $failed -gt 0 ]]; then
  overall_status="fail"
fi

cat > "$SUMMARY_FILE" <<EOF
{
  "status": "$overall_status",
  "commands_run": ${#COMMANDS[@]},
  "passed": $passed,
  "failed": $failed
}
EOF

echo "Overall verification status: $overall_status" | tee -a "$TEXT_SUMMARY"

if [[ "$overall_status" == "fail" ]]; then
  exit 1
fi
