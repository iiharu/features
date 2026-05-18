#!/bin/bash

set -e

source dev-container-features-test-lib

check "codex is in path" command -v codex
check "codex reports version" codex --version
check "codex config is mounted" test -f /etc/codex/config.toml
check "codex config is readable" grep -q . /etc/codex/config.toml
check "CODEX_HOME is configured" test "${CODEX_HOME}" = "/var/tmp/codex"
check "CODEX_HOME exists" test -d /var/tmp/codex
check "CODEX_HOME is writable" test -w /var/tmp/codex
check "CODEX_HOME group is primary group" test "$(stat -c '%G' /var/tmp/codex)" = "$(id -gn)"
check "CODEX_HOME permissions are group-private" test "$(stat -c '%a' /var/tmp/codex)" = "770"

reportResults
