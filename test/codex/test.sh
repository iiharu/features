#!/bin/bash

set -e

source dev-container-features-test-lib

check "codex is in path" command -v codex
check "codex reports version" codex --version

reportResults
