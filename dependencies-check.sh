#!/bin/bash
# dependencies-check.sh

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPENDENCIES_FILE="$DOTFILES_DIR/dependencies.txt"
MISSING_DEPS_FILE="$DOTFILES_DIR/missing-dependencies.log"

echo "🔍 Verificando dependências dos dotfiles..."

# Lista de dependências essenciais para Hyprland
declare -A ESSENTIAL_DEPS=(
    # Compositor e Gestor de Janelas
    ["hyprland"]="hyprland"
    ["hyprpaper"]="hyprpaper"
    
    # Barra e Status
    ["waybar"]="waybar"
    
    # Terminal
    ["alacritty"]="alacritty"
    
    # Launcher e Menus
    ["wofi"]="wofi"
    ["fuzzel"]="fuzzel"
    
    # Notificações
    ["dunst"]="dunst"
    
    # Gerenciamento de Arquivos
    ["thunar"]="thunar"
    ["thunar-archive-plugin"]="thunar-archive-plugin"
    ["tumbler"]="tumbler"
    
    # Visualizador de PDF/Imagens
    ["zathura"]="zathura"
    ["zathura-pdf-mupdf"]="zathura-pdf-mupdf"
    
    # Áudio
    ["pipewire"]="pipewire"
    ["wireplumber"]="wireplumber"
    ["pulseaudio"]="pulseaudio"
    
    # Bluetooth
    ["blueman"]="blueman"
    
    # Rede
    ["networkmanager"]="networkmanager"
    ["network-manager-applet"]="network-manager-applet"
    
    # Screenshot e Captura
    ["grim"]="grim"
    ["slurp"]="slurp"
    ["wf-recorder"]="wf-recorder"
    
    # Utilitários Básicos
    ["polkit"]="polkit"
    ["xdg-desktop-portal-hyprland"]="xdg-desktop-portal-hyprland"
    ["xdg-user-dirs"]="xdg-user-dirs"
    
    # Shell e Utilitários
    ["bash"]="bash"
    ["git"]="git"
    ["curl"]="curl"
    ["wget"]="wget"
)

# Dependências opcionais/recomendadas
declare -A OPTIONAL_DEPS=(
    ["spotify"]="spotify"
    ["discord"]="discord"
    ["firefox"]="firefox"
    ["vlc"]="vlc"
    ["gimp"]="gimp"
    ["neovim"]="neovim"
    ["ranger"]="ranger"
    ["htop"]="htop"
    ["btop"]="btop"
)

# Função para verificar se um pacote está instalado
check_dependency() {
    local dep_name="$1"
    local package_name="$2"
    
    if command -v "$dep_name" >/dev/null 2>&1 || \
       pacman -Qs "$package_name" >/dev/null 2>&1; then
        echo "✅ $dep_name"
        return 0
    else
        echo "❌ $dep_name"
        return 1
    fi
}

# Gerar arquivo de dependências se não existir
generate_dependencies_file() {
    echo "# Dependências essenciais para os dotfiles" > "$DEPENDENCIES_FILE"
    echo "# Gerado em: $(date)" >> "$DEPENDENCIES_FILE"
    echo "" >> "$DEPENDENCIES_FILE"
    echo "[ESSENTIAL]" >> "$DEPENDENCIES_FILE"
    for dep in "${!ESSENTIAL_DEPS[@]}"; do
        echo "${ESSENTIAL_DEPS[$dep]}" >> "$DEPENDENCIES_FILE"
    done
    
    echo "" >> "$DEPENDENCIES_FILE"
    echo "[OPTIONAL]" >> "$DEPENDENCIES_FILE"
    for dep in "${!OPTIONAL_DEPS[@]}"; do
        echo "${OPTIONAL_DEPS[$dep]}" >> "$DEPENDENCIES_FILE"
    done
    
    echo "📁 Arquivo de dependências gerado: $DEPENDENCIES_FILE"
}

# Verificação principal
check_all_dependencies() {
    local missing_count=0
    local optional_missing=0
    
    echo "## Dependências Essenciais ##"
    for dep in "${!ESSENTIAL_DEPS[@]}"; do
        if ! check_dependency "$dep" "${ESSENTIAL_DEPS[$dep]}"; then
            echo "MISSING: ${ESSENTIAL_DEPS[$dep]}" >> "$MISSING_DEPS_FILE"
            ((missing_count++))
        fi
    done
    
    echo ""
    echo "## Dependências Opcionais ##"
    for dep in "${!OPTIONAL_DEPS[@]}"; do
        if ! check_dependency "$dep" "${OPTIONAL_DEPS[$dep]}"; then
            ((optional_missing++))
        fi
    done
    
    # Relatório final
    echo ""
    echo "📊 RELATÓRIO:"
    echo "✅ Essenciais presentes: $(( ${#ESSENTIAL_DEPS[@]} - missing_count ))/${#ESSENTIAL_DEPS[@]}"
    echo "❌ Essenciais faltando: $missing_count"
    echo "💡 Opcionais faltando: $optional_missing"
    
    if [ $missing_count -gt 0 ]; then
        echo ""
        echo "🚨 Dependências essenciais faltando!"
        echo "📋 Lista completa em: $MISSING_DEPS_FILE"
        echo ""
        echo "Para instalar as dependências faltantes:"
        echo "sudo pacman -S $(grep 'MISSING' "$MISSING_DEPS_FILE" | cut -d' ' -f2 | tr '\n' ' ')"
    fi
}

# Script de instalação automática
install_missing_deps() {
    if [ ! -f "$MISSING_DEPS_FILE" ]; then
        echo "ℹ️  Nenhuma dependência faltando encontrada."
        return
    fi
    
    local missing_packages=$(grep 'MISSING' "$MISSING_DEPS_FILE" | cut -d' ' -f2 | tr '\n' ' ')
    
    if [ -z "$missing_packages" ]; then
        echo "✅ Todas as dependências estão instaladas!"
        return
    fi
    
    echo "📦 Instalando dependências faltantes: $missing_packages"
    read -p "Continuar? (s/N): " confirm
    if [[ $confirm =~ ^[Ss]$ ]]; then
        sudo pacman -S --needed $missing_packages
    fi
}

# Menu principal
case "${1:-}" in
    "install")
        install_missing_deps
        ;;
    "generate")
        generate_dependencies_file
        ;;
    *)
        # Limpar arquivo de missing deps anterior
        > "$MISSING_DEPS_FILE"
        
        # Verificar se arquivo de dependências existe, senão gerar
        if [ ! -f "$DEPENDENCIES_FILE" ]; then
            generate_dependencies_file
        fi
        
        check_all_dependencies
        
        echo ""
        echo "💡 Uso:"
        echo "./dependencies-check.sh          # Verificar dependências"
        echo "./dependencies-check.sh install  # Instalar dependências faltantes"
        echo "./dependencies-check.sh generate # Gerar arquivo de dependências"
        ;;
esac
