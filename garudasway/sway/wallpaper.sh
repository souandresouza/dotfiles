#!/usr/bin/env bash
# Script para mudar wallpapers aleatoriamente

WALL_PATH="$HOME/Imagens/backgrounds"

# Encontrar imagens de forma segura
mapfile -d $'\0' WALLPAPERS < <(find "$WALL_PATH" -type f -print0 2>/dev/null)
NUM_WALLPAPERS=${#WALLPAPERS[@]}

if [ $NUM_WALLPAPERS -eq 0 ]; then
    echo "Erro: Nenhuma imagem encontrada em $WALL_PATH" >&2
    exit 1
fi

# Primeiro wallpaper
NEW_WALL=${WALLPAPERS[$((RANDOM % NUM_WALLPAPERS))]}
swaybg -o "*" -i "$NEW_WALL" -m fill &
OLD_PID=$!

# Loop para trocar a cada 10 minutos
while true; do
    sleep 600
    
    # Novo wallpaper aleatório
    NEW_WALL=${WALLPAPERS[$((RANDOM % NUM_WALLPAPERS))]}
    echo "Mudando para: $NEW_WALL"
    
    # Iniciar novo processo
    swaybg -o "*" -i "$NEW_WALL" -m fill &
    NEW_PID=$!
    
    sleep 1
    kill $OLD_PID
    OLD_PID=$NEW_PID
done
