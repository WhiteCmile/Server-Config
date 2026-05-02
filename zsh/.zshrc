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
