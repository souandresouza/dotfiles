#!/bin/bash

now=$(date +%s)
year=$(date +%Y)
start=$(date -d "$year-01-01" +%s)
end=$(date -d "$((year+1))-01-01" +%s)

# Calcula porcentagem
progress=$(echo "$now $start $end" | awk '{
    total = $3 - $2;
    elapsed = $1 - $2;
    printf "%.1f", (elapsed / total) * 100;
}')

# Cria barra de progresso visual (10 blocos)
filled=$(( ${progress%.*} / 10 ))
empty=$((10 - filled))

bar=""
for ((i=0; i<filled; i++)); do bar="${bar}█"; done
for ((i=0; i<empty; i++)); do bar="${bar}░"; done

# Saída no formato JSON para Waybar
echo "${progress}% ${bar}"
