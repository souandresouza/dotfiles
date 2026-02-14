#!/usr/bin/env bash
set -euo pipefail

# ========= XDG BASE =========
HOME_DIR="$HOME"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME_DIR/.config}"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME_DIR/.cache}"
DATA_DIR="${XDG_DATA_HOME:-$HOME_DIR/.local/share}"

PICTURES_DIR="$(xdg-user-dir PICTURES 2>/dev/null || echo "$HOME_DIR/Pictures")"

# ========= USER CONFIG =========
USER_CONFIG="$CONFIG_DIR/dotfiles/config.sh"
[[ -f "$USER_CONFIG" ]] && source "$USER_CONFIG"

THEME_MODE="${THEME_MODE:-dark}"
WALLPAPER_BASE_DIR="${WALLPAPER_BASE_DIR:-$PICTURES_DIR/wallpapers}"
WALLPAPER_DIR="$WALLPAPER_BASE_DIR/$THEME_MODE"

# ========= CACHE =========
DOTFILES_CACHE="$CACHE_DIR/dotfiles"
mkdir -p "$DOTFILES_CACHE"

HISTORY_FILE="$DOTFILES_CACHE/wallpaper_history.txt"
HASH_FILE="$DOTFILES_CACHE/wallpaper.hash"
BASE_WALL="$DOTFILES_CACHE/wallpaper_base.png"
HYPRLOCK_WALL="$DOTFILES_CACHE/wallpaper_hyprlock.png"

MAX_HISTORY=20

# ========= PATHS =========
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="$SCRIPT_DIR/modules"

log() { echo -e "▶️ $*"; }
error() { echo -e "❌ $*" >&2; }
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
    --light) THEME_MODE="light" ;;
    --dark) THEME_MODE="dark" ;;
    --help)
      echo "Uso: theme.sh [flags]"
      echo ""
      echo "--random        Força wallpaper novo"
      echo "--same          Reaplica o atual"
      echo "--light         Modo claro"
      echo "--dark          Modo escuro"
      echo "--no-swww       Não aplicar swww"
      echo "--no-hellwal    Não aplicar hellwal"
      echo "--no-pywal      Não aplicar pywal"
      echo "--sddm          Atualiza background do SDDM"
      exit 0
      ;;
    *)
      error "Flag desconhecida: $arg"
      exit 1
      ;;
  esac
done

# ========= DEP CHECK =========
for dep in magick jq feh xwallpaper; do
  command -v "$dep" &>/dev/null || { error "Dependência faltando: $dep"; exit 1; }
done

# ========= VALIDATE DIR =========
[[ ! -d "$WALLPAPER_DIR" ]] && { error "Diretório não encontrado: $WALLPAPER_DIR"; exit 1; }

# ========= RESOLUTION =========
get_resolution() {
  if command -v hyprctl &>/dev/null; then
    hyprctl monitors -j 2>/dev/null | jq -r '
      map(select(.focused == true))[0] // .[0] |
      "\(.width)x\(.height)"
    '
  elif command -v xrandr &>/dev/null; then
    xrandr | grep '*' | awk '{print $1}'
  fi
}

RESOLUTION="$(get_resolution || true)"
[[ -z "$RESOLUTION" ]] && RESOLUTION="1920x1080"
log "Resolução: $RESOLUTION"

# ========= WALLPAPER LIST =========
mapfile -t WALLPAPERS < <(
  find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \)
)

[[ ${#WALLPAPERS[@]} -eq 0 ]] && { error "Nenhum wallpaper encontrado"; exit 1; }

mapfile -t USED < "$HISTORY_FILE" 2>/dev/null || USED=()

AVAILABLE=()
for w in "${WALLPAPERS[@]}"; do
  if ! printf '%s\n' "${USED[@]}" | grep -Fxq "$w"; then
    AVAILABLE+=("$w")
  fi
done
[[ ${#AVAILABLE[@]} -eq 0 ]] && AVAILABLE=("${WALLPAPERS[@]}")

# ========= SELECT =========
if [[ "$USE_SAME" == true && -f "$BASE_WALL" ]]; then
  SELECTED="$BASE_WALL"
else
  [[ "$USE_RANDOM" == true ]] && AVAILABLE=("${WALLPAPERS[@]}")
  SELECTED="${AVAILABLE[RANDOM % ${#AVAILABLE[@]}]}"
fi
log "Selecionado: $(basename "$SELECTED")"

# ========= PROCESS =========
NEW_HASH="$(sha256sum "$SELECTED" | awk '{print $1}')"
OLD_HASH="$(cat "$HASH_FILE" 2>/dev/null || true)"

if [[ "$NEW_HASH" != "$OLD_HASH" ]]; then
  echo "$NEW_HASH" > "$HASH_FILE"

  magick "$SELECTED" -resize "${RESOLUTION}^" -gravity center -extent "$RESOLUTION" "$BASE_WALL"
  magick "$SELECTED" -resize "${RESOLUTION}^" -gravity center -extent "$RESOLUTION" -blur 0x12 -brightness-contrast -10x-5 "$HYPRLOCK_WALL"
fi
# ========= LOAD MODULES =========
shopt -s nullglob
for module in "$MODULES_DIR"/*.sh; do
  [[ -f "$module" ]] && source "$module"
done
shopt -u nullglob

# ========= APPLY =========
# Usando feh ou xwallpaper como fallback para X11
apply_wallpaper() {
  if command -v swww &>/dev/null && [[ "$DISABLE_SWWW" != true ]]; then
    apply_swww
  elif command -v hellwal &>/dev/null && [[ "$DISABLE_HELLWAL" != true ]]; then
    apply_hellwal
  elif command -v pywal &>/dev/null && [[ "$DISABLE_PYWAL" != true ]]; then
    apply_pywal
  elif command -v feh &>/dev/null; then
    feh --bg-scale "$SELECTED"
  elif command -v xwallpaper &>/dev/null; then
    xwallpaper --zoom "$SELECTED"
  else
    error "Nenhum método de aplicação de wallpaper encontrado!"
    exit 1
  fi
}

apply_wallpaper

# ========= SDDM =========
[[ "$FORCE_SDDM" == true ]] && type apply_sddm &>/dev/null && apply_sddm

# ========= HISTORY =========
{
  echo "$SELECTED"
  printf "%s\n" "${USED[@]}"
} | head -n "$MAX_HISTORY" > "$HISTORY_FILE"

echo "✅ Concluído"
