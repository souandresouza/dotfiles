apply_sddm() {
  local dest="/usr/share/sddm/themes/sddm-astronaut-theme/Backgrounds/black_hole.png"

  if [[ ! -e "$dest" ]]; then
    log "SDDM não detectado — ignorando"
    return
  fi

  if [[ $EUID -ne 0 ]]; then
    log "SDDM requer root — pulando"
    return
  fi

  cp "$BASE_WALL" "$dest"
}
