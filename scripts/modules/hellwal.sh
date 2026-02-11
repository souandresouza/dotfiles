apply_hellwal() {
  command -v hellwal &>/dev/null || return 0
  hellwal -i "$BASE_WALL"
}
