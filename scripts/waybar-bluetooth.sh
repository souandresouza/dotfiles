#!/bin/bash

# Tempo limite em segundos (10 minutos = 600 segundos)
TIMEOUT=600
CONTADOR=0

while true; do
    # Verifica se o Bluetooth está ligado (powered: yes)
    if bluetoothctl show | grep -q "Powered: yes"; then
        
        # Verifica se existe algum dispositivo conectado
        if bluetoothctl info | grep -q "Connected: yes"; then
            # Se houver conexão, reseta o contador
            CONTADOR=0
            OUTPUT='{"text": " Conectado", "class": "connected", "tooltip": "Bluetooth ativo e conectado"}'
        else
            # Se estiver ligado mas sem conexão, incrementa o tempo
            CONTADOR=$((CONTADOR + 10))
            RESTANTE=$((TIMEOUT - CONTADOR))
            
            OUTPUT="{\"text\": \" Ativo\", \"class\": \"disconnected\", \"tooltip\": \"Desligando em $((RESTANTE / 60))m\"}"
            
            # Se atingir os 10 minutos, desliga o Bluetooth
            if [ $CONTADOR -ge $TIMEOUT ]; then
                bluetoothctl power off
                CONTADOR=0
            fi
        fi
    else
        # Bluetooth está desligado
        CONTADOR=0
        OUTPUT='{"text": "   Inativo", "class": "disabled", "tooltip": "Bluetooth desligado"}'
    fi

    # Envia o JSON formatado para o Waybar
    echo "$OUTPUT"
    sleep 10
done
