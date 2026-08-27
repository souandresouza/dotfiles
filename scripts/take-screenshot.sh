#!/bin/bash
BASE_DIR="$HOME/Imagens/Screenshots"

DATE=$(date +%d-%m-%Y)
TIMESTAMP=$(date +%d%m%Y_%H%M%S)
OUTPUT="$BASE_DIR/$DATE/screenshot_${TIMESTAMP}.png"

mkdir -p "$(dirname "$OUTPUT")"

if ! GEOMETRY=$(slurp -d 2>/dev/null); then
    notify-send "Screenshot cancelado" "Nenhuma região selecionada"
    exit 0
fi

grim -g "$GEOMETRY" -t ppm - | satty --filename - --output-filename "$OUTPUT"

if [ $? -eq 0 ]; then
    notify-send "Screenshot salvo!" "📸 $OUTPUT"
else
    notify-send "Erro!" "Falha ao salvar screenshot" --urgency=critical
fi
