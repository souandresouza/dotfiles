#!/bin/sh
# buscar atajos de teclado en niri/binds.kdl

grep -E "^\s*(Mod|Super|Alt|Shift|Ctrl|Print|XF86)"\
 $HOME/.config/niri/binds.kdl |\
 fuzzel --dmenu --prompt " Buscar :>   " --match-mode=exact --no-sort --no-icons -l 30 -w 110 # for version >= 1.11.0-1


