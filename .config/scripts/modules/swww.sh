#!/usr/bin/env bash
# modules/swww.sh

apply_swww() {
  command -v swww &>/dev/null || return 0
  [[ -f "$BASE_WALL" ]] || { error "Wallpaper não encontrado"; return 1; }
  
  swww query &>/dev/null || { swww-daemon &>/dev/null & sleep 0.5; }
  
  log "Aplicando wallpaper com swww"
  safe swww img "$BASE_WALL" --transition-type grow
}
