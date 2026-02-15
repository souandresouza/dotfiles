#!/bin/bash

# ~/.config/scripts/screenshot.sh

# Configurações de notificação
NOTIFY_TIMEOUT=5000  # 5 segundos em milissegundos
NOTIFY_URGENCY="normal"  # pode ser "low", "normal" ou "critical"

# Função de notificação otimizada para Dunst
notify() {
    local title="$1"
    local message="$2"
    local urgency="${3:-$NOTIFY_URGENCY}"
    local timeout="${4:-$NOTIFY_TIMEOUT}"
    
    if command -v notify-send &> /dev/null; then
        # Usando parâmetros específicos do Dunst
        notify-send -u "$urgency" -t "$timeout" -i camera-photo \
            -a "Screenshot" \
            -h string:x-dunst-stack-tag:screenshot \
            "$title" "$message"
        
        # Log para debug (opcional)
        echo "[$(date +'%H:%M:%S')] Notificação: $title - $message" >> /tmp/screenshot_notify.log
    else
        # Fallback para terminal
        echo "📸 $title - $message"
    fi
}

# Função para notificação de progresso/status
notify_with_action() {
    local title="$1"
    local message="$2"
    local file="$3"
    
    if command -v notify-send &> /dev/null; then
        # Notificação com ação de abrir a pasta
        notify-send -u "normal" -t 7000 -i camera-photo \
            -a "Screenshot" \
            -h string:x-dunst-stack-tag:screenshot \
            "$title" "$message" \
            --action="open=📂 Abrir pasta" \
            --action="view=👁️ Visualizar"
        
        # Monitorar resposta da ação (requer suporte do Dunst)
        # Nota: Isso é opcional e depende do seu gerenciador de notificações
    else
        notify "$title" "$message"
    fi
}

# Função para verificar se o Dunst está rodando
check_dunst() {
    if pgrep -x "dunst" > /dev/null; then
        return 0  # Dunst está rodando
    else
        return 1  # Dunst não está rodando
    fi
}

# Detectar monitores automaticamente
detect_monitors() {
    LAPTOP="eDP-1"
    HDMI=$(hyprctl monitors -j | jq -r '.[] | select(.name | startswith("HDMI")) | .name' | head -1)
    DP=$(hyprctl monitors -j | jq -r '.[] | select(.name | startswith("DP")) | .name' | head -1)
}

# Verificar Dunst status
if check_dunst; then
    notify "Screenshot" "Script iniciado - Pronto para capturar" "low" 2000
fi

# Configurações
DATA=$(date +"%d-%m-%Y")
HORA=$(date +"%H-%M-%S")
SCREENSHOT_DIR="$HOME/Pictures/Screenshots/$DATA"
mkdir -p "$SCREENSHOT_DIR"

detect_monitors

# Variável para armazenar o tipo de captura
CAPTURE_TYPE=""

case "$1" in
    window)
        CAPTURE_TYPE="Janela"
        WINDOW_TITLE=$(hyprctl activewindow -j | jq -r '.title' 2>/dev/null | cut -c1-30 | sed 's/[^a-zA-Z0-9]/_/g')
        [ -z "$WINDOW_TITLE" ] && WINDOW_TITLE="window"
        FILENAME="janela_${WINDOW_TITLE}_${HORA}.png"
        notify "Iniciando captura" "Capturando janela ativa..." "normal" 2000
        hyprshot -m window -m active -o "$SCREENSHOT_DIR" -f "$FILENAME"
        ;;
    region)
        CAPTURE_TYPE="Região"
        FILENAME="regiao_${HORA}.png"
        notify "Selecione uma região" "Clique e arraste para selecionar" "normal" 3000
        hyprshot -m region -o "$SCREENSHOT_DIR" -f "$FILENAME"
        ;;
    laptop)
        CAPTURE_TYPE="Laptop"
        FILENAME="laptop_${HORA}.png"
        notify "Capturando tela" "Monitor interno: $LAPTOP" "normal" 2000
        hyprshot -m output -m "$LAPTOP" -o "$SCREENSHOT_DIR" -f "$FILENAME"
        ;;
    monitor)
        CAPTURE_TYPE="Monitor Externo"
        if [ -n "$HDMI" ]; then
            FILENAME="hdmi_${HORA}.png"
            notify "Capturando monitor" "HDMI conectado: $HDMI" "normal" 2000
            hyprshot -m output -m "$HDMI" -o "$SCREENSHOT_DIR" -f "$FILENAME"
        elif [ -n "$DP" ]; then
            FILENAME="displayport_${HORA}.png"
            notify "Capturando monitor" "DisplayPort conectado: $DP" "normal" 2000
            hyprshot -m output -m "$DP" -o "$SCREENSHOT_DIR" -f "$FILENAME"
        else
            notify "❌ Erro" "Nenhum monitor externo detectado" "critical" 8000
            exit 1
        fi
        ;;
    all)
        CAPTURE_TYPE="Toda a tela"
        FILENAME="tela_${HORA}.png"
        notify "Capturando" "Todos os monitores" "normal" 2000
        hyprshot -m output -o "$SCREENSHOT_DIR" -f "$FILENAME"
        ;;
    *)
        echo "Uso: $0 {window|region|laptop|monitor|all}"
        exit 1
        ;;
esac

# Verificar resultado da captura
if [ $? -eq 0 ]; then
    FULL_PATH="$SCREENSHOT_DIR/$FILENAME"
    
    # Verificar se o arquivo foi criado
    if [ -f "$FULL_PATH" ]; then
        # Notificação principal com detalhes
        notify_with_action "✅ Screenshot capturado!" \
            "📁 $CAPTURE_TYPE\n📄 $FILENAME\n📊 $(du -h "$FULL_PATH" | cut -f1)" \
            "$FULL_PATH"
        
        # Copiar para clipboard se disponível
        if command -v wl-copy &> /dev/null; then
            wl-copy < "$FULL_PATH"
            # Notificação adicional para clipboard
            notify "📋 Imagem copiada!" \
                "Pronta para colar (Ctrl+V)" \
                "normal" 3000
        fi
        
        # Notificação de sucesso estendida
        notify "📸 Captura concluída" \
            "Salvo em: ~/Pictures/Screenshots/$DATA/\nTamanho: $(du -h "$FULL_PATH" | cut -f1)" \
            "normal" 7000
    else
        notify "❌ Erro" "Arquivo não foi criado" "critical" 8000
    fi
else
    # Notificação de erro
    notify "❌ Falha na captura" \
        "Não foi possível capturar a tela\nModo: $CAPTURE_TYPE" \
        "critical" 8000
fi

# Notificação final (opcional)
notify "🖼️ Screenshot Manager" "Processo finalizado" "low" 3000
