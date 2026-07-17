#!/bin/bash

# Diretório onde os vídeos serão salvos
VIDEO_DIR="$HOME/Vídeos/Recordings"

# Cria a pasta caso não exista
mkdir -p "$VIDEO_DIR"

# Nome do arquivo baseado na data e hora
FILE_NAME="$VIDEO_DIR/recording-$(date +%Y-%m-%d_%H-%M-%S).mp4"

# Verifica se o gpu-screen-recorder já está rodando
if pgrep -x "gpu-screen-recorder" > /dev/null
then
    # Para a gravação de forma suave (enviando SIGINT)
    pkill -INT -x "gpu-screen-recorder"
    notify-send "Gravador de Tela" "Gravação finalizada e salva!" -u low
else
    # Inicia a gravação pedindo para selecionar uma área (slurp)
    # Remova o ' -g "$(slurp)" ' se quiser gravar a tela inteira sempre.
    gpu-screen-recorder -g "$(slurp)" -f "$FILE_NAME" &
    notify-send "Gravador de Tela" "Gravação iniciada..." -u low
fi
