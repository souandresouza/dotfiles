#!/bin/bash

COLORS_FILE="$HOME/.cache/wal/colors.css"
ZATHURA_FILE=~/.config/zathura/zathurarc

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

# Limpar cores (remover colchetes, espaços e #)
clean_color() {
    echo "$1" | tr -d '[]# '
}

# DEBUG
echo "foreground = [$(clean_color "$foreground")]"
echo "background = [$(clean_color "$background")]"
echo "cursor = [$(clean_color "$cursor")]"
for i in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do
    eval "echo \"color$i = [\$(clean_color \"\$color$i\")]\""
done

# Verificar se as cores foram extraídas
if [ -z "$color0" ]; then
    echo "ERRO: Nenhuma cor extraída."
    exit 1
fi

mkdir -p "$(dirname "$ZATHURA_FILE")"

cat > "$ZATHURA_FILE" << EOF
# ==============================================================================
# Gerado em $(date)
# ==============================================================================

# UI and Window Settings
set girara-theme default
set guioptions "s"
set show-scrollbars false
set window-title-basename false

# Behaviour Settings
set pages-per-row 1
set scroll-step 40
set zoom-min 10
set zoom-max 1000
set adjust-open "best-fit"

# Cores do Pywal
set default-bg           "${color0}"
set default-fg           "${color7}"
set statusbar-bg         "${color0}"
set statusbar-fg         "${color7}"
set inputbar-bg          "${color0}"
set inputbar-fg          "${color5}"

# Highlight Colors (Hexadecimal com 80 no final para 50% de transparência)
set highlight-color        "${color2}80"
set highlight-active-color "${color4}80"

# Clipboard
set selection-clipboard "primary"

# Recolor (Dark Mode)
set recolor false
set recolor-lightcolor   "${color7}"
set recolor-darkcolor    "${color0}"
set recolor-reverse-video false
EOF

pkill -SIGUSR1 -x zathura