#!/bin/bash

DOTFILES_DIR=~/dotfiles

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}📦 Instalando Flatpaks...${NC}"
echo ""

if [ ! -f "$DOTFILES_DIR/lista_flatpak.txt" ]; then
    echo -e "${RED}❌ lista_flatpak.txt não encontrada em $DOTFILES_DIR${NC}"
    exit 1
fi

if ! command -v flatpak &> /dev/null; then
    echo -e "${RED}❌ Flatpak não está instalado!${NC}"
    echo "Instale com: sudo pacman -S flatpak"
    exit 1
fi

# Contar e mostrar pacotes
total=$(grep -v '^#' "$DOTFILES_DIR/lista_flatpak.txt" | grep -v '^$' | wc -l)
echo -e "${YELLOW}$total Flatpaks a serem instalados:${NC}"
grep -v '^#' "$DOTFILES_DIR/lista_flatpak.txt" | grep -v '^$' | column
echo ""

read -p "Continuar? [s/N]: " confirm
if [[ ! $confirm =~ ^[Ss]$ ]]; then
    echo "Cancelado."
    exit 0
fi

# Instalar cada flatpak
while IFS= read -r line; do
    [[ "$line" =~ ^#.*$ ]] && continue
    [[ -z "$line" ]] && continue
    
    echo -e "${CYAN}Instalando: $line${NC}"
    flatpak install -y "$line"
done < "$DOTFILES_DIR/lista_flatpak.txt"

echo -e "${GREEN}✅ Instalação concluída!${NC}"