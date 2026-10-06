# Server-Config: route interactive `claude` / `codex` through Happy.
# Sourced by zsh (~/.zshrc) and bash (~/.bashrc).
#
# - Only wraps interactive launches (stdin/stdout are TTYs) once Happy is
#   installed and logged in (~/.happy/access.key exists).
# - Subcommands and non-interactive usage (codex exec, claude -p, mcp, ...)
#   go straight to the real binary.
# - Bypass once: `command codex ...` / `command claude ...`
#   Disable entirely: `export HAPPY_WRAP=0`

export APPS_HOME="${APPS_HOME:-$HOME/apps}"
case ":$PATH:" in
  *":$APPS_HOME/happy/bin:"*) ;;
  *) export PATH="$APPS_HOME/happy/bin:$PATH" ;;
esac

# Node only honors http(s)_proxy with this set (Node >= 22.21 / 24).
export NODE_USE_ENV_PROXY=1

_happy_should_wrap() {
  [ "${HAPPY_WRAP:-1}" != "0" ] || return 1
  command -v happy >/dev/null 2>&1 || return 1
  [ -f "$HOME/.happy/access.key" ] || return 1
  [ -t 0 ] && [ -t 1 ]
}

claude() {
  if _happy_should_wrap; then
    case "${1-}" in
      ""|-c|--continue|-r|--resume|--model|--permission-mode|--dangerously-skip-permissions|--add-dir|--settings|--mcp-config|--append-system-prompt|--allowedTools|--disallowedTools|--resume=*|--model=*|--permission-mode=*)
        _happy_claude_ok=1 ;;
      *) _happy_claude_ok=0 ;;
    esac
    for _happy_arg in "$@"; do
      case "$_happy_arg" in
        -p|--print|-v|--version|-h|--help|--output-format*|--input-format*) _happy_claude_ok=0 ;;
      esac
    done
    if [ "$_happy_claude_ok" = "1" ]; then
      unset _happy_claude_ok _happy_arg
      happy claude "$@"
      return
    fi
    unset _happy_claude_ok _happy_arg
  fi
  command claude "$@"
}

codex() {
  if _happy_should_wrap; then
    # `happy codex` only understands these flags; anything else (prompts,
    # subcommands, -c overrides, ...) would be silently dropped.
    _happy_codex_ok=1
    _happy_expect_value=0
    for _happy_arg in "$@"; do
      if [ "$_happy_expect_value" = "1" ]; then
        _happy_expect_value=0
        continue
      fi
      case "$_happy_arg" in
        --model|--effort|--permission-mode|--resume|-r) _happy_expect_value=1 ;;
        --yolo|--no-sandbox|--resume=*) ;;
        *) _happy_codex_ok=0 ;;
      esac
    done
    if [ "$_happy_codex_ok" = "1" ]; then
      unset _happy_codex_ok _happy_expect_value _happy_arg
      happy codex "$@"
      return
    fi
    unset _happy_codex_ok _happy_expect_value _happy_arg
  fi
  command codex "$@"
}
