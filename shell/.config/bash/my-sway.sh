# my-sway shell integration (stowed to ~/.config/bash/my-sway.sh).
# Sourced from ~/.bashrc by scripts/provision-user.sh (idempotent append).
# Safe on non-Sway machines too: everything is guarded by command -v.

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

# fzf: key bindings + completion (Fedora path)
if command -v fzf >/dev/null 2>&1; then
  [ -f /usr/share/fzf/shell/key-bindings.bash ] && . /usr/share/fzf/shell/key-bindings.bash
  [ -f /usr/share/fzf/shell/completion.bash ] && . /usr/share/fzf/shell/completion.bash
fi

# Editors: vim default, helix as hx / hl
command -v vim >/dev/null 2>&1 && export EDITOR="${EDITOR:-vim}"
command -v hx >/dev/null 2>&1 && alias hl='hx'
