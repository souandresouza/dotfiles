apply_hellwal() {
  command -v hellwal &>/dev/null || {
    log "hellwal não encontrado — ignorando"
    return
  }

  log "Aplicando Hellwal"
  safe hellwal -i "$BASE_WALL"
}
