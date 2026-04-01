#!/bin/bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "node is available" node -v
check "npm is available" npm -v
check "npx is available" npx -v
check "gemini is in path" command -v gemini

echo "--- Debugging Information ---"
echo "Current user: $(id)"
echo "HOME: $HOME"

echo "Contents of host mount point (/var/tmp/.gemini):"
ls -la /var/tmp/.gemini || echo "/var/tmp/.gemini listing failed"

echo "Contents of container .gemini directory ($HOME/.gemini):"
ls -la $HOME/.gemini || echo "$HOME/.gemini listing failed"

if [ -L "$HOME/.gemini/GEMINI.md" ]; then
    echo "GEMINI.md link points to: $(readlink $HOME/.gemini/GEMINI.md)"
else
    echo "GEMINI.md is NOT a symbolic link"
fi
echo "------------------------------"

check ".gemini host mount exists" test -d /var/tmp/.gemini
check ".gemini is directory" test -d $HOME/.gemini
check ".gemini is not a link" test ! -h $HOME/.gemini
check "GEMINI.md is linked" test -h $HOME/.gemini/GEMINI.md
check "GEMINI.md link target is correct" test "$(readlink $HOME/.gemini/GEMINI.md)" == "/var/tmp/.gemini/GEMINI.md"

# Report results
reportResults
