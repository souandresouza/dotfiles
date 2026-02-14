#!/bin/bash

# ~/.config/scripts/screenshot.sh

# Notificação mais compatível com Hyprland
notify() {
    if command -v notify-send &> /dev/null; then
        notify-send "$1" "$2" -i camera-photo -t 3000
    else
        echo "📸 $1 - $2"
    fi
}

# Detectar monitores automaticamente
detect_monitors() {
    LAPTOP="eDP-1"
    HDMI=$(hyprctl monitors -j | jq -r '.[] | select(.name | startswith("HDMI")) | .name' | head -1)
    DP=$(hyprctl monitors -j | jq -r '.[] | select(.name | startswith("DP")) | .name' | head -1)
}

# Configurações
DATA=$(date +"%d-%m-%Y")
HORA=$(date +"%H-%M-%S")
SCREENSHOT_DIR="$HOME/Pictures/Screenshots/$DATA"
mkdir -p "$SCREENSHOT_DIR"

detect_monitors

case "$1" in
    window)
        WINDOW_TITLE=$(hyprctl activewindow -j | jq -r '.title' 2>/dev/null | cut -c1-30 | sed 's/[^a-zA-Z0-9]/_/g')
        [ -z "$WINDOW_TITLE" ] && WINDOW_TITLE="window"
        FILENAME="janela_${WINDOW_TITLE}_${HORA}.png"
        hyprshot -m window -m active -o "$SCREENSHOT_DIR" -f "$FILENAME"
        ;;
    region)
        FILENAME="regiao_${HORA}.png"
        hyprshot -m region -o "$SCREENSHOT_DIR" -f "$FILENAME"
        ;;
    laptop)
        FILENAME="laptop_${HORA}.png"
        hyprshot -m output -m "$LAPTOP" -o "$SCREENSHOT_DIR" -f "$FILENAME"
        ;;
    monitor)
        if [ -n "$HDMI" ]; then
            FILENAME="hdmi_${HORA}.png"
            hyprshot -m output -m "$HDMI" -o "$SCREENSHOT_DIR" -f "$FILENAME"
        elif [ -n "$DP" ]; then
            FILENAME="displayport_${HORA}.png"
            hyprshot -m output -m "$DP" -o "$SCREENSHOT_DIR" -f "$FILENAME"
        else
            notify "Erro" "Nenhum monitor externo detectado"
            exit 1
        fi
        ;;
    all)
        FILENAME="tela_${HORA}.png"
        hyprshot -m output -o "$SCREENSHOT_DIR" -f "$FILENAME"
        ;;
    *)
        echo "Uso: $0 {window|region|laptop|monitor|all}"
        exit 1
        ;;
esac

if [ $? -eq 0 ]; then
    notify "📸 Screenshot" "Salvo: ~/Pictures/Screenshots/$DATA/$FILENAME"
    
    if command -v wl-copy &> /dev/null; then
        wl-copy < "$SCREENSHOT_DIR/$FILENAME"
        notify "📋 Clipboard" "Imagem copiada!"
    fi
fi
