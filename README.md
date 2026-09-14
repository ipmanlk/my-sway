# my-sway — Fedora Sway, Omarchy-style (GNU Stow layout)

Retired in favor of Noctalia upstream, but fully working. This repo mirrors
`$HOME` via [GNU Stow](https://www.gnu.org/software/stow/): each top-level
directory is a **stow package**. No system files under `/etc/sway/` or
`/usr/share/sway/` are ever edited; Sway user overrides live in
`~/.config/sway/config.d/` (loaded last).

```
my-sway/
├── install.sh            # stow wrapper (backs up originals to *.bak)
├── scripts/
│   ├── provision-sudo.sh # PRIVILEGED: dnf repos + packages + codecs (run with sudo)
│   └── provision-user.sh # UNPRIVILEGED: fonts, theme, mise, gsettings (run as user)
├── sway/         -> ~/.config/sway/
├── waybar/       -> ~/.config/waybar/
├── rofi/         -> ~/.config/rofi/
├── ghostty/      -> ~/.config/ghostty/   # default terminal (replaces Alacritty)
├── foot/         -> ~/.config/foot/      # kept as fallback terminal
├── dunst/        -> ~/.config/dunst/
├── gtk/          -> ~/.config/gtk-3.0 + gtk-4.0/
├── bin/          -> ~/.local/bin/        # sway-screenshot/record/nightlight
├── applications/ -> ~/.local/share/applications/
└── shell/        -> ~/.config/bash/my-sway.sh (zoxide/fzf/mise wiring)
```

## 0. Fresh machine order (Fedora Sway spin, 44+)

```bash
git clone <this-repo> ~/my-sway
cd ~/my-sway

sudo ./scripts/provision-sudo.sh   # repos, packages, codecs, Ghostty COPR
./scripts/provision-user.sh        # fonts, Nordic theme, mise, bashrc line (NO sudo)
./install.sh                       # stow everything into $HOME
```

Then on the Sway machine only:

```bash
swaymsg reload
pkill -SIGUSR2 waybar
python3 -c "import re,json; t=open('$HOME/.config/waybar/config.jsonc').read(); json.loads(re.sub(r'//.*','',t)); print('JSON OK')"
rofi -theme ~/.config/rofi/omarchy-dark.rasi -dump-theme >/dev/null && echo rofi-OK
desktop-file-validate ~/.local/share/applications/nm-connection-editor.desktop
grim /tmp/check.png   # screenshot-verify
```

`$mod` = Super (Mod4).

## 1. What changed vs the original doc

- **Terminal is Ghostty, not Alacritty.** `sway/…/15-terminal.conf` sets
  `set $term ghostty` (overrides system `10-terminal.conf`). The old
  `alacritty.toml` is gone; the same Omarchy-dark palette lives in
  `ghostty/.config/ghostty/config`. Foot config is kept as fallback.
  Ghostty install: `sudo dnf copr enable scottames/ghostty && sudo dnf install ghostty`
  (still COPR-only as of F44 — no official package yet).
- **No binary downloads.** `cliphist` is now an official Fedora package
  (since F44, `0.7.0-1`), so `provision-sudo.sh` does `dnf install cliphist`
  — the old `curl …/cliphist … > ~/.local/bin/cliphist` step is deleted.
  Fonts (Nerd Fonts), Nordic theme, and mise remain user-local downloads
  (they have no RPM; that is the only sane way to install them without sudo).
- **Multimedia follows current RPM Fusion docs** (ffmpeg swap + `@multimedia`
  group, OpenH264 opt-in, freeworld VA drivers). See `provision-sudo.sh`.
- **Only non-spin packages are installed.** Verified against the F44 comps
  (`sway-desktop-environment` + `swaywm-extended` + `sway-config-fedora` deps):
  the spin already ships sway/swaylock/swayidle/waybar/foot/dunst/grim/slurp/
  wl-clipboard/brightnessctl/pavucontrol/mpv/firefox/nm-connection-editor/
  git-core/bash-completion/curl — so `provision-sudo.sh` installs just
  `stow ghostty rofi cliphist wf-recorder gammastep zenity libnotify`
  plus your asks `gh vim helix zoxide fastfetch fzf htop btop qbittorrent uget`.
  `uget` is guarded (`|| skip`) — legacy upstream, may vanish from future Fedora.
  Note: the spin serves the PPD D-Bus API via `tuned-ppd`, so `power-profiles-daemon`
  is deliberately NOT installed (Waybar's module works as-is; installing PPD would
  remove tuned).
- **mise** (user-local): `curl https://mise.run | sh`, wired via
  `shell/.config/bash/my-sway.sh` + a `~/.bashrc` source line.

## 2. Sudo vs user — what runs where

| Script | Privilege | Does |
|---|---|---|
| `scripts/provision-sudo.sh` | `sudo` | RPM Fusion, OpenH264, ffmpeg swap, @multimedia, GPU VA drivers, Ghostty COPR, all `dnf install` |
| `scripts/provision-user.sh` | normal user, never sudo | Nerd Font, Nordic theme, `mise`, `gsettings`, `~/.bashrc` source line |
| `./install.sh` | normal user | `stow` symlinks only (backs up clobbered files to `*.bak`) |

## 3. Fonts

User-local JetBrainsMono Nerd Font (see `provision-user.sh`). Font stack
everywhere: `'JetBrainsMono Nerd Font', 'Noto Sans Mono', 'Font Awesome 6 Free',
'Font Awesome 6 Brands', monospace`. Diagnose a suspect glyph with
`fc-list ":charset=f6ff" family`.

## 4. Glyph legend (Waybar PUA icons)

All Font Awesome 6 Free Solid (verified via `fc-list ":charset=XXXX"`):
lock F023, unlock F09C, scratchpad F2D2, mpd note F001, queue brackets 2E28/2E29,
consume F0C4, random F074, repeat/single F01E, pause F04C / play F04B,
idle eye F06E / eye-slash F070, thermometer F2DB, degrees 00B0, levels F2C9,
sun F185, charging F5E7, plug F1E6, battery F240–F244, bolt F0E7, balance F24E,
leaf F06C, wifi F1EB, ethernet F796, warning F071, bluetooth F294, mute F6A9,
mic F130 / mic-slash F131, volumes F025/F026/F027/F028, headset F590,
phone F095, car F1B9, spotify F1BC, media fallback 1F39C, power 23FB, rec dot 25CF.

## 5. Keybindings

| Keys | Action |
|---|---|
| `bindcode 107` / `Shift+107` / `Ctrl+107` | Screenshot region / full / window |
| `$mod+Shift+s` | Screenshot region fallback |
| `$mod+Shift+r` | Recording toggle |
| `$mod+space` / `$mod+d` | Rofi launcher (system combi drun+run) |
| `$mod+Tab` | Rofi window switcher |
| `$mod+Shift+v` / `$mod+Shift+x` | Clipboard pick / wipe (cliphist, now from dnf) |
| `$mod+Shift+n` | gammastep night light |
| `$mod+w` kill, `$mod+t` floating | User overrides (20-omarchy-keys) |
| `$mod+v` splitv, `$mod+b` splith, `$mod+e` layout toggle | Tiling (system defaults) |
| `XF86MonBrightnessUp/Down` | brightnessctl ±5% + OSD (system file, do not duplicate) |
| clock/network/volume/power clicks | Calendar / nm-connection-editor / pavucontrol / rofi menu |

## 6. Troubleshooting (condensed from the build notes)

- Red config-error bar with empty details: bisect user conf files, verify with
  `pgrep -x swaynag`. Never `pkill -f <pattern>` that matches your own shell —
  use `pkill -x`.
- `Print` keysym unbindable in VMs: virt-manager grabs it; `bindcode 107` + `$mod` fallback.
- `XF86Audio*` may not exist in a VM keymap: keep volume in the bar.
- Duplicating a bare system `XF86MonBrightness*` binding errors even with `--no-warn`.
- Gaps "not working": check `smart_gaps`, measure `swaymsg -t get_tree` rects; gaps show
  wallpaper — invisible on black is not a bug.
- Waybar icons wrong: check per-glyph coverage (§4).
- Waybar won't die: Sway re-runs `swaybar_command` on every reload; it does not
  respawn exited clients on its own.
- `bar-1` after reload: a second `bar {}` block exists — `swaymsg -t get_bar_config` lists them.
- GTK app stuck light: `thunar -q` + reopen; settings apply at startup.
- Terminal theme: new windows only.
- `timeout 3 rofi -show window` (exit 124 = ran fine) tests without a binding.
