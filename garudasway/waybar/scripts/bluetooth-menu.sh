#!/bin/bash

# Gera a lista de dispositivos para o Rofi/Wofi
devices_list=$(bluetoothctl devices | awk '{gsub("_", " ", $3); print $2 " " $3}')

# Usa Rofi ou Wofi para mostrar o menu (altere para o que você usa)
chosen=$(echo -e "$devices_list" | wofi --dmenu -p "Dispositivos Bluetooth:" | cut -d ' ' -f 1)

if [ -n "$chosen" ]; then
    # Verifica se já está conectado
    info=$(bluetoothctl info "$chosen")
    if echo "$info" | grep -q "Connected: yes"; then
        bluetoothctl disconnect "$chosen"
        notify-send "Bluetooth" "Desconectado de $chosen"
    else
        bluetoothctl connect "$chosen"
        notify-send "Bluetooth" "Conectando a $chosen..."
    fi
fi