#!/bin/bash

set -e  # Sai se algum comando falhar

DOTFILES_DIR=~/dotfiles

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}📦 Instalando pacotes oficiais (pacman)...${NC}"
echo ""

PACMAN_LIST="$DOTFILES_DIR/lista_pacman.txt"

if [ ! -f "$PACMAN_LIST" ]; then
    echo -e "${RED}❌ lista_pacman.txt não encontrada em $DOTFILES_DIR${NC}"
    exit 1
fi

# Filtra comentários e linhas vazias
PACKAGES=$(grep -v '^#' "$PACMAN_LIST" | grep -v '^$')

# Contar e mostrar pacotes
total=$(echo "$PACKAGES" | wc -l)
echo -e "${YELLOW}$total pacotes a serem instalados:${NC}"
echo "$PACKAGES" | column
echo ""

read -p "Continuar? [s/N]: " confirm
if [[ ! $confirm =~ ^[Ss]$ ]]; then
    echo "Cancelado."
    exit 0
fi

# Instalar
sudo pacman -S --needed $PACKAGES

echo -e "${GREEN}✅ Instalação concluída!${NC}"
