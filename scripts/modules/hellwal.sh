apply_hellwal() {
  # Verifica se o hellwal está instalado
  if ! command -v hellwal &>/dev/null; then
    echo "❌ hellwal não encontrado, não é possível aplicar o wallpaper."
    return 0
  fi

  # Verifica se o arquivo BASE_WALL existe antes de tentar aplicá-lo
  if [[ ! -f "$BASE_WALL" ]]; then
    echo "❌ Arquivo de wallpaper não encontrado: $BASE_WALL"
    return 1
  fi

  echo "Aplicando wallpaper com hellwal: $BASE_WALL"
  hellwal -i "$BASE_WALL"
}
