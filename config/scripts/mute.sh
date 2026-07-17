#!/bin/bash

# Alterna o mute do áudio
wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

# Verifica se está mutado
STATUS=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)

if echo "$STATUS" | grep -q "MUTED"; then
    # Se estiver mutado, manda notificação de mute
    notify-send -u low -i audio-volume-muted -r 2593 "Áudio" "Mutado"
else
    # Se não estiver mutado, mostra o volume atual
    VOLUME=$(echo "$STATUS" | awk '{print $2 * 100 "%"}')
    notify-send -u low -i audio-volume-high -r 2593 "Áudio" "Desmutado ($VOLUME)"
fi
