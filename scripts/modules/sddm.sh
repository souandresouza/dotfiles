apply_sddm() {
  # Define o destino do wallpaper do SDDM
  SDDM_BG_DEST="/usr/share/sddm/themes/sddm-astronaut-theme/Backgrounds/black_hole.png"

  # Verifica se o script está sendo executado como root
  if [[ $EUID -ne 0 ]]; then
    echo "❌ SDDM requer permissões de root."
    return 1
  fi

  # Verifica se o arquivo BASE_WALL existe
  if [[ ! -f "$BASE_WALL" ]]; then
    echo "❌ Arquivo de wallpaper não encontrado: $BASE_WALL"
    return 1
  fi

  # Verifica se o diretório de destino existe
  if [[ ! -d "$(dirname "$SDDM_BG_DEST")" ]]; then
    echo "❌ Diretório de destino do SDDM não encontrado: $(dirname "$SDDM_BG_DEST")"
    return 1
  fi

  # Copia o wallpaper para o destino do SDDM
  cp "$BASE_WALL" "$SDDM_BG_DEST"
  
  # Mensagem de sucesso
  echo "✅ Wallpaper atualizado no SDDM: $SDDM_BG_DEST"
}
