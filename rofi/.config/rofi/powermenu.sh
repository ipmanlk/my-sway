#!/bin/sh
# Rofi power menu (Omarchy-dark theme), used by Waybar custom/power on-click
choice=$(printf 'Lock\nSuspend\nLog out\nReboot\nShutdown' | rofi -dmenu -p 'Power' -theme ~/.config/rofi/omarchy-dark.rasi)
case "$choice" in
    Lock) swaylock -f ;;
    Suspend) systemctl suspend ;;
    'Log out') swaymsg exit ;;
    Reboot) systemctl reboot ;;
    Shutdown) systemctl poweroff ;;
esac
