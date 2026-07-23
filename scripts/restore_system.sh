#!/bin/bash

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🚀 Restauração completa do sistema${NC}"
echo -e "${CYAN}===================================${NC}"
echo ""
echo -e "${YELLOW}Este script vai:${NC}"
echo "  1. Configurar dotfiles (symlinks)"
echo "  2. Instalar pacotes oficiais"
echo "  3. Instalar pacotes AUR"
echo "  4. Instalar Flatpaks"
echo "  5. Mostrar AppImages necessárias"
echo ""

read -p "Continuar com a restauração completa? [s/N]: " confirm
if [[ ! $confirm =~ ^[Ss]$ ]]; then
    echo "Cancelado."
    exit 0
fi

# Array de scripts para executar na ordem correta
declare -A scripts
scripts=(
    ["1️⃣  Dotfiles"]="install_dotfiles.sh"
    ["2️⃣  Pacotes oficiais"]="install_pacman.sh"
    ["3️⃣  Pacotes AUR"]="install_aur.sh"
    ["4️⃣  Flatpaks"]="install_flatpak.sh"
)

for step in "${!scripts[@]}"; do
    script="${scripts[$step]}"
    
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}Executando $step${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    if [ -f "$SCRIPTS_DIR/$script" ]; then
        bash "$SCRIPTS_DIR/$script"
        if [ $? -ne 0 ]; then
            echo -e "${RED}❌ Erro em $step${NC}"
            read -p "Continuar mesmo assim? [s/N]: " continue_anyway
            if [[ ! $continue_anyway =~ ^[Ss]$ ]]; then
                echo -e "${YELLOW}Restauração interrompida.${NC}"
                exit 1
            fi
        fi
    else
        echo -e "${RED}❌ Script não encontrado: $script${NC}"
        echo -e "${YELLOW}Procurando em: $SCRIPTS_DIR/$script${NC}"
        read -p "Continuar para o próximo? [s/N]: " continue_anyway
        if [[ ! $continue_anyway =~ ^[Ss]$ ]]; then
            exit 1
        fi
    fi
done

# Verificar AppImages
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}5️⃣  AppImages${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ -f "$HOME/dotfiles/lista_appimage.txt" ]; then
    echo -e "${YELLOW}AppImages que precisam ser baixadas manualmente:${NC}"
    grep -v '^#' "$HOME/dotfiles/lista_appimage.txt" | grep -v '^$' | while read -r app; do
        echo "  • $app"
    done
    echo ""
    echo -e "${CYAN}Coloque as AppImages em ~/Applications/${NC}"
    echo -e "${CYAN}E torne executáveis com: chmod +x ~/Applications/*${NC}"
else
    echo -e "${YELLOW}Nenhuma lista de AppImages encontrada.${NC}"
fi

echo ""
echo -e "${GREEN}✅ Restauração do sistema concluída!${NC}"
echo ""
echo -e "${YELLOW}📋 Próximos passos recomendados:${NC}"
echo "  • Verificar se todos os serviços estão rodando"
echo "  • Configurar temas e ícones (se necessário)"
echo "  • Reiniciar a sessão para aplicar todas as mudanças"
echo "  • Verificar AppImages em ~/Applications/"
echo ""
echo -e "${CYAN}💡 Dica: Execute 'hyprctl reload' se estiver no Hyprland${NC}"