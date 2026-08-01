#!/bin/bash

# 1. Ajusta o brilho do notebook primeiro
if [ "$1" == "--up" ]; then
    brightnessctl set +5%
elif [ "$1" == "--down" ]; then
    brightnessctl set 5%-
fi

# 2. Pega o brilho atual do notebook (ex: 45)
BRILHO_ATUAL=$(brightnessctl i | grep -oP '\(\K[0-9]+(?=%\))')

# 3. COMPENSAÇÃO MATEMÁTICA PARA O MONITOR HDMI
# Se o brilho for maior que 0, reduzimos um valor proporcional para o monitor externo não ficar muito claro.
# Exemplo: Quando o note estiver em 10%, o monitor vai para ~4% para compensar a luz forte dele.
if [ "$BRILHO_ATUAL" -gt 0 ]; then
    BRILHO_MONITOR=$(( BRILHO_ATUAL * BRILHO_ATUAL / 100 ))
    
    # Garante que o monitor não desligue totalmente a luz de fundo antes do notebook (mínimo de 1%)
    if [ "$BRILHO_MONITOR" -eq 0 ]; then
        BRILHO_MONITOR=1
    fi
else
    BRILHO_MONITOR=0
fi

# 4. Envia o valor compensado para o monitor Horizon
ddcutil --display 1 setvcp 10 "$BRILHO_MONITOR"

# 5. Envia a notificação para o Dunst (mostrando a porcentagem real do notebook)
notify-send -u low \
         -h string:x-canonical-private-synchronous:brilho \
         -h int:value:"$BRILHO_ATUAL" \
         -t 1500 \
         "🔆 Brilho: $BRILHO_ATUAL%"
