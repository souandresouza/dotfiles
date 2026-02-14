#!/usr/bin/env bash
set -euo pipefail

# ================= CONFIG =================
WALLPAPER_DIR="$HOME/Pictures/wallpapers"
CACHE_DIR="$HOME/.cache"

HISTORY_FILE="$CACHE_DIR/wallpaper_history.txt"
HASH_FILE="$CACHE_DIR/wallpaper.hash"
MAX_HISTORY=10

# Wallpapers derivados
BASE_WALL="$CACHE_DIR/wallpaper_base.png"
HYPRLOCK_WALL="$CACHE_DIR/wallpaper_hyprlock.png"

# Caches
HELLWAL_CACHE_DIR="$CACHE_DIR/hellwal"
PYWAL_CACHE_DIR="$CACHE_DIR/wal"
PYWAL_CACHE_FILE="$PYWAL_CACHE_DIR/wal"

# SDDM (já é symlink, NÃO usar sudo)
SDDM_BG_DEST="/usr/share/sddm/themes/sddm-astronaut-theme/Backgrounds/black_hole.png"

HELLWAL_APPS=("hyprland" "kitty" "rofi")
PYWAL_APPS=("dunst" "vim" "zathura" "firefox" "spotify")
# ==========================================

mkdir -p "$CACHE_DIR" "$HELLWAL_CACHE_DIR" "$PYWAL_CACHE_DIR"

log() { echo -e "▶ $*"; }
safe() { "$@" 2>/dev/null || true; }

# ---------- RESOLUÇÃO DINÂMICA ----------
get_resolution() {
  hyprctl monitors -j | jq -r '
    map(select(.focused == true))[0] // .[0] |
    "\(.width)x\(.height)"
  '
}

# ---------- HASH ----------
get_hash() {
  sha256sum "$1" | awk '{print $1}'
}

# ---------- BLUR HYPRLOCK ----------
apply_hyprlock_blur() {
  magick "$1" \
    -resize "${RESOLUTION}^" \
    -gravity center -extent "$RESOLUTION" \
    -blur 0x12 \
    -brightness-contrast -10x-5 \
    "$2"
}

# ---------- COLETA WALLPAPERS ----------
mapfile -t WALLPAPERS < <(
  find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \)
)

[[ ${#WALLPAPERS[@]} -eq 0 ]] && { echo "❌ Nenhum wallpaper encontrado"; exit 1; }

mapfile -t USED < "$HISTORY_FILE" 2>/dev/null || USED=()

AVAILABLE=()
for w in "${WALLPAPERS[@]}"; do
  [[ " ${USED[*]} " =~ " $w " ]] || AVAILABLE+=("$w")
done
[[ ${#AVAILABLE[@]} -eq 0 ]] && AVAILABLE=("${WALLPAPERS[@]}")

SELECTED="${AVAILABLE[RANDOM % ${#AVAILABLE[@]}]}"
SELECTED_BASENAME="$(basename "$SELECTED")"
log "Wallpaper selecionado: $SELECTED_BASENAME"

# ---------- HASH CHECK ----------
NEW_HASH="$(get_hash "$SELECTED")"
OLD_HASH="$(cat "$HASH_FILE" 2>/dev/null || true)"

RESOLUTION="$(get_resolution)"
log "Resolução detectada: $RESOLUTION"

if [[ "$NEW_HASH" == "$OLD_HASH" ]]; then
  log "Wallpaper igual ao anterior — pulando processamento"
  SKIP_PROCESSING=true
else
  echo "$NEW_HASH" > "$HASH_FILE"
  SKIP_PROCESSING=false
fi

# ---------- PROCESSAMENTO ----------
if [[ "$SKIP_PROCESSING" != true ]]; then
  log "Gerando wallpaper base"
  magick "$SELECTED" \
    -resize "${RESOLUTION}^" \
    -gravity center -extent "$RESOLUTION" \
    "$BASE_WALL"

  log "Gerando wallpaper do Hyprlock (blur)"
  apply_hyprlock_blur "$BASE_WALL" "$HYPRLOCK_WALL"
fi

# ---------- SWWW ----------
if ! swww query &>/dev/null; then
  swww-daemon & sleep 1
fi
safe swww img "$BASE_WALL" --transition-type grow

# ---------- HELLWAL ----------
if command -v hellwal &>/dev/null; then
  log "Aplicando Hellwal (hyprland, kitty, rofi, etc)"
  safe hellwal -i "$BASE_WALL"
fi

# ---------- PYWAL ----------
if command -v wal &>/dev/null; then
  log "Aplicando Pywal (GTK / Waybar)"

  safe wal -i "$BASE_WALL"

  echo "$BASE_WALL" > "$PYWAL_CACHE_FILE"

  # Reload apps GTK
  safe pkill -USR2 waybar
  safe pkill -USR1 dunst
  safe pkill -USR1 zathura

  command -v spicetify &>/dev/null && safe spicetify apply
  command -v pywalfox &>/dev/null && safe pywalfox update
fi


# ---------- HISTÓRICO ----------
{
  echo "$SELECTED"
  printf "%s\n" "${USED[@]}"
} | head -n "$MAX_HISTORY" > "$HISTORY_FILE"

# ---------- NOTIFY ----------
command -v notify-send &>/dev/null && \
  notify-send "🎨 Tema aplicado" "$SELECTED_BASENAME" -i image-x-generic

# ---------- FINAL ----------
echo ""
echo "✅ CONCLUÍDO"
echo "Resolução: $RESOLUTION"
echo "Base: $BASE_WALL"
echo "Hyprlock: $HYPRLOCK_WALL"
echo "Hellwal → ${HELLWAL_APPS[*]}"
echo "Pywal  → ${PYWAL_APPS[*]}"
