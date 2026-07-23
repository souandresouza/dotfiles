#!/bin/bash

# Caminho do arquivo de histórico do wallpaper
WALLPAPER_HISTORY="$HOME/.cache/wallpapers/wallpaper_history.txt"
# Caminho do arquivo de configuração do hyprlock
HYPRLOCK_CONF="$HOME/.config/hypr/hyprlock.conf"
profile="$HOME/Documentos/eu.png"
wallpaper="$HOME/.cache/current_wallpaper.png"
font_family="Nasalization"

# Verifica se o arquivo de histórico existe
if [ ! -f "$WALLPAPER_HISTORY" ]; then
    echo "Erro: Arquivo $WALLPAPER_HISTORY não encontrado!"
    exit 1
fi

# Lê a primeira linha do arquivo (caminho do wallpaper atual)
WALLPAPER_PATH=$(head -n 1 "$WALLPAPER_HISTORY")

# Verifica se o caminho foi lido corretamente
if [ -z "$WALLPAPER_PATH" ]; then
    echo "Erro: Não foi possível ler o caminho do wallpaper do arquivo!"
    exit 1
fi

# Verifica se o arquivo de wallpaper existe
if [ ! -f "$WALLPAPER_PATH" ]; then
    echo "Erro: Arquivo de wallpaper $WALLPAPER_PATH não encontrado!"
    exit 1
fi

# Cria o diretório de configuração do hyprlock se não existir
mkdir -p "$(dirname "$HYPRLOCK_CONF")"

# Gera o arquivo hyprlock.conf
cat > "$HYPRLOCK_CONF" << EOF
# Configuração gerada automaticamente
# Wallpaper atual: $WALLPAPER_PATH

font_family = $font_family
wallpaper = "$HOME/.cache/current_wallpaper.png"
profile = $HOME/Documentos/eu.png
inner_color  = #c8c8c8
border_color = #111111
gradient = #30bfee, #01ee8f 45deg

general {
    ignore_empty_input = true
    grace = 0
}

# Background
background {
    monitor =
    path = $wallpaper
    brightness = 0.5
    blur_passes = 2 # 0 disables blurring
    blur_size = 7
}

# Profile Picture
image {
    monitor =
    path = $HOME/Documentos/eu.png
    size = 110
    rounding = 10
    border_size = 4
    border_color = $inner_color

    position = 20, -20
    halign = left
    valign = top
    zindex = 1
}

# User Info
label {
    monitor =
    text = cmd[update:1000000] /home/andre/.config/scripts/contador_pacotes.sh
    shadow_boost = 0.5
    shadow_passes = 1
    color = 
    font_size = 11
    font_family = Nasalization

    position = 170, -35
    halign = left
    valign = top
}

# DATE
label {
    monitor =
    text = cmd[update:18000000] echo "<b> "$(date +'%A, %-d %B %Y')" </b>"
    color = $border_color
    font_size = 30
    font_family = $font_family
    position = 0, 200
    halign = center
    valign = center
}

# TIME HR
label {
    monitor =
    text = cmd[update:1000] date +"%H:"
    color = $border_color
    shadow_size = 3
    shadow_color = rgb(0,0,0)
    shadow_boost = 1.2
    font_size = 200
    font_family = $font_family
    position = -410, -10
    halign = center
    valign = center
    zindex = 5
}

# TIME MIN
label {
    monitor =
    text = cmd[update:1000] date +"%M:"
    color = $border_color
    font_size = 200
    font_family = $font_family
    position = 10, -15
    halign = center
    valign = center
    zindex = 5
}

# TIME SEC
label {
    monitor =
    text = cmd[update:1000] date +"%S"
    color = $border_color
    shadow_size = 3
    shadow_color = rgb(0,0,0)
    shadow_boost = 1.2
    font_size = 200
    font_family = $font_family
    position = 400, -6
    halign = center
    valign = center
    zindex = 5
}

# Input Field
input-field {
    monitor =
    size = 200, 50
    outline_thickness = 3
    dots_size = 0.33
    dots_spacing = 0.15
    dots_center = true
    dots_rounding = -1
    outer_color = $gradient
    inner_color = $inner_color
    font_color = white
    fade_on_empty = true
    fade_timeout = 1000
    placeholder_text = Digite a senha...</i>
    hide_input = false
    rounding = -1
    check_color = blue
    fail_color = red
    fail_text = <i>$FAIL <b>($ATTEMPTS)</b></i>
    fail_transition = 300
    capslock_color = $border_color
    numlock_color = -1
    bothlock_color = -1
    invert_numlock = false
    swap_font_color = false
    position = 0, -200
    halign = center
    valign = center
}

label { # Status
    monitor =
    text = cmd[update:5000] ${XDG_CONFIG_HOME:-$HOME/.config}/scripts/music-progress.sh
    color = $gradient
    font_size = 14
    font_family = $font_family

    position = 30, 30
    halign = center
    valign = bottom
}
label { # Status
    monitor =
    text = cmd[update:86400] ${XDG_CONFIG_HOME:-$HOME/.config}/scripts/year-progress.sh
    color = $gradient
    font_size = 14
    font_family = $font_family

    position = 500, 30
    halign = center
    valign = bottom
}
label { # Status
    monitor =
    text = cmd[update:300] ${XDG_CONFIG_HOME:-$HOME/.config}/scripts/battery-status.sh
    color = $gradient
    font_size = 14
    font_family = $font_family

    position = -500, 30
    halign = center
    valign = bottom
}
EOF

echo "hyprlock.conf gerado com sucesso!"
echo "Wallpaper: $WALLPAPER_PATH"
echo "Arquivo salvo em: $HYPRLOCK_CONF"