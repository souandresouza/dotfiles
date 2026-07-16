#!/usr/bin/env bash
set -euo pipefail

# ========= CONFIG =========
BASE_DIR="$HOME/Imagens/Screenshots"

DATE=$(date +%d-%m-%Y)
TIMESTAMP=$(date +%d%m%Y_%H%M%S)

DIR="$BASE_DIR/$DATE"
mkdir -p "$DIR"

# ========= DETECT COMPOSITOR =========
detect_compositor() {
  if command -v hyprctl >/dev/null 2>&1; then
    echo "hyprland"
  elif command -v niri >/dev/null 2>&1; then
    echo "niri"
  elif command -v swaymsg >/dev/null 2>&1; then
    echo "sway"
  else
    echo "unknown"
  fi
}

COMPOSITOR=$(detect_compositor)

# ========= GET ACTIVE WINDOW GEOMETRY =========
get_window_geom() {
  case "$COMPOSITOR" in
    hyprland)
      hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"'
      ;;
    niri)
      niri msg -j windows | jq -r '.[] | select(.focused==true) | "\(.rect.x),\(.rect.y) \(.rect.width)x\(.rect.height)"'
      ;;
    sway)
      swaymsg -t get_tree | jq -r '
        .. | select(.focused? == true) |
        "\(.rect.x),\(.rect.y) \(.rect.width)x\(.rect.height)"' | head -n1
      ;;
    *)
      return 1
      ;;
  esac
}

# ========= HELP =========
usage() {
  echo "Uso: screenshot [all|monitor|region|window]"
  exit 1
}

# ========= MODES =========
case "${1:-}" in
  all)
    MODE="all"
    FILE="$DIR/screenshot_${MODE}_${TIMESTAMP}.png"
    grim "$FILE"
    ;;

  monitor)
    MONITOR=$(slurp -o -f "%o")
    MODE="$MONITOR"
    FILE="$DIR/screenshot_${MODE}_${TIMESTAMP}.png"
    grim -o "$MONITOR" "$FILE"
    ;;

  region)
    MODE="region"
    FILE="$DIR/screenshot_${MODE}_${TIMESTAMP}.png"
    GEOM=$(slurp)
    grim -g "$GEOM" "$FILE"
    ;;

  window)
    MODE="window"
    FILE="$DIR/screenshot_${MODE}_${TIMESTAMP}.png"

    GEOM=$(get_window_geom || true)

    if [[ -z "${GEOM:-}" ]]; then
      notify-send "Screenshot" "Erro ao obter janela ($COMPOSITOR)"
      exit 1
    fi

    grim -g "$GEOM" "$FILE"
    ;;

  *)
    usage
    ;;
esac

# ========= COPY =========
wl-copy < "$FILE"

# ========= FEEDBACK (SwayNC Thumbnail) =========
# O SwayNC processa nativamente o parâmetro -i como a prévia lateral se receber o caminho absoluto.
FILENAME=$(basename "$FILE")
notify-send -i "$FILE" "Screenshot Capturada" "$MODE • $FILENAME"
echo "Salvo em: $FILE"
