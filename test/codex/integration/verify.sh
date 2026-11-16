#!/bin/bash
set -euo pipefail

test "$(id -u)" -ne 0
test "$(command -v codex)" = "$HOME/.local/bin/codex"
test -L "$HOME/.local/bin/codex"
test -w "$HOME/.local/bin"
test -w "$CODEX_HOME/packages/standalone"
test "$(stat -c %U "$(readlink -f "$HOME/.local/bin/codex")")" = "$(id -un)"
codex --version

# Keep settings unchanged across repeated setup and a real, unprivileged update.
printf 'model = "test"\n' > "$CODEX_HOME/config.toml"
printf 'test-auth-preservation\n' > "$CODEX_HOME/auth.json"
before=$(sha256sum "$CODEX_HOME/config.toml" "$CODEX_HOME/auth.json" /etc/codex/config.toml)
selected=$(readlink -f "$HOME/.local/bin/codex")
sh -c "$CODEX_FEATURE_INSTALL_COMMAND"
test "$(readlink -f "$HOME/.local/bin/codex")" = "$selected"
codex update
codex --version
test "$(sha256sum "$CODEX_HOME/config.toml" "$CODEX_HOME/auth.json" /etc/codex/config.toml)" = "$before"

for shell in 'bash -lc' 'bash -ic'; do
    $shell 'test "$(command -v codex)" = "$HOME/.local/bin/codex"'
done
if command -v zsh >/dev/null; then
    zsh -ic 'test "$(command -v codex)" = "$HOME/.local/bin/codex"'
fi

# Simulate both download and installer failures without contacting the network.
mock_dir=$(mktemp -d)
trap 'rm -rf "$mock_dir"' EXIT
cat > "$mock_dir/curl" <<'EOF'
#!/bin/sh
exit 22
EOF
chmod +x "$mock_dir/curl"
if PATH="$mock_dir:$PATH" sh -c "$CODEX_FEATURE_INSTALL_COMMAND"; then
    echo 'Installer download failure was ignored' >&2
    exit 1
else
    test "$?" -eq 22
fi
cat > "$mock_dir/curl" <<'EOF'
#!/bin/sh
printf '#!/bin/sh\nexit 42\n'
EOF
if PATH="$mock_dir:$PATH" sh -c "$CODEX_FEATURE_INSTALL_COMMAND"; then
    echo 'Installer execution failure was ignored' >&2
    exit 1
else
    test "$?" -eq 42
fi
echo 'Codex integration checks passed.'
