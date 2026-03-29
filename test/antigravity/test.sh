#!/bin/bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check ".gitconfig is mounted" test -f /var/tmp/.gitconfig
check ".gitconfig is link" test -h $HOME/.gitconfig
check ".gitconfig is linked" test "$(readlink $HOME/.gitconfig)" == "/var/tmp/.gitconfig"
check ".bash_aliases is created" test -f $HOME/.bash_aliases
check "code alias is set" grep -q "alias code='command antigravity'" $HOME/.bash_aliases

# Report results
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
