#!/usr/bin/env bash
# provision-user.sh — UNPRIVILEGED part. Run as your normal user, NEVER with sudo:
#   ./scripts/provision-user.sh
# Fonts, GTK theme, mise, gsettings, bashrc wiring. All user-local (~/.local, ~/.config).
set -eu
set -o pipefail 2>/dev/null || true

if [ "$(id -u)" -eq 0 ]; then
  echo "Do NOT run this as root. Run as your normal user." >&2
  exit 1
fi

echo "==> Fonts: JetBrainsMono Nerd Font (user-local, no sudo)"
mkdir -p "$HOME/.local/share/fonts/JetBrainsMonoNerd"
cd "$HOME/.local/share/fonts/JetBrainsMonoNerd"
if [ "$(ls -1 ./*.ttf 2>/dev/null | wc -l)" -lt 5 ]; then
  curl -sSL -o JBMNerd.zip \
    https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip
  unzip -o -q JBMNerd.zip && rm -f JBMNerd.zip
fi
fc-cache -f "$HOME/.local/share/fonts" >/dev/null
echo "    JetBrainsMono Nerd faces: $(fc-list | grep -i -c 'JetBrainsMono Nerd' || true) (expect ~48)"

echo "==> GTK theme: Nordic-darker (user-local, no sudo)"
echo "    (Fedora ships no dark GTK3 theme; Adwaita-dark resolves to nothing.)"
mkdir -p "$HOME/.local/share/themes"
if [ ! -d "$HOME/.local/share/themes/Nordic-darker" ]; then
  curl -sSL -o /tmp/nordic.tar.xz \
    https://github.com/EliverLara/Nordic/releases/download/v2.2.0/Nordic-darker.tar.xz
  tar -xJf /tmp/nordic.tar.xz -C "$HOME/.local/share/themes" && rm -f /tmp/nordic.tar.xz
else
  echo "    Nordic-darker already present, skipping download."
fi

echo "==> gsettings: dark theme preference (applies to new app windows)"
gsettings set org.gnome.desktop.interface gtk-theme 'Nordic-darker' 2>/dev/null || true
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
echo "    NOTE: Thunar runs as a daemon — after stowing, run 'thunar -q' and reopen it."

echo "==> mise (user-local, no sudo): https://mise.run"
if ! command -v mise >/dev/null 2>&1 && [ ! -x "$HOME/.local/bin/mise" ]; then
  curl https://mise.run | sh
else
  echo "    mise already installed, skipping."
fi

echo "==> Default browser: Brave Beta"
if command -v xdg-settings >/dev/null 2>&1; then
  xdg-settings set default-web-browser brave-browser-beta.desktop
else
  echo "    xdg-settings not found, skipping."
fi

echo "==> shell: source ~/.config/bash/my-sway.sh from ~/.bashrc (stowed by ./install.sh)"
touch "$HOME/.bashrc"
if ! grep -q 'my-sway.sh' "$HOME/.bashrc"; then
  printf '\n# my-sway (stow-managed shell integration)\n[ -f "$HOME/.config/bash/my-sway.sh" ] && . "$HOME/.config/bash/my-sway.sh"\n' >> "$HOME/.bashrc"
  echo "    appended source line to ~/.bashrc"
else
  echo "    ~/.bashrc already sources my-sway.sh"
fi

echo "==> cliphist roundtrip hint (run INSIDE Sway, needs wl-clipboard session):"
echo "    echo test | wl-copy; sleep 2; cliphist list"

echo
echo "OK: user provisioning done."
echo "Next: ./install.sh   (stows configs into \$HOME)"
