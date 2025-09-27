#!/bin/bash

set -e # Encerra o script imediatamente em caso de erro

DOTFILES_DIR=~/dotfiles
CONFIG_DIR=~/.config
BACKUP_DIR="$DOTFILES_DIR/backup_$(date +%Y%m%d_%H%M%S)"

declare -A DOTFILES
DOTFILES=(
    ["hypr"]="$CONFIG_DIR/hypr"
    ["waybar"]="$CONFIG_DIR/waybar"
    ["Thunar"]="$CONFIG_DIR/Thunar"
    ["alacritty"]="$CONFIG_DIR/alacritty"
    ["dunst"]="$CONFIG_DIR/dunst"
    ["zathura"]="$CONFIG_DIR/zathura"
)

declare -A HOME_FILES
HOME_FILES=(
    [".bashrc"]="$HOME/.bashrc"
)

echo "=========================================="
echo "🚀 Configuração do Dotfiles - Garuda Hyprland"
echo "=========================================="
echo "Diretório dos dotfiles: $DOTFILES_DIR"
echo "Backup será salvo em: $BACKUP_DIR"
echo "=========================================="

# Verificar se o diretório dos dotfiles existe
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "❌ ERRO: Diretório dos dotfiles não encontrado: $DOTFILES_DIR"
    echo "💡 Certifique-se de que o repositório foi clonado corretamente."
    exit 1
fi

# Função para fazer backup e criar link
link_file() {
    local source="$1"
    local target="$2"
    local item_name="$(basename "$source")"

    # Verifica se o arquivo/diretório de origem existe
    if [ ! -e "$source" ]; then
        echo "⚠️  AVISO: O caminho de origem '$source' não existe. Pulando."
        return 1
    fi

    # Criar diretório de backup se necessário
    mkdir -p "$BACKUP_DIR"

    # Se o target já existe, move para o backup
    if [ -e "$target" ] || [ -L "$target" ]; then
        echo "📦 Fazendo backup de '$target' para '$BACKUP_DIR'"
        # Criar estrutura de diretórios no backup
        local backup_path="$BACKUP_DIR/$(dirname "${target#$HOME/}")"
        mkdir -p "$backup_path"
        mv "$target" "$backup_path/" 2>/dev/null || {
            echo "❌ Erro ao fazer backup de $target"
            return 1
        }
    fi

    # Criar diretório pai do target se não existir
    mkdir -p "$(dirname "$target")"

    # Cria o link simbólico
    if ln -sfn "$source" "$target"; then
        echo "✅ Link criado: $source -> $target"
        return 0
    else
        echo "❌ Erro ao criar link para $target"
        return 1
    fi
}

# Verificar dependências antes de prosseguir
echo ""
echo "🔍 Verificando dependências essenciais..."
essential_deps=("hyprland" "waybar" "alacritty" "thunar")
missing_deps=()

for dep in "${essential_deps[@]}"; do
    if ! command -v "$dep" >/dev/null 2>&1 && ! pacman -Qs "$dep" >/dev/null 2>&1; then
        missing_deps+=("$dep")
    fi
done

if [ ${#missing_deps[@]} -gt 0 ]; then
    echo "❌ Dependências essenciais faltando: ${missing_deps[*]}"
    echo "💡 Execute './dependencies-check.sh' para ver todas as dependências"
    echo "💡 Instale com: sudo pacman -S ${missing_deps[*]}"
    read -p "⏳ Deseja continuar mesmo assim? (s/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        echo "❌ Instalação cancelada."
        exit 1
    fi
else
    echo "✅ Todas as dependências essenciais estão instaladas!"
fi

# Criar diretórios necessários
echo ""
echo "📁 Criando estrutura de diretórios..."
mkdir -p "$CONFIG_DIR"
mkdir -p "$BACKUP_DIR"

# Cria links para as pastas de configuração
echo ""
echo "🔗 Criando links para configurações..."
for folder in "${!DOTFILES[@]}"; do
    link_file "$DOTFILES_DIR/$folder" "${DOTFILES[$folder]}"
done

# Cria links para os arquivos no home
echo ""
echo "🏠 Criando links para arquivos home..."
for file in "${!HOME_FILES[@]}"; do
    link_file "$DOTFILES_DIR/$file" "${HOME_FILES[$file]}"
done

# Configurações pós-instalação
echo ""
echo "⚙️  Aplicando configurações finais..."

# Garantir que scripts sejam executáveis
find "$DOTFILES_DIR" -name "*.sh" -type f -exec chmod +x {} \; 2>/dev/null && \
echo "✅ Scripts tornados executáveis"

# Configurar xdg-user-dirs se necessário
if command -v xdg-user-dirs-update >/dev/null 2>&1; then
    xdg-user-dirs-update 2>/dev/null && \
    echo "✅ Diretórios de usuário configurados"
fi

# Recarrega o Hyprland apenas se estiver em execução
echo ""
echo "🔄 Verificando se o Hyprland está ativo..."
if command -v hyprctl >/dev/null 2>&1 && hyprctl monitors >/dev/null 2>&1; then
    echo "🎯 Hyprland detectado - recarregando configurações..."
    if hyprctl reload; then
        echo "✅ Hyprland recarregado com sucesso!"
    else
        echo "⚠️  Hyprland recarregado com avisos (pode ser normal)"
    fi
else
    echo "💤 Hyprland não está em execução. Recarregue manualmente após login."
fi

# Relatório final
echo ""
echo "=========================================="
echo "🎉 CONFIGURAÇÃO CONCLUÍDA COM SUCESSO!"
echo "=========================================="
echo "✅ Links simbólicos criados"
echo "✅ Backup salvo em: $BACKUP_DIR"
echo "✅ Dependências verificadas"
echo "✅ Configurações aplicadas"
echo ""
echo "💡 Próximos passos:"
echo "   1. Reinicie as aplicações ou faça logout/login"
echo "   2. Execute './dependencies-check.sh' para verificar tudo"
echo "   3. Personalize as configurações conforme necessário"
echo "=========================================="

# Verificar se há problemas comuns
echo ""
echo "🔍 Verificando problemas comuns..."
if [ ! -L "$CONFIG_DIR/hypr" ] || [ ! -e "$CONFIG_DIR/hypr" ]; then
    echo "⚠️  AVISO: Link do Hyprland pode estar quebrado"
fi

if [ ! -L "$CONFIG_DIR/waybar" ] || [ ! -e "$CONFIG_DIR/waybar" ]; then
    echo "⚠️  AVISO: Link do Waybar pode estar quebrado"
fi

echo "✅ Verificação de problemas concluída"