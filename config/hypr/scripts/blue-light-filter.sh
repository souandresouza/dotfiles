#!/bin/bash

# Script simples de filtro de luz azul

apply_night_mode() {
    echo "Aplicando filtro noturno..."
    # Usa um shader simples para warmer colors
    hyprctl keyword decoration:screen_shader "[[EMPTY]]"
    # Alternativa: usar gammastep se estiver instalado
    if command -v gammastep &> /dev/null; then
        pkill gammastep || true
        gammastep -O 4000 &
    fi
}

apply_day_mode() {
    echo "Voltando às cores normais..."
    hyprctl keyword decoration:screen_shader "[[EMPTY]]"
    if command -v gammastep &> /dev/null; then
        pkill gammastep || true
    fi
}

while true; do
    current_hour=$(date +%H)
    if [ "$current_hour" -ge 21 ] || [ "$current_hour" -lt 7 ]; then
        apply_night_mode
    else
        apply_day_mode
    fi
    # Verifica a cada 5 minutos
    sleep 300
done