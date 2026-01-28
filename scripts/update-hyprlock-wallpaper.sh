#!/bin/bash
# ~/.config/scripts/update-hyprlock-wallpaper.sh

# Copia o wallpaper atual para o cache do hyprlock
cp ~/.cache/current_wallpaper_content ~/.cache/hyprlock_wallpaper 2>/dev/null || true

# Ou cria um wallpaper sólido se não existir
if [ ! -f ~/.cache/hyprlock_wallpaper ]; then
    convert -size 1920x1080 xc:"#1a1a1a" ~/.cache/hyprlock_wallpaper
fi