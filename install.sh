#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

echo "▶ Installing dotfiles..."
echo "▶ Backup dir: $BACKUP_DIR"

mkdir -p "$BACKUP_DIR"
mkdir -p "$CONFIG_DIR"

backup() {
    local target="$1"
    if [[ -e "$target" && ! -L "$target" ]]; then
        echo "Backing up $target"
        mv "$target" "$BACKUP_DIR/"
    fi
}

link() {
    local source="$1"
    local target="$2"

    backup "$target"
    ln -sfn "$source" "$target"
    echo "Linked $source -> $target"
}

# Config folders
for dir in hypr waybar rofi kitty dunst zathura; do
    if [[ -d "$DOTFILES_DIR/$dir" ]]; then
        link "$DOTFILES_DIR/$dir" "$CONFIG_DIR/$dir"
    fi
done

# Home files
for file in .bashrc; do
    if [[ -f "$DOTFILES_DIR/$file" ]]; then
        link "$DOTFILES_DIR/$file" "$HOME/$file"
    fi
done

# Reload Hyprland if running
command -v hyprctl &>/dev/null && hyprctl reload || true

echo ""
echo "✅ Done!"
echo "Backups stored in: $BACKUP_DIR"
