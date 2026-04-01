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
check ".gemini host mount exists" test -d /var/tmp/.gemini

# Debugging: show contents of mount point
echo "Contents of /var/tmp/.gemini:"
ls -la /var/tmp/.gemini || echo "/var/tmp/.gemini listing failed"

check ".gemini is directory" test -d $HOME/.gemini
check ".gemini is not a link" test ! -h $HOME/.gemini
check "GEMINI.md is linked" test -h $HOME/.gemini/GEMINI.md
check "GEMINI.md link target is correct" test "$(readlink $HOME/.gemini/GEMINI.md)" == "/var/tmp/.gemini/GEMINI.md"

# Report results
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
