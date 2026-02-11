apply_sddm() {
  SDDM_BG_DEST="/usr/share/sddm/themes/sddm-astronaut-theme/Backgrounds/black_hole.png"

  if [[ $EUID -ne 0 ]]; then
    echo "❌ SDDM requer root"
    return 1
  fi

  cp "$BASE_WALL" "$SDDM_BG_DEST"
}
