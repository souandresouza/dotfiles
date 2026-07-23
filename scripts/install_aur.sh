#!/bin/bash

DOTFILES_DIR=~/dotfiles

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🅰️  Instalando pacotes AUR...${NC}"
echo ""

if [ ! -f "$DOTFILES_DIR/lista_aur.txt" ]; then
    echo -e "${RED}❌ lista_aur.txt não encontrada em $DOTFILES_DIR${NC}"
    exit 1
fi

# Detectar AUR helper
if command -v yay &> /dev/null; then
    AUR_HELPER="yay"
elif command -v paru &> /dev/null; then
    AUR_HELPER="paru"
else
    echo -e "${RED}❌ Nenhum AUR helper encontrado!${NC}"
    echo "Instale yay ou paru:"
    echo "  git clone https://aur.archlinux.org/yay.git"
    echo "  cd yay && makepkg -si"
    exit 1
fi

echo -e "${GREEN}Usando AUR helper: $AUR_HELPER${NC}"

# Contar e mostrar pacotes
total=$(grep -v '^#' "$DOTFILES_DIR/lista_aur.txt" | grep -v '^$' | wc -l)
echo -e "${YELLOW}$total pacotes AUR a serem instalados:${NC}"
grep -v '^#' "$DOTFILES_DIR/lista_aur.txt" | grep -v '^$' | column
echo ""

read -p "Continuar? [s/N]: " confirm
if [[ ! $confirm =~ ^[Ss]$ ]]; then
    echo "Cancelado."
    exit 0
fi

# Instalar
$AUR_HELPER -S --needed $(grep -v '^#' "$DOTFILES_DIR/lista_aur.txt" | grep -v '^$')

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Instalação concluída!${NC}"
else
    echo -e "${RED}❌ Erro na instalação${NC}"
    exit 1
fi