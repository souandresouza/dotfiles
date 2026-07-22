#!/bin/bash

# Script para habilitar serviços essenciais no Arch Linux
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

# ============================================
# FUNÇÕES DE DETECÇÃO
# ============================================

# Detectar Desktop Environment (DE)
detect_de() {
    local de=""
    
    # Verificar variáveis de ambiente
    if [ -n "$XDG_CURRENT_DESKTOP" ]; then
        de="$XDG_CURRENT_DESKTOP"
    fi
    
    # Verificar processos específicos de DEs
    if [ -z "$de" ] || [ "$de" = "Unknown" ]; then
        if pgrep -x "plasmashell" > /dev/null; then
            de="KDE"
        elif pgrep -x "gnome-shell" > /dev/null; then
            de="GNOME"
        elif pgrep -x "xfdesktop" > /dev/null || pgrep -x "xfce4-session" > /dev/null; then
            de="XFCE"
        elif pgrep -x "mate-panel" > /dev/null; then
            de="MATE"
        elif pgrep -x "lxqt-session" > /dev/null; then
            de="LXQt"
        elif pgrep -x "lxpanel" > /dev/null; then
            de="LXDE"
        elif pgrep -x "budgie-wm" > /dev/null; then
            de="Budgie"
        elif pgrep -x "cinnamon" > /dev/null; then
            de="Cinnamon"
        elif pgrep -x "deepin-wm" > /dev/null; then
            de="Deepin"
        fi
    fi
    
    echo "$de"
}

# Detecção do WM/Compositor
detect_wm() {
    local wm=""
    
    # Verificar variáveis de ambiente (mais confiável quando em sessão gráfica)
    if [ -n "$XDG_CURRENT_DESKTOP" ]; then
        wm="$XDG_CURRENT_DESKTOP"
    elif [ -n "$DESKTOP_SESSION" ]; then
        wm="$DESKTOP_SESSION"
    elif [ -n "$GDMSESSION" ]; then
        wm="$GDMSESSION"
    fi
    
    # Verificar processos em execução
    if [ -z "$wm" ] || [ "$wm" = "Unknown" ]; then
        if pgrep -x "hyprland" > /dev/null; then
            wm="Hyprland"
        elif pgrep -x "sway" > /dev/null; then
            wm="Sway"
        elif pgrep -x "niri" > /dev/null; then
            wm="Niri"
        elif pgrep -x "river" > /dev/null; then
            wm="River"
        elif pgrep -x "labwc" > /dev/null; then
            wm="LabWC"
        elif pgrep -x "wayfire" > /dev/null; then
            wm="Wayfire"
        elif pgrep -x "qtile" > /dev/null; then
            wm="Qtile"
        elif pgrep -x "i3" > /dev/null; then
            wm="i3"
        elif pgrep -x "bspwm" > /dev/null; then
            wm="bspwm"
        elif pgrep -x "dwm" > /dev/null; then
            wm="dwm"
        elif pgrep -x "awesome" > /dev/null; then
            wm="Awesome"
        elif pgrep -x "gnome-shell" > /dev/null; then
            wm="GNOME"
        elif pgrep -x "kwin_wayland" > /dev/null || pgrep -x "kwin_x11" > /dev/null; then
            wm="KDE"
        elif pgrep -x "openbox" > /dev/null; then
            wm="Openbox"
        elif pgrep -x "fluxbox" > /dev/null; then
            wm="Fluxbox"
        elif pgrep -x "icewm" > /dev/null; then
            wm="IceWM"
        elif pgrep -x "herbstluftwm" > /dev/null; then
            wm="Herbstluftwm"
        elif pgrep -x "xmonad" > /dev/null; then
            wm="XMonad"
        elif pgrep -x "spectrwm" > /dev/null; then
            wm="Spectrwm"
        elif pgrep -x "cage" > /dev/null; then
            wm="Cage"
        elif pgrep -x "hikari" > /dev/null; then
            wm="Hikari"
        elif pgrep -x "wayv" > /dev/null; then
            wm="WayV"
        fi
    fi
    
    # Verificar arquivos de sessão instalados
    if [ -z "$wm" ] || [ "$wm" = "Unknown" ]; then
        local sessions_dir="/usr/share/wayland-sessions"
        local x11_sessions_dir="/usr/share/xsessions"
        
        # Prioridade para Wayland
        if [ -d "$sessions_dir" ]; then
            if ls "$sessions_dir"/niri*.desktop &> /dev/null; then
                wm="Niri"
            elif ls "$sessions_dir"/hyprland*.desktop &> /dev/null; then
                wm="Hyprland"
            elif ls "$sessions_dir"/sway*.desktop &> /dev/null; then
                wm="Sway"
            elif ls "$sessions_dir"/river*.desktop &> /dev/null; then
                wm="River"
            elif ls "$sessions_dir"/labwc*.desktop &> /dev/null; then
                wm="LabWC"
            elif ls "$sessions_dir"/wayfire*.desktop &> /dev/null; then
                wm="Wayfire"
            elif ls "$sessions_dir"/qtile*.desktop &> /dev/null; then
                wm="Qtile"
            elif ls "$sessions_dir"/hikari*.desktop &> /dev/null; then
                wm="Hikari"
            fi
        fi
        
        # Verificar X11 sessions se nenhum Wayland encontrado
        if [ -z "$wm" ] && [ -d "$x11_sessions_dir" ]; then
            if ls "$x11_sessions_dir"/qtile*.desktop &> /dev/null; then
                wm="Qtile (X11)"
            elif ls "$x11_sessions_dir"/i3*.desktop &> /dev/null; then
                wm="i3"
            elif ls "$x11_sessions_dir"/bspwm*.desktop &> /dev/null; then
                wm="bspwm"
            elif ls "$x11_sessions_dir"/dwm*.desktop &> /dev/null; then
                wm="dwm"
            elif ls "$x11_sessions_dir"/awesome*.desktop &> /dev/null; then
                wm="Awesome"
            elif ls "$x11_sessions_dir"/openbox*.desktop &> /dev/null; then
                wm="Openbox"
            elif ls "$x11_sessions_dir"/fluxbox*.desktop &> /dev/null; then
                wm="Fluxbox"
            elif ls "$x11_sessions_dir"/icewm*.desktop &> /dev/null; then
                wm="IceWM"
            elif ls "$x11_sessions_dir"/herbstluftwm*.desktop &> /dev/null; then
                wm="Herbstluftwm"
            elif ls "$x11_sessions_dir"/xmonad*.desktop &> /dev/null; then
                wm="XMonad"
            elif ls "$x11_sessions_dir"/spectrwm*.desktop &> /dev/null; then
                wm="Spectrwm"
            fi
        fi
    fi
    
    echo "$wm"
}

# Detectar agente Polkit disponível
detect_polkit_agent() {
    local polkit_agent=""
    
    # KDE
    if [ -f /usr/lib/polkit-kde-authentication-agent-1 ] || command -v polkit-kde-authentication-agent-1 &> /dev/null; then
        polkit_agent="kde"
    # GNOME
    elif [ -f /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 ] || command -v polkit-gnome-authentication-agent-1 &> /dev/null; then
        polkit_agent="gnome"
    # MATE
    elif [ -f /usr/lib/mate-polkit/polkit-mate-authentication-agent-1 ] || command -v polkit-mate-authentication-agent-1 &> /dev/null; then
        polkit_agent="mate"
    # XFCE
    elif [ -f /usr/libexec/xfce-polkit ] || [ -f /usr/lib/xfce-polkit/xfce-polkit ] || command -v xfce-polkit &> /dev/null; then
        polkit_agent="xfce"
    # LXDE/LXQt
    elif command -v lxpolkit &> /dev/null; then
        polkit_agent="lxde"
    # Genérico - procurar qualquer agente
    else
        local found_agent=$(find /usr/lib /usr/libexec -name "*polkit*" -type f 2>/dev/null | grep -v "polkitd" | head -n1)
        if [ -n "$found_agent" ]; then
            polkit_agent="custom:$found_agent"
        fi
    fi
    
    echo "$polkit_agent"
}

# Verificar se é Wayland
is_wayland() {
    if [ -n "$WAYLAND_DISPLAY" ]; then
        return 0
    elif [ -n "$XDG_SESSION_TYPE" ] && [ "$XDG_SESSION_TYPE" = "wayland" ]; then
        return 0
    elif pgrep -x "Xwayland" > /dev/null; then
        return 0
    else
        return 1
    fi
}

# Detectar Display Manager instalado
detect_dm() {
    local dm=""
    
    if command -v sddm &> /dev/null; then
        dm="sddm"
    elif command -v gdm &> /dev/null; then
        dm="gdm"
    elif command -v lightdm &> /dev/null; then
        dm="lightdm"
    elif command -v ly &> /dev/null; then
        dm="ly"
    elif command -v lxdm &> /dev/null; then
        dm="lxdm"
    elif command -v entrance &> /dev/null; then
        dm="entrance"
    fi
    
    echo "$dm"
}

# Inicializar variáveis de detecção
DE_NAME=$(detect_de)
WM_NAME=$(detect_wm)
POLKIT_AGENT=$(detect_polkit_agent)
DM_INSTALLED=$(detect_dm)
IS_WAYLAND=false
is_wayland && IS_WAYLAND=true

# ============================================
# FUNÇÕES AUXILIARES
# ============================================

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

# ============================================
# VERIFICAÇÕES INICIAIS
# ============================================

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

# ============================================
# MENU INTERATIVO
# ============================================

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
            "8. Display Manager ($DM_INSTALLED)"
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

# ============================================
# CONFIGURAÇÃO DE SERVIÇOS
# ============================================

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
            
            if systemctl list-unit-files | grep -q "tlp.service"; then
                sudo systemctl enable tlp.service 2>/dev/null
                sudo systemctl mask systemd-rfkill.service systemd-rfkill.socket 2>/dev/null || true
                
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
                
                sudo tlp start 2>/dev/null || true
                print_success "TLP habilitado e configurado para laptop"
            else
                print_warning "Serviço TLP não encontrado no systemd"
            fi
        else
            print_warning "TLP não instalado. Instale com: sudo pacman -S tlp tlp-rdw"
        fi
    fi
    
    # Auto-montagem USB
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
    
    # Firewall (firewalld ou ufw)
    if command -v firewall-cmd &> /dev/null; then
        safe_enable_service "firewalld"
        print_success "Firewalld habilitado"
    elif command -v ufw &> /dev/null; then
        safe_enable_service "ufw"
        print_success "UFW habilitado"
    fi
    
    # Cron ou systemd timers
    if command -v cronie &> /dev/null; then
        safe_enable_service "cronie"
        print_success "Cron habilitado"
    fi
}

# Configurar Display Manager
setup_display_manager() {
    should_run "8" || return 0
    print_header "CONFIGURANDO DISPLAY MANAGER"
    
    local session_file=""
    
    # Verificar se existe sessão para o WM atual
    if [ -n "$WM_NAME" ] && [ "$WM_NAME" != "Unknown" ]; then
        # Converter nome do WM para formato de arquivo
        local wm_lower=$(echo "$WM_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/ (x11)//')
        
        if [ -d "/usr/share/wayland-sessions" ]; then
            session_file=$(ls /usr/share/wayland-sessions/${wm_lower}*.desktop 2>/dev/null | head -n1)
        fi
        
        if [ -z "$session_file" ] && [ -d "/usr/share/xsessions" ]; then
            session_file=$(ls /usr/share/xsessions/${wm_lower}*.desktop 2>/dev/null | head -n1)
        fi
        
        if [ -z "$session_file" ]; then
            print_warning "Nenhum arquivo de sessão encontrado para $WM_NAME"
            print_message "Isso pode ser normal se o WM iniciar via .xinitrc ou similar"
        fi
    fi
    
    if [ -z "$DM_INSTALLED" ]; then
        print_warning "Nenhum Display Manager detectado"
        print_message "Seu WM pode ser iniciado via .xinitrc ou script personalizado"
        return
    fi
    
    case "$DM_INSTALLED" in
        sddm)
            print_step "Configurando SDDM..."
            
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
            
            # Configurar sessão padrão se detectada
            if [ -n "$session_file" ]; then
                local session_name=$(basename "$session_file" .desktop)
                echo -e "\n[Autologin]\nSession=$session_name" | sudo tee -a /etc/sddm.conf.d/sddm.conf
                print_message "Sessão padrão configurada: $session_name"
            fi
            
            safe_enable_service "sddm"
            print_success "SDDM configurado e habilitado"
            ;;
            
        gdm)
            print_step "Configurando GDM..."
            safe_enable_service "gdm"
            print_success "GDM habilitado"
            print_message "GDM usa configuração padrão, edite manualmente se necessário"
            ;;
            
        lightdm)
            print_step "Configurando LightDM..."
            
            # Tentar detectar o melhor greeter
            if command -v lightdm-gtk-greeter &> /dev/null; then
                sudo sed -i 's/^#greeter-session=.*/greeter-session=lightdm-gtk-greeter/' /etc/lightdm/lightdm.conf 2>/dev/null || true
            elif command -v lightdm-webkit2-greeter &> /dev/null; then
                sudo sed -i 's/^#greeter-session=.*/greeter-session=lightdm-webkit2-greeter/' /etc/lightdm/lightdm.conf 2>/dev/null || true
            fi
            
            safe_enable_service "lightdm"
            print_success "LightDM configurado e habilitado"
            ;;
            
        ly)
            print_step "Configurando Ly..."
            safe_enable_service "ly"
            print_success "Ly habilitado (TUI display manager)"
            print_message "Ly funciona com qualquer WM/X11/Wayland automaticamente"
            ;;
            
        lxdm)
            print_step "Configurando LXDM..."
            safe_enable_service "lxdm"
            print_success "LXDM habilitado"
            ;;
    esac
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

# Configurar serviços específicos do usuário
setup_user_services() {
    should_run "6" || return 0
    print_header "CONFIGURANDO SERVIÇOS DO USUÁRIO"
    
    # Polkit agent
    print_step "Configurando agente Polkit..."
    local polkit_configured=false
    
    case "$POLKIT_AGENT" in
        kde)
            print_message "Adicionando Polkit KDE ao autostart..."
            mkdir -p "$REAL_HOME/.config/autostart"
            cat > "$REAL_HOME/.config/autostart/polkit-kde.desktop" << EOF
[Desktop Entry]
Type=Application
Name=Polkit KDE
Exec=/usr/lib/polkit-kde-authentication-agent-1
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
X-KDE-autostart-phase=1
OnlyShowIn=KDE;
EOF
            print_success "Polkit KDE configurado"
            polkit_configured=true
            ;;
            
        gnome)
            print_message "Adicionando Polkit GNOME ao autostart..."
            mkdir -p "$REAL_HOME/.config/autostart"
            cat > "$REAL_HOME/.config/autostart/polkit-gnome.desktop" << EOF
[Desktop Entry]
Type=Application
Name=Polkit GNOME
Exec=/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
OnlyShowIn=GNOME;
EOF
            print_success "Polkit GNOME configurado"
            polkit_configured=true
            ;;
            
        mate)
            print_message "Adicionando Polkit MATE ao autostart..."
            mkdir -p "$REAL_HOME/.config/autostart"
            cat > "$REAL_HOME/.config/autostart/polkit-mate.desktop" << EOF
[Desktop Entry]
Type=Application
Name=Polkit MATE
Exec=/usr/lib/mate-polkit/polkit-mate-authentication-agent-1
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
OnlyShowIn=MATE;
EOF
            print_success "Polkit MATE configurado"
            polkit_configured=true
            ;;
            
        xfce)
            print_message "Adicionando XFCE Polkit ao autostart..."
            mkdir -p "$REAL_HOME/.config/autostart"
            local xfce_polkit_path=""
            if [ -f /usr/libexec/xfce-polkit ]; then
                xfce_polkit_path="/usr/libexec/xfce-polkit"
            elif [ -f /usr/lib/xfce-polkit/xfce-polkit ]; then
                xfce_polkit_path="/usr/lib/xfce-polkit/xfce-polkit"
            else
                xfce_polkit_path="xfce-polkit"
            fi
            
            cat > "$REAL_HOME/.config/autostart/xfce-polkit.desktop" << EOF
[Desktop Entry]
Type=Application
Name=XFCE Polkit
Exec=$xfce_polkit_path
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
OnlyShowIn=XFCE;
EOF
            print_success "XFCE Polkit configurado"
            polkit_configured=true
            ;;
            
        lxde)
            print_message "Adicionando LXPolkit ao autostart..."
            mkdir -p "$REAL_HOME/.config/autostart"
            cat > "$REAL_HOME/.config/autostart/lxpolkit.desktop" << EOF
[Desktop Entry]
Type=Application
Name=LXPolkit
Exec=lxpolkit
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
OnlyShowIn=LXDE;LXQt;
EOF
            print_success "LXPolkit configurado"
            polkit_configured=true
            ;;
            
        custom:*)
            local custom_path="${POLKIT_AGENT#custom:}"
            print_message "Agente Polkit encontrado: $custom_path"
            mkdir -p "$REAL_HOME/.config/autostart"
            cat > "$REAL_HOME/.config/autostart/polkit-custom.desktop" << EOF
[Desktop Entry]
Type=Application
Name=Polkit Agent
Exec=$custom_path
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF
            print_success "Agente Polkit genérico configurado"
            polkit_configured=true
            ;;
            
        *)
            print_warning "Nenhum agente Polkit encontrado"
            print_message "Recomendado instalar um dos seguintes:"
            print_message "  • polkit-kde-agent (KDE)"
            print_message "  • polkit-gnome (GNOME/GTK)"
            print_message "  • lxpolkit (LXDE/LXQt)"
            print_message "  • xfce-polkit (XFCE)"
            print_message "  • mate-polkit (MATE)"
            ;;
    esac
    
    # Verificar se há processos polkit em execução
    if pgrep -a "polkit" 2>/dev/null | grep -v "polkitd" > /dev/null; then
        print_success "Agente Polkit já está em execução"
    fi
    
    # Clipboard manager
    print_step "Configurando clipboard manager..."
    if [ "$IS_WAYLAND" = true ] && command -v wl-paste &> /dev/null; then
        print_message "Configurando clipboard manager para Wayland..."
        mkdir -p "$REAL_HOME/.config/autostart"
        
        if command -v clipman &> /dev/null; then
            cat > "$REAL_HOME/.config/autostart/clipman.desktop" << EOF
[Desktop Entry]
Type=Application
Name=Clipman
Exec=wlopm -- wl-paste -t text --watch clipman store --max-items=50
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF
            print_success "Clipman configurado"
        elif command -v cliphist &> /dev/null; then
            print_message "Cliphist disponível - configure manualmente no seu WM"
        else
            print_message "wl-clipboard disponível para clipboard Wayland"
        fi
    elif [ -n "$DISPLAY" ] && command -v xclip &> /dev/null; then
        print_message "X11 detectado com xclip disponível"
        if command -v clipit &> /dev/null; then
            mkdir -p "$REAL_HOME/.config/autostart"
            cat > "$REAL_HOME/.config/autostart/clipit.desktop" << EOF
[Desktop Entry]
Type=Application
Name=ClipIt
Exec=clipit
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF
            print_success "ClipIt configurado"
        elif command -v parcellite &> /dev/null; then
            mkdir -p "$REAL_HOME/.config/autostart"
            cat > "$REAL_HOME/.config/autostart/parcellite.desktop" << EOF
[Desktop Entry]
Type=Application
Name=Parcellite
Exec=parcellite
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF
            print_success "Parcellite configurado"
        fi
    fi
    
    # Idle management
    print_step "Configurando gerenciamento de inatividade..."
    if command -v swayidle &> /dev/null && [ "$IS_WAYLAND" = true ]; then
        print_message "Configurando swayidle..."
        mkdir -p "$REAL_HOME/.config/autostart"
        cat > "$REAL_HOME/.config/autostart/swayidle.desktop" << EOF
[Desktop Entry]
Type=Application
Name=SwayIdle
Exec=swayidle -w
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF
        print_success "SwayIdle configurado"
    elif command -v xautolock &> /dev/null && [ -n "$DISPLAY" ]; then
        print_message "xautolock disponível para X11"
    fi
    
    # Notification daemon
    print_step "Verificando notification daemon..."
    if command -v dunst &> /dev/null; then
        print_message "Dunst encontrado - configurado manualmente no WM"
    elif command -v mako &> /dev/null; then
        print_message "Mako encontrado - configurado manualmente no WM"
    elif command -v swaync &> /dev/null; then
        print_message "SwayNC encontrado - configurado manualmente no WM"
    else
        print_warning "Nenhum notification daemon encontrado"
        print_message "Recomendado: dunst (leve e configurável)"
    fi
    
    # Wallpaper setter
    print_step "Verificando wallpaper setter..."
    if command -v swaybg &> /dev/null && [ "$IS_WAYLAND" = true ]; then
        print_message "Swaybg disponível para Wayland"
    elif command -v hyprpaper &> /dev/null; then
        print_message "Hyprpaper disponível"
    elif command -v feh &> /dev/null && [ -n "$DISPLAY" ]; then
        print_message "Feh disponível para X11"
    elif command -v nitrogen &> /dev/null && [ -n "$DISPLAY" ]; then
        print_message "Nitrogen disponível para X11"
    fi
    
    # Screen locker
    print_step "Verificando screen locker..."
    if command -v hyprlock &> /dev/null; then
        print_message "Hyprlock disponível (funciona com Niri e outros compositores Wayland)"
        print_message "  hyprlock é recomendado para Niri e Hyprland"
    elif command -v swaylock &> /dev/null && [ "$IS_WAYLAND" = true ]; then
        print_message "Swaylock disponível para Wayland"
    elif command -v gtklock &> /dev/null && [ "$IS_WAYLAND" = true ]; then
        print_message "Gtklock disponível para Wayland"
    elif command -v i3lock &> /dev/null; then
        print_message "i3lock disponível (X11)"
    elif command -v slock &> /dev/null; then
        print_message "slock disponível"
    else
        print_warning "Nenhum screen locker encontrado"
        if [ "$WM_NAME" = "Niri" ] || [ "$WM_NAME" = "Hyprland" ]; then
            print_message "  Recomendado: hyprlock (sudo pacman -S hyprlock)"
        elif [ "$IS_WAYLAND" = true ]; then
            print_message "  Recomendado: swaylock (sudo pacman -S swaylock) ou gtklock"
        else
            print_message "  Recomendado: i3lock (sudo pacman -S i3lock)"
        fi
    fi
}

# ============================================
# EXIBIÇÃO DE INFORMAÇÕES
# ============================================

# Mostrar informações do sistema
show_system_info() {
    print_header "INFORMAÇÕES DO SISTEMA"
    
    echo -e "${CYAN}Sistema:${NC}"
    echo -e "  Kernel: $(uname -r)"
    echo -e "  Arquitetura: $(uname -m)"
    echo -e "  Hostname: $(hostname)"
    
    echo -e "\n${CYAN}Ambiente Gráfico:${NC}"
    if [ -n "$DE_NAME" ] && [ "$DE_NAME" != "Unknown" ]; then
        echo -e "  ${GREEN}✓${NC} Desktop Environment: ${GREEN}$DE_NAME${NC}"
    fi
    
    if [ -n "$WM_NAME" ] && [ "$WM_NAME" != "Unknown" ]; then
        echo -e "  ${GREEN}✓${NC} Window Manager: ${GREEN}$WM_NAME${NC}"
    elif [ -z "$DE_NAME" ] || [ "$DE_NAME" = "Unknown" ]; then
        echo -e "  ${YELLOW}⚠${NC} Nenhum WM/DE detectado automaticamente"
    fi
    
    if [ "$IS_WAYLAND" = true ]; then
        echo -e "  ${GREEN}✓${NC} Protocolo: Wayland"
    elif [ -n "$DISPLAY" ]; then
        echo -e "  ${GREEN}✓${NC} Protocolo: X11 (DISPLAY=$DISPLAY)"
    else
        echo -e "  ${YELLOW}⚠${NC} Ambiente gráfico não detectado (modo texto?)"
    fi
    
    # Mostrar qual agente polkit está em execução
    local polkit_process=$(pgrep -a "polkit" 2>/dev/null | grep -v "polkitd" | head -n1)
    echo -e "\n${CYAN}Agente Polkit:${NC}"
    if [ -n "$polkit_process" ]; then
        echo -e "  ${GREEN}✓${NC} Em execução: $(echo $polkit_process | cut -d' ' -f2-)"
    elif [ -n "$POLKIT_AGENT" ] && [ "$POLKIT_AGENT" != "custom:"* ]; then
        echo -e "  ${YELLOW}○${NC} Detectado: $POLKIT_AGENT (não está em execução)"
    elif [ -n "$POLKIT_AGENT" ] && [ "$POLKIT_AGENT" == "custom:"* ]; then
        echo -e "  ${YELLOW}○${NC} Agente encontrado: ${POLKIT_AGENT#custom:}"
    else
        echo -e "  ${RED}✗${NC} Nenhum agente Polkit detectado"
    fi
    
    echo -e "\n${CYAN}Display Manager:${NC}"
    if [ -n "$DM_INSTALLED" ]; then
        if systemctl is-enabled --quiet "$DM_INSTALLED" 2>/dev/null; then
            echo -e "  ${GREEN}✓${NC} $DM_INSTALLED (habilitado)"
        else
            echo -e "  ${YELLOW}○${NC} $DM_INSTALLED (instalado mas desabilitado)"
        fi
    else
        echo -e "  ${YELLOW}⚠${NC} Nenhum Display Manager detectado"
    fi
}

# Mostrar status dos serviços
show_services_status() {
    print_header "STATUS DOS SERVIÇOS"
    
    echo -e "${CYAN}Serviços do sistema:${NC}"
    local system_services=("NetworkManager" "bluetooth" "sddm" "gdm" "lightdm" "ly" "lxdm" "iwd" "smartd" "tlp" "firewalld" "ufw" "cronie")
    for service in "${system_services[@]}"; do
        if systemctl is-active --quiet "$service" 2>/dev/null; then
            echo -e "  ${GREEN}●${NC} $service: ${GREEN}ativo${NC}"
        elif systemctl is-enabled --quiet "$service" 2>/dev/null; then
            echo -e "  ${YELLOW}○${NC} $service: ${YELLOW}habilitado mas inativo${NC}"
        elif systemctl list-unit-files | grep -q "^${service}\.service" 2>/dev/null; then
            echo -e "  ${RED}✗${NC} $service: ${RED}desabilitado${NC}"
        fi
    done
    
    echo -e "\n${CYAN}Serviços do usuário:${NC}"
    local user_services=("pipewire" "pipewire-pulse" "wireplumber" "pulseaudio")
    for service in "${user_services[@]}"; do
        if systemctl --user is-active --quiet "$service" 2>/dev/null; then
            echo -e "  ${GREEN}●${NC} $service: ${GREEN}ativo${NC}"
        elif systemctl --user is-enabled --quiet "$service" 2>/dev/null; then
            echo -e "  ${YELLOW}○${NC} $service: ${YELLOW}habilitado mas inativo${NC}"
        elif systemctl --user list-unit-files | grep -q "^${service}\.service" 2>/dev/null; then
            echo -e "  ${RED}✗${NC} $service: ${RED}desabilitado${NC}"
        fi
    done
}

# Mostrar recomendações finais
show_reboot_warning() {
    print_header "PRÓXIMOS PASSOS"
    
    echo -e "${YELLOW}⚠️  IMPORTANTE:${NC}"
    echo -e "  Para que todas as configurações tenham efeito, é recomendado:"
    echo -e "\n  1. ${GREEN}Reiniciar o sistema${NC}"
    
    if [ -n "$WM_NAME" ] && [ "$WM_NAME" != "Unknown" ]; then
        echo -e "  2. Fazer login e iniciar ${GREEN}$WM_NAME${NC}"
    else
        echo -e "  2. Fazer login manualmente"
    fi
    
    # Verificar se existem dotfiles para o WM detectado
    local wm_config_dir=""
    case "${WM_NAME,,}" in
        niri) wm_config_dir="$REAL_HOME/.config/niri" ;;
        hyprland) wm_config_dir="$REAL_HOME/.config/hypr" ;;
        sway) wm_config_dir="$REAL_HOME/.config/sway" ;;
        river) wm_config_dir="$REAL_HOME/.config/river" ;;
        labwc) wm_config_dir="$REAL_HOME/.config/labwc" ;;
        wayfire) wm_config_dir="$REAL_HOME/.config/wayfire" ;;
        qtile) wm_config_dir="$REAL_HOME/.config/qtile" ;;
        i3) wm_config_dir="$REAL_HOME/.config/i3" ;;
        bspwm) wm_config_dir="$REAL_HOME/.config/bspwm" ;;
        awesome) wm_config_dir="$REAL_HOME/.config/awesome" ;;
        openbox) wm_config_dir="$REAL_HOME/.config/openbox" ;;
        fluxbox) wm_config_dir="$REAL_HOME/.fluxbox" ;;
        icewm) wm_config_dir="$REAL_HOME/.icewm" ;;
        herbstluftwm) wm_config_dir="$REAL_HOME/.config/herbstluftwm" ;;
        xmonad) wm_config_dir="$REAL_HOME/.xmonad" ;;
        spectrwm) wm_config_dir="$REAL_HOME/.config/spectrwm" ;;
        *) wm_config_dir="" ;;
    esac
    
    if [ -n "$wm_config_dir" ] && [ ! -d "$wm_config_dir" ]; then
        echo -e "  3. Configurar ${GREEN}$WM_NAME${NC} em $wm_config_dir"
    elif [ -n "$wm_config_dir" ] && [ -d "$wm_config_dir" ]; then
        echo -e "  3. Configuração do ${GREEN}$WM_NAME${NC} já existe em $wm_config_dir"
    fi
    
    # Verificar grupos do usuário
    local groups_to_check=("adbusers" "lp" "network" "power" "video" "audio" "wheel" "storage" "input")
    echo -e "\n${CYAN}Grupos do usuário $REAL_USER:${NC}"
    for group in "${groups_to_check[@]}"; do
        if getent group "$group" > /dev/null 2>&1 && groups "$REAL_USER" 2>/dev/null | grep -q "\b$group\b"; then
            echo -e "  ${GREEN}✓${NC} $group"
        fi
    done
    
    # Recomendações específicas por WM
    if [ -n "$WM_NAME" ] && [ "$WM_NAME" != "Unknown" ]; then
        echo -e "\n${CYAN}Dicas para $WM_NAME:${NC}"
        case "$WM_NAME" in
            Niri)
                echo -e "  • Configuração: ~/.config/niri/config.kdl"
                echo -e "  • Iniciar: niri-session (via TTY) ou pelo DM"
                echo -e "  • Dica: Niri usa scrollable tiling, experimente!"
                echo -e "  • Para screenshots: grim + slurp"
                echo -e "  • Para clipboard: wl-clipboard + cliphist"
                echo -e "  • Para screen lock: hyprlock (sudo pacman -S hyprlock)"
                echo -e "  • Para barra de status: waybar ou i3status-rust"
                ;;
            Hyprland)
                echo -e "  • Configuração: ~/.config/hypr/hyprland.conf"
                echo -e "  • Iniciar: Hyprland (via TTY) ou pelo DM"
                echo -e "  • Dica: Hyprland é altamente customizável"
                echo -e "  • Para screen lock: hyprlock (integrado)"
                ;;
            Sway)
                echo -e "  • Configuração: ~/.config/sway/config"
                echo -e "  • Compatível com configurações do i3"
                echo -e "  • Use 'swaymsg' para comandos em tempo real"
                echo -e "  • Para screen lock: swaylock"
                ;;
            River)
                echo -e "  • Configuração: ~/.config/river/init"
                echo -e "  • Gerenciado via riverctl"
                echo -e "  • Layouts dinâmicos com rivertile"
                echo -e "  • Para screen lock: swaylock ou gtklock"
                ;;
            Qtile)
                echo -e "  • Configuração: ~/.config/qtile/config.py"
                echo -e "  • Escrito em Python, altamente programável"
                ;;
            i3|"i3-gaps")
                echo -e "  • Configuração: ~/.config/i3/config"
                echo -e "  • Use 'i3-msg' para comandos em tempo real"
                echo -e "  • Para screen lock: i3lock"
                ;;
            bspwm)
                echo -e "  • Configuração: ~/.config/bspwm/bspwmrc"
                echo -e "  • Gerenciado via bspc"
                ;;
            dwm)
                echo -e "  • Configuração: source code (config.h)"
                echo -e "  • Requer recompilação para mudanças"
                ;;
            Awesome)
                echo -e "  • Configuração: ~/.config/awesome/rc.lua"
                echo -e "  • Escrito em Lua, extremamente flexível"
                ;;
            KDE)
                echo -e "  • Configuração: Sistema de Configurações do KDE"
                echo -e "  • Dica: Use 'kwriteconfig5' para configs via CLI"
                ;;
            GNOME)
                echo -e "  • Configuração: dconf / gnome-tweaks"
                echo -e "  • Dica: Use 'gsettings' para configs via CLI"
                ;;
        esac
    fi
    
    # Verificar e sugerir pacotes complementares
    echo -e "\n${CYAN}Pacotes complementares sugeridos:${NC}"
    
    if [ "$IS_WAYLAND" = true ]; then
        if ! command -v grim &> /dev/null; then
            echo -e "  ${YELLOW}○${NC} grim + slurp (screenshots para Wayland)"
        fi
        if ! command -v wl-clipboard &> /dev/null; then
            echo -e "  ${YELLOW}○${NC} wl-clipboard (clipboard para Wayland)"
        fi
        if ! command -v wofi &> /dev/null && ! command -v rofi &> /dev/null; then
            echo -e "  ${YELLOW}○${NC} wofi ou rofi (launcher para Wayland)"
        fi
        if [ "$WM_NAME" = "Niri" ] || [ "$WM_NAME" = "Hyprland" ]; then
            if ! command -v hyprlock &> /dev/null; then
                echo -e "  ${YELLOW}○${NC} hyprlock (screen lock para Niri/Hyprland)"
            fi
        fi
    fi
    
    if ! command -v dunst &> /dev/null && ! command -v mako &> /dev/null; then
        echo -e "  ${YELLOW}○${NC} dunst (notification daemon leve)"
    fi
    
    if ! command -v alacritty &> /dev/null && ! command -v kitty &> /dev/null; then
        echo -e "  ${YELLOW}○${NC} alacritty ou kitty (terminais modernos)"
    fi
}

# ============================================
# FUNÇÃO PRINCIPAL
# ============================================

main() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════╗"
    echo "║     SERVICE ENABLER FOR ARCH LINUX       ║"
    echo "║         POST-INSTALLATION SCRIPT         ║"
    echo "╚══════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # Inicializar log
    log_with_timestamp "=== Iniciando configuração de serviços ==="
    log_with_timestamp "Usuário: $REAL_USER"
    log_with_timestamp "Sistema: $(uname -a)"
    log_with_timestamp "DE detectado: $DE_NAME"
    log_with_timestamp "WM detectado: $WM_NAME"
    log_with_timestamp "Agente Polkit: $POLKIT_AGENT"
    log_with_timestamp "Display Manager: $DM_INSTALLED"
    log_with_timestamp "Wayland: $IS_WAYLAND"
    
    # Verificações iniciais
    check_sudo
    check_disk_space
    check_dependencies
    check_permissions
    
    # Mostrar informações do sistema
    show_system_info
    
    # Menu interativo (se ativado)
    show_menu
    
    # Configurar todos os serviços
    setup_network
    setup_bluetooth
    setup_audio
    setup_power
    setup_system_services
    setup_display_manager
    setup_user_services
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

# ============================================
# PROCESSAR ARGUMENTOS
# ============================================

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
            echo ""
            echo "Este script detecta automaticamente seu WM/Compositor"
            echo "e configura os serviços apropriados."
            echo ""
            echo "WMs suportados:"
            echo "  Wayland: Hyprland, Sway, Niri, River, LabWC, Wayfire, Qtile, Hikari, Cage"
            echo "  X11: i3, bspwm, dwm, Awesome, Openbox, Fluxbox, IceWM, Herbstluftwm, XMonad, Spectrwm"
            echo ""
            echo "DEs suportados: KDE, GNOME, XFCE, MATE, LXQt, LXDE, Budgie, Cinnamon, Deepin"
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