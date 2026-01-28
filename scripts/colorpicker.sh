#!/bin/bash

# Define as cores da borda do selecionador (estilo Archcraft)
selection=$(slurp -p -b 00000000 -c 00FFFFFF -w 2)

# Se o usuário cancelar, sai do script
if [ -z "$selection" ]; then
    exit 1
fi

# Captura a cor no ponto selecionado
COLOR=$(grim -g "$selection" -t ppm - | convert - -format '%[pixel:p{0,0}]' txt:- | tail -n 1 | cut -d ' ' -f 4)

# Gera o ícone do quadradinho de cor
PREVIEW_ICON="/tmp/color_preview.png"
convert -size 64x64 xc:"$COLOR" "$PREVIEW_ICON"

# Copia para o clipboard e notifica
echo -n "$COLOR" | wl-copy
notify-send -i "$PREVIEW_ICON" "Color Picker" "Cor $COLOR copiada!"
