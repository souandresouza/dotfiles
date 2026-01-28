#!/usr/bin/env bash

# Serviços de upload alternativos (alguns podem ser mais rápidos)
UPLOAD_SERVICES=(
    "https://uguu.se/upload"
    "https://bashupload.com/"
    "https://transfer.sh/"
)

# Função para tentar upload em diferentes serviços
upload_image() {
    local file="$1"
    
    # Primeiro tentativa com uguu.se
    local link=$(curl -sF files[]=@"$file" 'https://uguu.se/upload' | jq -r '.files[0].url' 2>/dev/null)
    
    if [[ -n "$link" && "$link" != "null" ]]; then
        echo "$link"
        return 0
    fi
    
    # Fallback para transfer.sh
    link=$(curl --upload-file "$file" "https://transfer.sh/$(basename "$file")" 2>/dev/null)
    
    if [[ -n "$link" ]]; then
        echo "$link"
        return 0
    fi
    
    return 1
}

# Captura
grim -g "$(slurp)" /tmp/image.png || exit 1

# Upload
notify-send "Google Lens" "📤 Uploading image..."
link=$(upload_image /tmp/image.png)

if [[ -n "$link" ]]; then
    echo "$link" | wl-copy
    xdg-open "https://lens.google.com/uploadbyurl?url=${link}"
    notify-send "Google Lens" "✅ Success!\n📋 Link copied"
else
    notify-send "Google Lens" "❌ Upload failed"
fi

rm -f /tmp/image.png
