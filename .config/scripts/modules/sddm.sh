#!/usr/bin/env bash
# modules/sddm.sh

SDDM_BG_DEST="/usr/share/sddm/themes/sddm-astronaut-theme/Backgrounds/black_hole.png"
SDDM_BACKUP="${SDDM_BG_DEST}.backup"

apply_sddm() {
  [[ $EUID -eq 0 ]] || { error "SDDM requer root"; return 1; }
  [[ -f "$HYPRLOCK_WALL" ]] || { error "Wallpaper hyprlock não encontrado"; return 1; }
  
  log "Configurando SDDM background (symlink)"
  
  # Backup do original se existir e não for symlink
  if [[ -f "$SDDM_BG_DEST" && ! -L "$SDDM_BG_DEST" ]]; then
    safe mv "$SDDM_BG_DEST" "$SDDM_BACKUP"
  fi
  
  # Cria/atualiza symlink
  ln -sf "$HYPRLOCK_WALL" "$SDDM_BG_DEST"
  log "✓ SDDM symlink atualizado: $SDDM_BG_DEST → $HYPRLOCK_WALL"
}
