#!/bin/bash
# Versão simplificada - apenas fuzzel

IMAGE_URL=$(echo "" | fuzzel --dmenu --prompt="🔗 Link da imagem: " --lines=0)

if [ -z "$IMAGE_URL" ]; then
    echo "Operação cancelada"
    exit 1
fi

# Extrai nome do arquivo
FILENAME=$(basename "$IMAGE_URL" | cut -d'?' -f1)
[ -z "$FILENAME" ] && FILENAME="imagem_$(date +%s).jpg"

# Pergunta nome para salvar
SAVE_NAME=$(echo "$FILENAME" | fuzzel --dmenu --prompt="💾 Salvar como: " --lines=0 --prepopulate="$FILENAME")

# Se não digitou nada, usa o nome extraído
[ -z "$SAVE_NAME" ] && SAVE_NAME="$FILENAME"

echo "📥 Baixando: $IMAGE_URL"
echo "💾 Salvando como: $SAVE_NAME"

# Gera QR code
qrencode -o qrcode.png "$IMAGE_URL" && echo "✅ QR code gerado: $SAVE_NAME_qrcode.png"

# Faz o download
if wget "$IMAGE_URL" -O "$SAVE_NAME"; then
    echo "✅ Download concluído com sucesso!"
    notify-send "✅ Download concluído" "Imagem salva como: $SAVE_NAME" --icon=document-save
else
    echo "❌ Falha no download"
    notify-send "❌ Erro" "Não foi possível baixar a imagem" --icon=dialog-error
fi
