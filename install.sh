#!/usr/bin/env bash
# install.sh — symlink this repo into $HOME with GNU Stow.
# Layout: each top-level dir (sway, waybar, ...) is a stow package that
# mirrors $HOME (e.g. sway/.config/sway/... -> ~/.config/sway/...).
#   ./install.sh            # stow everything
#   ./install.sh --delete   # unstow everything (removes symlinks only)
set -eu

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
PACKAGES="sway waybar rofi ghostty dunst gtk bin applications shell"
MODE="--restow"
if [ "${1:-}" = "--delete" ]; then
  MODE="--delete"
fi

command -v stow >/dev/null 2>&1 || {
  echo "GNU Stow not found. Install it first: sudo dnf install stow" >&2
  exit 1
}

# Back up anything stow would overwrite (regular files only, -> *.bak).
backup_if_regular() {
  # $1 = $HOME-relative path, e.g. .config/waybar/config.jsonc
  target="$HOME/$1"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "backup: $target -> $target.bak"
    mv -f "$target" "$target.bak"
  fi
}

if [ "$MODE" != "--delete" ]; then
  backup_if_regular .config/sway/config.d/15-terminal.conf
  backup_if_regular .config/sway/config.d/20-omarchy-keys.conf
  backup_if_regular .config/sway/config.d/30-gaps-chrome.conf
  backup_if_regular .config/sway/config.d/40-productivity.conf
  backup_if_regular .config/waybar/config.jsonc
  backup_if_regular .config/waybar/style.css
  backup_if_regular .config/rofi/config.rasi
  backup_if_regular .config/rofi/omarchy-dark.rasi
  backup_if_regular .config/rofi/powermenu.sh
  backup_if_regular .config/ghostty/config
  backup_if_regular .config/dunst/dunstrc
  backup_if_regular .config/gtk-3.0/settings.ini
  backup_if_regular .config/gtk-4.0/settings.ini
  backup_if_regular .config/bash/my-sway.sh
  backup_if_regular .local/bin/sway-screenshot
  backup_if_regular .local/bin/sway-record
  backup_if_regular .local/bin/nightlight-toggle
  backup_if_regular .local/share/applications/nm-connection-editor.desktop
fi

# shellcheck disable=SC2086
stow --dir="$REPO_DIR" --target="$HOME" $MODE $PACKAGES

echo "stowed: $PACKAGES -> \$HOME ($MODE)"
echo
echo "Apply on the Sway machine:"
echo "  swaymsg reload; pkill -SIGUSR2 waybar"
echo "  desktop-file-validate ~/.local/share/applications/nm-connection-editor.desktop"
