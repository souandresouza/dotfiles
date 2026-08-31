#!/usr/bin/env bash
# walgen.sh - Extrator de paleta de cores sem depender de python-pywal
#
# Usa ImageMagick para quantizar a imagem e gera cache compatível
# com o formato do pywal:
#
#   colors
#   colors.json
#   colors.sh
#   colors.css
#   sequences
#   wal -> wallpaper
#
# Uso:
#   walgen.sh [-l] [-n N] <imagem>
#
#   -l       Gera esquema "light" em vez de "dark"
#   -n N     Número de cores a extrair (padrão: 16)
#
# Comportamento:
#
#   16+ cores distintas:
#       Seleciona 16 cores distintas.
#
#   8-15 cores distintas:
#       Seleciona 4 cores mais escuras + 4 mais claras.
#       Essas 8 cores ocupam color0-color7.
#       color8-color15 repetem color0-color7.
#
#   Menos de 8 cores distintas:
#       Aborta, pois não é possível formar a paleta mínima
#       de 8 cores distintas.
#
# Para aplicar as sequências nos terminais já abertos:
#
#   APPLY_SEQUENCES=1 ./walgen.sh wallpaper.png
#
# Por padrão, o script NÃO escreve nos /dev/pts/*.

set -euo pipefail

CACHE_DIR="${HOME}/.cache/wal"
NUM_COLORS=16
MODE="dark"

# ---------------------------------------------------------------------------
# Uso
# ---------------------------------------------------------------------------

usage() {
    echo "Uso: $(basename "$0") [-l] [-n N] <imagem>" >&2
    exit 1
}

# ---------------------------------------------------------------------------
# Argumentos
# ---------------------------------------------------------------------------

while getopts ":ln:h" opt; do
    case "$opt" in
        l)
            MODE="light"
            ;;
        n)
            NUM_COLORS="$OPTARG"
            ;;
        h)
            usage
            ;;
        *)
            usage
            ;;
    esac
done

shift $((OPTIND - 1))

[[ $# -eq 1 ]] || usage

IMG="$1"

[[ -f "$IMG" ]] || {
    echo "Erro: imagem não encontrada: $IMG" >&2
    exit 1
}

[[ "$NUM_COLORS" =~ ^[0-9]+$ ]] || {
    echo "Erro: número de cores inválido: $NUM_COLORS" >&2
    exit 1
}

(( NUM_COLORS >= 8 && NUM_COLORS <= 256 )) || {
    echo "Erro: N deve estar entre 8 e 256." >&2
    exit 1
}

# ---------------------------------------------------------------------------
# ImageMagick
# ---------------------------------------------------------------------------

if command -v magick >/dev/null 2>&1; then
    CONVERT="magick"
elif command -v convert >/dev/null 2>&1; then
    CONVERT="convert"
else
    echo "Erro: ImageMagick não encontrado." >&2
    echo "Instale o pacote 'imagemagick'." >&2
    exit 1
fi

mkdir -p "$CACHE_DIR"

# ---------------------------------------------------------------------------
# Extração da paleta
# ---------------------------------------------------------------------------

mapfile -t RAW_COLORS < <(
    "$CONVERT" "$IMG" \
        -resize '15%' \
        -colors "$NUM_COLORS" \
        -depth 8 \
        +dither \
        -unique-colors \
        txt:- |
    tail -n +2 |
    awk -F'#' '{print $2}' |
    awk '{print $1}' |
    tr 'a-f' 'A-F' |
    grep -E '^[0-9A-F]{6}$' |
    awk '!seen[$0]++'
)

UNIQUE_COUNT=${#RAW_COLORS[@]}

if (( UNIQUE_COUNT < 8 )); then
    echo "Erro: apenas $UNIQUE_COUNT cores distintas foram extraídas." >&2
    echo "São necessárias pelo menos 8 cores distintas." >&2
    exit 1
fi

# ---------------------------------------------------------------------------
# Funções auxiliares
# ---------------------------------------------------------------------------

hex_to_rgb() {
    # RRGGBB -> "R G B"
    local hex="$1"

    printf '%d %d %d' \
        "0x${hex:0:2}" \
        "0x${hex:2:2}" \
        "0x${hex:4:2}"
}

luminance() {
    # RRGGBB -> luminância aproximada 0-255
    local r g b

    read -r r g b <<< "$(hex_to_rgb "$1")"

    echo $(( (r * 299 + g * 587 + b * 114) / 1000 ))
}

# ---------------------------------------------------------------------------
# Ordena as cores por luminância
# ---------------------------------------------------------------------------

declare -a SORTED=()

while IFS= read -r color; do
    [[ -n "$color" ]] && SORTED+=("$color")
done < <(
    for color in "${RAW_COLORS[@]}"; do
        printf '%s %s\n' "$(luminance "$color")" "$color"
    done |
    sort -n |
    awk '{print $2}'
)

# ---------------------------------------------------------------------------
# Seleção das 8/16 cores
# ---------------------------------------------------------------------------

declare -a BASE_COLORS=()

if (( UNIQUE_COUNT >= 16 )); then

    # -----------------------------------------------------------------------
    # Existem pelo menos 16 cores distintas.
    #
    # Selecionamos 16 cores distribuídas pela escala de luminância.
    # Isso evita que todas as cores escolhidas fiquem concentradas
    # somente nas regiões escuras ou claras.
    # -----------------------------------------------------------------------

    for i in {0..15}; do
        idx=$(( i * (UNIQUE_COUNT - 1) / 15 ))
        BASE_COLORS+=("${SORTED[$idx]}")
    done

else

    # -----------------------------------------------------------------------
    # Existem entre 8 e 15 cores distintas.
    #
    # Selecionamos exatamente:
    #
    #   4 mais escuras
    #   4 mais claras
    #
    # Não há repetição.
    # -----------------------------------------------------------------------

    for i in 0 1 2 3; do
        BASE_COLORS+=("${SORTED[$i]}")
    done

    start=$(( UNIQUE_COUNT - 4 ))

    for i in 0 1 2 3; do
        BASE_COLORS+=("${SORTED[$((start + i))]}")
    done

fi

# ---------------------------------------------------------------------------
# Verificação de unicidade
# ---------------------------------------------------------------------------

declare -A SEEN_BASE=()
declare -a UNIQUE_BASE=()

for color in "${BASE_COLORS[@]}"; do
    if [[ -z "${SEEN_BASE[$color]+x}" ]]; then
        UNIQUE_BASE+=("$color")
        SEEN_BASE["$color"]=1
    fi
done

BASE_COLORS=("${UNIQUE_BASE[@]}")

if (( ${#BASE_COLORS[@]} < 8 )); then
    echo "Erro: não foi possível obter 8 cores distintas." >&2
    exit 1
fi

# ---------------------------------------------------------------------------
# Geração da paleta ANSI
# ---------------------------------------------------------------------------

declare -a COLORS=()

if (( ${#BASE_COLORS[@]} >= 16 )); then

    # 16 cores reais extraídas da imagem.
    for i in {0..15}; do
        COLORS[$i]="${BASE_COLORS[$i]}"
    done

else

    # -----------------------------------------------------------------------
    # Fallback de 8 cores:
    #
    # color0-color7 = 8 cores distintas extraídas
    #
    # color8-color15 = repetição exata das mesmas 8 cores.
    #
    # Nenhuma cor é criada, clareada ou escurecida artificialmente.
    # -----------------------------------------------------------------------

    for i in {0..7}; do
        COLORS[$i]="${BASE_COLORS[$i]}"
    done

    for i in {0..7}; do
        COLORS[$((i + 8))]="${BASE_COLORS[$i]}"
    done

fi

# ---------------------------------------------------------------------------
# Background / foreground
# ---------------------------------------------------------------------------
#
# No modo dark:
#   background = cor mais escura
#   foreground = cor mais clara
#
# No modo light:
#   background = cor mais clara
#   foreground = cor mais escura
#
# As cores continuam sendo cores reais extraídas da imagem.

if [[ "$MODE" == "dark" ]]; then
    BG="${BASE_COLORS[0]}"
    FG="${BASE_COLORS[${#BASE_COLORS[@]}-1]}"
else
    BG="${BASE_COLORS[${#BASE_COLORS[@]}-1]}"
    FG="${BASE_COLORS[0]}"
fi

# ---------------------------------------------------------------------------
# Cache: colors
# ---------------------------------------------------------------------------

{
    for color in "${COLORS[@]}"; do
        echo "#$color"
    done
} > "$CACHE_DIR/colors"

# ---------------------------------------------------------------------------
# Cache: colors.json
# ---------------------------------------------------------------------------

{
    echo "{"
    echo "  \"wallpaper\": \"$IMG\","
    echo "  \"alpha\": \"100\","
    echo "  \"special\": {"
    echo "    \"background\": \"#$BG\","
    echo "    \"foreground\": \"#$FG\","
    echo "    \"cursor\": \"#$FG\""
    echo "  },"
    echo "  \"colors\": {"

    for i in "${!COLORS[@]}"; do
        if [[ "$i" -eq 15 ]]; then
            echo "    \"color$i\": \"#${COLORS[$i]}\""
        else
            echo "    \"color$i\": \"#${COLORS[$i]}\","
        fi
    done

    echo "  }"
    echo "}"

} > "$CACHE_DIR/colors.json"

# ---------------------------------------------------------------------------
# Cache: colors.sh
# ---------------------------------------------------------------------------

{
    echo "background='#$BG'"
    echo "foreground='#$FG'"
    echo "cursor='#$FG'"

    for i in "${!COLORS[@]}"; do
        echo "color$i='#${COLORS[$i]}'"
    done

} > "$CACHE_DIR/colors.sh"

# ---------------------------------------------------------------------------
# Cache: colors.css
# ---------------------------------------------------------------------------

{
    echo ":root {"
    echo "  --background: #$BG;"
    echo "  --foreground: #$FG;"

    for i in "${!COLORS[@]}"; do
        echo "  --color$i: #${COLORS[$i]};"
    done

    echo "}"

} > "$CACHE_DIR/colors.css"

# ---------------------------------------------------------------------------
# Sequências OSC
# ---------------------------------------------------------------------------

{
    printf '\033]10;#%s\007' "$FG"
    printf '\033]11;#%s\007' "$BG"
    printf '\033]12;#%s\007' "$FG"

    for i in "${!COLORS[@]}"; do
        printf '\033]4;%d;#%s\007' "$i" "${COLORS[$i]}"
    done

} > "$CACHE_DIR/sequences"

# ---------------------------------------------------------------------------
# Link para o wallpaper atual
# ---------------------------------------------------------------------------

ln -sfn "$IMG" "$CACHE_DIR/wal"

# ---------------------------------------------------------------------------
# Aplicação opcional nos terminais abertos
# ---------------------------------------------------------------------------

apply_sequences() {
    local seq

    seq="$(cat "$CACHE_DIR/sequences")"

    for tty in /dev/pts/*; do
        [[ -w "$tty" ]] || continue

        printf '%s' "$seq" > "$tty" 2>/dev/null || true
    done
}

if [[ "${APPLY_SEQUENCES:-0}" == "1" ]]; then
    apply_sequences
fi

# ---------------------------------------------------------------------------
# Resultado
# ---------------------------------------------------------------------------

echo
echo "Paleta gerada com sucesso."
echo
echo "  Imagem:       $IMG"
echo "  Modo:         $MODE"
echo "  Extraídas:    $UNIQUE_COUNT"
echo "  Cores ANSI:   ${#COLORS[@]}"
echo
echo "  Background:   #$BG"
echo "  Foreground:   #$FG"
echo
echo "Cache:"
echo "  $CACHE_DIR/colors"
echo "  $CACHE_DIR/colors.json"
echo "  $CACHE_DIR/colors.sh"
echo "  $CACHE_DIR/colors.css"
echo "  $CACHE_DIR/sequences"
echo "  $CACHE_DIR/wal"
