#!/usr/bin/env bash
set -euo pipefail

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Detecta o diretório atual onde o script está localizado
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
BIN_DIR="$HOME/.local/bin"

echo -e "${BLUE}▶️ Iniciando a instalação dos dotfiles...${NC}"
echo -e "${BLUE}▶️ Diretório de backups: $BACKUP_DIR${NC}"

# Cria os diretórios necessários
mkdir -p "$BACKUP_DIR"
mkdir -p "$CONFIG_DIR"
mkdir -p "$BIN_DIR"

# Função de backup melhorada
backup() {
    local target="$1"
    if [[ -e "$target" || -L "$target" ]]; then
        local backup_path="$BACKUP_DIR/$(basename "$target")"
        if [[ -e "$backup_path" ]]; then
            backup_path="$BACKUP_DIR/$(basename "$target")_$(date +%s)"
        fi
        echo -e "${YELLOW}📦 Fazendo backup de $target -> $backup_path${NC}"
        mv "$target" "$backup_path"
    fi
}

# Função de link simbólico melhorada
link() {
    local source="$1"
    local target="$2"
    
    if [[ ! -e "$source" ]]; then
        echo -e "${RED}❌ Origem não encontrada: $source${NC}"
        return 1
    fi
    
    backup "$target"
    ln -sfn "$source" "$target"
    echo -e "${GREEN}🔗 Linkado $source -> $target${NC}"
}

# Verifica dependências essenciais
check_dependencies() {
    local deps=("stow" "git")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${YELLOW}⚠️ Dependências faltando: ${missing[*]}${NC}"
        echo -e "${BLUE}▶️ Instalando...${NC}"
        sudo pacman -S --noconfirm "${missing[@]}"
    fi
}

# Lista atualizada de configurações (baseada na sua nova estrutura)
# Adicione ou remova pastas conforme sua necessidade atual
CONFIGS=(
    "hypr"
    "waybar"
    "rofi"
    "kitty"
    "dunst"
    "swaync"          # Novo: notificações
    "swww"            # Novo: wallpaper
    "hyprlock"        # Novo: lock screen
    "hypridle"        # Novo: idle manager
    "nvim"            # Editor
    "zathura"         # PDF viewer
    "fastfetch"       # Novo: info do sistema
    "yazi"            # Novo: file manager
    "tmux"            # Terminal multiplexer
    "gtk-3.0"         # Tema GTK3
    "gtk-4.0"         # Tema GTK4
    "qt5ct"           # Configuração Qt5
    "qt6ct"           # Configuração Qt6
    "mpv"             # Media player
    "user-dirs.dirs"  # Pastas do usuário
)

# Arquivos no diretório home (atualizados)
HOME_FILES=(
    ".bashrc"
    ".zshrc"
    ".zprofile"
    ".gitconfig"
    ".p10k.zsh"       # Powerlevel10k config
)

# 🔥 NOVA FUNÇÃO: Processa scripts de forma mais inteligente
install_scripts() {
    local scripts_dir="$DOTFILES_DIR/scripts"
    local scripts_config="$DOTFILES_DIR/.config/scripts"
    
    # Verifica múltiplas possíveis localizações da pasta scripts
    if [[ -d "$scripts_dir" ]]; then
        echo -e "${BLUE}▶️ Instalando scripts de $scripts_dir...${NC}"
        
        # Torna todos os scripts executáveis
        find "$scripts_dir" -type f -name "*.sh" -exec chmod +x {} \;
        find "$scripts_dir" -type f -name "*.py" -exec chmod +x {} \;
        
        # Copia para ~/.local/bin/
        cp -r "$scripts_dir"/* "$BIN_DIR/" 2>/dev/null || true
        
        # Link simbólico também para .config/scripts (se quiser manter lá)
        if [[ ! -L "$CONFIG_DIR/scripts" ]]; then
            link "$scripts_dir" "$CONFIG_DIR/scripts"
        fi
        
        echo -e "${GREEN}✅ Scripts instalados em $BIN_DIR${NC}"
        
    elif [[ -d "$scripts_config" ]]; then
        echo -e "${BLUE}▶️ Instalando scripts de $scripts_config...${NC}"
        find "$scripts_config" -type f -name "*.sh" -exec chmod +x {} \;
        find "$scripts_config" -type f -name "*.py" -exec chmod +x {} \;
        cp -r "$scripts_config"/* "$BIN_DIR/" 2>/dev/null || true
        echo -e "${GREEN}✅ Scripts instalados em $BIN_DIR${NC}"
    else
        echo -e "${YELLOW}⚠️ Nenhum script encontrado${NC}"
    fi
    
    # Adiciona ~/.local/bin ao PATH se não estiver
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
        echo -e "${YELLOW}⚠️ ~/.local/bin adicionado ao PATH (reinicie o shell)${NC}"
    fi
}

# 🔥 NOVA FUNÇÃO: Verifica e instala pacotes necessários
install_packages() {
    if [[ -f "$DOTFILES_DIR/packages.txt" ]]; then
        echo -e "${BLUE}▶️ Instalando pacotes listados...${NC}"
        sudo pacman -S --noconfirm --needed - < "$DOTFILES_DIR/packages.txt"
    fi
    
    if [[ -f "$DOTFILES_DIR/aur-packages.txt" ]] && command -v yay &>/dev/null; then
        echo -e "${BLUE}▶️ Instalando pacotes AUR...${NC}"
        yay -S --noconfirm --needed - < "$DOTFILES_DIR/aur-packages.txt"
    fi
}

# 🔥 NOVA FUNÇÃO: Aplica permissões corretas
fix_permissions() {
    echo -e "${BLUE}▶️ Ajustando permissões...${NC}"
    
    # Scripts em .local/bin
    find "$BIN_DIR" -type f -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true
    find "$BIN_DIR" -type f -name "*.py" -exec chmod +x {} \; 2>/dev/null || true
    
    # Configurações do Hyprland (alguns arquivos precisam ser executáveis)
    [[ -f "$CONFIG_DIR/hypr/hyprland.conf" ]] && chmod 644 "$CONFIG_DIR/hypr/hyprland.conf"
}

# Main execution
main() {
    # Verifica dependências
    check_dependencies
    
    # Configurações do .config
    echo -e "${BLUE}▶️ Linkando configurações...${NC}"
    for dir in "${CONFIGS[@]}"; do
        if [[ -d "$DOTFILES_DIR/$dir" ]]; then
            link "$DOTFILES_DIR/$dir" "$CONFIG_DIR/$dir"
        elif [[ -d "$DOTFILES_DIR/.config/$dir" ]]; then
            link "$DOTFILES_DIR/.config/$dir" "$CONFIG_DIR/$dir"
        fi
    done
    
    # Arquivos na home
    echo -e "${BLUE}▶️ Linkando arquivos da home...${NC}"
    for file in "${HOME_FILES[@]}"; do
        if [[ -f "$DOTFILES_DIR/$file" ]]; then
            link "$DOTFILES_DIR/$file" "$HOME/$file"
        elif [[ -f "$DOTFILES_DIR/.$file" ]]; then
            link "$DOTFILES_DIR/.$file" "$HOME/$file"
        fi
    done
    
    # Instala scripts
    install_scripts
    
    # Instala pacotes (opcional, comentado por padrão)
    # install_packages
    
    # Ajusta permissões
    fix_permissions
    
    # Recarrega WM se possível
    if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
        if command -v hyprctl &>/dev/null; then
            echo -e "${BLUE}▶️ Recarregando Hyprland...${NC}"
            hyprctl reload 2>/dev/null || true
        fi
    fi
    
    echo ""
    echo -e "${GREEN}✅ Instalação concluída com sucesso!${NC}"
    echo -e "${BLUE}Backups armazenados em: $BACKUP_DIR${NC}"
    echo ""
    echo -e "${YELLOW}📝 Próximos passos:${NC}"
    echo "1. Reinicie seu shell: exec $SHELL"
    echo "2. Verifique se tudo está funcionando: ls -la ~/.config/"
    echo "3. Se algo não funcionar, os backups estão em $BACKUP_DIR"
}

# Executa o script
main "$@"
