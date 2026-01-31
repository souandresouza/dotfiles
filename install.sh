#!/bin/bash
set -euo pipefail

# ============================================
#  INSTALADOR DE DOTFILES - ESTRUTURA ATUAL
# ============================================

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$DOTFILES/install.log"
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
    echo "║      DOTFILES INSTALLER v2.0        ║"
    echo "║   Estrutura: dunst/hypr/kitty/rofi   ║"
    echo "╚══════════════════════════════════════╝"
    echo -e "${NC}"
    log "Iniciando instalação em: $(date)"
}

show_help() {
    echo "Uso: $0 [OPÇÃO]"
    echo
    echo "Opções:"
    echo "  install     Instalação completa (padrão)"
    echo "  update      Atualiza sistema e pacotes"
    echo "  link        Apenas linka configurações"
    echo "  backup      Backup das configs atuais"
    echo "  restore     Restaura do backup mais recente"
    echo "  clean       Limpa pacotes órfãos"
    echo "  list        Lista configs disponíveis"
    echo "  help        Mostra esta ajuda"
    echo
    echo "Exemplos:"
    echo "  $0               # Instala tudo"
    echo "  $0 update        # Atualiza tudo"
    echo "  $0 link          # Linka dotfiles"
}

list_configs() {
    echo "Configurações disponíveis em $DOTFILES:"
    echo
    for item in "$DOTFILES"/*; do
        if [ -d "$item" ]; then
            local name="$(basename "$item")"
            case "$name" in
                dunst)    echo "  📢 $name   - Notificações" ;;
                hypr)     echo "  🪟 $name    - Compositor Hyprland" ;;
                kitty)    echo "  🐱 $name   - Terminal" ;;
                rofi)     echo "  🚀 $name     - Launcher de aplicações" ;;
                swaync)   echo "  🔔 $name  - Centro de notificações" ;;
                Thunar)   echo "  📁 $name  - Gerenciador de arquivos" ;;
                waybar)   echo "  📊 $name   - Barra de status" ;;
                zathura)  echo "  📚 $name  - Visualizador PDF" ;;
                scripts)  echo "  🔧 $name  - Scripts utilitários" ;;
                *)        echo "  📂 $name" ;;
            esac
        fi
    done
    echo
    echo "Arquivos de configuração:"
    [ -f "$DOTFILES/.bashrc" ] && echo "  📄 .bashrc"
    [ -f "$DOTFILES/black.qbtheme" ] && echo "  🎨 black.qbtheme (qBittorrent)"
    echo
}

backup_current() {
    log "Criando backup em: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR/.config"
    
    # Diretórios que serão substituídos
    local config_dirs=("dunst" "hypr" "kitty" "rofi" "swaync" "Thunar" "waybar" "zathura")
    
    for dir in "${config_dirs[@]}"; do
        if [ -d "$CONFIG_DIR/$dir" ]; then
            cp -r "$CONFIG_DIR/$dir" "$BACKUP_DIR/.config/" 2>/dev/null && \
            log "  📁 Backup: $dir"
        fi
    done
    
    # Backup de dotfiles
    [ -f ~/.bashrc ] && cp ~/.bashrc "$BACKUP_DIR/" && log "  📄 Backup: .bashrc"
    [ -f ~/.config/qBittorrent/qBittorrent.conf ] && \
        mkdir -p "$BACKUP_DIR/.config/qBittorrent" && \
        cp ~/.config/qBittorrent/qBittorrent.conf "$BACKUP_DIR/.config/qBittorrent/" && \
        log "  📄 Backup: qBittorrent config"
    
    success "Backup concluído: $BACKUP_DIR ($(du -sh "$BACKUP_DIR" | cut -f1))"
}

restore_backup() {
    local latest_backup=$(ls -td ~/dotfiles-backup-* 2>/dev/null | head -1)
    
    if [ -z "$latest_backup" ]; then
        error "Nenhum backup encontrado"
        return 1
    fi
    
    log "Restaurando backup: $latest_backup"
    
    if [ -d "$latest_backup/.config" ]; then
        for dir in "$latest_backup/.config"/*; do
            local name=$(basename "$dir")
            cp -r "$dir" "$CONFIG_DIR/" && log "  📁 Restaurado: $name"
        done
    fi
    
    [ -f "$latest_backup/.bashrc" ] && cp "$latest_backup/.bashrc" ~/ && log "  📄 Restaurado: .bashrc"
    
    success "Backup restaurado: $latest_backup"
}

update_system() {
    log "Atualizando sistema Arch Linux..."
    sudo pacman -Syu --noconfirm 2>&1 | tee -a "$LOG_FILE"
    
    if command -v yay >/dev/null 2>&1; then
        log "Atualizando pacotes AUR..."
        yay -Syu --noconfirm --devel 2>&1 | tee -a "$LOG_FILE"
    else
        warn "yay não encontrado. Pacotes AUR não serão atualizados."
    fi
    
    success "Sistema atualizado"
}

install_yay() {
    if command -v yay >/dev/null 2>&1; then
        log "yay já está instalado"
        return 0
    fi
    
    log "Instalando yay (AUR helper)..."
    sudo pacman -S --needed --noconfirm git base-devel 2>&1 | tee -a "$LOG_FILE"
    
    local tmp_dir=$(mktemp -d)
    trap "rm -rf '$tmp_dir'" EXIT
    
    if git clone https://aur.archlinux.org/yay.git "$tmp_dir" 2>&1 | tee -a "$LOG_FILE"; then
        (cd "$tmp_dir" && makepkg -si --noconfirm) 2>&1 | tee -a "$LOG_FILE"
        success "yay instalado com sucesso"
    else
        error "Falha ao instalar yay"
        return 1
    fi
}

install_packages() {
    local file="$1"
    local installer="$2"
    local name="$3"
    
    [ -f "$file" ] || {
        warn "Arquivo não encontrado: $file"
        return 0
    }
    
    log "Instalando $name..."
    
    # Processar lista de pacotes
    local packages=()
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Remover comentários e espaços
        line="${line%%#*}"
        line="${line## }"
        line="${line%% }"
        [[ -n "$line" ]] && packages+=("$line")
    done < "$file"
    
    if [ ${#packages[@]} -eq 0 ]; then
        warn "Nenhum pacote em $file"
        return 0
    fi
    
    log "Encontrados ${#packages[@]} pacotes"
    
    # Instalar em lotes menores
    for ((i=0; i<${#packages[@]}; i+=15)); do
        local batch=("${packages[@]:i:15}")
        log "Lote $((i/15+1)): ${batch[*]}"
        
        if ! $installer "${batch[@]}" 2>&1 | tee -a "$LOG_FILE"; then
            warn "Alguns pacotes podem ter falhado no lote $((i/15+1))"
        fi
        sleep 0.5
    done
    
    success "$name instalados"
}

link_configurations() {
    log "Linkando configurações para $CONFIG_DIR..."
    mkdir -p "$CONFIG_DIR"
    
    # Linkar cada diretório de configuração
    local config_dirs=("dunst" "hypr" "kitty" "rofi" "swaync" "Thunar" "waybar" "zathura")
    
    for dir in "${config_dirs[@]}"; do
        if [ -d "$DOTFILES/$dir" ]; then
            # Remover se existir (link quebrado ou diretório)
            [ -L "$CONFIG_DIR/$dir" ] && rm -f "$CONFIG_DIR/$dir"
            [ -d "$CONFIG_DIR/$dir" ] && mv "$CONFIG_DIR/$dir" "$CONFIG_DIR/${dir}.backup"
            
            ln -sfn "$DOTFILES/$dir" "$CONFIG_DIR/$dir" && \
            log "  🔗 $dir"
        fi
    done
    
    # Linkar scripts para ~/.config/scripts/ (CORREÇÃO AQUI!)
    if [ -d "$DOTFILES/scripts" ]; then
        local scripts_dest="$CONFIG_DIR/scripts"  # MUDOU AQUI
        mkdir -p "$scripts_dest"
        
        for script in "$DOTFILES/scripts"/*; do
            if [ -f "$script" ]; then
                local script_name=$(basename "$script")
                
                # Dar permissão de execução se for .sh ou .py
                if [[ "$script" == *.sh || "$script" == *.py ]]; then
                    chmod +x "$script"
                fi
                
                ln -sf "$script" "$scripts_dest/$script_name" && \
                log "  🔧 script: $script_name → ~/.config/scripts/"
            fi
        done
    fi
    
    # ========== CORREÇÃO DO HELLWAL (ADICIONADO AQUI) ==========
    # Corrigir permissões do Hellwal
    log "Configurando permissões do Hellwal..."
    local hellwal_cache="$HOME/.cache/hellwal/cache"
    
    # Criar diretório de cache se não existir
    mkdir -p "$hellwal_cache"
    
    # Ajustar permissões (apenas o dono tem acesso)
    chmod 700 "$HOME/.cache/hellwal/" 2>/dev/null || true
    
    # Garantir que o diretório pertence ao usuário atual
    if [ -d "$HOME/.cache/hellwal" ]; then
        chown -R "$USER:$USER" "$HOME/.cache/hellwal/" 2>/dev/null || true
        success "Permissões do Hellwal configuradas"
    else
        warn "Diretório .cache/hellwal não encontrado"
    fi
    # ========== FIM DA CORREÇÃO ==========
    
    # Linkar arquivos individuais
    [ -f "$DOTFILES/.bashrc" ] && {
        ln -sf "$DOTFILES/.bashrc" "$HOME/.bashrc"
        log "  📄 .bashrc"
    }
    
    # Aplicar tema do qBittorrent se existir
    [ -f "$DOTFILES/black.qbtheme" ] && {
        mkdir -p "$CONFIG_DIR/qBittorrent"
        cp "$DOTFILES/black.qbtheme" "$CONFIG_DIR/qBittorrent/" && \
        log "  🎨 Tema qBittorrent aplicado"
    }
    
    success "Configurações linkadas"
}

clean_orphans() {
    log "Limpando pacotes órfãos..."
    local orphans=$(pacman -Qtdq 2>/dev/null)
    
    if [ -n "$orphans" ]; then
        echo "Pacotes órfãos encontrados:"
        echo "$orphans"
        echo
        read -p "Remover? [s/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Ss]$ ]]; then
            sudo pacman -Rns $orphans 2>&1 | tee -a "$LOG_FILE"
            success "Pacotes órfãos removidos"
        fi
    else
        success "Nenhum pacote órfão encontrado"
    fi
}

verify_installation() {
    log "Verificando instalação..."
    
    local essential=("hypr" "waybar" "kitty" "rofi")
    local missing=()
    
    for pkg in "${essential[@]}"; do
        if pacman -Qi "$pkg" &>/dev/null || pacman -Qg "$pkg" &>/dev/null; then
            success "  ✓ $pkg"
        else
            error "  ✗ $pkg"
            missing+=("$pkg")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        warn "Pacotes essenciais faltando: ${missing[*]}"
        return 1
    fi
    
    success "Verificação concluída"
    return 0
}

# ==================== FLUXO PRINCIPAL ====================

main() {
    local action="${1:-install}"
    
    case "$action" in
        install)
            show_banner
            backup_current
            update_system
            install_yay
            install_packages "$DOTFILES/pacman.txt" "sudo pacman -S --needed --noconfirm" "Pacotes oficiais"
            install_packages "$DOTFILES/aur.txt" "yay -S --needed --noconfirm" "Pacotes AUR"
            link_configurations
            clean_orphans
            verify_installation
            
            echo -e "\n${GREEN}========================================${NC}"
            echo -e "${GREEN}        INSTALAÇÃO CONCLUÍDA!          ${NC}"
            echo -e "${GREEN}========================================${NC}"
            echo
            info "📂 Backup criado em: $BACKUP_DIR"
            info "📋 Log completo em: $LOG_FILE"
            echo
            info "Próximos passos:"
            echo "  1. Reinicie a sessão: logout/login"
            echo "  2. Ou inicie o Hyprland: Hyprland"
            echo "  3. Configure seus wallpapers"
            echo "  4. Personalize as configurações"
            echo
            ;;
            
        update)
            show_banner
            backup_current
            update_system
            link_configurations
            success "Sistema atualizado"
            ;;
            
        link)
            show_banner
            link_configurations
            success "Configurações linkadas"
            ;;
            
        backup)
            show_banner
            backup_current
            ;;
            
        restore)
            restore_backup
            ;;
            
        clean)
            clean_orphans
            ;;
            
        list)
            list_configs
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
