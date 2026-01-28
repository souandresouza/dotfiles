#!/bin/bash
set -euo pipefail

# ============================================
#  DESINSTALADOR DE DOTFILES
# ============================================

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$DOTFILES/uninstall.log"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/dotfiles-backup-$(date +%Y%m%d_%H%M%S)"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Funções de log
log() { echo -e "${BLUE}[*]${NC} $(date '+%H:%M:%S') $1" | tee -a "$LOG_FILE"; }
success() { echo -e "${GREEN}[✓]${NC} $1" | tee -a "$LOG_FILE"; }
warn() { echo -e "${YELLOW}[!]${NC} $1" | tee -a "$LOG_FILE"; }
error() { echo -e "${RED}[✗]${NC} $1" | tee -a "$LOG_FILE"; }
info() { echo -e "${CYAN}[i]${NC} $1" | tee -a "$LOG_FILE"; }

# ==================== FUNÇÕES ====================

show_banner() {
    echo -e "${MAGENTA}"
    echo "╔══════════════════════════════════════╗"
    echo "║     DOTFILES UNINSTALLER v1.0       ║"
    echo "║     Remoção Segura de Configs       ║"
    echo "╚══════════════════════════════════════╝"
    echo -e "${NC}"
    log "Iniciando desinstalação em: $(date)"
}

show_help() {
    echo "Uso: $0 [OPÇÃO]"
    echo
    echo "Opções:"
    echo "  uninstall     Remove links e restaura backup (padrão)"
    echo "  links-only    Remove apenas links simbólicos"
    echo "  restore       Restaura do backup específico"
    echo "  list-backups  Lista backups disponíveis"
    echo "  clean-all     Remove TODOS os backups"
    echo "  help          Mostra esta ajuda"
    echo
    echo "Exemplos:"
    echo "  $0                   # Desinstalação completa"
    echo "  $0 links-only        # Apenas remove links"
    echo "  $0 restore backup123 # Restaura backup específico"
}

list_backups() {
    local backups=$(ls -td ~/dotfiles-backup-* 2>/dev/null)
    
    if [ -z "$backups" ]; then
        echo "Nenhum backup encontrado."
        return 0
    fi
    
    echo "Backups disponíveis:"
    echo
    local count=1
    for backup in $backups; do
        local size=$(du -sh "$backup" 2>/dev/null | cut -f1)
        local date=$(basename "$backup" | sed 's/dotfiles-backup-//')
        echo "  $count) $date ($size)"
        count=$((count + 1))
    done
    echo
}

backup_before_uninstall() {
    log "Criando backup final antes da desinstalação..."
    mkdir -p "$BACKUP_DIR/.config"
    
    # Diretórios linkados pelo install.sh
    local linked_dirs=("dunst" "hypr" "kitty" "rofi" "swaync" "Thunar" "waybar" "zathura")
    
    for dir in "${linked_dirs[@]}"; do
        if [ -L "$CONFIG_DIR/$dir" ] || [ -d "$CONFIG_DIR/$dir" ]; then
            cp -r "$CONFIG_DIR/$dir" "$BACKUP_DIR/.config/" 2>/dev/null && \
            log "  📁 Backup: $dir"
        fi
    done
    
    # Backup de scripts
    if [ -d "$CONFIG_DIR/scripts" ]; then
        cp -r "$CONFIG_DIR/scripts" "$BACKUP_DIR/.config/" 2>/dev/null && \
        log "  🔧 Backup: scripts/"
    fi
    
    # Backup de dotfiles
    [ -f ~/.bashrc ] && cp ~/.bashrc "$BACKUP_DIR/" && log "  📄 Backup: .bashrc"
    
    success "Backup final criado: $BACKUP_DIR"
}

remove_links() {
    log "Removendo links simbólicos..."
    
    # Diretórios linkados
    local linked_dirs=("dunst" "hypr" "kitty" "rofi" "swaync" "Thunar" "waybar" "zathura")
    
    for dir in "${linked_dirs[@]}"; do
        if [ -L "$CONFIG_DIR/$dir" ]; then
            rm -f "$CONFIG_DIR/$dir" && \
            log "  🔗 Removido link: $dir"
        elif [ -d "$CONFIG_DIR/$dir" ] && [ -f "$CONFIG_DIR/$dir/.dotfiles-linked" ]; then
            rm -rf "$CONFIG_DIR/$dir" && \
            log "  📁 Removido diretório marcado: $dir"
        fi
    done
    
    # Remover scripts linkados
    if [ -d "$CONFIG_DIR/scripts" ]; then
        # Verificar se é diretório de links ou tem arquivos linkados
        local link_count=0
        for script in "$CONFIG_DIR/scripts"/* 2>/dev/null; do
            if [ -L "$script" ]; then
                rm -f "$script"
                link_count=$((link_count + 1))
            fi
        done
        
        # Remover diretório se estiver vazio
        if [ "$(ls -A "$CONFIG_DIR/scripts" 2>/dev/null | wc -l)" -eq 0 ]; then
            rmdir "$CONFIG_DIR/scripts" 2>/dev/null && \
            log "  📁 Removido diretório vazio: scripts/"
        fi
        
        [ $link_count -gt 0 ] && log "  🔧 Removidos $link_count scripts linkados"
    fi
    
    # Remover .bashrc linkado
    if [ -L ~/.bashrc ] && [ "$(readlink ~/.bashrc)" = "$DOTFILES/.bashrc" ]; then
        rm -f ~/.bashrc && \
        log "  📄 Removido link: .bashrc"
    fi
    
    success "Links removidos"
}

restore_backup() {
    local backup_path="$1"
    
    if [ ! -d "$backup_path" ]; then
        error "Backup não encontrado: $backup_path"
        return 1
    fi
    
    log "Restaurando backup: $backup_path"
    
    # Restaurar diretórios de configuração
    if [ -d "$backup_path/.config" ]; then
        for dir in "$backup_path/.config"/*; do
            if [ -d "$dir" ]; then
                local name=$(basename "$dir")
                cp -r "$dir" "$CONFIG_DIR/" && \
                log "  📁 Restaurado: $name"
            fi
        done
    fi
    
    # Restaurar .bashrc
    [ -f "$backup_path/.bashrc" ] && cp "$backup_path/.bashrc" ~/ && log "  📄 Restaurado: .bashrc"
    
    success "Backup restaurado: $(basename "$backup_path")"
}

restore_specific_backup() {
    local backup_name="$1"
    local backup_path="$HOME/$backup_name"
    
    if [ ! -d "$backup_path" ]; then
        # Tentar encontrar pelo padrão
        backup_path=$(ls -td ~/dotfiles-backup-*"$backup_name"* 2>/dev/null | head -1)
    fi
    
    if [ -z "$backup_path" ] || [ ! -d "$backup_path" ]; then
        error "Backup não encontrado: $backup_name"
        echo
        list_backups
        return 1
    fi
    
    restore_backup "$backup_path"
}

remove_all_backups() {
    local backups=$(ls -td ~/dotfiles-backup-* 2>/dev/null)
    
    if [ -z "$backups" ]; then
        success "Nenhum backup para remover"
        return 0
    fi
    
    echo "Backups encontrados:"
    for backup in $backups; do
        echo "  - $(basename "$backup") ($(du -sh "$backup" 2>/dev/null | cut -f1))"
    done
    
    echo
    read -p "⚠️  Remover TODOS os backups listados acima? [s/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        warn "Operação cancelada"
        return 0
    fi
    
    local removed_count=0
    for backup in $backups; do
        rm -rf "$backup" && removed_count=$((removed_count + 1))
    done
    
    success "Removidos $removed_count backups"
}

check_packages_to_remove() {
    log "Verificando pacotes instalados pelo dotfiles..."
    
    if [ ! -f "$DOTFILES/pacman.txt" ] && [ ! -f "$DOTFILES/aur.txt" ]; then
        warn "Arquivos de pacotes não encontrados"
        return 0
    fi
    
    local all_packages=()
    
    # Ler pacotes do pacman.txt
    if [ -f "$DOTFILES/pacman.txt" ]; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            line="${line%%#*}"
            line="${line## }"
            line="${line%% }"
            [[ -n "$line" ]] && all_packages+=("$line")
        done < "$DOTFILES/pacman.txt"
    fi
    
    # Ler pacotes do aur.txt
    if [ -f "$DOTFILES/aur.txt" ]; then
        while IFS= read -r line || [[ -n "$line" ]]; do
            line="${line%%#*}"
            line="${line## }"
            line="${line%% }"
            [[ -n "$line" ]] && all_packages+=("$line")
        done < "$DOTFILES/aur.txt"
    fi
    
    if [ ${#all_packages[@]} -eq 0 ]; then
        warn "Nenhum pacote listado para verificação"
        return 0
    fi
    
    log "Verificando ${#all_packages[@]} pacotes..."
    
    local installed_packages=()
    for pkg in "${all_packages[@]}"; do
        if pacman -Qi "$pkg" &>/dev/null; then
            installed_packages+=("$pkg")
        fi
    done
    
    if [ ${#installed_packages[@]} -gt 0 ]; then
        echo "⚠️  Pacotes instalados que podem ser removidos:"
        echo
        for pkg in "${installed_packages[@]}"; do
            echo "  - $pkg"
        done
        echo
        read -p "Deseja remover estes pacotes? [s/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Ss]$ ]]; then
            sudo pacman -Rns "${installed_packages[@]}" 2>&1 | tee -a "$LOG_FILE"
            success "Pacotes removidos"
        else
            log "Pacotes mantidos"
        fi
    else
        success "Nenhum pacote do dotfiles encontrado no sistema"
    fi
}

# ==================== FLUXO PRINCIPAL ====================

main() {
    local action="${1:-uninstall}"
    local backup_name="$2"
    
    case "$action" in
        uninstall|remove)
            show_banner
            backup_before_uninstall
            remove_links
            check_packages_to_remove
            
            echo -e "\n${GREEN}========================================${NC}"
            echo -e "${GREEN}    DESINSTALAÇÃO CONCLUÍDA!           ${NC}"
            echo -e "${GREEN}========================================${NC}"
            echo
            info "📂 Backup final criado em: $BACKUP_DIR"
            info "📋 Log completo em: $LOG_FILE"
            echo
            info "Seus dados originais foram preservados no backup."
            info "Para restaurar: ./uninstall.sh restore $BACKUP_DIR"
            echo
            ;;
            
        links-only)
            show_banner
            backup_before_uninstall
            remove_links
            
            success "Links removidos (pacotes mantidos)"
            info "Backup criado em: $BACKUP_DIR"
            ;;
            
        restore)
            if [ -z "$backup_name" ]; then
                error "Especifique o nome do backup para restaurar"
                echo
                list_backups
                echo "Uso: $0 restore <nome-do-backup>"
                exit 1
            fi
            
            show_banner
            restore_specific_backup "$backup_name"
            ;;
            
        list-backups)
            list_backups
            ;;
            
        clean-all)
            show_banner
            remove_all_backups
            ;;
            
        help|--help|-h)
            show_help
            ;;
            
        *)
            error "Opção inválida: $action"
            show_help
            exit 1
            ;;
    esac
}

# Executar
main "$@"