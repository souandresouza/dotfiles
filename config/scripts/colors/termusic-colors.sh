#!/bin/sh

COLORS_FILE="$HOME/.cache/wal/colors.css"
TERMUSIC_FILE="$HOME/.config/termusic/themes/termusic-color.yml"

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

mkdir -p "$(dirname "$TERMUSIC_FILE")"
rm -f "$TERMUSIC_FILE"

cat > "$TERMUSIC_FILE" << EOF
# Colors (Base16 Default Dark)
colors:
  # Default colors
  primary:
    background: "${color0}"
    foreground: "${color7}"

  cursor:
    text: "${color7}"
    cursor: "${color7}"

  # Normal colors
  normal:
    black:   "${color0}"
    red:     "${color1}"
    green:   "${color2}"
    yellow:  "${color3}"
    blue:    "${color4}"
    magenta: "${color5}"
    cyan:    "${color6}"
    white:   "${color7}"

  # Bright colors
  bright:
    black:   "${color8}"
    red:     "${color9}"
    green:   "${color10}"
    yellow:  "${color11}"
    blue:    "${color12}"
    magenta: "${color13}"
    cyan:    "${color14}"
    white:   "${color15}"
EOF