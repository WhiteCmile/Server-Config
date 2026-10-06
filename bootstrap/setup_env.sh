#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

APPS_HOME="${APPS_HOME:-$HOME/apps}"
NODE_VERSION="${NODE_VERSION:-v22.22.0}"
NODE_ARCHIVE="node-${NODE_VERSION}-linux-x64.tar.xz"
NODE_URL="https://nodejs.org/dist/${NODE_VERSION}/${NODE_ARCHIVE}"

INSTALL_BASE_PACKAGES="${INSTALL_BASE_PACKAGES:-1}"
INSTALL_NODE="${INSTALL_NODE:-1}"
SETUP_SSH_ALIAS="${SETUP_SSH_ALIAS:-1}"
SETUP_TMUX="${SETUP_TMUX:-1}"
SETUP_VIM="${SETUP_VIM:-1}"
SETUP_ZSH="${SETUP_ZSH:-1}"
SET_DEFAULT_SHELL_ZSH="${SET_DEFAULT_SHELL_ZSH:-0}"
SETUP_HAPPY="${SETUP_HAPPY:-1}"
HAPPY_SERVER_URL="${HAPPY_SERVER_URL:-https://47.74.47.171}"

log() {
  printf '[setup] %s\n' "$*"
}

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

ensure_line_in_file() {
  local line="$1"
  local file="$2"
  touch "$file"
  if ! grep -Fqx "$line" "$file"; then
    printf '\n%s\n' "$line" >> "$file"
  fi
}

install_base_packages() {
  if [[ "$INSTALL_BASE_PACKAGES" != "1" ]]; then
    log "skip base package install"
    return
  fi

  if has_cmd apt-get; then
    log "install base packages via apt-get"

    if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
      if ! apt-get update; then
        log "apt-get update failed; continue without package installation"
        return
      fi
      if ! apt-get install -y curl tar git tmux vim zsh openssh-client ca-certificates; then
        log "apt-get install failed; continue with existing environment"
      fi
      return
    fi

    if ! has_cmd sudo; then
      log "sudo not found; skip package installation"
      return
    fi

    if ! sudo apt-get update; then
      log "sudo apt-get update failed; continue without package installation"
      return
    fi
    if ! sudo apt-get install -y curl tar git tmux vim zsh openssh-client ca-certificates; then
      log "sudo apt-get install failed; continue with existing environment"
    fi
  else
    log "apt-get not found; skip package installation"
  fi
}

setup_node() {
  if [[ "$INSTALL_NODE" != "1" ]]; then
    log "skip node setup"
    return
  fi

  mkdir -p "$APPS_HOME"

  if [[ -x "$APPS_HOME/node/bin/node" ]]; then
    log "node already exists at $APPS_HOME/node, skip download"
  else
    local tmp_dir
    tmp_dir="$(mktemp -d)"

    log "download node from $NODE_URL"
    curl -fL "$NODE_URL" -o "$tmp_dir/$NODE_ARCHIVE"
    tar -xf "$tmp_dir/$NODE_ARCHIVE" -C "$tmp_dir"

    rm -rf "$APPS_HOME/node"
    mv "$tmp_dir/node-${NODE_VERSION}-linux-x64" "$APPS_HOME/node"
    rm -rf "$tmp_dir"
    log "node installed at $APPS_HOME/node"
  fi

  ensure_line_in_file "export PATH=\"$APPS_HOME/node/bin:\$PATH\"" "$HOME/.bashrc"
}

setup_ssh_alias() {
  if [[ "$SETUP_SSH_ALIAS" != "1" ]]; then
    log "skip ssh alias setup"
    return
  fi

  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  touch "$HOME/.ssh/config"
  chmod 600 "$HOME/.ssh/config"

  if grep -Fq "Host github.ztl" "$HOME/.ssh/config"; then
    log "ssh alias github.ztl already exists"
  else
    cat >> "$HOME/.ssh/config" <<'SSH_EOF'

Host github.ztl
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
SSH_EOF
    log "ssh alias github.ztl added"
  fi
}

setup_dotfiles() {
  if [[ "$SETUP_TMUX" == "1" ]]; then
    ln -sfn "$REPO_ROOT/tmux/.tmux.conf" "$HOME/.tmux.conf"
    log "linked ~/.tmux.conf"
  fi

  if [[ "$SETUP_VIM" == "1" ]]; then
    ln -sfn "$REPO_ROOT/vim/.vimrc" "$HOME/.vimrc"
    log "linked ~/.vimrc"
  fi

  if [[ "$SETUP_ZSH" == "1" ]]; then
    ln -sfn "$REPO_ROOT/zsh/.zshrc" "$HOME/.zshrc"
    ln -sfn "$REPO_ROOT/zsh/.zprofile" "$HOME/.zprofile"
    ln -sfn "$REPO_ROOT/zsh/.zsh_aliases" "$HOME/.zsh_aliases"
    ln -sfn "$REPO_ROOT/zsh/.zsh_functions" "$HOME/.zsh_functions"
    log "linked zsh dotfiles"

    if [[ "$SET_DEFAULT_SHELL_ZSH" == "1" ]]; then
      if has_cmd zsh; then
        if chsh -s "$(command -v zsh)"; then
          log "default shell changed to zsh"
        else
          log "chsh failed; keep current default shell"
        fi
      else
        log "zsh not found; cannot change default shell"
      fi
    fi
  fi
}

setup_happy() {
  if [[ "$SETUP_HAPPY" != "1" ]]; then
    log "skip happy setup"
    return
  fi

  local npm_bin="npm"
  if [[ -x "$APPS_HOME/node/bin/npm" ]]; then
    npm_bin="$APPS_HOME/node/bin/npm"
    export PATH="$APPS_HOME/node/bin:$PATH"
  fi
  if ! has_cmd "$npm_bin"; then
    log "npm not found; skip happy setup"
    return
  fi

  local happy_dir="$APPS_HOME/happy"
  if [[ -x "$happy_dir/bin/happy" ]]; then
    log "happy already exists at $happy_dir, skip install"
  else
    log "install happy cli to $happy_dir"
    if ! "$npm_bin" install -g happy --prefix "$happy_dir"; then
      log "happy install failed; continue without happy"
      return
    fi
  fi

  # npm >= 11 may skip install scripts; unpack bundled tools (idempotent).
  local unpack="$happy_dir/lib/node_modules/happy/scripts/unpack-tools.cjs"
  if [[ -f "$unpack" ]]; then
    node "$unpack" >/dev/null || log "happy unpack-tools failed"
  fi

  mkdir -p "$HOME/.happy"
  if [[ -f "$HOME/.happy/settings.json" ]]; then
    log "keep existing ~/.happy/settings.json"
  else
    printf '{"schemaVersion":2,"onboardingCompleted":false,"serverUrl":"%s"}\n' \
      "$HAPPY_SERVER_URL" > "$HOME/.happy/settings.json"
    log "happy server url set to $HAPPY_SERVER_URL"
  fi

  # zsh sources happy.sh via the managed .zshrc; bash needs it explicitly.
  ensure_line_in_file "[ -f \"$REPO_ROOT/happy/happy.sh\" ] && . \"$REPO_ROOT/happy/happy.sh\"" "$HOME/.bashrc"
  log "happy wrapper enabled; run 'happy auth login' once to pair with the phone app"
}

print_verification() {
  log "verification commands:"
  cat <<'VERIFY_EOF'

node -v
npm -v
which codex || true
ssh -T git@github.ztl

tmux -V
vim --version | head -n 1
zsh --version

happy --version
cat ~/.happy/settings.json
type codex claude

# Happy pairing (manual, in a NEW terminal; run `proxy` first if needed):
happy auth login
bash ~/Server-Config/happy/install-daemon-service.sh

VERIFY_EOF
}

main() {
  log "repo root: $REPO_ROOT"
  log "apps home: $APPS_HOME"
  install_base_packages
  setup_node
  setup_ssh_alias
  setup_dotfiles
  setup_happy
  print_verification
  log "done"
}

main "$@"
