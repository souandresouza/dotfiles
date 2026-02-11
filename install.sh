#!/usr/bin/env bash
set -euo pipefail

# Detecta o diretório atual onde o script está localizado
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
SCRIPTS_DIR="$DOTFILES_DIR/scripts"

echo "▶️ Iniciando a instalação dos dotfiles..."
echo "▶️ Diretório de backups: $BACKUP_DIR"

# Cria o diretório de backup e config
mkdir -p "$BACKUP_DIR"
mkdir -p "$CONFIG_DIR"

# Função de backup
backup() {
    local target="$1"
    if [[ -e "$target" && ! -L "$target" ]]; then
        echo "Fazendo backup de $target"
        mv "$target" "$BACKUP_DIR/"
    fi
}

# Função de link simbólico
link() {
    local source="$1"
    local target="$2"

    backup "$target"
    ln -sfn "$source" "$target"
    echo "Linkado $source -> $target"
}

# Verificando se stow está instalado
if ! command -v stow &>/dev/null; then
    echo "⚠️ O 'stow' não foi encontrado. Instalando..."
    sudo pacman -S --noconfirm stow
fi

# Configurações genéricas de dotfiles
CONFIGS=("hypr" "waybar" "rofi" "kitty" "dunst" "zathura")

for dir in "${CONFIGS[@]}"; do
    if [[ -d "$DOTFILES_DIR/$dir" ]]; then
        link "$DOTFILES_DIR/$dir" "$CONFIG_DIR/$dir"
    fi
done

# Arquivos no diretório home
HOME_FILES=(".bashrc" ".zshrc")

for file in "${HOME_FILES[@]}"; do
    if [[ -f "$DOTFILES_DIR/$file" ]]; then
        link "$DOTFILES_DIR/$file" "$HOME/$file"
    fi
done

# Instalando scripts
if [[ -d "$SCRIPTS_DIR" ]]; then
    echo "▶️ Instalando scripts..."

    # Verifica se o diretório de scripts existe e copia os arquivos
    for script in "$SCRIPTS_DIR"/*; do
        if [[ -f "$script" && -x "$script" ]]; then
            # Copia o script para o diretório de bin do usuário, se não existir
            cp "$script" "$HOME/.local/bin/"
            echo "Instalado script: $(basename "$script")"
        fi
    done
else
    echo "⚠️ Nenhum script encontrado na pasta '$SCRIPTS_DIR'."
fi

# Verificando o tipo de sessão (Wayland ou X11) para recarregar o WM
if [[ "$XDG_SESSION_TYPE" == "wayland" && -x "$(command -v hyprctl)" ]]; then
    echo "▶️ Recarregando Hyprland..."
    hyprctl reload || true
elif command -v swaymsg &>/dev/null; then
    echo "▶️ Recarregando Sway..."
    swaymsg reload || true
elif command -v i3-msg &>/dev/null; then
    echo "▶️ Recarregando i3..."
    i3-msg reload || true
fi

echo ""
echo "✅ Instalação concluída!"
echo "Backups armazenados em: $BACKUP_DIR"
