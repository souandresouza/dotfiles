#!/bin/bash

WAL_COLORS="/home/andre/.cache/wal/colors.css"
DUNST_CONFIG_DIR="/home/andre/.config/dunst/"
DUNST_FILE="/home/andre/.config/dunst/dunstrc"

if [ ! -f "$WAL_COLORS" ]; then
    echo "Erro: $WAL_COLORS não encontrado"
    exit 1
fi

# Extrair cores - AJUSTE O CAMPO (print $2 ou $3) conforme seu arquivo
color0=$(grep 'color0' "$WAL_COLORS" | awk '{print $2}' | tr -d ';')
color15=$(grep 'color15' "$WAL_COLORS" | awk '{print $2}' | tr -d ';')
color7=$(grep 'color7' "$WAL_COLORS" | awk '{print $2}' | tr -d ';')

# DEBUG - Mostrar o que foi extraído
echo "DEBUG: color0 = [$color0]"
echo "DEBUG: color15 = [$color15]"
echo "DEBUG: color15 = [$color15]"

# Se estiver vazio, tenta com $3
if [ -z "$color0" ]; then
    color0=$(grep 'color0' "$WAL_COLORS" | awk '{print $3}' | tr -d ';')
    color15=$(grep 'color15' "$WAL_COLORS" | awk '{print $3}' | tr -d ';')
    color15=$(grep 'color15' "$WAL_COLORS" | awk '{print $3}' | tr -d ';')
    echo "DEBUG: Tentou com \$3 - color0 = [$color0]"
fi

# Se ainda estiver vazio, ERRO
if [ -z "$color0" ] || [ -z "$color15" ]; then
    echo "ERRO: Não consegui extrair as cores"
    echo "Conteúdo do arquivo:"
    cat "$WAL_COLORS"
    exit 1
fi

# Criar pasta de configuração se não existir
mkdir -p "$(dirname "$DUNST_CONFIG_DIR")"
mkdir -p "$(dirname "$DUNST_FILE")"

# Remover arquivo antigo se existir
rm -f "$DUNST_FILE"

# Criar a configuração do Dunst com as variáveis de cor
cat > "$DUNST_FILE" << EOF
[global]
    font = Monospace 8
    monitor = 0
    follow = mouse
    width = 320
    height = (0, 300)
    origin = top-right
    offset = (9, 9)

    icon_path = /usr/share/icons/gnome/16x16/status/:/usr/share/icons/gnome/16x16/devices/

    separator_color = frame
    frame_width = 3
    frame_color = "$color15"
    notification_limit = 20
    
    progress_bar = true
    progress_bar_height = 10
    progress_bar_frame_width = 1
    progress_bar_min_width = 150
    progress_bar_max_width = 300
    progress_bar_corner_radius = 4
    progress_bar_corners = all
    
    indicate_hidden = yes
    transparency = 0
    padding = 8
    horizontal_padding = 8
    text_icon_padding = 0
    gap_size = 0
    sort = yes
    
    line_height = 0
    markup = full
    alignment = center
    vertical_alignment = center
    show_age_threshold = 60
    ellipsize = middle
    ignore_newline = no
    stack_duplicates = true
    hide_duplicate_count = false
    show_indicators = yes
    enable_posix_regex = false
    enable_recursive_icon_lookup = true
    icon_theme = Adwaita
    icon_position = left
    max_icon_size = 128
    
    sticky_history = yes
    history_length = 20
    dmenu = /usr/bin/dmenu -p dunst:
    browser = /usr/bin/xdg-open
    always_run_script = true
    title = Dunst
    class = Dunst
    corner_radius = 4
    ignore_dbusclose = false
    layer = overlay
    force_xwayland = false
    force_xinerama = false
    mouse_left_click = close_current
    mouse_middle_click = do_action, close_current
    mouse_right_click = close_all

[urgency_low]
    background = "$color0"
    foreground = "$color15"
    timeout = 4
    default_icon = dialog-information

[urgency_normal]
    background = "$color0"
    foreground = "$color15"
    timeout = 5
    override_pause_level = 30
    default_icon = dialog-information

[urgency_critical]
    background = "#900000"
    foreground = "#ffffff"
    frame_color = "#ff0000"
    timeout = 0
    override_pause_level = 60
    default_icon = dialog-warning

EOF

# Recarregar ou iniciar o Dunst
pkill -SIGUSR1 -x dunst

echo "Dunst atualizado!"