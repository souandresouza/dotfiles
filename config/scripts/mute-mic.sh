#!/bin/bash

# Alterna o mute do microfone
wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

# Verifica se está mutado
STATUS=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@)

if echo "$STATUS" | grep -q "MUTED"; then
    # Ícone genérico se o do mic falhar
    notify-send -u low -i audio-volume-muted -r 2594 "Microfone" "Mutado"
else
    VOLUME=$(echo "$STATUS" | awk '{print $2 * 100 "%"}')
    notify-send -u low -i audio-volume-high -r 2594 "Microfone" "Ativo ($VOLUME)"
fi
