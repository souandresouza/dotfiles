#!/bin/bash

set -e # Encerra o script imediatamente em caso de erro

DOTFILES_DIR=~/dotfiles
CONFIG_DIR=~/.config
BACKUP_DIR="$DOTFILES_DIR/backup_$(date +%Y%m%d_%H%M%S)"

declare -A DOTFILES
DOTFILES=(
    ["hypr"]="$CONFIG_DIR/hypr"
    ["waybar"]="$CONFIG_DIR/waybar"
    ["Thunar"]="$CONFIG_DIR/Thunar"
    ["alacritty"]="$CONFIG_DIR/alacritty"
    ["dunst"]="$CONFIG_DIR/dunst"
    ["zathura"]="$CONFIG_DIR/zathura"
)

declare -A HOME_FILES
HOME_FILES=(
    [".bashrc"]="$HOME/.bashrc"
)

echo "Iniciando configuração dos dotfiles..."
echo "Fazendo backup dos arquivos atuais em: $BACKUP_DIR"

# Cria diretórios necessários
mkdir -p "$CONFIG_DIR"
mkdir -p "$BACKUP_DIR"

# Função para fazer backup e criar link
link_file() {
    local source="$1"
    local target="$2"

    # Verifica se o arquivo/diretório de origem existe
    if [ ! -e "$source" ]; then
        echo "AVISO: O caminho de origem '$source' não existe. Pulando."
        return
    fi

    # Se o target já existe, move para o backup
    if [ -e "$target" ] || [ -L "$target" ]; then
        echo "Fazendo backup de '$target' para '$BACKUP_DIR'"
        mv "$target" "$BACKUP_DIR/"
    fi

    # Cria o link simbólico
    ln -sfn "$source" "$target"
    echo "Link criado: $source -> $target"
}

# Cria links para as pastas de configuração
for folder in "${!DOTFILES[@]}"; do
    link_file "$DOTFILES_DIR/$folder" "${DOTFILES[$folder]}"
done

# Cria links para os arquivos no home
for file in "${!HOME_FILES[@]}"; do
    link_file "$DOTFILES_DIR/$file" "${HOME_FILES[$file]}"
done

# Recarrega o Hyprland apenas se estiver em execução
echo "Verificando se o Hyprland está ativo..."
if command -v hyprctl >/dev/null 2>&1 && hyprctl monitors >/dev/null 2>&1; then
    hyprctl reload
    echo "Hyprland recarregado com sucesso."
else
    echo "Hyprland não está em execução. O recarregamento foi pulado."
fi

echo "✅ Configuração dos dotfiles concluída!"
