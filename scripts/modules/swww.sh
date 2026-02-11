apply_swww() {
  command -v swww &>/dev/null || return 0

  if ! swww query &>/dev/null; then
    swww-daemon & sleep 1
  fi

  swww img "$BASE_WALL" --transition-type grow
}
