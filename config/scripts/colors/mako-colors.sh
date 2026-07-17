#!/bin/sh

COLORS_FILE="$HOME/.cache/wal/colors.css"
MAKO_FILE="$HOME/.config/mako/config"

if [ ! -f "$COLORS_FILE" ]; then
    echo "ERRO: Arquivo $COLORS_FILE não encontrado!"
    exit 1
fi

# Extrair cores do formato Pywal/CSS (--color0: #xxx;)
extract_color() {
    grep "\-\-color$1:" "$COLORS_FILE" | head -1 | awk -F': ' '{print $2}' | tr -d '; '
}

# Extrair background, foreground e cursor
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
if [ -z "$color0" ] || [ -z "$background" ]; then
    echo "ERRO: Cores não extraídas corretamente."
    exit 1
fi

mkdir -p "$(dirname "$MAKO_FILE")"
rm -f "$MAKO_FILE"

# Usa background como fundo, foreground como texto e color0 como borda
cat > "$MAKO_FILE" << EOF
sort=-time
layer=top
anchor=top-right
width=300
margin=12
height=150
border-size=4
border-radius=8
padding=20
icons=1
icon-location=left
markup=1
max-icon-size=64
default-timeout=5000
ignore-timeout=1
font=Millimetre 10
text-alignment=center
max-visible=5

background-color=${color0}
text-color=${color7}
border-color=${color1}

# urgency=low
# background-color=${color0}
# text-color=${color7}
# border-color=${color1}

# urgency=normal
# background-color=${color0}
# text-color=${color7}
# border-color=${color1}

# urgency=high
# background-color=#ff0033
# text-color=${color7}
# border-color=${color1}
EOF

# Recarrega o mako
makoctl reload