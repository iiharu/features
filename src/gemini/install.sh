#!/bin/sh

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Selective symlink from the host's mount point to the container's .gemini directory
# This avoids sharing architecture-dependent binaries (like those in ~/.gemini/tmp/bin)
HOST_GEMINI_DIR="/var/tmp/.gemini"

# Ensure we have the remote user's home directory
if [ -z "${_REMOTE_USER_HOME}" ]; then
    _REMOTE_USER_HOME=$(getent passwd "${_REMOTE_USER:-root}" | cut -d: -f6)
fi
CONTAINER_GEMINI_DIR="${_REMOTE_USER_HOME}/.gemini"

mkdir -p "${CONTAINER_GEMINI_DIR}"

# List of items to share between host and container
SHARE_ITEMS="settings.json GEMINI.md skills extensions trusted-folders.json"

for item in ${SHARE_ITEMS}; do
    # Create symlinks even if the source doesn't exist during build, 
    # as the mount will be available at runtime.
    ln -sf "${HOST_GEMINI_DIR}/${item}" "${CONTAINER_GEMINI_DIR}/${item}"
done

chown -R -h ${_REMOTE_USER:-root}:${_REMOTE_USER:-root} "${CONTAINER_GEMINI_DIR}"

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

# Upgrade npm to >= 11.10 to support --min-release-age flag correctly.
npm install -g npm@latest --ignore-scripts=true

# Enforce an artificial delay (--min-release-age) to mitigate supply-chain attacks via compromised rapid updates.
npm install -g @google/gemini-cli --min-release-age=7 --ignore-scripts=true

# Expose the installed Gemini CLI globally.
ln -sf /usr/local/lib/nodejs/bin/gemini /usr/local/bin/gemini

gemini --version || echo "Warning: gemini command might only be available in the final container session."
