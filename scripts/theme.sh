#!/usr/bin/env bash
set -euo pipefail

# ========= CONFIG =========
WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/Imagens/wallpapers}"
CACHE_DIR="${CACHE_DIR:-$HOME/.cache/theme}"

HISTORY_FILE="$CACHE_DIR/wallpaper_history.txt"
HASH_FILE="$CACHE_DIR/wallpaper.hash"
MAX_HISTORY=20

BASE_WALL="$CACHE_DIR/wallpaper_base.png"
HYPRLOCK_WALL="$CACHE_DIR/wallpaper_hyprlock.png"
# ==========================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="$SCRIPT_DIR/modules"

mkdir -p "$CACHE_DIR"

log() { echo -e "▶ $*"; }
safe() { "$@" 2>/dev/null || true; }

# ========= FLAGS =========
USE_RANDOM=false
USE_SAME=false
DISABLE_SWWW=false
DISABLE_HELLWAL=false
DISABLE_PYWAL=false
FORCE_SDDM=false

for arg in "$@"; do
  case "$arg" in
    --random) USE_RANDOM=true ;;
    --same) USE_SAME=true ;;
    --no-swww) DISABLE_SWWW=true ;;
    --no-hellwal) DISABLE_HELLWAL=true ;;
    --no-pywal) DISABLE_PYWAL=true ;;
    --sddm) FORCE_SDDM=true ;;
    --help)
      echo "Uso: theme.sh [flags]"
      echo ""
      echo "--random        Força wallpaper novo"
      echo "--same          Reaplica o atual"
      echo "--no-swww       Não aplicar swww"
      echo "--no-hellwal    Não aplicar hellwal"
      echo "--no-pywal      Não aplicar pywal"
      echo "--sddm          Atualiza background do SDDM (root)"
      exit 0
      ;;
    *)
      echo "Flag desconhecida: $arg"
      exit 1
      ;;
  esac
done

# ========= DEP CHECK =========
check_dep() {
  command -v "$1" &>/dev/null || {
    echo "❌ Dependência faltando: $1"
    exit 1
  }
}

check_dep magick
check_dep jq

# ========= RESOLUTION =========
get_resolution() {
  hyprctl monitors -j 2>/dev/null | jq -r '
    map(select(.focused == true))[0] // .[0] |
    "\(.width)x\(.height)"
  ' 2>/dev/null
}

RESOLUTION="$(get_resolution || true)"
[[ -z "$RESOLUTION" ]] && RESOLUTION="1920x1080"

log "Resolução detectada: $RESOLUTION"

# ========= HASH =========
get_hash() {
  sha256sum "$1" | awk '{print $1}'
}

# ========= LOAD WALLPAPERS =========
mapfile -t WALLPAPERS < <(
  find "$WALLPAPER_DIR" -type f \( \
    -iname "*.jpg" -o \
    -iname "*.jpeg" -o \
    -iname "*.png" -o \
    -iname "*.webp" \
  \)
)

[[ ${#WALLPAPERS[@]} -eq 0 ]] && {
  echo "❌ Nenhum wallpaper encontrado em $WALLPAPER_DIR"
  exit 1
}

mapfile -t USED < "$HISTORY_FILE" 2>/dev/null || USED=()

AVAILABLE=()
for w in "${WALLPAPERS[@]}"; do
  if ! printf '%s\n' "${USED[@]}" | grep -Fxq "$w"; then
    AVAILABLE+=("$w")
  fi
done

[[ ${#AVAILABLE[@]} -eq 0 ]] && AVAILABLE=("${WALLPAPERS[@]}")

# ========= SELECT WALLPAPER =========
if [[ "$USE_SAME" == true && -f "$BASE_WALL" ]]; then
  log "Reutilizando wallpaper atual"
  SELECTED="$BASE_WALL"
else
  if [[ "$USE_RANDOM" == true ]]; then
    AVAILABLE=("${WALLPAPERS[@]}")
  fi

  SELECTED="${AVAILABLE[RANDOM % ${#AVAILABLE[@]}]}"
fi

SELECTED_BASENAME="$(basename "$SELECTED")"
log "Wallpaper selecionado: $SELECTED_BASENAME"

# ========= PROCESS =========
NEW_HASH="$(get_hash "$SELECTED")"
OLD_HASH="$(cat "$HASH_FILE" 2>/dev/null || true)"

if [[ "$NEW_HASH" != "$OLD_HASH" ]]; then
  echo "$NEW_HASH" > "$HASH_FILE"

  log "Gerando wallpaper base"
  magick "$SELECTED" \
    -resize "${RESOLUTION}^" \
    -gravity center -extent "$RESOLUTION" \
    "$BASE_WALL"

  log "Gerando wallpaper blur (hyprlock)"
  magick "$SELECTED" \
    -resize "${RESOLUTION}^" \
    -gravity center -extent "$RESOLUTION" \
    -blur 0x12 \
    -brightness-contrast -10x-5 \
    "$HYPRLOCK_WALL"
else
  log "Wallpaper igual ao anterior — pulando processamento"
fi

# ========= LOAD MODULES =========
for module in "$MODULES_DIR"/*.sh; do
  [[ -f "$module" ]] && source "$module"
done

# ========= APPLY MODULES =========
[[ "$DISABLE_SWWW" != true ]] && type apply_swww &>/dev/null && apply_swww
[[ "$DISABLE_HELLWAL" != true ]] && type apply_hellwal &>/dev/null && apply_hellwal
[[ "$DISABLE_PYWAL" != true ]] && type apply_pywal &>/dev/null && apply_pywal
[[ "$FORCE_SDDM" == true ]] && type apply_sddm &>/dev/null && apply_sddm

# ========= UPDATE HISTORY =========
{
  echo "$SELECTED"
  printf "%s\n" "${USED[@]}"
} | head -n "$MAX_HISTORY" > "$HISTORY_FILE"

echo ""
echo "✅ CONCLUÍDO"
echo "Base: $BASE_WALL"
echo "Hyprlock: $HYPRLOCK_WALL"
