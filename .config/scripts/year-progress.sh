#!/bin/bash
# year-progress.sh com barra visual

current_day=$((10#$(date +%j)))
year=$(date +%Y)
total_days=$(( (year%4==0 && year%100!=0) || year%400==0 ? 366 : 365 ))

# Porcentagem numérica
percentage=$(( (current_day * 1000) / total_days ))
integer=$((percentage / 10))
decimal=$((percentage % 10))

# Barra de progresso (10 blocos)
filled=$(( (current_day * 10) / total_days ))
empty=$((10 - filled))
bar=$(printf "%0.s█" $(seq 1 $filled))$(printf "%0.s░" $(seq 1 $empty))

echo "{\"text\": \"${bar} ${integer}.${decimal}%\", \"tooltip\": \"Dia ${current_day} de ${total_days}\"}"
