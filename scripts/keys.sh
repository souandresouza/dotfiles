#!/bin/sh


grep -E "^\s*(NONE|bind|ALT|CTRL|SUPER|SHIFT|PRINT|super|alt|shift|ctrl|print|XF86)"\
 /home/andre/.config/mango/bind.conf |\
 fuzzel --dmenu --prompt " Buscar :>   " --match-mode=exact --no-sort --no-icons -l 30 -w 110 # for version >= 1.11.0-1
