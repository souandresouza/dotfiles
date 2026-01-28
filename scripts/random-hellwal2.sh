#!/usr/bin/env bash

# Diretório dos wallpapers
WALLPAPER_DIR="/home/andre/Imagens/wallpapers/"
# Arquivo para histórico
HISTORY_FILE="/home/andre/last_wallpapers.txt"
MAX_HISTORY=10

# Arquivos para wallpaper atual (compatíveis com hyprlock e sddm)
CURRENT_WALLPAPER_FILE="$HOME/.cache/hellwal/wallpaper.png"  # Hellwal
CURRENT_WALLPAPER_GLOBAL="$HOME/.cache/current_wallpaper"    # Para hyprlock/sddm
CURRENT_WALLPAPER_SYMLINK="$HOME/.config/wallpaper"          # Symlink global

# 1. Verifica o diretório
if [[ ! -d "$WALLPAPER_DIR" ]]; then
  echo "Erro: O diretório '$WALLPAPER_DIR' não existe!"
  exit 1
fi

# 2. Encontra todas as imagens
readarray -d '' wallpapers < <(find "$WALLPAPER_DIR" -type f \
  \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \
  -o -iname "*.webp" \) -print0 2>/dev/null)

# 3. Verifica se há imagens
if [[ ${#wallpapers[@]} -eq 0 ]]; then
  echo "Erro: Nenhum wallpaper encontrado em '$WALLPAPER_DIR'."
  exit 1
fi

# 4. Lê o wallpaper atual (se existir)
current_wallpaper=""
if [[ -f "$CURRENT_WALLPAPER_FILE" ]]; then
  current_wallpaper=$(readlink -f "$CURRENT_WALLPAPER_FILE" 2>/dev/null || echo "")
fi

# 5. Lê histórico anterior
if [[ -f "$HISTORY_FILE" ]]; then
    mapfile -t used_wallpapers < "$HISTORY_FILE"
else
    used_wallpapers=()
fi

# 6. Filtrar wallpapers já usados recentemente
available_files=()
for file in "${wallpapers[@]}"; do
    # Não incluir o wallpaper atual se estiver no histórico
    if [[ "$file" == "$current_wallpaper" ]]; then
        continue
    fi
    
    # Verificar se está no histórico
    found=0
    for used in "${used_wallpapers[@]}"; do
        if [[ "$used" == "$file" ]]; then
            found=1
            break
        fi
    done
    
    if [[ $found -eq 0 ]]; then
        available_files+=("$file")
    fi
done

# 7. Se todos já foram usados, reiniciar o histórico
if [[ ${#available_files[@]} -eq 0 ]]; then
    echo "Todos os wallpapers foram usados recentemente! Reiniciando histórico..."
    available_files=("${wallpapers[@]}")
    used_wallpapers=()
fi

# 8. Selecionar aleatoriamente dos disponíveis
selected_wallpaper="${available_files[$((RANDOM % ${#available_files[@]}))]}"
echo "Mudando para: $(basename "$selected_wallpaper")"

# 9. Criar arquivos de wallpaper atual para hyprlock/sddm
echo "Criando arquivos de wallpaper atual..."
mkdir -p "$(dirname "$CURRENT_WALLPAPER_GLOBAL")"

# Salvar apenas o caminho do wallpaper
echo "$selected_wallpaper" > "$CURRENT_WALLPAPER_GLOBAL"

# Criar symlink para acesso fácil
ln -sf "$selected_wallpaper" "$CURRENT_WALLPAPER_SYMLINK"

# ATUALIZAR WALLPAPER PARA HYPRLOCK
echo "Atualizando wallpaper para hyprlock..."
HYPRLOCK_WALLPAPER="$HOME/.cache/wallpaper.png"

# Garantir que o diretório existe
mkdir -p "$(dirname "$HYPRLOCK_WALLPAPER")"

# Converter/copiar a imagem mantendo formato PNG
if [[ "$selected_wallpaper" == *.png ]]; then
    cp -f "$selected_wallpaper" "$HYPRLOCK_WALLPAPER"
else
    # Se não for PNG, converter para PNG
    if command -v convert &> /dev/null; then
        convert "$selected_wallpaper" "$HYPRLOCK_WALLPAPER"
    else
        # Fallback: copiar mesmo se não for PNG
        cp -f "$selected_wallpaper" "$HYPRLOCK_WALLPAPER"
    fi
fi

# Verificar se foi criado
if [[ -f "$HYPRLOCK_WALLPAPER" ]]; then
    echo "✓ Hyprlock wallpaper atualizado: $HYPRLOCK_WALLPAPER"
else
    echo "✗ Falha ao atualizar wallpaper para hyprlock"
fi

# 9. Criar arquivos de wallpaper atual
echo "Criando arquivos de wallpaper atual..."
mkdir -p "$(dirname "$CURRENT_WALLPAPER_GLOBAL")"

# Opção A: Salvar apenas o caminho
echo "$selected_wallpaper" > "$CURRENT_WALLPAPER_GLOBAL"

# Opção B: Copiar o conteúdo da imagem para um arquivo que hyprlock pode usar diretamente
WALLPAPER_CONTENT="$HOME/.cache/current_wallpaper_content"
if [[ "$selected_wallpaper" == *.png ]]; then
    cp -f "$selected_wallpaper" "$WALLPAPER_CONTENT"
else
    # Converter para PNG se necessário
    if command -v convert &> /dev/null; then
        convert "$selected_wallpaper" "$WALLPAPER_CONTENT"
    else
        cp -f "$selected_wallpaper" "$WALLPAPER_CONTENT"
    fi
fi

# Criar symlink para acesso fácil
ln -sf "$selected_wallpaper" "$CURRENT_WALLPAPER_SYMLINK"

# 10. Atualizar histórico
used_wallpapers=("$selected_wallpaper" "${used_wallpapers[@]:0:$((MAX_HISTORY-1))}")
printf "%s\n" "${used_wallpapers[@]}" > "$HISTORY_FILE"

# 11. Garantir que o daemon swww está rodando e APLICAR O WALLPAPER
if ! swww query > /dev/null 2>&1; then
    echo "Iniciando o daemon swww..."
    swww-daemon &
    # Dar um tempo para o daemon inicializar
    sleep 2
fi

echo "Aplicando wallpaper com swww..."
swww img "$selected_wallpaper" --transition-type grow

# 12. Gera cores com Hellwal
echo "Gerando paleta de cores com hellwal..."
hellwal -i "$selected_wallpaper"

# 13. Recarrega Waybar
if command -v waybar &> /dev/null; then
    echo "Recarregando Waybar..."
    pkill -USR2 waybar 2>/dev/null || true
fi

# 14. Atualizar hyprlock (se estiver usando)
if command -v hyprlock &> /dev/null; then
    echo "Wallpaper atual disponível para hyprlock em: $CURRENT_WALLPAPER_GLOBAL"
    echo "Symlink em: $CURRENT_WALLPAPER_SYMLINK"
fi

# 15. Opcional: Atualizar SDDM (requer sudo)
SDDM_WALLPAPER="/usr/share/sddm/themes/sugar-dark/background.png"
if [[ -d "/usr/share/sddm" ]] && [[ -w "$SDDM_WALLPAPER" || $EUID -eq 0 ]]; then
    echo "Atualizando wallpaper do SDDM..."
    sudo cp "$selected_wallpaper" "$SDDM_WALLPAPER" 2>/dev/null && \
        echo "✅ SDDM atualizado" || echo "⚠️  Não foi possível atualizar SDDM"
fi

# 16. Notificação opcional
if command -v notify-send &> /dev/null; then
    notify-send "🎨 Tema Atualizado" "Wallpaper: $(basename "$selected_wallpaper")" \
      -i "$selected_wallpaper" \
      -a "Hellwal"
fi

echo "✅ Script concluído com sucesso!"
echo "📁 Wallpaper atual salvo em:"
echo "   $CURRENT_WALLPAPER_GLOBAL (caminho)"
echo "   $CURRENT_WALLPAPER_SYMLINK (symlink)"
echo "   $WALLPAPER_CACHE (cópia)"
