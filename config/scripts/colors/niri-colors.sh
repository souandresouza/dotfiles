#!/bin/sh

COLORS_FILE="$HOME/.cache/cwal/colors.css"
NIRI_FILE="$HOME/.config/niri/layout.kdl"

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

mkdir -p "$(dirname "$NIRI_FILE")"

# Criar configuração com alpha ff
cat > "$NIRI_FILE" << EOF
// Configurações de layout e aparência
layout {
    gaps 16
    center-focused-column "never"
    empty-workspace-above-first
    default-column-display "tabbed"
    background-color "${color0}"

    preset-column-widths {
        proportion 0.33333
        proportion 0.5
        proportion 0.66667
    }

    default-column-width { proportion 0.5; }

    preset-window-heights {
        proportion 0.33333
        proportion 0.5
        proportion 0.66667
    }

    focus-ring {
        on
        width 4
        active-color "${color15}"
        inactive-color "${color0}"
        urgent-color "#9b0000"
    }

    border {
        off
        width 4
        active-color "${color15}"
        inactive-color "${color0}"
        urgent-color "#9b0000"
    }

    shadow {
        off
        softness 30
        spread 5
        offset x=0 y=5
        draw-behind-window true
        color "${color0}"
    }

    tab-indicator {
        on
        hide-when-single-tab
        place-within-column
        gap 5
        width 4
        length total-proportion=1.0
        position "right"
        gaps-between-tabs 2
        corner-radius 8
        active-color "red"
        inactive-color "gray"
        urgent-color "blue"
    }

    insert-hint {
        on
        color "#ffc87f80"
    }
}
EOF

echo "Layout niri atualizado!"
