#!/bin/bash

set -e

source dev-container-features-test-lib

check "codex is in path" command -v codex
check "codex reports version" codex --version
check "codex config is mounted" test -f /etc/codex/config.toml
check "codex config is readable" grep -q . /etc/codex/config.toml

reportResults
