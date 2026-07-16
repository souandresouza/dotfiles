#!/bin/bash
# ~/.config/hypr/scripts/record.sh

SAVE_DIR="$HOME/Vídeos/Recordings"
mkdir -p "$SAVE_DIR"

# Se já está gravando, PARA
if pgrep -f "gpu-screen-recorder" >/dev/null; then
    pkill -SIGINT -f "gpu-screen-recorder"
    notify-send -t 5000 "⏹️" "Video saved to $SAVE_DIR"
else
    # Começa gravação
    gpu-screen-recorder -w portal -q ultra -a default_output -ac opus -cr full -f 60 -o "$SAVE_DIR/$(date +%d-%m-%Y-%H-%M-%S).mp4" &
    notify-send -t 5000 "🔴" "Full screen"
fi
