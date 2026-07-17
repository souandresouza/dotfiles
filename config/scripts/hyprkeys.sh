#!/bin/sh
grep -E '^hl\.bind\(' $HOME/.config/hypr/config/binds.lua | \
  grep -oP '(?<=")[^"]+' | \
  grep -E '(hl.bind | SUPER | ALT | XF86 | CTRL |)' | \
  fuzzel --dmenu --prompt " Atalhos:> " --match-mode=exact --no-sort --no-icons -l 30 -w 110
