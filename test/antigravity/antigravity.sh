#!/bin/bash

# This test file will be executed against one of the scenarios devcontainer.json test that
# includes the 'antigravity' feature.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check "node-exists" node -v
check "npm-exists" npm -v
# Ensure npm version is >= 11.10.0
check "npm-version-sufficient" [ "$(printf '%s\n' "11.10.0" "$(npm -v)" | sort -V | head -n1)" = "11.10.0" ]
check "gemini-exists" gemini --version
check "gemini-executable" command -v gemini

# Report results
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
