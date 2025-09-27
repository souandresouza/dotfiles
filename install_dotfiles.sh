#!/bin/bash

DOTFILES_DIR=~/dotfiles
CONFIG_DIR=~/.config

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

echo "Setting up dotfiles..."

# Criar diretório .config se não existir
mkdir -p "$CONFIG_DIR"

# Linkar pastas do .config
for folder in "${!DOTFILES[@]}"; do
    TARGET="${DOTFILES[$folder]}"
    SOURCE="$DOTFILES_DIR/$folder"

    if [ -e "$TARGET" ]; then
        rm -rf "$TARGET"
    fi

    ln -sfn "$SOURCE" "$TARGET"
    echo "Linked $SOURCE -> $TARGET"
done

# Linkar arquivos do HOME
for file in "${!HOME_FILES[@]}"; do
    TARGET="${HOME_FILES[$file]}"
    SOURCE="$DOTFILES_DIR/$file"

    if [ -e "$TARGET" ]; then
        rm "$TARGET"
    fi

    ln -sf "$SOURCE" "$TARGET"
    echo "Linked $SOURCE -> $TARGET"
done

# Recarregar Hyprland apenas se estiver rodando
if command -v hyprctl >/dev/null 2>&1 && hyprctl monitors >/dev/null 2>&1; then
    hyprctl reload
    echo "Hyprland reloaded"
else
    echo "Hyprland not running, skip reload"
fi

echo "Dotfiles setup complete!"
