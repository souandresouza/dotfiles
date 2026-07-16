#!/bin/bash

# Script para habilitar serviços essenciais no Arch Linux/Hyprland
# Uso: ./enable_services.sh
# Deve ser executado após a instalação dos pacotes

# Configuração de erro
set -e
trap 'print_error "Erro na linha $LINENO. Comando: $BASH_COMMAND"' ERR

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Configurações
LOG_FILE="/tmp/enable_services_$(date +%Y%m%d_%H%M%S).log"
INTERACTIVE_MODE=false
SELECTED_SERVICES=""
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

# Funções auxiliares
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
    log_with_timestamp "[INFO] $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    log_with_timestamp "[ERROR] $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
    log_with_timestamp "[WARNING] $1"
}

print_header() {
    echo -e "\n${BLUE}════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}════════════════════════════════════════${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_step() {
    echo -e "\n${CYAN}▶${NC} $1"
}

print_service() {
    echo -e "${MAGENTA}🔧${NC} $1"
}

log_with_timestamp() {
    echo "[$(date '+%d-%m-%Y %H:%M:%S')] $1" >> "$LOG_FILE"
}

safe_enable_service() {
    local service="$1"
    local type="${2:-system}"
    
    if [ "$type" = "user" ]; then
        if timeout 10 systemctl --user enable --now "$service" 2>/dev/null; then
            return 0
        else
            print_warning "Falha ou timeout ao habilitar $service (usuário)"
            return 1
        fi
    else
        if timeout 10 sudo systemctl enable --now "$service" 2>/dev/null; then
            return 0
        else
            print_warning "Falha ou timeout ao habilitar $service (sistema)"
            return 1
        fi
    fi
}

# Verificações iniciais
check_sudo() {
    if ! sudo -v &>/dev/null; then
        print_error "Este script requer privilégios sudo"
        print_message "Execute com um usuário que tenha acesso sudo"
        exit 1
    fi
}

check_disk_space() {
    print_step "Verificando espaço em disco..."
    
    local available=$(df / | awk 'NR==2 {print $4}')
    local available_gb=$((available / 1024 / 1024))
    
    if [ "$available_gb" -lt 1 ]; then
        print_error "Espaço em disco insuficiente: ${available_gb}GB disponível"
        print_message "Mínimo recomendado: 1GB"
        exit 1
    else
        print_success "Espaço disponível: ${available_gb}GB"
    fi
}

check_dependencies() {
    print_step "Verificando serviços instalados..."
    local missing_services=()
    local required_services=("NetworkManager" "bluetooth" "pipewire" "wireplumber")
    
    for service in "${required_services[@]}"; do
        if ! systemctl list-unit-files 2>/dev/null | grep -q "^${service}\.service" && \
           ! systemctl --user list-unit-files 2>/dev/null | grep -q "^${service}\.service"; then
            missing_services+=("$service")
        fi
    done
    
    if [ ${#missing_services[@]} -gt 0 ]; then
        print_warning "Serviços não encontrados: ${missing_services[*]}"
        print_message "Execute ./install_packages.sh primeiro"
        read -p "Continuar mesmo assim? (s/N): " -n 1 -r
        echo
        [[ ! $REPLY =~ ^[Ss]$ ]] && exit 0
    fi
}

check_permissions() {
    print_step "Verificando permissões..."
    
    if [ "$EUID" -eq 0 ]; then
        print_warning "Script executado como root. Usando usuário real: $REAL_USER"
    else
        print_message "Script executado como usuário: $REAL_USER"
    fi
}

# Menu interativo
show_menu() {
    if [ "$INTERACTIVE_MODE" = true ]; then
        print_header "SERVIÇOS A CONFIGURAR"
        echo "Selecione os serviços (Enter = todos, número para toggle):"
        echo ""
        
        local options=(
            "1. Rede (NetworkManager, IWD)"
            "2. Bluetooth"
            "3. Áudio (PipeWire/PulseAudio)"
            "4. Energia (ZRAM, TLP)"
            "5. Serviços do sistema"
            "6. Serviços do usuário"
            "7. Android udev"
        )
        
        printf '%s\n' "${options[@]}"
        echo ""
        read -p "Opção (ex: 1 3 5 ou Enter para todos): " -r choice
        
        if [ -n "$choice" ]; then
            SELECTED_SERVICES=" $choice "
        fi
    fi
}

should_run() {
    local section="$1"
    if [ -z "$SELECTED_SERVICES" ]; then
        return 0
    else
        [[ "$SELECTED_SERVICES" == *" $section "* ]]
    fi
}

# Configurar rede
setup_network() {
    should_run "1" || return 0
    print_header "CONFIGURANDO SERVIÇOS DE REDE"
    
    print_step "Desabilitando serviços conflitantes..."
    sudo systemctl disable --now dhcpcd 2>/dev/null || true
    sudo systemctl disable --now systemd-networkd 2>/dev/null || true
    
    safe_enable_service "NetworkManager"
    
    if systemctl list-unit-files | grep -q "iwd.service"; then
        print_step "Configurando IWD como backend..."
        sudo mkdir -p /etc/NetworkManager/conf.d/
        sudo tee /etc/NetworkManager/conf.d/wifi-backend.conf << EOF
[device]
wifi.backend=iwd
EOF
        safe_enable_service "iwd"
    fi
    
    safe_enable_service "wpa_supplicant"
    safe_enable_service "NetworkManager-wait-online"
}

# Configurar Bluetooth
setup_bluetooth() {
    should_run "2" || return 0
    print_header "CONFIGURANDO BLUETOOTH"
    
    safe_enable_service "bluetooth"
    
    # Configuração básica do Bluetooth
    sudo tee /etc/bluetooth/main.conf << EOF
[General]
DiscoverableTimeout = 0
AutoEnable = true

[Policy]
AutoEnable = true
EOF
    
    print_success "Bluetooth configurado para iniciar automaticamente"
    print_message "Nenhum grupo adicional necessário para Bluetooth no Arch Linux"
}

# Configurar áudio (PipeWire/PulseAudio)
setup_audio() {
    should_run "3" || return 0
    print_header "CONFIGURANDO ÁUDIO"
    
    if command -v pipewire &> /dev/null; then
        print_message "PipeWire detectado"
        
        # Desabilitar serviços conflitantes
        systemctl --user disable --now pulseaudio.socket 2>/dev/null || true
        systemctl --user disable --now pulseaudio.service 2>/dev/null || true
        systemctl --user disable --now pipewire-media-session.service 2>/dev/null || true
        sudo systemctl --global disable pipewire.socket 2>/dev/null || true
        
        safe_enable_service "pipewire" "user"
        safe_enable_service "pipewire-pulse" "user"
        safe_enable_service "wireplumber" "user"
        
        # Configuração de alta qualidade
        mkdir -p "$REAL_HOME/.config/pipewire/pipewire.conf.d"
        cat > "$REAL_HOME/.config/pipewire/pipewire.conf.d/99-quality.conf" << EOF
context.properties = {
    default.clock.rate = 48000
    default.clock.quantum = 1024
    default.clock.min-quantum = 32
    default.clock.max-quantum = 2048
}
EOF
        print_success "PipeWire configurado para qualidade máxima"
        
    elif command -v pulseaudio &> /dev/null; then
        print_message "PulseAudio detectado"
        safe_enable_service "pulseaudio" "user"
        systemctl --user enable --now pulseaudio.socket 2>/dev/null || true
        print_success "PulseAudio configurado"
    else
        print_warning "Nenhum servidor de áudio encontrado"
    fi
}

# Configurar gerenciamento de energia
setup_power() {
    should_run "4" || return 0
    print_header "CONFIGURANDO GERENCIAMENTO DE ENERGIA"
    
    # ZRAM
    if [ ! -f /etc/systemd/zram-generator.conf ]; then
        print_step "Configurando ZRAM..."
        sudo tee /etc/systemd/zram-generator.conf << EOF
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
EOF
        print_success "ZRAM configurado (50% da RAM)"
    fi
    sudo systemctl enable --now systemd-zram-setup@zram0.service 2>/dev/null || true
    
    # TLP para laptops
    if ls /sys/class/power_supply/BAT* 1> /dev/null 2>&1; then
        print_message "Laptop detectado"
        
        if command -v tlp &> /dev/null; then
            print_step "Configurando TLP..."
            
            # TLP é um serviço oneshot - apenas habilitar, não usar --now
            if systemctl list-unit-files | grep -q "tlp.service"; then
                # Habilitar o serviço (sem --now, pois é oneshot)
                sudo systemctl enable tlp.service 2>/dev/null
                
                # Mask systemd-rfkill (recomendado pelo TLP)
                sudo systemctl mask systemd-rfkill.service systemd-rfkill.socket 2>/dev/null || true
                
                # Aplicar configurações otimizadas se ainda não existirem
                if ! grep -q "CPU_SCALING_GOVERNOR_ON_AC=performance" /etc/tlp.conf 2>/dev/null; then
                    print_message "Aplicando configurações otimizadas..."
                    sudo tee -a /etc/tlp.conf << 'EOF'
# Otimizações para laptop
CPU_SCALING_GOVERNOR_ON_AC=performance
CPU_SCALING_GOVERNOR_ON_BAT=powersave
ENERGY_PERF_POLICY_ON_AC=performance
ENERGY_PERF_POLICY_ON_BAT=power
PCIE_ASPM_ON_BAT=powersupersave
WIFI_PWR_ON_BAT=on
EOF
                fi
                
                # Iniciar TLP (comando correto)
                sudo tlp start 2>/dev/null || true
                
                print_success "TLP habilitado e configurado para laptop"
                print_message "Use 'sudo tlp-stat' para verificar as configurações"
            else
                print_warning "Serviço TLP não encontrado no systemd"
            fi
        else
            print_warning "TLP não instalado. Instale com: sudo pacman -S tlp tlp-rdw"
        fi
    fi
    
    # Auto-montagem USB (apenas se ambiente gráfico disponível)
    if command -v udiskie &> /dev/null; then
        print_step "Configurando auto-montagem USB..."
        
        if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
            mkdir -p "$REAL_HOME/.config/autostart"
            cat > "$REAL_HOME/.config/autostart/udiskie.desktop" << EOF
[Desktop Entry]
Type=Application
Name=udiskie
Exec=udiskie --tray
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF
            print_success "udiskie configurado para auto-montagem (com tray)"
        else
            print_message "Ambiente gráfico não detectado, udiskie configurado sem --tray"
            mkdir -p "$REAL_HOME/.config/autostart"
            cat > "$REAL_HOME/.config/autostart/udiskie.desktop" << EOF
[Desktop Entry]
Type=Application
Name=udiskie
Exec=udiskie
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF
        fi
    fi
}

# Configurar serviços do sistema
setup_system_services() {
    should_run "5" || return 0
    print_header "CONFIGURANDO SERVIÇOS DO SISTEMA"
    
    # plocate
    if command -v updatedb &> /dev/null; then
        sudo systemctl enable --now plocate-updatedb.timer 2>/dev/null || true
        print_success "plocate atualização diária agendada"
    fi
    
    # smartmontools
    if command -v smartd &> /dev/null; then
        safe_enable_service "smartd"
    fi
    
    # reflector
    if command -v reflector &> /dev/null; then
        sudo systemctl enable --now reflector.timer 2>/dev/null || true
        print_success "Reflector configurado para atualizar mirrors"
    fi
    
    # SDDM (sem autologin)
    if command -v sddm &> /dev/null; then
        print_step "Configurando SDDM..."
        
        # Verificar se existe sessão do Hyprland
        if ! ls /usr/share/wayland-sessions/hyprland*.desktop 1>/dev/null 2>&1; then
            print_warning "Nenhuma sessão Hyprland encontrada para SDDM"
            print_message "Instale o Hyprland primeiro: ./install_packages.sh"
            return
        fi
        
        sudo mkdir -p /etc/sddm.conf.d/
        sudo tee /etc/sddm.conf.d/sddm.conf << EOF
[General]
Numlock=on
HaltCommand=/usr/bin/systemctl poweroff
RebootCommand=/usr/bin/systemctl reboot

[Theme]
Current=breeze
CursorTheme=Adwaita
EOF
        
        safe_enable_service "sddm"
        print_success "SDDM habilitado (login manual)"
    fi
}

# Configurar udev para Android
setup_android_udev() {
    should_run "7" || return 0
    print_header "CONFIGURANDO ANDROID UDEV"
    
    if [ -f /usr/lib/udev/rules.d/51-android.rules ]; then
        sudo udevadm control --reload-rules
        sudo udevadm trigger
        print_success "Regras Android udev carregadas"
        
        if getent group adbusers &> /dev/null; then
            sudo usermod -aG adbusers "$REAL_USER"
            print_success "Usuário $REAL_USER adicionado ao grupo adbusers"
        fi
    else
        print_warning "Regras Android udev não encontradas"
    fi
}

# Configurar XDG User Directories
setup_xdg_dirs() {
    print_header "CONFIGURANDO DIRETÓRIOS DO USUÁRIO"
    
    if command -v xdg-user-dirs-update &> /dev/null; then
        su - "$REAL_USER" -c "xdg-user-dirs-update" 2>/dev/null || xdg-user-dirs-update
        print_success "Diretórios XDG configurados"
        
        if locale -a | grep -qi "pt_br"; then
            su - "$REAL_USER" -c "xdg-user-dirs-gtk-update" 2>/dev/null || xdg-user-dirs-gtk-update
            print_success "Configuração de localidade aplicada"
        fi
    fi
}

# Mostrar status dos serviços
show_services_status() {
    print_header "STATUS DOS SERVIÇOS"
    
    echo -e "${CYAN}Serviços do sistema:${NC}"
    local system_services=("NetworkManager" "bluetooth" "sddm" "iwd" "smartd" "tlp")
    for service in "${system_services[@]}"; do
        if systemctl is-active --quiet "$service" 2>/dev/null; then
            echo -e "  ${GREEN}●${NC} $service: ${GREEN}ativo${NC}"
        elif systemctl is-enabled --quiet "$service" 2>/dev/null; then
            echo -e "  ${YELLOW}○${NC} $service: ${YELLOW}habilitado mas inativo${NC}"
        else
            echo -e "  ${RED}✗${NC} $service: ${RED}não encontrado/desabilitado${NC}"
        fi
    done
    
    echo -e "\n${CYAN}Serviços do usuário:${NC}"
    local user_services=("pipewire" "pipewire-pulse" "wireplumber" "pulseaudio")
    for service in "${user_services[@]}"; do
        if systemctl --user is-active --quiet "$service" 2>/dev/null; then
            echo -e "  ${GREEN}●${NC} $service: ${GREEN}ativo${NC}"
        elif systemctl --user is-enabled --quiet "$service" 2>/dev/null; then
            echo -e "  ${YELLOW}○${NC} $service: ${YELLOW}habilitado mas inativo${NC}"
        fi
    done
}

# Mostrar recomendações finais
show_reboot_warning() {
    print_header "PRÓXIMOS PASSOS"
    
    echo -e "${YELLOW}⚠️  IMPORTANTE:${NC}"
    echo -e "  Para que todas as configurações tenham efeito, é recomendado:"
    echo -e "\n  1. ${GREEN}Reiniciar o sistema${NC}"
    echo -e "  2. Fazer login manualmente"
    echo -e "  3. Executar ${CYAN}./install.sh${NC} para configurar os dotfiles"
    
    # Verificar grupos do usuário
    local groups_to_check=("adbusers" "lp" "network" "power" "video" "audio" "wheel" "storage")
    echo -e "\n${CYAN}Grupos do usuário $REAL_USER:${NC}"
    for group in "${groups_to_check[@]}"; do
        if getent group "$group" > /dev/null 2>&1 && groups "$REAL_USER" 2>/dev/null | grep -q "\b$group\b"; then
            echo -e "  ${GREEN}✓${NC} $group"
        fi
    done
}

# Função principal
main() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════╗"
    echo "║     SERVICE ENABLER FOR ARCH/HYPRLAND    ║"
    echo "║         POST-INSTALLATION SCRIPT         ║"
    echo "╚══════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # Inicializar log
    log_with_timestamp "=== Iniciando configuração de serviços ==="
    log_with_timestamp "Usuário: $REAL_USER"
    log_with_timestamp "Sistema: $(uname -a)"
    
    # Verificações iniciais
    check_sudo
    check_disk_space
    check_dependencies
    check_permissions
    
    # Menu interativo (se ativado)
    show_menu
    
    # Configurar todos os serviços
    setup_network
    setup_bluetooth
    setup_audio
    setup_power
    setup_system_services
    setup_android_udev
    setup_xdg_dirs
    
    # Mostrar status
    show_services_status
    show_reboot_warning
    
    print_header "CONFIGURAÇÃO CONCLUÍDA"
    print_success "Todos os serviços foram configurados!"
    
    echo -e "\n${BLUE}📝 Log completo:${NC} $LOG_FILE\n"
    log_with_timestamp "=== Configuração finalizada com sucesso ==="
}

# Processar argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--interactive)
            INTERACTIVE_MODE=true
            shift
            ;;
        -h|--help)
            echo "Uso: $0 [OPÇÕES]"
            echo "Opções:"
            echo "  -i, --interactive  Modo interativo (selecionar serviços)"
            echo "  -h, --help         Mostrar esta ajuda"
            exit 0
            ;;
        *)
            print_error "Opção desconhecida: $1"
            exit 1
            ;;
    esac
done

# Executar função principal
main "$@"
