#!/bin/bash

DOTFILES_DIR=~/dotfiles
CONFIG_DIR=~/.config

declare -A DOTFILES
DOTFILES=(
    ["cava"]="$CONFIG_DIR/cava"
    ["dunst"]="$CONFIG_DIR/dunst"
    ["fastfetch"]="$CONFIG_DIR/fastfetch"
    ["fuzzel"]="$CONFIG_DIR/fuzzel"
    ["hypr"]="$CONFIG_DIR/hypr"
    ["kitty"]="$CONFIG_DIR/kitty"
    ["mako"]="$CONFIG_DIR/mako"
    ["mango"]="$CONFIG_DIR/mango"
    ["music-tui"]="$CONFIG_DIR/music-tui"
    ["niri"]="$CONFIG_DIR/niri"
    ["scripts"]="$CONFIG_DIR/scripts"
    ["swaylock"]="$CONFIG_DIR/swaylock"
    ["swaync"]="$CONFIG_DIR/swaync"
    ["wallpapers"]="$CONFIG_DIR/wallpapers"
    ["waybar"]="$CONFIG_DIR/waybar"
    ["zathura"]="$CONFIG_DIR/zathura"
)

declare -A HOME_FILES
HOME_FILES=(
    [".bashrc"]="$HOME/.bashrc"
)

echo "Setting up dotfiles..."

for folder in "${!DOTFILES[@]}"; do
    TARGET="${DOTFILES[$folder]}"
    SOURCE="$DOTFILES_DIR/$folder"

    # Remove o diretório de destino existente
    rm -rf "$TARGET"

    # Copia o diretório do dotfiles para o destino
    cp -r "$SOURCE" "$TARGET"
    echo "Copied $SOURCE -> $TARGET"
done

for file in "${!HOME_FILES[@]}"; do
    SOURCE="$DOTFILES_DIR/$file"
    TARGET="$HOME/$file"

    # Remove o arquivo de destino existente
    rm -f "$TARGET"

    # Copia o arquivo do dotfiles para o home
    cp "$SOURCE" "$TARGET"
    echo "Copied $SOURCE -> $TARGET"
done

echo "Dotfiles setup complete!"
