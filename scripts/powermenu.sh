#!/bin/bash  
set -euo pipefail

# --- CONFIGURAÇÕES (Hyprland Puro) ---
conf="--dmenu --match-mode=exact --launch-prefix=<not set>"

# --- MENU PRINCIPAL ---
options=("🔒\tBloquear\n""⏸\tSuspender\n""⏏\tSair\n""🔄\tReiniciar\n""⏻\tDesligar")
sel_option=$(echo -e "${options[@]}" | fuzzel $conf --lines=5 --prompt "Seleciona: ")

if [[ -n $sel_option ]]; then  
    action=$(echo "$sel_option" | awk '{print $NF}')  
    
    # --- CONFIRMAÇÃO ---
    confirm=$(echo -e "Não\nSim" | fuzzel $conf --lines=2 --prompt "Confirmar $action?")
    
    if [[ $confirm == "Sim" ]]; then
        case $action in  
            "Bloquear")
                hyprlock                # <<--- USA O HYPRLOCK NATIVO
                ;;  
            "Suspender")
                hyprlock &              # <<--- MANDA PRA BACKGROUND E JÁ SUSPENDE
                sleep 0.5               # Pequena pausa pra tela renderizar o lock
                systemctl suspend  
                ;;  
            "Sair")
                hyprctl dispatch exit
                ;;  
            "Reiniciar")
                systemctl reboot  
                ;;  
            "Desligar")
                systemctl poweroff  
                ;;  
        esac  
    fi  
fi  
exit 0
