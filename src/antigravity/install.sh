#!/bin/sh

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

cat << 'EOF' > "${_REMOTE_USER_HOME}/.bash_aliases"
alias code='command antigravity'
EOF

chown -R ${_REMOTE_USER}:${_REMOTE_USER} "${_REMOTE_USER_HOME}/.bash_aliases"

ln -s /var/tmp/.gitconfig "${_REMOTE_USER_HOME}/.gitconfig"
chown -h ${_REMOTE_USER}:${_REMOTE_USER} "${_REMOTE_USER_HOME}/.gitconfig"
ln -s /var/tmp/.gemini "${_REMOTE_USER_HOME}/.gemini"
chown -h ${_REMOTE_USER}:${_REMOTE_USER} "${_REMOTE_USER_HOME}/.gemini"
