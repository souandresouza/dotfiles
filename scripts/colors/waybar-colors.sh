#!/bin/sh

COLORS_FILE="$HOME/.cache/wal/colors.css"
WAYBAR_FILE="$HOME/.config/waybar/colors-waybar.css"

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

mkdir -p "$(dirname "$WAYBAR_FILE")"
rm -f "$WAYBAR_FILE"

# Gerar arquivo no formato Waybar (sem aspas)
cat > "$WAYBAR_FILE" << EOF
@define-color foreground $foreground;
@define-color background $background;
@define-color cursor $cursor;

@define-color color0 $color0;
@define-color color1 $color1;
@define-color color2 $color2;
@define-color color3 $color3;
@define-color color4 $color4;
@define-color color5 $color5;
@define-color color6 $color6;
@define-color color7 $color7;
@define-color color8 $color8;
@define-color color9 $color9;
@define-color color10 $color10;
@define-color color11 $color11;
@define-color color12 $color12;
@define-color color13 $color13;
@define-color color14 $color14;
@define-color color15 $color15;
EOF