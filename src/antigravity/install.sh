#!/bin/sh

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Antigravity's devcontainer doesn't provide `code` binary.
cat << 'EOF' > "${_REMOTE_USER_HOME}/.bash_aliases"
if ! command -v code &> /dev/null; then
    alias code='command antigravity'
fi
EOF
chown -R ${_REMOTE_USER}:${_REMOTE_USER} "${_REMOTE_USER_HOME}/.bash_aliases"

for f in .gitconfig .gemini; do
    ln -s "/var/tmp/$f" "${_REMOTE_USER_HOME}/$f"
    chown -h ${_REMOTE_USER}:${_REMOTE_USER} "${_REMOTE_USER_HOME}/$f"
done

# Fetch the latest Node.js LTS version dynamically to ensure we always install an up-to-date and supported runtime.
TARGET_NODE_VER=$(curl -s https://nodejs.org/dist/index.json | jq -r '[.[] | select(.lts != false)] | .[0].version')
if [ -z "$TARGET_NODE_VER" ]; then
    echo "Error: Failed to fetch the latest Node.js LTS version."
    exit 1
fi

ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then ARCH="x64"; elif [ "$ARCH" = "aarch64" ]; then ARCH="arm64"; fi

NODE_TAR="node-${TARGET_NODE_VER}-linux-${ARCH}.tar.xz"

# Prevent conflicts with the base OS environment.
mkdir -p /usr/local/lib/nodejs
curl -fsSL --compressed "https://nodejs.org/dist/${TARGET_NODE_VER}/${NODE_TAR}" | tar -xJ -C /usr/local/lib/nodejs --strip-components=1

# Expose Node.js and its package manager locally within the script's path and globally for the OS.
ln -sf /usr/local/lib/nodejs/bin/node /usr/local/bin/node
ln -sf /usr/local/lib/nodejs/bin/npm /usr/local/bin/npm
ln -sf /usr/local/lib/nodejs/bin/npx /usr/local/bin/npx

node -v || { echo "Error: Node.js installation failed"; exit 1; }
npm -v || { echo "Error: npm installation failed"; exit 1; }

# Enforce an artificial delay (--min-release-age) to mitigate supply-chain attacks via compromised rapid updates.
npm install -g @google/gemini-cli --min-release-age=7

# Expose the installed Gemini CLI globally.
ln -sf /usr/local/lib/nodejs/bin/gemini /usr/local/bin/gemini

gemini --version || echo "Warning: gemini command might only be available in the final container session."
