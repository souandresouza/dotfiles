#!/bin/bash

set -e

DOTFILES_DIR=~/dotfiles

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}📦 Instalando Flatpaks...${NC}"
echo ""

FLATPAK_LIST="$DOTFILES_DIR/lista_flatpak.txt"

if [ ! -f "$FLATPAK_LIST" ]; then
    echo -e "${RED}❌ lista_flatpak.txt não encontrada em $DOTFILES_DIR${NC}"
    exit 1
fi

if ! command -v flatpak &> /dev/null; then
    echo -e "${RED}❌ Flatpak não está instalado!${NC}"
    echo "Instale com: sudo pacman -S flatpak"
    exit 1
fi

# Contar e mostrar pacotes
PACKAGES=$(grep -v '^#' "$FLATPAK_LIST" | grep -v '^$')
total=$(echo "$PACKAGES" | wc -l)
echo -e "${YELLOW}$total Flatpaks a serem instalados:${NC}"
echo "$PACKAGES" | column
echo ""

read -p "Continuar? [s/N]: " confirm
if [[ ! $confirm =~ ^[Ss]$ ]]; then
    echo "Cancelado."
    exit 0
fi

# Instalar cada flatpak
while IFS= read -r package; do
    [[ -z "$package" ]] && continue
    echo -e "${CYAN}Instalando: $package${NC}"
    flatpak install -y "$package"
done <<< "$PACKAGES"

echo -e "${GREEN}✅ Instalação concluída!${NC}"
