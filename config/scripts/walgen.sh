#!/usr/bin/env bash
# walgen.sh - Extrator de paleta de cores sem depender de python-pywal
# Usa ImageMagick para quantizar a imagem e gera cache compatível com o
# formato do pywal (colors, colors.json, colors.sh, colors.css, sequences).
#
# Uso: walgen.sh [-l] [-n N] <imagem>
#   -l       Gera esquema "light" (fundo claro) em vez de "dark"
#   -n N     Numero de cores a extrair da imagem (padrao: 16)

set -euo pipefail

CACHE_DIR="${HOME}/.cache/wal"
NUM_COLORS=16
MODE="dark"

usage() {
    echo "Uso: $(basename "$0") [-l] [-n N] <imagem>" >&2
    exit 1
}

while getopts ":ln:h" opt; do
    case "$opt" in
        l) MODE="light" ;;
        n) NUM_COLORS="$OPTARG" ;;
        h) usage ;;
        *) usage ;;
    esac
done
shift $((OPTIND - 1))

IMG="${1:-}"
[[ -z "$IMG" || ! -f "$IMG" ]] && { echo "Erro: imagem invalida: $IMG" >&2; exit 1; }

if command -v magick >/dev/null 2>&1; then
    CONVERT="magick"
elif command -v convert >/dev/null 2>&1; then
    CONVERT="convert"
else
    echo "Erro: ImageMagick nao encontrado (pacote 'imagemagick')" >&2
    exit 1
fi

mkdir -p "$CACHE_DIR"

# --- Extracao de paleta ---------------------------------------------------
mapfile -t RAW_COLORS < <(
    "$CONVERT" "$IMG" -resize 15% -colors "$NUM_COLORS" -depth 8 \
        +dither -unique-colors txt:- \
    | tail -n +2 \
    | awk -F'#' '{print $2}' \
    | awk '{print $1}' \
    | tr 'a-f' 'A-F'
)

[[ ${#RAW_COLORS[@]} -eq 0 ]] && { echo "Erro: falha ao extrair cores" >&2; exit 1; }

# --- Funcoes auxiliares de cor --------------------------------------------
hex_to_rgb() { # $1=RRGGBB -> "R G B"
    local hex="$1"
    printf '%d %d %d' "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}"
}

luminance() { # $1=RRGGBB -> 0-255
    local r g b
    read -r r g b <<< "$(hex_to_rgb "$1")"
    echo $(( (r * 299 + g * 587 + b * 114) / 1000 ))
}

darken() { # $1=hex $2=percent -> hex mais escuro
    local hex="$1" pct="$2" r g b
    read -r r g b <<< "$(hex_to_rgb "$hex")"
    r=$(( r - r * pct / 100 )); g=$(( g - g * pct / 100 )); b=$(( b - b * pct / 100 ))
    (( r < 0 )) && r=0; (( g < 0 )) && g=0; (( b < 0 )) && b=0
    printf '%02X%02X%02X' "$r" "$g" "$b"
}

lighten() { # $1=hex $2=percent -> hex mais claro
    local hex="$1" pct="$2" r g b
    read -r r g b <<< "$(hex_to_rgb "$hex")"
    r=$(( r + (255 - r) * pct / 100 )); g=$(( g + (255 - g) * pct / 100 )); b=$(( b + (255 - b) * pct / 100 ))
    (( r > 255 )) && r=255; (( g > 255 )) && g=255; (( b > 255 )) && b=255
    printf '%02X%02X%02X' "$r" "$g" "$b"
}

# --- Ordena por luminancia -------------------------------------------------
declare -a SORTED
while IFS= read -r c; do SORTED+=("$c"); done < <(
    for c in "${RAW_COLORS[@]}"; do
        printf '%s %s\n' "$(luminance "$c")" "$c"
    done | sort -n | awk '{print $2}'
)

while [[ ${#SORTED[@]} -lt 16 ]]; do
    SORTED+=("${SORTED[-1]}")
done

DARKEST="${SORTED[0]}"
LIGHTEST="${SORTED[-1]}"

if [[ "$MODE" == "dark" ]]; then
    BG="$(darken "$DARKEST" 20)"
    FG="$(lighten "$LIGHTEST" 20)"
else
    BG="$(lighten "$LIGHTEST" 10)"
    FG="$(darken "$DARKEST" 30)"
fi

# color0-15 no estilo pywal
declare -a COLORS
COLORS[0]="$BG"
for i in 1 2 3 4 5 6; do
    idx=$(( i * (${#SORTED[@]} - 1) / 7 ))
    COLORS[$i]="${SORTED[$idx]}"
done
COLORS[7]="$FG"
COLORS[8]="$(lighten "${COLORS[0]}" 40)"
for i in 9 10 11 12 13 14; do
    src=$(( i - 8 ))
    COLORS[$i]="$(lighten "${COLORS[$src]}" 15)"
done
COLORS[15]="$FG"

# --- Grava arquivos de cache (compat. formato pywal) ----------------------
{
    for c in "${COLORS[@]}"; do echo "#$c"; done
} > "$CACHE_DIR/colors"

{
    echo "{"
    echo "  \"wallpaper\": \"$IMG\","
    echo "  \"alpha\": \"100\","
    echo "  \"special\": {"
    echo "    \"background\": \"#${COLORS[0]}\","
    echo "    \"foreground\": \"#${COLORS[7]}\","
    echo "    \"cursor\": \"#${COLORS[7]}\""
    echo "  },"
    echo "  \"colors\": {"
    for i in "${!COLORS[@]}"; do
        sep=","
        [[ "$i" -eq 15 ]] && sep=""
        echo "    \"color$i\": \"#${COLORS[$i]}\"$sep"
    done
    echo "  }"
    echo "}"
} > "$CACHE_DIR/colors.json"

{
    echo "background='#${COLORS[0]}'"
    echo "foreground='#${COLORS[7]}'"
    echo "cursor='#${COLORS[7]}'"
    for i in "${!COLORS[@]}"; do
        echo "color$i='#${COLORS[$i]}'"
    done
} > "$CACHE_DIR/colors.sh"

{
    echo ":root {"
    echo "  --background: #${COLORS[0]};"
    echo "  --foreground: #${COLORS[7]};"
    for i in "${!COLORS[@]}"; do
        echo "  --color$i: #${COLORS[$i]};"
    done
    echo "}"
} > "$CACHE_DIR/colors.css"

# --- Sequencias de escape (Xresources/urxvt/kitty/foot etc.) -------------
{
    printf '\033]10;#%s\007' "${COLORS[7]}"
    printf '\033]11;#%s\007' "${COLORS[0]}"
    printf '\033]12;#%s\007' "${COLORS[7]}"
    for i in "${!COLORS[@]}"; do
        printf '\033]4;%d;#%s\007' "$i" "${COLORS[$i]}"
    done
} > "$CACHE_DIR/sequences"

ln -sf "$IMG" "$CACHE_DIR/wal"

# --- Aplica nos terminais abertos no momento ------------------------------
apply_sequences() {
    local seq
    seq="$(cat "$CACHE_DIR/sequences")"
    for tty in /dev/pts/*; do
        [[ -w "$tty" ]] && printf '%s' "$seq" > "$tty" 2>/dev/null || true
    done
}
apply_sequences

echo "Paleta gerada em: $CACHE_DIR"
echo "  colors, colors.json, colors.sh, colors.css, sequences"
