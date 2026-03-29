#!/bin/sh

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Antigravity's devcontainer doesn't provide `code` binary.
cat << 'EOF' > "${_REMOTE_USER_HOME}/.bash_aliases"
alias code='command antigravity'
EOF
chown -R ${_REMOTE_USER}:${_REMOTE_USER} "${_REMOTE_USER_HOME}/.bash_aliases"

for f in .gitconfig; do
    ln -s "/var/tmp/$f" "${_REMOTE_USER_HOME}/$f"
    chown -h ${_REMOTE_USER}:${_REMOTE_USER} "${_REMOTE_USER_HOME}/$f"
done
