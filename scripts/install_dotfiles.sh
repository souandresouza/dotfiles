#!/bin/bash

DOTFILES_DIR=~/dotfiles
CONFIG_DIR=~/.config

# Configurações de diretórios (todos dentro de dotfiles/config/)
declare -A CONFIG_DIRS
CONFIG_DIRS=(
    # Diretórios simples
    ["cava"]="$CONFIG_DIR/cava"
    ["dunst"]="$CONFIG_DIR/dunst"
    ["fastfetch"]="$CONFIG_DIR/fastfetch"
    ["fuzzel"]="$CONFIG_DIR/fuzzel"
    ["kitty"]="$CONFIG_DIR/kitty"
    ["niri"]="$CONFIG_DIR/niri"
    ["scripts"]="$CONFIG_DIR/scripts"
    ["termusic"]="$CONFIG_DIR/termusic"
    ["wallpapers"]="$CONFIG_DIR/wallpapers"
    ["waybar"]="$CONFIG_DIR/waybar"
    ["zathura"]="$CONFIG_DIR/zathura"
    
    # Hyprland - estrutura especial com subdiretório config/
    ["hypr"]="$CONFIG_DIR/hypr"
)

# Arquivos individuais no diretório home
declare -A HOME_FILES
HOME_FILES=(
    [".bashrc"]="$HOME/.bashrc"
    [".bash_profile"]="$HOME/.bash_profile"
)

# Arquivos de documentação/listas que ficam apenas no dotfiles
DOTFILES_DOCS=(
    "LICENSE"
    "lista_appimage.txt"
    "lista_aur.txt"
    "lista_flatpak.txt"
    "lista_pacman.txt"
)

# Função para criar backup com timestamp
backup_existing() {
    local path="$1"
    if [ -e "$path" ]; then
        local backup="${path}.backup.$(date +%Y%m%d_%H%M%S)"
        mv "$path" "$backup"
        echo "  📦 Backup criado: $(basename "$backup")"
    fi
}

# Função para criar diretório se não existir
ensure_dir() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        echo "  📁 Diretório criado: $dir"
    fi
}

# Função para criar symlink com verificações
create_symlink() {
    local source="$1"
    local target="$2"
    
    # Verificar se fonte existe
    if [ ! -e "$source" ]; then
        echo "  ⚠️  Fonte não encontrada: $source"
        return 1
    fi
    
    # Garantir que o diretório pai do target existe
    ensure_dir "$(dirname "$target")"
    
    # Remover symlink existente ou fazer backup de diretório/arquivo real
    if [ -L "$target" ]; then
        rm "$target"
        echo "  🗑️  Symlink anterior removido"
    elif [ -e "$target" ]; then
        backup_existing "$target"
    fi
    
    # Criar o symlink
    ln -sfn "$source" "$target"
    echo "  ✅ $(basename "$source") → $target"
    return 0
}

echo "🚀 Configurando dotfiles..."
echo "================================"
echo "📂 Diretório fonte: $DOTFILES_DIR"
echo "📂 Config fonte: $DOTFILES_DIR/config/"
echo "📂 Diretório destino: $CONFIG_DIR"
echo "================================"

# Verificar arquivos de documentação no dotfiles
echo ""
echo "📋 Verificando arquivos de documentação..."
for doc in "${DOTFILES_DOCS[@]}"; do
    if [ -f "$DOTFILES_DIR/$doc" ]; then
        size=$(du -h "$DOTFILES_DIR/$doc" | cut -f1)
        echo "  ✅ $doc ($size)"
    else
        echo "  ❌ $doc (não encontrado)"
    fi
done

# Processar diretórios de configuração
echo ""
echo "📁 Configurando diretórios de config..."

for dir in "${!CONFIG_DIRS[@]}"; do
    TARGET="${CONFIG_DIRS[$dir]}"
    SOURCE="$DOTFILES_DIR/config/$dir"
    
    echo ""
    echo "📌 Processando: $dir"
    create_symlink "$SOURCE" "$TARGET"
done

# Processar arquivos do home
if [ ${#HOME_FILES[@]} -gt 0 ]; then
    echo ""
    echo "📁 Configurando arquivos do home..."
    
    for file in "${!HOME_FILES[@]}"; do
        SOURCE="$DOTFILES_DIR/$file"
        TARGET="${HOME_FILES[$file]}"
        
        echo ""
        echo "📌 Processando: $file"
        create_symlink "$SOURCE" "$TARGET"
    done
fi

# Verificações específicas da estrutura
echo ""
echo "================================"
echo "🔍 Verificações detalhadas..."
echo "================================"

# Verificar estrutura do Hyprland
echo ""
echo "🔍 Estrutura do Hyprland:"
if [ -d "$CONFIG_DIR/hypr" ]; then
    echo "✅ Diretório principal encontrado"
    
    # Arquivos principais
    HYPR_MAIN_FILES=("hyprland.lua" "hypridle.conf" "hyprlock.conf" "monitors.lua" "workspaces.lua")
    echo "  Arquivos principais:"
    for file in "${HYPR_MAIN_FILES[@]}"; do
        if [ -f "$CONFIG_DIR/hypr/$file" ]; then
            echo "    ✅ $file"
        else
            echo "    ❌ $file (faltando)"
        fi
    done
    
    # Subdiretório config/
    if [ -d "$CONFIG_DIR/hypr/config" ]; then
        echo "  ✅ Subdiretório config/ encontrado"
        
        HYPR_CONFIG_FILES=("animations.lua" "appearance.lua" "autostart.lua" "binds.lua" "colors.lua" "env.lua" "input.lua" "windowrules.lua")
        echo "  Arquivos de configuração:"
        for file in "${HYPR_CONFIG_FILES[@]}"; do
            if [ -f "$CONFIG_DIR/hypr/config/$file" ]; then
                echo "    ✅ $file"
            else
                echo "    ❌ $file (faltando)"
            fi
        done
    else
        echo "  ❌ Subdiretório config/ não encontrado"
    fi
else
    echo "❌ Diretório hypr não encontrado"
fi

# Verificar estrutura do Niri
echo ""
echo "🔍 Estrutura do Niri:"
if [ -d "$CONFIG_DIR/niri" ]; then
    echo "✅ Diretório encontrado"
    
    NIRI_FILES=("animations.kdl" "binds.kdl" "config.kdl" "input.kdl" "layout.kdl" "outputs.kdl" "spawn.kdl" "windows.kdl")
    echo "  Arquivos:"
    for file in "${NIRI_FILES[@]}"; do
        if [ -f "$CONFIG_DIR/niri/$file" ]; then
            echo "    ✅ $file"
        else
            echo "    ❌ $file (faltando)"
        fi
    done
else
    echo "❌ Diretório niri não encontrado"
fi

# Verificar outros diretórios importantes
echo ""
echo "🔍 Outros diretórios de configuração:"
OTHER_DIRS=("waybar" "kitty" "dunst" "cava" "fastfetch" "fuzzel" "scripts" "termusic" "wallpapers")
for dir in "${OTHER_DIRS[@]}"; do
    if [ -d "$CONFIG_DIR/$dir" ]; then
        file_count=$(ls -1 "$CONFIG_DIR/$dir" 2>/dev/null | wc -l)
        echo "  ✅ $dir ($file_count arquivos)"
    else
        echo "  ❌ $dir (não encontrado)"
    fi
done

# Verificar zathura (futuro)
if [ ! -d "$DOTFILES_DIR/config/zathura" ]; then
    echo ""
    echo "💡 Lembrete: O diretório zathura ainda precisa ser adicionado em:"
    echo "   $DOTFILES_DIR/config/zathura"
fi

# Estatísticas dos arquivos de documentação
echo ""
echo "📊 Estatísticas das listas:"
for doc in "${DOTFILES_DOCS[@]}"; do
    if [ -f "$DOTFILES_DIR/$doc" ]; then
        case "$doc" in
            "lista_pacman.txt")
                pkg_count=$(grep -c -v '^#' "$DOTFILES_DIR/$doc" 2>/dev/null || echo "0")
                echo "  📦 Pacotes oficiais: $pkg_count"
                ;;
            "lista_aur.txt")
                aur_count=$(grep -c -v '^#' "$DOTFILES_DIR/$doc" 2>/dev/null || echo "0")
                echo "  🅰️  Pacotes AUR: $aur_count"
                ;;
            "lista_flatpak.txt")
                flatpak_count=$(grep -c -v '^#' "$DOTFILES_DIR/$doc" 2>/dev/null || echo "0")
                echo "  📦 Pacotes Flatpak: $flatpak_count"
                ;;
            "lista_appimage.txt")
                appimage_count=$(grep -c -v '^#' "$DOTFILES_DIR/$doc" 2>/dev/null || echo "0")
                echo "  📦 AppImages: $appimage_count"
                ;;
            "LICENSE")
                echo "  📄 Licença presente"
                ;;
        esac
    fi
done

# Recarregar configurações do Hyprland
echo ""
echo "================================"
if command -v hyprctl &> /dev/null; then
    echo "🔄 Recarregando Hyprland..."
    if hyprctl reload &> /dev/null; then
        echo "✅ Hyprland recarregado com sucesso"
    else
        echo "⚠️  Erro ao recarregar Hyprland"
    fi
else
    echo "ℹ️  hyprctl não encontrado - execute manualmente se necessário"
fi

# Recarregar Niri se disponível
if command -v niri &> /dev/null; then
    echo "🔄 Recarregando Niri..."
    if niri msg action reload-config &> /dev/null; then
        echo "✅ Niri recarregado com sucesso"
    else
        echo "⚠️  Niri pode não estar em execução"
    fi
fi

echo ""
echo "================================"
echo "🎉 Dotfiles configurados com sucesso!"
echo "================================"

# Resumo final
echo ""
echo "📊 Resumo final:"
echo "  • Diretórios configurados: ${#CONFIG_DIRS[@]}"
echo "  • Arquivos home configurados: ${#HOME_FILES[@]}"
echo "  • Arquivos de documentação: ${#DOTFILES_DOCS[@]}"
echo "  • Diretório fonte: $DOTFILES_DIR"
echo "  • Config fonte: $DOTFILES_DIR/config/"
echo "  • Diretório destino: $CONFIG_DIR"

# Sugestões úteis
echo ""
echo "💡 Dicas úteis:"
echo "  • Para instalar pacotes: grep -v '^#' lista_pacman.txt | sudo pacman -S -"
echo "  • Para instalar AUR: grep -v '^#' lista_aur.txt | yay -S -"
echo "  • Para instalar Flatpaks: grep -v '^#' lista_flatpak.txt | xargs flatpak install"
