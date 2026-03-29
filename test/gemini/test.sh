#!/bin/bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check "node is available" node -v
check "npm is available" npm -v
check "npx is available" npx -v
# To avoid side effects (file creation/rename errors) in mounted .gemini directory
# check "gemini is available" gemini --version
check "gemini is in path" command -v gemini
check ".gemini is mounted" test -d /var/tmp/.gemini
check ".gemini is link" test -h $HOME/.gemini
check ".gemini is linked" test "$(readlink $HOME/.gemini)" == "/var/tmp/.gemini"

# Report results
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
