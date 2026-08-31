#!/bin/sh

COLORS_FILE="$HOME/.cache/wal/colors.css"
MANGO_FILE="$HOME/.config/mango/theme.conf"

if [ ! -f "$COLORS_FILE" ]; then
    echo "ERRO: Arquivo $COLORS_FILE não encontrado!"
    exit 1
fi

# Extrair cores do formato Pywal/CSS (--color0: #xxx;)
extract_color() {
    grep -- "--color$1:" "$COLORS_FILE" | head -1 | awk -F': ' '{print $2}' | tr -d '; '
}

# Extrair também background, foreground e cursor
background=$(grep -- "--background:" "$COLORS_FILE" | head -1 | awk -F': ' '{print $2}' | tr -d '; ')
foreground=$(grep -- "--foreground:" "$COLORS_FILE" | head -1 | awk -F': ' '{print $2}' | tr -d '; ')
cursor=$(grep -- "--cursor:" "$COLORS_FILE" | head -1 | awk -F': ' '{print $2}' | tr -d '; ')

# Extrair cores 0-15
color0=$(extract_color 0)
color1=$(extract_color 1)
color2=$(extract_color 2)
color3=$(extract_color 3)
color4=$(extract_color 4)
color5=$(extract_color 5)
color6=$(extract_color 6)
color7=$(extract_color 7)
color8=$(extract_color 8)
color9=$(extract_color 9)
color10=$(extract_color 10)
color11=$(extract_color 11)
color12=$(extract_color 12)
color13=$(extract_color 13)
color14=$(extract_color 14)
color15=$(extract_color 15)

# Limpar cores (remover #, colchetes, espaços e outros caracteres especiais)
clean_color() {
    echo "$1" | sed 's/[^a-fA-F0-9]//g'
}

# Limpar todas as cores
background=$(clean_color "$background")
foreground=$(clean_color "$foreground")
cursor=$(clean_color "$cursor")
color0=$(clean_color "$color0")
color1=$(clean_color "$color1")
color2=$(clean_color "$color2")
color3=$(clean_color "$color3")
color4=$(clean_color "$color4")
color5=$(clean_color "$color5")
color6=$(clean_color "$color6")
color7=$(clean_color "$color7")
color8=$(clean_color "$color8")
color9=$(clean_color "$color9")
color10=$(clean_color "$color10")
color11=$(clean_color "$color11")
color12=$(clean_color "$color12")
color13=$(clean_color "$color13")
color14=$(clean_color "$color14")
color15=$(clean_color "$color15")

# DEBUG
echo "foreground = [$foreground]"
echo "background = [$background]"
echo "cursor = [$cursor]"
for i in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do
    eval "echo \"color$i = [\$(eval echo \"\\\$color$i\")]\""
done

# Verificar se as cores foram extraídas
if [ -z "$color0" ]; then
    echo "ERRO: Nenhuma cor extraída."
    exit 1
fi

mkdir -p "$(dirname "$MANGO_FILE")"

# Criar configuração com alpha ff
cat > "$MANGO_FILE" << EOF
shadowscolor= 0x${color0}ff
rootcolor=0x${color0}ff
bordercolor=0x${color6}ff
dropcolor=0x${color6}55
splitcolor=0x${color14}ff
focuscolor=0x${color5}ff
maximizescreencolor=0x${color6}ff
urgentcolor=0x${color7}ff
scratchpadcolor=0x${color13}ff
globalcolor=0x${color5}ff
overlaycolor=0x${color14}ff
EOF

echo "Configuração gerada em $MANGO_FILE"
mangoctl reload
