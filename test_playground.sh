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

# 4. WASM build includes C++ exception support (issue #8)
#    Without -sDISABLE_EXCEPTION_CATCHING=0, any C++ exception (including those
#    used internally by ChaiScript during function definition) calls abort().
assert_file_contains "playground/chaiscript.js" "___cxa_begin_catch"
assert_file_contains "playground/chaiscript.js" "___cxa_end_catch"

# Verify ___cxa_throw throws instead of calling abort()
CXA_THROW_BODY=$(grep -oP '___cxa_throw=\(ptr,type,destructor\)=>\{[^}]+\}' "$REPO_ROOT/playground/chaiscript.js" 2>/dev/null)
if echo "$CXA_THROW_BODY" | grep -q 'abort()'; then
  echo "FAIL: playground/chaiscript.js ___cxa_throw calls abort() — missing exception support"
  FAIL=1
elif echo "$CXA_THROW_BODY" | grep -q 'throw'; then
  echo "PASS: playground/chaiscript.js ___cxa_throw throws instead of aborting"
else
  echo "FAIL: playground/chaiscript.js could not find ___cxa_throw definition"
  FAIL=1
fi

# 5. WASM eval works with function definitions (issue #8 regression)
if command -v node >/dev/null 2>&1; then
  NODE_OUTPUT=$(cd "$REPO_ROOT/playground" && node -e "
    global.__filename = process.cwd() + '/chaiscript.js';
    global.__dirname = process.cwd();
    global.Module = {
      print: function() {},
      printErr: function() {},
      onRuntimeInitialized: function() {
        try {
          Module.eval('def greet(name) { return \"Hello, \" + name + \"!\" }');
          var r = Module.evalString('greet(\"World\")');
          if (r === 'Hello, World!') {
            process.stdout.write('FUNC_DEF_OK');
          } else {
            process.stdout.write('WRONG_RESULT:' + r);
          }
        } catch(e) {
          process.stdout.write('ERROR:' + (e.message || e));
        }
        process.exit(0);
      },
      onAbort: function() { process.stdout.write('ABORTED'); process.exit(0); }
    };
    var vm = require('vm');
    var fs = require('fs');
    vm.runInThisContext(fs.readFileSync('./chaiscript.js', 'utf8'));
    setTimeout(function(){ process.stdout.write('TIMEOUT'); process.exit(0); }, 30000);
  " 2>/dev/null)
  if [ "$NODE_OUTPUT" = "FUNC_DEF_OK" ]; then
    echo "PASS: WASM eval handles function definitions"
  else
    echo "FAIL: WASM eval with function definition returned: $NODE_OUTPUT"
    FAIL=1
  fi
else
  echo "SKIP: node not available for WASM eval test"
fi

if [ "$FAIL" -ne 0 ]; then
  echo ""
  echo "RESULT: SOME TESTS FAILED"
  exit 1
fi

echo ""
echo "RESULT: ALL TESTS PASSED"
exit 0
