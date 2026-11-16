Codex CLI is installed as the remote user during `postCreateCommand`. Run
`codex update` without sudo to update it. Container creation requires `curl`, `tar`,
CA certificates, and network access to the official installer and release downloads.
The host must provide `/etc/codex/config.toml` for the configuration bind mount.
