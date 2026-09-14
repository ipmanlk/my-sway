#!/usr/bin/env bash
# provision-sudo.sh — PRIVILEGED part. Run ONCE on the Fedora Sway machine:
#   sudo ./scripts/provision-sudo.sh
# Everything in here needs root (dnf / rpm). Nothing user-local goes here.
# Safe to re-run: dnf is idempotent. Tested target: Fedora 44+ (dnf5).
set -eu
# pipefail where supported
set -o pipefail 2>/dev/null || true

if [ "$(id -u)" -ne 0 ]; then
  echo "Run as root: sudo $0" >&2
  exit 1
fi

DNF="dnf"
if command -v dnf5 >/dev/null 2>&1; then
  DNF="dnf5"
fi
FEDORA_VER="$(rpm -E %fedora)"

echo "==> [$DNF] Fedora $FEDORA_VER — refresh + base tooling"
$DNF upgrade --refresh -y
$DNF install -y stow

echo "==> RPM Fusion free + nonfree (version-agnostic URLs)"
$DNF install -y \
  "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VER}.noarch.rpm" \
  "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VER}.noarch.rpm"

echo "==> Enable Cisco OpenH264 (Fedora-managed, disabled by default)"
$DNF config-manager setopt fedora-cisco-openh264.enabled=1 || true

echo "==> Multimedia: full ffmpeg + @multimedia group (current RPM Fusion docs)"
echo "    Source: https://rpmfusion.org/Howto/Multimedia"
$DNF swap -y ffmpeg-free ffmpeg --allowerasing
$DNF install -y @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin

echo "==> Hardware video decode — choose your GPU (installs ONLY that driver)"
echo "    1) AMD Radeon (any age, e.g. Ryzen 4000+ / RX 5000+ laptops & desktops)"
echo "       -> mesa-va-drivers-freeworld  (rpmfusion-free)"
echo "    2) Intel recent, Gen9+ / Skylake 2015+ (e.g. ThinkPad T480s i5-8250U/8350U, UHD 620)"
echo "       -> intel-media-driver (rpmfusion-nonfree)"
echo "    3) Intel older, pre-Gen9 (e.g. HD 4000/4400 — ThinkPad X230/T430 era)"
echo "       -> libva-intel-driver         (rpmfusion-free)"
echo "    4) NVIDIA discrete (e.g. ThinkPad P-series Quadro, GeForce + proprietary driver)"
echo "       -> libva-nvidia-driver, VA-API bridge"
echo "    5) None / VM -> skip, CPU decode only"
echo "    Unattended: sudo GPU=1|2|3|4|5 $0"
GPU_CHOICE="${GPU:-}"
if [ -z "$GPU_CHOICE" ] && [ -r /dev/tty ]; then
  printf "GPU [1-5, default 5]: " > /dev/tty
  read -r GPU_CHOICE < /dev/tty || GPU_CHOICE="5"
  GPU_CHOICE="${GPU_CHOICE:-5}"
fi
GPU_CHOICE="${GPU_CHOICE:-5}"
case "$GPU_CHOICE" in
  1|amd|AMD)
    $DNF install -y mesa-va-drivers-freeworld libva-utils
    # Steam / 32-bit games need the i686 build too (uncomment if you game):
    # $DNF install -y mesa-va-drivers-freeworld.i686
    ;;
  2|intel|Intel)
    $DNF install -y intel-media-driver libva-utils
    ;;
  3|intel-old|old)
    $DNF install -y libva-intel-driver libva-utils
    ;;
  4|nvidia|NVIDIA)
    $DNF install -y libva-nvidia-driver libva-utils
    ;;
  *)
    echo "    skipping hardware video drivers (CPU decode only)"
    ;;
esac
echo "    Verify on the machine with: vainfo  (look for H264/HEVC/AV1 profiles)"

# Optional: DVD playback (tainted repos). Uncomment if you need it.
# $DNF install -y rpmfusion-free-release-tainted rpmfusion-nonfree-release-tainted
# $DNF install -y libdvdcss

echo "==> Ghostty (COPR scottames/ghostty — still not in official repos as of F44)"
$DNF copr enable -y scottames/ghostty
$DNF install -y ghostty

echo "==> Brave Beta"
# config-manager ships with dnf5-plugins (already in the spin), no extra setup needed.
$DNF config-manager addrepo --from-repofile=https://brave-browser-rpm-beta.s3.brave.com/brave-browser-beta.repo
$DNF install -y brave-browser-beta

echo "==> Sway stack extras"
# power-profiles-daemon left out on purpose: the spin serves that D-Bus API
# via tuned-ppd, installing it would remove tuned.
$DNF install -y \
  rofi cliphist wf-recorder gammastep \
  zenity libnotify

echo "==> CLI + dev tools"
$DNF install -y \
  gh vim helix \
  zoxide fastfetch fzf \
  htop btop

echo "==> Desktop apps"
$DNF install -y qbittorrent
# uget is legacy/abandoned upstream; still packaged for now. Don't fail if gone.
$DNF install -y uget || echo "NOTE: 'uget' not available on Fedora $FEDORA_VER — skipping."

echo
echo "OK: privileged provisioning done."
echo "Next (as your normal user, NO sudo): ./scripts/provision-user.sh && ./install.sh"
