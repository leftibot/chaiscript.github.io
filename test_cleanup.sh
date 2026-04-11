#!/bin/bash
# Regression test for issue #4: website cleanup
# Checks that outdated/unreachable links and buttons have been removed

FAIL=0

# Test 1: Dashboard button should not exist in header
if grep -q "dashboard" _includes/header.html; then
  echo "FAIL: Dashboard button still present in header.html"
  FAIL=1
else
  echo "PASS: Dashboard button removed from header.html"
fi

# Test 2: Discourse Forums button should not exist in header
if grep -q "discourse.chaiscript.com" _includes/header.html; then
  echo "FAIL: Discourse Forums button still present in header.html"
  FAIL=1
else
  echo "PASS: Discourse Forums button removed from header.html"
fi

# Test 3: Discourse link should not exist in support page
if grep -q "discourse.chaiscript.com" support.html; then
  echo "FAIL: Discourse link still present in support.html"
  FAIL=1
else
  echo "PASS: Discourse link removed from support.html"
fi

# Test 4: Google+ widget should not exist (service shut down in 2019)
if grep -q "g-plusone" _includes/header.html; then
  echo "FAIL: Google+ widget still present in header.html"
  FAIL=1
else
  echo "PASS: Google+ widget removed from header.html"
fi

# Test 5: Gitter chat widget should not exist (service deprecated)
if grep -q "gitter.im" _includes/common.html; then
  echo "FAIL: Gitter chat widget still present in common.html"
  FAIL=1
else
  echo "PASS: Gitter chat widget removed from common.html"
fi

# Test 6: Google Analytics (Universal Analytics) was sunset July 2023
if grep -q "google-analytics.com/analytics.js" _includes/header.html; then
  echo "FAIL: Deprecated Universal Analytics still present in header.html"
  FAIL=1
else
  echo "PASS: Deprecated Universal Analytics removed from header.html"
fi

exit $FAIL
