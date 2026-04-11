#!/bin/bash
# Regression test for issue #6: WASM playground
# Validates that all required files exist and contain expected content.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
FAIL=0

assert_file_exists() {
  if [ ! -f "$REPO_ROOT/$1" ]; then
    echo "FAIL: $1 does not exist"
    FAIL=1
  else
    echo "PASS: $1 exists"
  fi
}

assert_file_contains() {
  if ! grep -q "$2" "$REPO_ROOT/$1" 2>/dev/null; then
    echo "FAIL: $1 does not contain '$2'"
    FAIL=1
  else
    echo "PASS: $1 contains '$2'"
  fi
}

# 1. GitHub Actions workflow exists and runs hourly
assert_file_exists ".github/workflows/update-wasm.yml"
assert_file_contains ".github/workflows/update-wasm.yml" "schedule"
assert_file_contains ".github/workflows/update-wasm.yml" "cron:"
assert_file_contains ".github/workflows/update-wasm.yml" "wasm-latest"
assert_file_contains ".github/workflows/update-wasm.yml" "ChaiScript/ChaiScript"

# 2. Playground page exists with required elements
assert_file_exists "playground.html"
assert_file_contains "playground.html" "chaiscript.js"
assert_file_contains "playground.html" "Module"
assert_file_contains "playground.html" "header.html"

# 3. Navigation includes playground link
assert_file_contains "_includes/header.html" "playground"

if [ "$FAIL" -ne 0 ]; then
  echo ""
  echo "RESULT: SOME TESTS FAILED"
  exit 1
fi

echo ""
echo "RESULT: ALL TESTS PASSED"
exit 0
