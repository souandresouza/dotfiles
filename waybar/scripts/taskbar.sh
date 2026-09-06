#!/bin/bash
# ~/.config/waybar/scripts/taskbar.sh

# Pega processos com janelas (funciona em TODOS compositores)
windows=$(ps aux | grep -E "(thunar|firefox|code|alacritty|chromium|brave|discord|spotify|vlc|mpv|kitty|wezterm|foot|gedit|nautilus|dolphin|libreoffice|gimp|inkscape|blender|obsidian|telegram|slack|zoom|teams)" | grep -v grep | awk '{print $11}' | sed 's/.*\///' | sort | uniq -c)

if [ -z "$windows" ]; then
    echo '[]'
    exit 0
fi

# Converte pra JSON
echo "$windows" | while read count app; do
    if [ -n "$app" ]; then
        # Pega título do processo
        title=$(ps aux | grep "$app" | grep -v grep | head -1 | awk '{for(i=11;i<=NF;i++) print $i}' | head -1)
        echo "{\"class\":\"$app\",\"title\":\"$title\",\"count\":$count}"
    fi
done | jq -s '
    map({
        "text": .class + " " + (.count | tostring),
        "tooltip": .title,
        "class": .class
    })
'
