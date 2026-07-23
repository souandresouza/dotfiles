#!/bin/bash

DOTFILES_DIR=~/dotfiles

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}📦 Instalando pacotes oficiais (pacman)...${NC}"
echo ""

if [ ! -f "$DOTFILES_DIR/lista_pacman.txt" ]; then
    echo -e "${RED}❌ lista_pacman.txt não encontrada em $DOTFILES_DIR${NC}"
    exit 1
fi

# Contar e mostrar pacotes
total=$(grep -v '^#' "$DOTFILES_DIR/lista_pacman.txt" | grep -v '^$' | wc -l)
echo -e "${YELLOW}$total pacotes a serem instalados:${NC}"
grep -v '^#' "$DOTFILES_DIR/lista_pacman.txt" | grep -v '^$' | column
echo ""

read -p "Continuar? [s/N]: " confirm
if [[ ! $confirm =~ ^[Ss]$ ]]; then
    echo "Cancelado."
    exit 0
fi

# Instalar
sudo pacman -S --needed $(grep -v '^#' "$DOTFILES_DIR/lista_pacman.txt" | grep -v '^$')

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Instalação concluída!${NC}"
else
    echo -e "${RED}❌ Erro na instalação${NC}"
    exit 1
fi