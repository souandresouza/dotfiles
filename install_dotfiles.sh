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
    [".zshrc"]="$HOME/.zshrc"
)

echo "Setting up dotfiles..."

for folder in "${!DOTFILES[@]}"; do
    TARGET="${DOTFILES[$folder]}"
    SOURCE="$DOTFILES_DIR/$folder"

    rm -rf "$TARGET"

    ln -sfn "$SOURCE" "$TARGET"
    echo "Linked $SOURCE -> $TARGET"
done

for file in "${!HOME_FILES[@]}"; do
    SOURCE="$DOTFILES_DIR/$file"

    rm "$HOME/$file"
    ln -sf "$SOURCE" "$HOME"
    echo "Copied $SOURCE -> $HOME"
done
echo "Dotfiles setup complete!"
