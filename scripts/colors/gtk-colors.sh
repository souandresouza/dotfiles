#!/bin/bash

# Script para converter cores do pywal para GTK CSS
# Uso: ./gtk-colors.sh

# Caminho do arquivo de cores do wal
WAL_COLORS="$HOME/.cache/wal/colors.css"
OUTPUT_FILE="$HOME/.config/gtk-3.0/gtk.css"
OUTPUT_FILE="$HOME/.config/gtk-4.0/gtk.css"

# Verifica se o arquivo de cores existe
if [ ! -f "$WAL_COLORS" ]; then
    echo "Arquivo de cores não encontrado: $WAL_COLORS"
    echo "Execute pywal primeiro ou verifique o caminho."
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

# Define a cor de acento (usa a cor1 como base)
ACCENT="$C1"

# Cria o diretório de saída se não existir
mkdir -p "$(dirname "$OUTPUT_FILE")"

# Gera o arquivo GTK CSS
cat > "$OUTPUT_FILE" << 'EOF'
/*
* GTK Colors - Gerado automaticamente do pywal
* Arquivo: 
EOF

echo "* Cores extraídas de: $WAL_COLORS" >> "$OUTPUT_FILE"
echo "*/" >> "$OUTPUT_FILE"

cat >> "$OUTPUT_FILE" << EOF

@define-color accent_color ${color6};
@define-color accent_bg_color ${color6};
@define-color accent_fg_color ${background};

@define-color destructive_color ${color6};
@define-color destructive_bg_color ${color6};
@define-color destructive_fg_color ${foreground};

@define-color success_color ${color2};
@define-color success_bg_color ${color2};
@define-color success_fg_color ${foreground};

@define-color warning_color ${color3};
@define-color warning_bg_color ${color3};
@define-color warning_fg_color ${background};

@define-color sidebar_bg_color ${background};
@define-color sidebar_fg_color ${foreground};
@define-color sidebar_border_color ${color8};
@define-color sidebar_backdrop_color ${background};

@define-color view_bg_color ${background};
@define-color view_fg_color ${foreground};

@define-color window_bg_color ${background};
@define-color window_fg_color ${foreground};

@define-color headerbar_bg_color ${background};
@define-color headerbar_fg_color ${foreground};
@define-color headerbar_border_color ${background};
@define-color headerbar_backdrop_color ${background};

@define-color card_bg_color ${color8};
@define-color card_fg_color ${foreground};

@define-color dialog_bg_color ${background};
@define-color dialog_fg_color ${foreground};
@define-color popover_bg_color ${background};
@define-color popover_fg_color ${foreground};

EOF

echo "Arquivo GTK CSS gerado com sucesso em: $OUTPUT_FILE"