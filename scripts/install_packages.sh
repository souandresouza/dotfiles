#!/bin/bash

DOTFILES_DIR=~/dotfiles
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}📦 Instalador de Pacotes - Dotfiles${NC}"
echo -e "${CYAN}======================================${NC}"
echo ""

# Verificar se os arquivos de lista existem
check_lists() {
    local missing=0
    local lists=("lista_pacman.txt" "lista_aur.txt" "lista_flatpak.txt" "lista_appimage.txt")
    
    for list in "${lists[@]}"; do
        if [ ! -f "$DOTFILES_DIR/$list" ]; then
            echo -e "${RED}❌ Lista não encontrada: $DOTFILES_DIR/$list${NC}"
            missing=1
        fi
    done
    
    return $missing
}

# Menu interativo
show_menu() {
    echo -e "${YELLOW}Escolha uma opção:${NC}"
    echo ""
    echo "1) Instalar pacotes oficiais (pacman)"
    echo "2) Instalar pacotes AUR (yay/paru)"
    echo "3) Instalar pacotes Flatpak"
    echo "4) Instalar AppImages"
    echo "5) Instalar TUDO"
    echo "6) Apenas verificar dependências"
    echo "7) Sair"
    echo ""
    read -p "Opção [1-7]: " option
    
    case $option in
        1) install_pacman ;;
        2) install_aur ;;
        3) install_flatpak ;;
        4) install_appimage ;;
        5) install_all ;;
        6) check_dependencies ;;
        7) echo "Saindo..." ; exit 0 ;;
        *) echo -e "${RED}Opção inválida!${NC}" ; show_menu ;;
    esac
}

# Verificar dependências
check_dependencies() {
    echo -e "${BLUE}🔍 Verificando dependências...${NC}"
    echo ""
    
    # Verificar pacman
    if command -v pacman &> /dev/null; then
        echo -e "${GREEN}✅ pacman encontrado${NC}"
    else
        echo -e "${RED}❌ pacman não encontrado (não é Arch-based?)${NC}"
    fi
    
    # Verificar AUR helper
    if command -v yay &> /dev/null; then
        echo -e "${GREEN}✅ yay encontrado${NC}"
    elif command -v paru &> /dev/null; then
        echo -e "${GREEN}✅ paru encontrado${NC}"
    else
        echo -e "${YELLOW}⚠️  Nenhum AUR helper encontrado (yay/paru)${NC}"
    fi
    
    # Verificar flatpak
    if command -v flatpak &> /dev/null; then
        echo -e "${GREEN}✅ flatpak encontrado${NC}"
    else
        echo -e "${YELLOW}⚠️  flatpak não encontrado${NC}"
    fi
    
    # Verificar appimagelauncher (opcional)
    if command -v appimagelauncherd &> /dev/null; then
        echo -e "${GREEN}✅ AppImageLauncher encontrado${NC}"
    else
        echo -e "${YELLOW}⚠️  AppImageLauncher não encontrado (recomendado para AppImages)${NC}"
    fi
    
    echo ""
    read -p "Pressione ENTER para voltar ao menu..." 
    show_menu
}

# Instalar pacotes oficiais
install_pacman() {
    echo -e "${BLUE}📦 Instalando pacotes oficiais...${NC}"
    
    if [ ! -f "$DOTFILES_DIR/lista_pacman.txt" ]; then
        echo -e "${RED}❌ lista_pacman.txt não encontrada${NC}"
        return 1
    fi
    
    # Contar pacotes
    total=$(grep -v '^#' "$DOTFILES_DIR/lista_pacman.txt" | grep -v '^$' | wc -l)
    echo -e "${CYAN}Total de pacotes: $total${NC}"
    echo ""
    
    # Mostrar lista
    echo -e "${YELLOW}Pacotes a serem instalados:${NC}"
    grep -v '^#' "$DOTFILES_DIR/lista_pacman.txt" | grep -v '^$' | column
    echo ""
    
    read -p "Continuar com a instalação? [s/N]: " confirm
    if [[ ! $confirm =~ ^[Ss]$ ]]; then
        echo "Instalação cancelada."
        show_menu
        return
    fi
    
    # Instalar
    grep -v '^#' "$DOTFILES_DIR/lista_pacman.txt" | grep -v '^$' | sudo pacman -S --needed -
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Pacotes oficiais instalados com sucesso!${NC}"
    else
        echo -e "${RED}❌ Erro na instalação${NC}"
    fi
    
    read -p "Pressione ENTER para voltar ao menu..."
    show_menu
}

# Instalar pacotes AUR
install_aur() {
    echo -e "${BLUE}🅰️  Instalando pacotes AUR...${NC}"
    
    if [ ! -f "$DOTFILES_DIR/lista_aur.txt" ]; then
        echo -e "${RED}❌ lista_aur.txt não encontrada${NC}"
        return 1
    fi
    
    # Detectar AUR helper
    if command -v yay &> /dev/null; then
        AUR_HELPER="yay"
    elif command -v paru &> /dev/null; then
        AUR_HELPER="paru"
    else
        echo -e "${RED}❌ Nenhum AUR helper encontrado!${NC}"
        echo -e "${YELLOW}Instale yay ou paru primeiro.${NC}"
        return 1
    fi
    
    echo -e "${CYAN}Usando: $AUR_HELPER${NC}"
    
    # Contar pacotes
    total=$(grep -v '^#' "$DOTFILES_DIR/lista_aur.txt" | grep -v '^$' | wc -l)
    echo -e "${CYAN}Total de pacotes: $total${NC}"
    echo ""
    
    # Mostrar lista
    echo -e "${YELLOW}Pacotes AUR a serem instalados:${NC}"
    grep -v '^#' "$DOTFILES_DIR/lista_aur.txt" | grep -v '^$' | column
    echo ""
    
    read -p "Continuar com a instalação? [s/N]: " confirm
    if [[ ! $confirm =~ ^[Ss]$ ]]; then
        echo "Instalação cancelada."
        show_menu
        return
    fi
    
    # Instalar
    grep -v '^#' "$DOTFILES_DIR/lista_aur.txt" | grep -v '^$' | $AUR_HELPER -S --needed -
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Pacotes AUR instalados com sucesso!${NC}"
    else
        echo -e "${RED}❌ Erro na instalação${NC}"
    fi
    
    read -p "Pressione ENTER para voltar ao menu..."
    show_menu
}

# Instalar Flatpaks
install_flatpak() {
    echo -e "${BLUE}📦 Instalando Flatpaks...${NC}"
    
    if [ ! -f "$DOTFILES_DIR/lista_flatpak.txt" ]; then
        echo -e "${RED}❌ lista_flatpak.txt não encontrada${NC}"
        return 1
    fi
    
    # Contar pacotes
    total=$(grep -v '^#' "$DOTFILES_DIR/lista_flatpak.txt" | grep -v '^$' | wc -l)
    echo -e "${CYAN}Total de Flatpaks: $total${NC}"
    echo ""
    
    # Mostrar lista
    echo -e "${YELLOW}Flatpaks a serem instalados:${NC}"
    grep -v '^#' "$DOTFILES_DIR/lista_flatpak.txt" | grep -v '^$' | column
    echo ""
    
    read -p "Continuar com a instalação? [s/N]: " confirm
    if [[ ! $confirm =~ ^[Ss]$ ]]; then
        echo "Instalação cancelada."
        show_menu
        return
    fi
    
    # Instalar
    while IFS= read -r line; do
        # Ignorar comentários e linhas vazias
        [[ "$line" =~ ^#.*$ ]] && continue
        [[ -z "$line" ]] && continue
        
        echo -e "${CYAN}Instalando: $line${NC}"
        flatpak install -y "$line"
    done < "$DOTFILES_DIR/lista_flatpak.txt"
    
    echo -e "${GREEN}✅ Flatpaks instalados com sucesso!${NC}"
    read -p "Pressione ENTER para voltar ao menu..."
    show_menu
}

# Instalar AppImages
install_appimage() {
    echo -e "${BLUE}📦 Configurando AppImages...${NC}"
    
    if [ ! -f "$DOTFILES_DIR/lista_appimage.txt" ]; then
        echo -e "${RED}❌ lista_appimage.txt não encontrada${NC}"
        return 1
    fi
    
    APPDIR="$HOME/Applications"
    mkdir -p "$APPDIR"
    
    echo -e "${YELLOW}⚠️  AppImages precisam ser baixados manualmente.${NC}"
    echo -e "${CYAN}Diretório de AppImages: $APPDIR${NC}"
    echo ""
    echo -e "${YELLOW}AppImages listados:${NC}"
    grep -v '^#' "$DOTFILES_DIR/lista_appimage.txt" | grep -v '^$' | while read -r app; do
        echo "  • $app"
    done
    echo ""
    echo -e "${CYAN}Após baixar, torne executável com:${NC}"
    echo "  chmod +x ~/Applications/nome_do_appimage"
    echo ""
    echo -e "${CYAN}Dica: Use AppImageLauncher para integração automática${NC}"
    
    read -p "Pressione ENTER para voltar ao menu..."
    show_menu
}

# Instalar tudo
install_all() {
    echo -e "${CYAN}🚀 Instalando TODOS os pacotes...${NC}"
    echo ""
    
    install_pacman
    echo ""
    install_aur
    echo ""
    install_flatpak
    echo ""
    install_appimage
    
    echo ""
    echo -e "${GREEN}✅ Instalação completa finalizada!${NC}"
    read -p "Pressione ENTER para sair..."
}

# Verificar listas primeiro
if ! check_lists; then
    echo -e "${YELLOW}⚠️  Algumas listas não foram encontradas.${NC}"
    echo ""
fi

# Iniciar menu
show_menu