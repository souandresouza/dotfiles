#!/bin/bash
# ~/.config/scripts/random-wallpaper.sh

set -euo pipefail

# Configuração
WALLPAPER_DIR="$HOME/.config/wallpapers"
CACHE_DIR="$HOME/.cache/wallpapers"
HISTORY_FILE="$CACHE_DIR/wallpaper_history.txt"
CURRENT_WALLPAPER="$HOME/.cache/current_wallpaper.png"
HISTORY_SIZE=10
COLORS_FILE="$HOME/.cache/wal/colors.lua"
CSS_FILE="$HOME/.cache/wal/colors.css"

# ============================================
# FUNÇÕES
# ============================================

# Detecta resolução da tela
detect_resolution() {
    local res=""
    
    if command -v hyprctl &>/dev/null && command -v jq &>/dev/null; then
        res=$(hyprctl monitors -j 2>/dev/null | jq -r '.[] | select(.focused == true) | "\(.width)x\(.height)"' | head -1)
    fi
    
    if [[ -z "$res" ]] && command -v wlr-randr &>/dev/null; then
        res=$(wlr-randr 2>/dev/null | grep -oP 'current mode: \K\d+x\d+' | head -1)
    fi
    
    if [[ -z "$res" ]] && command -v xrandr &>/dev/null; then
        res=$(xrandr --current 2>/dev/null | grep '*' | head -1 | awk '{print $1}')
    fi
    
    echo "${res:-1920x1080}"
}

# Verifica e cria diretórios necessários
ensure_directories() {
    mkdir -p "$CACHE_DIR"
    mkdir -p "$(dirname "$COLORS_FILE")"
    mkdir -p "$(dirname "$CSS_FILE")"
    mkdir -p "$(dirname "$CURRENT_WALLPAPER")"
    touch "$HISTORY_FILE"
    
    # Verifica permissões
    if [[ ! -w "$CACHE_DIR" ]]; then
        echo "❌ Sem permissão de escrita em: $CACHE_DIR" >&2
        exit 1
    fi
}

# Obtém o wallpaper atual do histórico (primeira linha)
get_current_wallpaper() {
    if [[ -f "$HISTORY_FILE" ]]; then
        head -n 1 "$HISTORY_FILE" 2>/dev/null || echo ""
    else
        echo ""
    fi
}

# Lista todos os wallpapers disponíveis
list_available_wallpapers() {
    local wallpapers=()
    
    # Verifica se o diretório existe
    if [[ ! -d "$WALLPAPER_DIR" ]]; then
        echo "❌ Diretório não encontrado: $WALLPAPER_DIR" >&2
        return 1
    fi
    
    # Busca arquivos de imagem
    while IFS= read -r -d $'\0' file; do
        wallpapers+=("$file")
    done < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( \
        -iname "*.jpg" -o -iname "*.jpeg" \
        -o -iname "*.png" -o -iname "*.gif" \
        -o -iname "*.webp" -o -iname "*.bmp" \
    \) -print0 2>/dev/null | sort -z)
    
    # Retorna o array
    printf '%s\n' "${wallpapers[@]}"
}

# Seleciona wallpaper aleatório diferente do atual
select_wallpaper() {
    # Lista todos os wallpapers usando array
    local all_wallpapers=()
    while IFS= read -r file; do
        [[ -n "$file" ]] && all_wallpapers+=("$file")
    done < <(list_available_wallpapers)
    
    if [[ ${#all_wallpapers[@]} -eq 0 ]]; then
        echo "❌ Nenhum wallpaper encontrado em: $WALLPAPER_DIR" >&2
        echo "📁 Verifique se o diretório existe e contém imagens" >&2
        return 1
    fi
    
    echo "📸 Encontrados ${#all_wallpapers[@]} wallpapers" >&2
    
    # Obtém o wallpaper atual
    local current=$(get_current_wallpaper)
    if [[ -n "$current" ]]; then
        echo "🖼️  Wallpaper atual: $(basename "$current")" >&2
    else
        echo "🖼️  Nenhum wallpaper atual definido" >&2
    fi
    
    # Filtra wallpapers diferentes do atual
    local available=()
    for w in "${all_wallpapers[@]}"; do
        if [[ "$w" != "$current" ]]; then
            available+=("$w")
        fi
    done
    
    # Se não há wallpapers diferentes do atual
    if [[ ${#available[@]} -eq 0 ]]; then
        if [[ ${#all_wallpapers[@]} -eq 1 ]]; then
            echo "⚠️  Apenas um wallpaper disponível. Usando ele mesmo." >&2
            echo "${all_wallpapers[0]}"
            return 0
        else
            echo "⚠️  Nenhum wallpaper diferente do atual." >&2
            # Escolhe aleatório da lista completa
            local idx=$((RANDOM % ${#all_wallpapers[@]}))
            echo "${all_wallpapers[$idx]}"
            return 0
        fi
    fi
    
    # Seleciona aleatoriamente entre os disponíveis
    local idx=$((RANDOM % ${#available[@]}))
    local selected="${available[$idx]}"
    echo "🎯 Selecionado: $(basename "$selected")" >&2
    echo "$selected"
    return 0
}

# Atualiza o histórico (primeira linha = wallpaper atual)
update_history() {
    local wallpaper="$1"
    
    echo "📝 Atualizando histórico..." >&2
    
    # Lê o histórico existente (ignorando primeira linha)
    local history_lines=()
    if [[ -f "$HISTORY_FILE" ]]; then
        # Pula a primeira linha (wallpaper atual)
        while IFS= read -r line; do
            [[ -n "$line" ]] && history_lines+=("$line")
        done < <(tail -n +2 "$HISTORY_FILE" 2>/dev/null | head -n $((HISTORY_SIZE - 1)))
    fi
    
    # Escreve novo histórico: novo wallpaper + histórico antigo (limitado)
    {
        echo "$wallpaper"
        printf '%s\n' "${history_lines[@]}" | head -n $((HISTORY_SIZE - 1))
    } > "$HISTORY_FILE"
    
    echo "✅ Histórico atualizado. Wallpaper atual: $(basename "$wallpaper")" >&2
}

# Cria cópia do wallpaper atual como PNG
create_current_wallpaper_copy() {
    local source="$1"
    local destination="$CURRENT_WALLPAPER"
    
    echo "📸 Criando cópia do wallpaper atual..." >&2
    
    # Verifica se o arquivo existe
    if [[ ! -f "$source" ]]; then
        echo "❌ Arquivo fonte não encontrado: $source" >&2
        return 1
    fi
    
    # Converte para PNG usando ImageMagick
    if command -v convert &>/dev/null; then
        if convert "$source" -quality 95 "$destination" 2>/dev/null; then
            echo "✅ current_wallpaper.png criado: $destination" >&2
            return 0
        else
            echo "⚠️ Falha ao converter com ImageMagick, tentando cópia direta..." >&2
        fi
    fi
    
    # Fallback: cópia direta se for PNG
    if [[ "${source,,}" == *.png ]]; then
        if cp "$source" "$destination" 2>/dev/null; then
            echo "✅ current_wallpaper.png copiado diretamente" >&2
            return 0
        fi
    fi
    
    # Último recurso: cópia mesmo não sendo PNG
    if cp "$source" "$destination" 2>/dev/null; then
        echo "⚠️ current_wallpaper.png criado como cópia (pode não ser PNG válido)" >&2
        return 0
    fi
    
    echo "❌ Falha ao criar current_wallpaper.png" >&2
    return 1
}

# Aplica wallpaper
apply_wallpaper() {
    local wallpaper="$1"
    
    if [[ ! -f "$wallpaper" ]]; then
        echo "❌ Wallpaper não encontrado: $wallpaper" >&2
        return 1
    fi
    
    # Mata processos existentes
    pkill -x swaybg 2>/dev/null || true
    
    # Tenta swaybg primeiro
    if command -v swaybg &>/dev/null; then
        swaybg -i "$wallpaper" -m fill 2>/dev/null &
        echo "✅ Wallpaper aplicado com swaybg" >&2
        return 0
    fi
    
    # Tenta feh (fallback)
    if command -v feh &>/dev/null; then
        feh --bg-fill "$wallpaper" 2>/dev/null
        echo "✅ Wallpaper aplicado com feh" >&2
        return 0
    fi
    
    echo "❌ Nenhum backend encontrado" >&2
    return 1
}

# ============================================
# MAIN
# ============================================

main() {
    echo "🚀 Iniciando troca de wallpaper..." >&2
    
    # Verifica se o diretório de wallpapers existe
    if [[ ! -d "$WALLPAPER_DIR" ]]; then
        echo "❌ Diretório de wallpapers não encontrado: $WALLPAPER_DIR" >&2
        echo "💡 Crie o diretório e adicione algumas imagens:" >&2
        echo "   mkdir -p $WALLPAPER_DIR" >&2
        exit 1
    fi
    
    # Verifica se há wallpapers no diretório
    local has_wallpapers=false
    while IFS= read -r -d $'\0' file; do
        has_wallpapers=true
        break
    done < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" -o -iname "*.bmp" \) -print0 2>/dev/null)
    
    if [[ "$has_wallpapers" == "false" ]]; then
        echo "❌ Nenhuma imagem encontrada em: $WALLPAPER_DIR" >&2
        echo "📁 Adicione algumas imagens no diretório:" >&2
        echo "   cp /caminho/para/imagens/* $WALLPAPER_DIR/" >&2
        exit 1
    fi
    
    # Verifica e cria diretórios
    ensure_directories
    
    # 1. Seleciona wallpaper diferente do atual
    SELECTED=$(select_wallpaper)
    
    # Verifica se o wallpaper foi selecionado
    if [[ -z "$SELECTED" || ! -f "$SELECTED" ]]; then
        echo "❌ Falha ao selecionar um wallpaper válido" >&2
        echo "🔍 SELECTED='$SELECTED'" >&2
        exit 1
    fi
    
    echo "📌 Aplicando: $(basename "$SELECTED")" >&2
    
    # 2. Detecta resolução (apenas para informação)
    RESOLUTION=$(detect_resolution)
    echo "🖥️  Resolução: $RESOLUTION" >&2
    
    # 3. Aplica wallpaper
    if ! apply_wallpaper "$SELECTED"; then
        echo "❌ Falha ao aplicar wallpaper" >&2
        exit 1
    fi
    
    # 4. Atualiza histórico (primeira linha = wallpaper atual)
    update_history "$SELECTED"
    
    # 5. Cria cópia do wallpaper como PNG
    create_current_wallpaper_copy "$SELECTED"

    wal -i "$SELECTED"

    notify-send "Wallpaper alterado" "$(basename "$SELECTED")"
            
    echo "✨ Concluído!" >&2
}

# Executa
main "$@"
