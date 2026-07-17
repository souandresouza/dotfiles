#!/usr/bin/env bash
set -euo pipefail

dir_alvo="/home/$USER/Downloads/"

echo "Iniciando processamento de imagens em: $dir_alvo"
echo "=============================================="

# Processar HEIC/HEIF separadamente (mais robusto)
echo -e "\n🔵 PROCESSANDO ARQUIVOS HEIC/HEIF"

while IFS= read -r -d '' arquivo; do
    nome_base=$(basename "$arquivo")
    dir_arquivo=$(dirname "$arquivo")
    arquivo_png="${dir_arquivo}/${nome_base%.*}.png"
    
    echo "  📸 Convertendo: $nome_base"
    
    # Detectar tipo MIME
    mime_type=$(file --mime-type -b "$arquivo")
    echo "     Tipo: $mime_type"
    
    # Usar ImageMagick diretamente (mais confiável)
    if magick convert "$arquivo" -quality 90 "$arquivo_png" 2>&1; then
        if [ -f "$arquivo_png" ] && [ -s "$arquivo_png" ]; then
            rm "$arquivo"
            echo "     ✅ CONVERTIDO COM SUCESSO: $(basename "$arquivo_png")"
            ls -lh "$arquivo_png"
        else
            echo "     ❌ Arquivo PNG não foi criado corretamente"
        fi
    else
        echo "     ❌ Falha na conversão"
        # Tentativa com heif-convert como fallback
        echo "     Tentando heif-convert..."
        if heif-convert -q 90 "$arquivo" "$arquivo_png" 2>&1; then
            rm "$arquivo"
            echo "     ✅ CONVERTIDO (heif-convert): $nome_base"
        else
            echo "     ❌ Falha total na conversão de: $nome_base"
        fi
    fi
done < <(find "$dir_alvo" -type f \( -iname "*.heic" -o -iname "*.HEIC" -o -iname "*.heif" -o -iname "*.HEIF" \) -print0 2>/dev/null || true)

# Processar outros formatos
for ext in jpg jpeg JPEG webp WEBP; do
    echo -e "\n🔵 PROCESSANDO ARQUIVOS .$ext"
    
    while IFS= read -r -d '' arquivo; do
        nome_base=$(basename "$arquivo")
        arquivo_png="${arquivo%.*}.png"
        
        echo "  Convertendo: $nome_base"
        
        if magick convert "$arquivo" -quality 90 "$arquivo_png" 2>/dev/null; then
            rm "$arquivo"
            echo "    ✅ Convertido: $(basename "$arquivo_png")"
        else
            echo "    ❌ Falha: $nome_base"
        fi
    done < <(find "$dir_alvo" -type f -iname "*.$ext" -print0 2>/dev/null || true)
done

# Redimensionar PNGs
echo -e "\n🔵 REDIMENSIONANDO PNGs PARA 1080p"

find "$dir_alvo" -type f -iname "*.png" -print0 | while IFS= read -r -d '' arquivo_png; do
    nome_base=$(basename "$arquivo_png")
    
    # Obter dimensões
    dimensoes=$(magick identify -format "%wx%h" "$arquivo_png" 2>/dev/null)
    
    if [ -n "$dimensoes" ]; then
        largura=$(echo "$dimensoes" | cut -d'x' -f1)
        altura=$(echo "$dimensoes" | cut -d'x' -f2)
        
        if (( largura > 1920 || altura > 1080 )); then
            echo "  📐 Redimensionando: $nome_base (${largura}x${altura})"
            magick convert "$arquivo_png" -resize 1920x1080\> -quality 90 "${arquivo_png}.tmp" && \
            mv "${arquivo_png}.tmp" "$arquivo_png"
            echo "    ✅ Redimensionado para 1080p"
        fi
    fi
done

echo -e "\n✅ PROCESSAMENTO CONCLUÍDO!"
