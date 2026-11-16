#!/bin/bash
set -euo pipefail
repo=$(cd "$(dirname "$0")/../../.." && pwd)
test_dir=$(mktemp -d)
test_dir=$(cd "$test_dir" && pwd -P)
mkdir -p "$test_dir/.devcontainer"
volume="codex-feature-test-$(basename "$test_dir" | tr '[:upper:]' '[:lower:]')"
cleanup() {
    docker ps -aq --filter "label=devcontainer.local_folder=$test_dir" | while read -r container; do
        if [ -n "$container" ]; then docker rm -f "$container" >/dev/null; fi
    done
    docker volume rm "$volume" >/dev/null 2>&1 || true
    rm -rf "$test_dir"
}
trap cleanup EXIT
printf 'model = "test"\n' > "$test_dir/config.toml"
python3 - "$repo" "$test_dir" "$volume" "${1:-mcr.microsoft.com/devcontainers/base:ubuntu}" "${2:-vscode}" <<'PY'
import json, shutil, sys
repo, folder, volume, image, user = sys.argv[1:]
shutil.copytree(repo + '/src/codex', folder + '/.devcontainer/codex')
with open(repo + '/src/codex/devcontainer-feature.json') as f:
    install_command = json.load(f)['postCreateCommand']
config = {
    'image': image, 'remoteUser': user,
    'features': {'./codex': {}},
    'remoteEnv': {'CODEX_FEATURE_INSTALL_COMMAND': install_command},
    'workspaceMount': f'source={repo},target=/workspaces/codex-test,type=bind',
    'workspaceFolder': '/workspaces/codex-test',
    'mounts': [
        f'source={folder}/config.toml,target=/etc/codex/config.toml,type=bind',
        f'source={volume},target=/home/vscode/.codex,type=volume'],
    'postCreateCommand': 'test "$(command -v codex)" = "$HOME/.local/bin/codex" && codex --version',
    'waitFor': 'postCreateCommand'
}
with open(folder + '/.devcontainer/devcontainer.json', 'w') as f:
    json.dump(config, f)
PY
for creation in first recreated; do
    devcontainer up --workspace-folder "$test_dir" --remove-existing-container > "$test_dir/up.json"
    devcontainer exec --workspace-folder "$test_dir" bash /workspaces/codex-test/test/codex/integration/verify.sh
done
