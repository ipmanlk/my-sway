# my-sway — quick config for the Fedora Sway spin

Personal Sway setup (Waybar, rofi, Ghostty). Made for the **Fedora Sway spin
only** — assumes its packages and defaults, won't work as-is elsewhere.

Stowed with GNU Stow: each top-level directory mirrors `$HOME`.

## Quick start

```bash
git clone <this-repo> ~/my-sway
cd ~/my-sway

sudo ./scripts/provision-sudo.sh   # repos, codecs, packages (asks GPU once)
./scripts/provision-user.sh        # fonts, GTK theme, mise (NO sudo)
./install.sh                       # symlink everything into $HOME
```

Then apply: `swaymsg reload`.

## Layout

```
my-sway/
├── install.sh            # stow wrapper (backs up originals to *.bak)
├── scripts/
│   ├── provision-sudo.sh # privileged: repos + packages + codecs (run with sudo)
│   └── provision-user.sh # unprivileged: fonts, theme, mise (run as user)
├── sway/         -> ~/.config/sway/
├── waybar/       -> ~/.config/waybar/
├── rofi/         -> ~/.config/rofi/
├── ghostty/      -> ~/.config/ghostty/   # default terminal ($term override)
├── dunst/        -> ~/.config/dunst/
├── gtk/          -> ~/.config/gtk-3.0 + gtk-4.0/
├── bin/          -> ~/.local/bin/        # screenshot / record / nightlight helpers
├── applications/ -> ~/.local/share/applications/
└── shell/        -> ~/.config/bash/my-sway.sh (zoxide/fzf/mise wiring)
```

## Scripts

| Script | Run as | Does |
|---|---|---|
| `scripts/provision-sudo.sh` | `sudo` | RPM Fusion, codecs, GPU driver, packages, Ghostty |
| `scripts/provision-user.sh` | normal user, never sudo | Nerd Font, GTK theme, `mise`, `~/.bashrc` line |
| `./install.sh` | normal user | `stow` symlinks into `$HOME` (`--delete` to remove) |

## Keybindings

`$mod` = Super.

| Keys | Action |
|---|---|
| `Print` / `Shift+Print` / `Ctrl+Print` (`$mod+Shift+s` fallback) | Screenshot region / full / window |
| `$mod+Shift+r` | Screen recording toggle |
| `$mod+Shift+n` | Night light toggle |
| `$mod+space` | App launcher |
| `$mod+Tab` | Window switcher |
| `$mod+Shift+v` / `$mod+Shift+x` | Clipboard history pick / wipe |
| `$mod+w` kill, `$mod+t` floating | Overrides |
