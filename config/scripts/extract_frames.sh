#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

INPUT="${1:-$HOME/Downloads}"
OUTPUT_DIR="$HOME/Downloads/frames"

FPS=2
MAX_SIZE_MB=100
MAX_DURATION=600
MAX_FRAMES=200

mkdir -p "$OUTPUT_DIR"

check_dependencies() {
    command -v ffmpeg >/dev/null || { echo -e "${RED}ffmpeg não encontrado${NC}"; exit 1; }
    command -v ffprobe >/dev/null || { echo -e "${RED}ffprobe não encontrado${NC}"; exit 1; }
}

process_video() {
    local VIDEO="$1"

    local filename filename_noext SAFE_NAME VIDEO_OUTPUT_DIR
    local size_mb duration frames_extracted DATE

    filename=$(basename "$VIDEO")
    filename_noext="${filename%.*}"
    SAFE_NAME=$(echo "$filename_noext" | sed 's/[^a-zA-Z0-9_-]/_/g')
    DATE=$(date +"%d-%m-%Y")

    VIDEO_OUTPUT_DIR="$OUTPUT_DIR/$SAFE_NAME"
    mkdir -p "$VIDEO_OUTPUT_DIR"

    echo -e "${YELLOW}Processando:${NC} $filename"

    # tamanho
    size_mb=$(( $(stat -c%s "$VIDEO") / 1024 / 1024 ))
    if (( size_mb > MAX_SIZE_MB )); then
        echo -e "${RED}Ignorado (grande):${NC} ${size_mb}MB"
        return
    fi

    # duração
    duration=$(ffprobe -v error -show_entries format=duration \
        -of default=noprint_wrappers=1:nokey=1 "$VIDEO" 2>/dev/null || echo 0)
    duration=${duration%.*}

    if (( duration > MAX_DURATION )); then
        echo -e "${RED}Ignorado (longo):${NC} ${duration}s"
        return
    fi

    rm -f "$VIDEO_OUTPUT_DIR"/*.png

    ffmpeg -i "$VIDEO" \
        -vf "fps=$FPS,scale=1280:-1" \
        -frames:v "$MAX_FRAMES" \
        "$VIDEO_OUTPUT_DIR/${SAFE_NAME}_${DATE}_frame%04d.png" \
        -hide_banner -loglevel error

    frames_extracted=$(ls "$VIDEO_OUTPUT_DIR"/*.png 2>/dev/null | wc -l)

    echo -e "  ${GREEN}✓${NC} $frames_extracted frames"
}

check_dependencies

# arquivo único
if [ -f "$INPUT" ]; then
    process_video "$INPUT"
    exit 0
fi

# múltiplos arquivos
find "$INPUT" -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.webm" \) -print0 |
while IFS= read -r -d '' file; do
    process_video "$file"
done

echo -e "${GREEN}Finalizado${NC}"
