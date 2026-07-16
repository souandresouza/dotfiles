#!/bin/sh

COLORS_FILE="$HOME/.cache/wal/colors.css"
CAVA_FILE="$HOME/.config/cava/themes/colors"

if [ ! -f "$COLORS_FILE" ]; then
    echo "ERRO: Arquivo $COLORS_FILE não encontrado!"
    exit 1
fi

# Extrair cores do formato Pywal/CSS (--color0: #xxx;)
extract_color() {
    grep "\-\-color$1:" "$COLORS_FILE" | head -1 | awk -F': ' '{print $2}' | tr -d '; '
}

# Extrair também background, foreground e cursor
background=$(grep "\-\-background:" "$COLORS_FILE" | head -1 | awk -F': ' '{print $2}' | tr -d '; ')
foreground=$(grep "\-\-foreground:" "$COLORS_FILE" | head -1 | awk -F': ' '{print $2}' | tr -d '; ')
cursor=$(grep "\-\-cursor:" "$COLORS_FILE" | head -1 | awk -F': ' '{print $2}' | tr -d '; ')

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

# DEBUG
echo "foreground = [$foreground]"
echo "background = [$background]"
echo "cursor = [$cursor]"
for i in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do
    eval "echo \"color$i = [\$color$i]\""
done

# Verificar se as cores foram extraídas
if [ -z "$color0" ]; then
    echo "ERRO: Nenhuma cor extraída."
    exit 1
fi

mkdir -p "$(dirname "$CAVA_FILE")"
rm -f "$CAVA_FILE"

# Criar configuração com alpha ff
cat > "$CAVA_FILE" << EOF
[color]

gradient = 1
gradient_color_1 = '${color0}'
gradient_color_2 = '${color1}'
gradient_color_3 = '${color2}'
gradient_color_4 = '${color3}'
gradient_color_5 = '${color4}'
gradient_color_6 = '${color5}'
gradient_color_7 = '${color6}'
gradient_color_8 = '${color7}'

horizontal_gradient = 1
horizontal_gradient_color_1 = '${color8}'
horizontal_gradient_color_2 = '${color9}'
horizontal_gradient_color_3 = '${color10}'
horizontal_gradient_color_4 = '${color11}'
horizontal_gradient_color_5 = '${color12}'
horizontal_gradient_color_6 = '${color13}'
horizontal_gradient_color_6 = '${color14}'
horizontal_gradient_color_6 = '${color15}'

blend_direction = 'right'

EOF

pkill -USR2 cava