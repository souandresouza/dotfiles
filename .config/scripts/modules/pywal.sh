#!/usr/bin/env bash
# modules/pywal.sh

PYWAL_CACHE="$CACHE_DIR/wal/wal"

apply_pywal() {
  command -v wal &>/dev/null || return 0
  [[ -f "$BASE_WALL" ]] || { error "Wallpaper não encontrado"; return 1; }
  
  log "Aplicando pywal"
  safe wal -i "$BASE_WALL"
  echo "$BASE_WALL" > "$PYWAL_CACHE"
  
  # Recarrega apps
  safe pkill -USR2 waybar
  safe pkill -USR1 dunst
  safe pkill -USR1 zathura
  
  # Integrações (só se existirem)
  command -v spicetify &>/dev/null && safe spicetify apply
  command -v pywalfox &>/dev/null && safe pywalfox update
}
