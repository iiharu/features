#!/bin/sh

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

mkdir -p /etc/codex
touch /etc/codex/config.toml

CODEX_HOME_DIR="/home/vscode/.codex"
CODEX_USER="${_REMOTE_USER:-root}"

mkdir -p "${CODEX_HOME_DIR}"
if ! id -u "${CODEX_USER}" >/dev/null 2>&1; then
    if id -u vscode >/dev/null 2>&1; then
        CODEX_USER="vscode"
    else
        CODEX_USER="root"
    fi
fi
CODEX_GROUP="$(id -gn "${CODEX_USER}")"
chown "${CODEX_USER}:${CODEX_GROUP}" "${CODEX_HOME_DIR}"
chmod 0700 "${CODEX_HOME_DIR}"
