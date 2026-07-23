#!/usr/bin/env bash

set -euo pipefail

# ==========================================================
# Arch Niri Dotfiles Installer
# Cria symlinks dos dotfiles e configura o ambiente
# ==========================================================

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.local/share/dotfiles/backups"

echo "🚀 Instalando dotfiles..."
echo "================================"
echo "📂 Origem: $DOTFILES_DIR"
echo "📂 Destino: $CONFIG_DIR"
echo "================================"

# ----------------------------------------------------------
# Funções
# ----------------------------------------------------------

backup_existing() {
    local target="$1"

    if [ -e "$target" ] || [ -L "$target" ]; then
        mkdir -p "$BACKUP_DIR"

        local name
        name=$(basename "$target")

        local backup="$BACKUP_DIR/${name}.$(date +%Y%m%d_%H%M%S)"

        mv "$target" "$backup"

        echo "📦 Backup: $backup"
    fi
}


create_symlink() {
    local source="$1"
    local target="$2"

    if [ ! -e "$source" ]; then
        echo "⚠️  Não encontrado: $source"
        return
    fi

    mkdir -p "$(dirname "$target")"

    if [ -L "$target" ]; then
        rm "$target"
    elif [ -e "$target" ]; then
        backup_existing "$target"
    fi

    ln -s "$source" "$target"

    echo "✅ $(basename "$source")"
}


create_directory() {
    local dir="$1"

    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        echo "📁 Criado: $dir"
    fi
}


# ----------------------------------------------------------
# Criar diretórios padrão
# ----------------------------------------------------------

echo ""
echo "📁 Criando diretórios..."

DIRECTORIES=(
    "$HOME/Imagens/wallpapers"
    "$HOME/Imagens/Screenshots"
    "$HOME/Vídeos/Recordings"
    "$HOME/.cache"
    "$HOME/.local/bin"
)

for dir in "${DIRECTORIES[@]}"; do
    create_directory "$dir"
done


# ----------------------------------------------------------
# Configurações ~/.config
# ----------------------------------------------------------

echo ""
echo "⚙️  Instalando configurações..."

CONFIGS=(
    "niri"
    "waybar"
    "fuzzel"
    "kitty"
    "dunst"
    "fastfetch"
    "cava"
    "zathura"
    "termusic"
    "hyprlock"
    "hyprpicker"
    "scripts"
)


for config in "${CONFIGS[@]}"; do

    SOURCE="$DOTFILES_DIR/config/$config"
    TARGET="$CONFIG_DIR/$config"

    echo ""
    echo "📌 $config"

    create_symlink "$SOURCE" "$TARGET"

done


# ----------------------------------------------------------
# Arquivos HOME
# ----------------------------------------------------------

echo ""
echo "🏠 Arquivos do Home..."

HOME_FILES=(
    ".bashrc"
    ".bash_profile"
)


for file in "${HOME_FILES[@]}"; do

    SOURCE="$DOTFILES_DIR/home/$file"
    TARGET="$HOME/$file"

    echo ""
    echo "📌 $file"

    create_symlink "$SOURCE" "$TARGET"

done


# ----------------------------------------------------------
# Permissões dos scripts
# ----------------------------------------------------------

echo ""
echo "🔧 Ajustando permissões..."

if [ -d "$CONFIG_DIR/scripts" ]; then
    chmod +x "$CONFIG_DIR/scripts/"* 2>/dev/null || true
fi


# ----------------------------------------------------------
# Validar Niri
# ----------------------------------------------------------

echo ""
echo "🔍 Validando Niri..."

if command -v niri >/dev/null; then

    if niri validate "$CONFIG_DIR/niri/config.kdl"; then
        echo "✅ Configuração Niri válida"
    else
        echo "⚠️  Erro na configuração Niri"
    fi

else
    echo "ℹ️  Niri não encontrado"
fi


# ----------------------------------------------------------
# Recarregar ambiente
# ----------------------------------------------------------

echo ""
echo "🔄 Recarregando..."

if command -v niri >/dev/null; then
    niri msg action reload-config 2>/dev/null || true
fi


echo ""
echo "================================"
echo "🎉 Dotfiles instalados!"
echo "================================"

echo ""
echo "Resumo:"
echo "• Configurações: ${#CONFIGS[@]}"
echo "• Arquivos HOME: ${#HOME_FILES[@]}"
echo "• Backups: $BACKUP_DIR"
