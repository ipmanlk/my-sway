# my-sway shell integration (stowed to ~/.config/bash/my-sway.sh).
# Sourced from ~/.bashrc by scripts/provision-user.sh (idempotent append).
# Safe on non-Sway machines too: everything is guarded by command -v.

# Interactive shells only — nothing here makes sense for scripts/scp/rsync.
# return-or-exit covers both sourcing (normal) and direct execution (accidental).
if [[ $- != *i* ]]; then
  return 0 2>/dev/null || exit 0
fi

# ~/.local/bin first (sway-* helpers, mise shims)
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) PATH="$HOME/.local/bin:$PATH" ;;
esac
export PATH

# mise (installed user-locally, no sudo): https://mise.run
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate bash)"
fi

# zoxide: smarter cd
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
fi

# fzf: key bindings + completion (upstream-recommended init for fzf >= 0.48)
if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --bash)"
fi

# Editors: helix default, vim fallback
if command -v hx >/dev/null 2>&1; then
  export EDITOR="${EDITOR:-hx}"
  export VISUAL="${VISUAL:-hx}"
  alias hl='hx'
elif command -v vim >/dev/null 2>&1; then
  export EDITOR="${EDITOR:-vim}"
  export VISUAL="${VISUAL:-vim}"
fi
