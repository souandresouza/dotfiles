#!/bin/bash
# Monitor de Bateria para Hyprland/Arch Linux
# Rastreia ciclo de descarga desde desconexão até 20%

LOG_FILE="$HOME/.battery_history"
BATDIR="/sys/class/power_supply/BAT1"
NOTIFYSEND="/usr/bin/notify-send"
CHECK_INTERVAL=60  # segundos
THRESHOLD=15       # porcentagem para notificação
SESSION_START=""   # timestamp de quando desconectou

# Funções principais
get_battery_percentage() {
    local rem_cap full_cap
    rem_cap=$(cat "${BATDIR}/charge_now" 2>/dev/null || cat "${BATDIR}/energy_now")
    full_cap=$(cat "${BATDIR}/charge_full" 2>/dev/null || cat "${BATDIR}/energy_full")
    echo $((rem_cap * 100 / full_cap))
}

get_battery_status() {
    cat "${BATDIR}/status" 2>/dev/null || echo "Unknown"
}

log_event() {
    echo "$(date '+%d-%m-%Y %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Configuração inicial
log_event "=== Iniciando monitor de bateria ==="
log_event "Threshold configurado: ${THRESHOLD}%"
log_event "Dispositivo: $(uname -n)"

# Loop principal de monitoramento
while true; do
    STATUS=$(get_battery_status)
    CHARGE=$(get_battery_percentage)
    
    case "$STATUS" in
        "Discharging")
            # Início do ciclo de descarga
            if [ -z "$SESSION_START" ]; then
                SESSION_START=$(date '+%d-%m-%Y %H:%M:%S')
                log_event "🔌 Desconectado - Bateria em ${CHARGE}%"
                $NOTIFYSEND -u low -t 2000 "Bateria" "Monitorando descarga iniciada em ${CHARGE}%"
            fi
            
            # Verificação do threshold
            if [ "$CHARGE" -le "$THRESHOLD" ]; then
                log_event "⚠️  ALERTA - Bateria em ${CHARGE}% (início: $SESSION_START)"
                $NOTIFYSEND -u critical -t 0 "🔋 Bateria Crítica!" \
                    "Conecte o carregador! (${CHARGE}%)\nDescarga iniciou às $SESSION_START"
                
                # Aguarda reconexão
                while [ "$(get_battery_status)" = "Discharging" ]; do
                    sleep 10
                done
                
                DURATION=$(( $(date +%s) - $(date -d "$SESSION_START" +%s) ))
                log_event "🔌 Reconectado após $(($DURATION/60)) minutos $(($DURATION%60)) segundos de uso"
                SESSION_START=""
            fi
            ;;
            
        "Charging"|"Full")
            # Fim do ciclo de descarga (se existia um)
            if [ -n "$SESSION_START" ]; then
                DURATION=$(( $(date +%s) - $(date -d "$SESSION_START" +%s) ))
                log_event "⚡ Conectado - Bateria em ${CHARGE}% (descarga durou $(($DURATION/60))min)"
                SESSION_START=""
            fi
            ;;
    esac
    
    sleep "$CHECK_INTERVAL"
done
