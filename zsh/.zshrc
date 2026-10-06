# Server-Config managed zshrc

export APPS_HOME="${APPS_HOME:-$HOME/apps}"

if [[ -f ~/.zsh_aliases ]]; then
  source ~/.zsh_aliases
fi

if [[ -f ~/.zsh_functions ]]; then
  source ~/.zsh_functions
fi

# Keep Node path in shell startup for non-login shells.
export PATH="$APPS_HOME/node/bin:$PATH"

# Route interactive claude/codex through Happy (see happy/happy.md).
_server_config_root="${${(%):-%x}:A:h:h}"
if [[ -f "$_server_config_root/happy/happy.sh" ]]; then
  source "$_server_config_root/happy/happy.sh"
fi
unset _server_config_root
