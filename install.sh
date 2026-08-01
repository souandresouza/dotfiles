#!/bin/bash

DOTFILES_DIR="$HOME/dotfiles"
CONFIG_DIR="$HOME/.config"

declare -A DOTFILES
DOTFILES=(
    ["cava"]="$CONFIG_DIR/cava"
    ["fastfetch"]="$CONFIG_DIR/fastfetch"
    ["fuzzel"]="$CONFIG_DIR/fuzzel"
    ["hypr"]="$CONFIG_DIR/hypr"
    ["kitty"]="$CONFIG_DIR/kitty"
    ["mako"]="$CONFIG_DIR/mako"
    ["niri"]="$CONFIG_DIR/niri"
    ["scripts"]="$CONFIG_DIR/scripts"
    ["wallpapers"]="$CONFIG_DIR/wallpapers"
    ["waybar"]="$CONFIG_DIR/waybar"
    ["zathura"]="$CONFIG_DIR/zathura"
)

declare -A HOME_FILES
HOME_FILES=(
    [".bashrc"]="$HOME/.bashrc"
    [".gtkrc-2.0"]="$HOME/.gtkrc-2.0"
)

echo "Restaurando dotfiles do backup..."

for folder in "${!DOTFILES[@]}"; do
    SOURCE="$DOTFILES_DIR/$folder"
    TARGET="${DOTFILES[$folder]}"

    [[ ! -e "$SOURCE" ]] && echo "Pulando $folder (não encontrado)" && continue

    rm -rf "$TARGET"
    mkdir -p "$(dirname "$TARGET")"
    ln -s "$SOURCE" "$TARGET"
    echo "$folder → $TARGET"
done

for file in "${!HOME_FILES[@]}"; do
    SOURCE="$DOTFILES_DIR/$file"
    TARGET="${HOME_FILES[$file]}"

    [[ ! -e "$SOURCE" ]] && echo "Pulando $file (não encontrado)" && continue

    rm -f "$TARGET"
    ln -s "$SOURCE" "$TARGET"
    echo "$file → $TARGET"
done

niri msg action do-screen-transition 2>/dev/null || true

echo "Restauração concluída!"
