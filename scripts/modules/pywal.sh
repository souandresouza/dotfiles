apply_pywal() {
  command -v wal &>/dev/null || return 0

  wal -i "$BASE_WALL"

  pkill -USR2 waybar 2>/dev/null || true
  pkill -USR1 dunst 2>/dev/null || true
}
