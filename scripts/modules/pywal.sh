apply_pywal() {
  # Verifica se o comando wal está disponível
  if ! command -v wal &>/dev/null; then
    echo "❌ pywal não encontrado, não é possível aplicar o wallpaper."
    return 0
  fi

  # Verifica se o arquivo de wallpaper existe
  if [[ ! -f "$BASE_WALL" ]]; then
    echo "❌ Arquivo de wallpaper não encontrado: $BASE_WALL"
    return 1
  fi

  # Aplica o wallpaper com o pywal
  echo "Aplicando wallpaper com pywal: $BASE_WALL"
  wal -i "$BASE_WALL"

  # Reinicia waybar e dunst para aplicar o novo tema
  pkill -USR2 waybar 2>/dev/null || true
  pkill -USR1 dunst 2>/dev/null || true
}
