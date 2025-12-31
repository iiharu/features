#!/bin/sh

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

FEATURE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# override shim, it redirects to antigravity
cp -f "${FEATURE_DIR}/bin/code" /usr/local/bin/
chmod +rx /usr/local/bin/code

exit $?
