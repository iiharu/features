#!/bin/bash

set -e

source dev-container-features-test-lib

check "codex is in path" command -v codex
check "codex reports version" codex --version
check "codex config is mounted" test -f /etc/codex/config.toml
check "codex config is readable" grep -q . /etc/codex/config.toml
check "CODEX_HOME is configured" test "${CODEX_HOME}" = "/home/vscode/.codex"
check "CODEX_HOME exists" test -d "${CODEX_HOME}"
check "CODEX_HOME is writable" test -w "${CODEX_HOME}"
check "CODEX_HOME owner is remote user" test "$(stat -c '%U' "${CODEX_HOME}")" = "$(id -un)"
check "CODEX_HOME permissions are user-private" test "$(stat -c '%a' "${CODEX_HOME}")" = "700"

reportResults
