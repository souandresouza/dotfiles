#!/bin/bash

# Verifica se o controlador Bluetooth está ligado
if ! bluetoothctl show | grep -q "Powered: yes"; then
    echo '{"text": "󰂲", "tooltip": "Bluetooth Desligado"}'
    exit 0
fi

# Obtém dispositivos pareados e seus status
devices=$(bluetoothctl devices | awk '{print $2, $3}')
connected_list=""
available_list=""

while read -r mac alias; do
    # Limpa o alias
    alias=$(echo "$alias" | sed 's/_/ /g')
    
    # Verifica o status de conexão
    info=$(bluetoothctl info "$mac")
    if echo "$info" | grep -q "Connected: yes"; then
        connected_list="${connected_list} $alias\n"
    else
        available_list="${available_list}󰘔 $alias\n"
    fi
done <<< "$devices"

tooltip=""
if [ -n "$connected_list" ]; then
    tooltip="Conectados:\n$connected_list"
fi
if [ -n "$available_list" ]; then
    tooltip="${tooltip}Disponíveis:\n$available_list"
fi
if [ -z "$tooltip" ]; then
    tooltip="Nenhum dispositivo pareado encontrado."
fi

# Retorna JSON para a Waybar
echo "{\"text\": \"󰂯\", \"tooltip\": \"$tooltip\"}"