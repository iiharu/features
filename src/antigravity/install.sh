#!/bin/sh

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

ZSH_CUSTOM="${_REMOTE_USER_HOME}/.oh-my-zsh/custom"

cat << 'EOF' > "${ZSH_CUSTOM}/antigravity.zsh"
alias code='command antigravity'
EOF

chown -R ${_REMOTE_USER}:${_REMOTE_USER} "${ZSH_CUSTOM}/antigravity.zsh"
