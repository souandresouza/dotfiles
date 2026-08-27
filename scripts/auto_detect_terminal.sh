#!/usr/bin/env bash

TERMINALS=(
  foot
  kitty
  alacritty
  ghostty
  wezterm
  konsole
  gnome-terminal
  xfce4-terminal
  lxterminal
  mate-terminal
  tilix
  urxvt
  rxvt
  st
  xterm
)

for term in "${TERMINALS[@]}"; do
  if command -v "$term" &>/dev/null; then
    "$term" &
    exit 0
  fi
done

notify-send "No Terminal Found" "Please install a terminal emulator"
paplay /usr/share/sounds/freedesktop/stereo/message.oga
