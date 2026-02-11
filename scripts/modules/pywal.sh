apply_pywal() {
  command -v wal &>/dev/null || {
    log "pywal não encontrado — ignorando"
    return
  }

  log "Aplicando Pywal"

  safe wal -i "$BASE_WALL"

  safe pkill -USR2 waybar
  safe pkill -USR1 dunst
  safe pkill -USR1 zathura

  command -v pywalfox &>/dev/null && safe pywalfox update
}
