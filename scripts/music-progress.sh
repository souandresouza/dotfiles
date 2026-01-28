#!/bin/bash

# Script: ~/.config/scripts/music-progress.sh
# Certifique-se de que o caminho está correto!

# Get player status
status=$(playerctl status 2>/dev/null)

# Se não houver player ativo
if [[ -z "$status" ]]; then
    echo "No music playing"
    exit 0
fi

# Obtém artista e título
artist=$(playerctl metadata artist 2>/dev/null | head -c 30)
title=$(playerctl metadata title 2>/dev/null | head -c 30)

# Se não conseguir pegar metadata, tenta formato alternativo
if [[ -z "$artist" ]] && [[ -z "$title" ]]; then
    # Tenta pegar de xesam:artist e xesam:title
    artist=$(playerctl metadata xesam:artist 2>/dev/null | head -c 30)
    title=$(playerctl metadata xesam:title 2>/dev/null | head -c 30)
fi

# Primeira linha: Artista e Título
if [[ -n "$artist" ]] && [[ -n "$title" ]]; then
    echo "$artist - $title"
elif [[ -n "$title" ]]; then
    echo "$title"
elif [[ -n "$artist" ]]; then
    echo "$artist"
elif [[ "$status" == "Playing" ]] || [[ "$status" == "Paused" ]]; then
    echo "Playing"
else
    echo "No music playing"
    exit 0
fi

# Segunda linha: Progresso (apenas se estiver tocando ou pausado)
if [[ "$status" == "Playing" || "$status" == "Paused" ]]; then
    # Get current position and duration
    position=$(playerctl position 2>/dev/null)
    duration=$(playerctl metadata mpris:length 2>/dev/null)
    
    if [[ -n "$position" && -n "$duration" && $duration -gt 0 ]]; then
        # Convert from microseconds to seconds
        duration_sec=$(echo "scale=2; $duration / 1000000" | bc -l 2>/dev/null)
        
        if [[ -z "$duration_sec" ]] || [[ "$duration_sec" == "0" ]]; then
            echo "[No time data]"
            exit 0
        fi
        
        # Calculate percentage
        percentage=$(echo "scale=2; ($position / $duration_sec) * 100" | bc -l 2>/dev/null)
        
        # Se bc falhar, tenta cálculo simples
        if [[ -z "$percentage" ]]; then
            percentage=$(awk "BEGIN {printf \"%.0f\", ($position / $duration_sec) * 100}")
        fi
        
        # Formata a porcentagem como inteiro
        percentage_int=$(printf "%.0f" "$percentage")
        
        # Limita entre 0 e 100
        if [[ $percentage_int -lt 0 ]]; then
            percentage_int=0
        elif [[ $percentage_int -gt 100 ]]; then
            percentage_int=100
        fi
        
        # Format the progress bar
        width=15  # Width of the progress bar in characters
        filled=$(( (percentage_int * width) / 100 ))
        
        # Cria a barra de progresso
        bar="["
        for ((i=0; i<width; i++)); do
            if [ $i -lt $filled ]; then
                bar="${bar}━"
            elif [ $i -eq $filled ] && [ $filled -gt 0 ] && [ $filled -lt $width ]; then
                bar="${bar}▶"
            else
                bar="${bar}─"
            fi
        done
        bar="${bar}]"
        
        # Formata o tempo
        pos_min=$(printf "%02d" $(echo "$position / 60" | bc -l 2>/dev/null | cut -d. -f1))
        pos_sec=$(printf "%02d" $(echo "$position % 60" | bc -l 2>/dev/null | cut -d. -f1))
        dur_min=$(printf "%02d" $(echo "$duration_sec / 60" | bc -l 2>/dev/null | cut -d. -f1))
        dur_sec=$(printf "%02d" $(echo "$duration_sec % 60" | bc -l 2>/dev/null | cut -d. -f1))
        
        # Se os cálculos falharem, mostra apenas a barra
        if [[ -z "$pos_min" ]] || [[ "$pos_min" == "00" && "$pos_sec" == "00" ]]; then
            echo "$bar ${percentage_int}%"
        else
            echo "$bar ${pos_min}:${pos_sec} / ${dur_min}:${dur_sec}"
        fi
    else
        if [[ "$status" == "Paused" ]]; then
            echo "[PAUSED]"
        else
            echo "[PLAYING]"
        fi
    fi
elif [[ "$status" == "Stopped" ]]; then
    echo "[STOPPED]"
fi
