#!/bin/bash
# ~/.config/waybar/toggle.sh

if pgrep -x "waybar" > /dev/null; then
    # Se waybar estiver rodando, mata ela (esconde)
    pkill waybar
else
    # Se não, inicia ela (exibe)
    waybar &
fi
