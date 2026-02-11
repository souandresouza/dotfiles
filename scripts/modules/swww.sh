apply_swww() {
  # Verifica se o swww está instalado
  if ! command -v swww &>/dev/null; then
    echo "❌ swww não encontrado, não é possível aplicar o wallpaper."
    return 0
  fi

  # Verifica se o swww está rodando, caso contrário inicia o daemon
  if ! swww query &>/dev/null; then
    echo "▶️ Iniciando o daemon swww..."
    swww-daemon &>/dev/null &  # Daemon inicia em segundo plano
    sleep 1  # Aguarda um segundo para garantir que o daemon foi iniciado
  fi

  # Aplica o wallpaper com transição
  if [[ -f "$BASE_WALL" ]]; then
    echo "Aplicando wallpaper com swww: $BASE_WALL"
    swww img "$BASE_WALL" --transition-type grow
  else
    echo "❌ Arquivo de wallpaper não encontrado: $BASE_WALL"
    return 1
  fi
}
