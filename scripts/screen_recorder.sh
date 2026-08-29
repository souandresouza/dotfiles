#!/usr/bin/env bash

RECORD_DIR="$HOME/Vídeos/Recordings"
DEVICE_NAME=""
TEMP_FILE="/tmp/screen_recorder_last.txt"
mkdir -p "$RECORD_DIR"

if pgrep -f "gpu-screen-recorder" > /dev/null; then
    # Stop recording
    pkill -f gpu-screen-recorder
    sleep 0.5
    notify-send "✅  Recording Stopped" "Saved in $RECORD_DIR" -t 3000

    # Pergunta se quer enviar para o celular
    if zenity --question --title="Enviar para celular?" \
              --text="Deseja enviar a gravação para o celular via LocalSend?\n\nO arquivo ficará salvo em:\n$RECORD_DIR" \
              --ok-label="Enviar" \
              --cancel-label="Não enviar" \
              --width=400; then

        FILENAME=$(cat "$TEMP_FILE" 2>/dev/null)
        if [ -z "$FILENAME" ]; then
            notify-send "Send failed" "Filename not found"
            exit 1
        fi

        # Verifica se localsend está instalado
        if ! command -v localsend &> /dev/null; then
            notify-send "LocalSend not found" "Please install localsend"
            exit 1
        fi

        # Envia via LocalSend CLI
        if localsend send "$RECORD_DIR/$FILENAME"; then
            notify-send "📤 Sent to phone" "$(basename "$FILENAME")"
        else
            notify-send "Send failed" "Saved locally at $RECORD_DIR/$FILENAME"
        fi
    else
        notify-send "💾 Recording saved" "File kept locally at $RECORD_DIR"
    fi

    rm -f "$TEMP_FILE"
else
    # Start recording
    FILENAME="Screen_recording_$(date +"%d%m%Y_%H%M%S").mkv"
    echo "$FILENAME" > "$TEMP_FILE"
    notify-send "🔴  Recording Started" "Press SUPER+SHIFT+R again to stop" -t 2000

    gpu-screen-recorder \
        -w screen \
        -f 60 \
        -q ultra \
        -a default_output \
        -o "$RECORD_DIR/$FILENAME" &
fi
