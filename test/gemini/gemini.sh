#!/bin/bash

set -e

# Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "node is available" node -v
check "npm is available" npm -v
check "gemini is in path" command -v gemini

# Report results
reportResults
