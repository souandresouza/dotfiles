#!/bin/bash

PASTA="/home/$USER/Downloads/movies/"
SAIDA="/home/$USER/Downloads/movies/video_saida.mp4"
LOG="/home/$USER/Downloads/movies/erro_ffmpeg.log"

cd "$PASTA" || exit 1

# Salva o erro no arquivo de log
ffmpeg -r 2 -pattern_type glob -i "*.png" -c:v libx264 -pix_fmt yuv420p "$SAIDA" 2> "$LOG"

if [ -f "$SAIDA" ] && [ -s "$SAIDA" ]; then
    echo "✅ VÍDEO GERADO: $SAIDA"
    rm -f "$LOG"
else
    echo "❌ ERRO! Log salvo em: $LOG"
    echo ""
    echo "Conteúdo do erro:"
    cat "$LOG"
fi
