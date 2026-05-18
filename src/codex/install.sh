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

ARCH="$(uname -m)"
case "${ARCH}" in
    x86_64)
        TARGET="x86_64-unknown-linux-musl"
        ;;
    aarch64|arm64)
        TARGET="aarch64-unknown-linux-musl"
        ;;
    *)
        echo "Unsupported architecture: ${ARCH}"
        exit 1
        ;;
esac

CODEX_TAR="codex-${TARGET}.tar.gz"
CODEX_BIN="codex-${TARGET}"
CODEX_URL="https://github.com/openai/codex/releases/latest/download/${CODEX_TAR}"
TMP_DIR="$(mktemp -d)"

cleanup() {
    rm -rf "${TMP_DIR}"
}
trap cleanup EXIT INT TERM

curl -fsSL "${CODEX_URL}" -o "${TMP_DIR}/${CODEX_TAR}"
tar -xzf "${TMP_DIR}/${CODEX_TAR}" -C "${TMP_DIR}"
install -m 0755 "${TMP_DIR}/${CODEX_BIN}" /usr/local/bin/codex

codex --version
