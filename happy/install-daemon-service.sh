#!/usr/bin/env bash
# Install a systemd user service that keeps `happy daemon` running (and starts
# it at boot), so the phone can always see this machine and spawn sessions.
#
# Usage (after `happy auth login`, from a shell with your normal env/proxy):
#   bash ~/Server-Config/happy/install-daemon-service.sh
#   bash ~/Server-Config/happy/install-daemon-service.sh --uninstall
set -euo pipefail

unit_dir="$HOME/.config/systemd/user"
unit="$unit_dir/happy-daemon.service"
env_file="$HOME/.config/happy-daemon.env"
log() { printf '[happy-daemon] %s\n' "$*"; }

if [[ "${1:-}" == "--uninstall" ]]; then
  systemctl --user disable --now happy-daemon.service 2>/dev/null || true
  rm -f "$unit" "$env_file"
  systemctl --user daemon-reload
  log "removed"
  exit 0
fi

if ! systemctl --user show-environment >/dev/null 2>&1; then
  log "systemd user session not available; use 'happy daemon start' instead"
  exit 1
fi
if [[ ! -f "$HOME/.happy/access.key" ]]; then
  log "not paired yet: run 'happy auth login' first"
  exit 1
fi

login_shell="$(getent passwd "$USER" | cut -d: -f7)"
login_shell="${login_shell:-/bin/bash}"

# Snapshot the proxy settings; everything else (PATH, model API keys, ...)
# comes from the interactive login shell the service runs in.
mkdir -p "$unit_dir"
: > "$env_file"
chmod 600 "$env_file"
for var in http_proxy https_proxy HTTP_PROXY HTTPS_PROXY all_proxy ALL_PROXY; do
  if [[ -n "${!var:-}" ]]; then
    printf '%s=%s\n' "$var" "${!var}" >> "$env_file"
  fi
done

cat > "$unit" <<UNIT_EOF
[Unit]
Description=Happy daemon (phone remote control for Claude Code / Codex)

[Service]
Type=simple
EnvironmentFile=-$env_file
ExecStart=$login_shell -ic 'happy daemon start-sync'
# Keep sessions spawned from the phone alive when the daemon restarts.
KillMode=process
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
UNIT_EOF

# Replace a manually started daemon so the two don't fight.
happy daemon stop >/dev/null 2>&1 || command happy daemon stop >/dev/null 2>&1 || true

systemctl --user daemon-reload
systemctl --user enable --now happy-daemon.service
log "installed: $unit"

if [[ "$(loginctl show-user "$USER" -p Linger --value 2>/dev/null)" != "yes" ]]; then
  log "to start at boot without logging in, run once: sudo loginctl enable-linger $USER"
fi
