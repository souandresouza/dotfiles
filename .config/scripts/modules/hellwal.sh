#!/usr/bin/env bash
# modules/hellwal.sh

apply_hellwal() {
  command -v hellwal &>/dev/null || return 0
  [[ -f "$BASE_WALL" ]] || { error "Wallpaper não encontrado"; return 1; }
  
  log "Aplicando hellwal"
  safe hellwal -i "$BASE_WALL"
}
