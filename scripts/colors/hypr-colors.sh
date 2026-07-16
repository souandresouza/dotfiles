#!/bin/sh
#hypr-colors.sh

# Extrair cores do colors.lua
COLORS_FILE="$HOME/.cache/wal/colors.lua"

# Verifica se o arquivo existe
if [ ! -f "$COLORS_FILE" ]; then
    echo "ERRO: Arquivo $COLORS_FILE não encontrado!"
    exit 1
fi

# Extrair cores - mantendo formato HEX
extract_color() {
    local color_name=$1
    local color_value
    
    # Tenta diferentes padrões de extração
    color_value=$(grep "$color_name" "$COLORS_FILE" | head -1 | sed -E 's/.*"([^"]+)".*/\1/' | tr -d ';#')
    
    # Se não encontrou com aspas, tenta sem aspas
    if [ -z "$color_value" ]; then
        color_value=$(grep "$color_name" "$COLORS_FILE" | head -1 | awk '{print $NF}' | tr -d ',;')
    fi
    
    # Remove # se existir
    color_value=$(echo "$color_value" | sed 's/^#//')
    
    echo "$color_value"
}

# Extrair as cores (mantém HEX)
color0=$(extract_color "color0")
color15=$(extract_color "color15")

# DEBUG
echo "DEBUG: color0 = [$color0]"
echo "DEBUG: color15 = [$color15]"

# Verifica se extraiu corretamente
if [ -z "$color0" ] || [ -z "$color15" ]; then
    echo "ERRO: Não consegui extrair as cores"
    echo "Conteúdo do arquivo:"
    cat "$COLORS_FILE"
    exit 1
fi

# Remove # se existir (por segurança)
background=$(echo "$color0" | sed 's/^#//')
active=$(echo "$color15" | sed 's/^#//')
inactive=$(echo "$color0" | sed 's/^#//')

echo "DEBUG: background = [$background]"
echo "DEBUG: active = [$active]"

# Cria o arquivo de configuração
mkdir -p "$HOME/.config/hypr/config"

cat >"$HOME/.config/hypr/config/colors.lua" <<EOF
local colors = {
    active_border = "rgba(${color15}ee)",
    inactive_border = "rgba(${color0}aa)"
}

return colors
EOF

# Recarrega o Hyprland
hyprctl reload