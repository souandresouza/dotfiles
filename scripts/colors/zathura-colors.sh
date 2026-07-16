#!/bin/bash

WAL_COLORS="/home/andre/.cache/cadroc/colors.css"

if [ ! -f "$WAL_COLORS" ]; then
    echo "Erro: $WAL_COLORS não encontrado"
    exit 1
fi

# Extrair cores principais do Pywal
color0=$(grep 'color0' "$WAL_COLORS" | awk '{print $3}' | tr -d ';')
color1=$(grep 'color1' "$WAL_COLORS" | awk '{print $3}' | tr -d ';')
color2=$(grep 'color2' "$WAL_COLORS" | awk '{print $3}' | tr -d ';')
color3=$(grep 'color3' "$WAL_COLORS" | awk '{print $3}' | tr -d ';')
color4=$(grep 'color4' "$WAL_COLORS" | awk '{print $3}' | tr -d ';')
color5=$(grep 'color5' "$WAL_COLORS" | awk '{print $3}' | tr -d ';')
color6=$(grep 'color6' "$WAL_COLORS" | awk '{print $3}' | tr -d ';')
color7=$(grep 'color7' "$WAL_COLORS" | awk '{print $3}' | tr -d ';')
color8=$(grep 'color8' "$WAL_COLORS" | awk '{print $3}' | tr -d ';')
color9=$(grep 'color9' "$WAL_COLORS" | awk '{print $3}' | tr -d ';')
color10=$(grep 'color10' "$WAL_COLORS" | awk '{print $3}' | tr -d ';')
color11=$(grep 'color11' "$WAL_COLORS" | awk '{print $3}' | tr -d ';')
color12=$(grep 'color12' "$WAL_COLORS" | awk '{print $3}' | tr -d ';')
color13=$(grep 'color13' "$WAL_COLORS" | awk '{print $3}' | tr -d ';')
color14=$(grep 'color14' "$WAL_COLORS" | awk '{print $3}' | tr -d ';')
color15=$(grep 'color15' "$WAL_COLORS" | awk '{print $3}' | tr -d ';')

# Carrega as cores do pywal
source ~/.cache/cadroc/colors.sh

# Define o arquivo de saída
CONFIG_FILE=~/.config/zathura/zathurarc

cat > "$CONFIG_FILE" << EOF
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