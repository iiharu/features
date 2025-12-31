#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'antigravity' Feature with no options.
#
# For more information, see: https://github.com/devcontainers/cli/blob/main/docs/features/test.md
#
# Eg:
# {
#    "image": "<..some-base-image...>",
#    "features": {
#      "antigravity": {}
#    },
#    "remoteUser": "root"
# }
#
# Thus, the value of all options will fall back to the default value in 
# the Feature's 'devcontainer-feature.json'.
# For the 'antigravity' feature, that means the default favorite greeting is 'hey'.
#
# These scripts are run as 'root' by default. Although that can be changed
# with the '--remote-user' flag.
# 
# This test can be run with the following command:
#
#    HOME=$(pwd)/test/antigravity/fixtures devcontainer features test \
#                   --features antigravity \
#                   --remote-user root \
#                   --skip-scenarios   \
#                   --base-image mcr.microsoft.com/devcontainers/base:ubuntu \
#                   /path/to/this/repo

set -e

# Optional: Import test library bundled with the devcontainer CLI
# See https://github.com/devcontainers/cli/blob/HEAD/docs/features/test.md#dev-container-features-test-lib
# Provides the 'check' and 'reportResults' commands.
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib. Syntax is...
# check <LABEL> <cmd> [args...]
check ".gitconfig is mounted" test -f /var/tmp/.gitconfig
check ".gitconfig is linked" test -h $HOME/.gitconfig
# TODO: confirm .gitconfig contents
check ".gemini is mounted" test -d /var/tmp/.gemini
check ".gemini is linked" test -h $HOME/.gemini
# TODO: confirm .gitconfig contents
check ".bash_aliases is created" test -f $HOME/.bash_aliases
# TODO: confirm .gitconfig contents

# Report results
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
