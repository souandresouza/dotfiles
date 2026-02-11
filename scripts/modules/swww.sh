apply_swww() {
  if ! command -v swww &>/dev/null; then
    log "swww não encontrado — ignorando"
    return
  fi

  if ! swww query &>/dev/null; then
    swww-daemon &
    until swww query &>/dev/null; do sleep 0.2; done
  fi

  swww img "$BASE_WALL" --transition-type grow
}
