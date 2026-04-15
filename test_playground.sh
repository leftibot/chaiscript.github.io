#!/bin/bash
# Regression tests for the ChaiScript website build artifacts.
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

# 4. Grammar railroad diagram workflow exists and runs hourly
assert_file_exists ".github/workflows/update-grammar.yml"
assert_file_contains ".github/workflows/update-grammar.yml" "schedule"
assert_file_contains ".github/workflows/update-grammar.yml" "cron:"
assert_file_contains ".github/workflows/update-grammar.yml" "chaiscript.ebnf"
assert_file_contains ".github/workflows/update-grammar.yml" "ChaiScript/ChaiScript"
assert_file_contains ".github/workflows/update-grammar.yml" "rr-webapp"

# 5. Grammar page exists with required elements
assert_file_exists "grammar.html"
assert_file_contains "grammar.html" "header.html"
assert_file_contains "grammar.html" "railroad"

# 6. Navigation includes grammar link
assert_file_contains "_includes/header.html" "grammar"

# 7. Playground has examples sidebar
assert_file_contains "playground.html" "examples-sidebar"
assert_file_contains "playground.html" "example-item"

# 8. Playground has live execution with debounce
assert_file_contains "playground.html" "debounceTimer"
assert_file_contains "playground.html" "addEventListener.*input"

# 9. Playground engine is reset between runs (issue #14)
assert_file_contains "playground.html" "resetEngine"
assert_file_contains "playground.html" "onAbort"

# 10. Playground catches and displays exceptions with detail (issue #14)
assert_file_contains "playground.html" "chai-output-error"
assert_file_contains "playground.html" "engineAborted"

# 11. Playground examples cover major ChaiScript features
assert_file_contains "playground.html" "Variables &amp; Types"
assert_file_contains "playground.html" "Functions"
assert_file_contains "playground.html" "Loops"
assert_file_contains "playground.html" "Strings"
assert_file_contains "playground.html" "Vectors &amp; Maps"
assert_file_contains "playground.html" "Classes"
assert_file_contains "playground.html" "Lambdas"
assert_file_contains "playground.html" "Error Handling"

if [ "$FAIL" -ne 0 ]; then
  echo ""
  echo "RESULT: SOME TESTS FAILED"
  exit 1
fi

echo ""
echo "RESULT: ALL TESTS PASSED"
exit 0
