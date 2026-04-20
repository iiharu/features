#!/bin/bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "node is available" node -v
check "npm is available" npm -v
check "npx is available" npx -v
check "gemini is in path" command -v gemini

check ".gemini host mount exists" test -d /var/tmp/.gemini
check ".gemini is directory" test -d $HOME/.gemini
check ".gemini is not a link" test ! -h $HOME/.gemini
check "GEMINI.md is linked" test -h $HOME/.gemini/GEMINI.md
check "GEMINI.md link target is correct" test "$(readlink $HOME/.gemini/GEMINI.md)" == "/var/tmp/.gemini/GEMINI.md"
check ".env is linked" test -h $HOME/.gemini/.env
check ".env link target is correct" test "$(readlink $HOME/.gemini/.env)" == "/var/tmp/.gemini/.env"

check "GEMINI_TELEMETRY_OTLP_ENDPOINT is set" [ "$GEMINI_TELEMETRY_OTLP_ENDPOINT" = "http://host.docker.internal:4318" ]

# Report results
reportResults
