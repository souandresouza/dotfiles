#!/bin/bash
# Script para conectar uma Echo Dot como saída de áudio no Arch Linux

# --- CONFIGURAÇÃO ---
# Substitua pelo MAC ADDRESS da sua Echo Dot (ex: AA:BB:CC:DD:EE:FF)
MAC_ECHO="9B:3A:0B:0C:C8:D8"
# Comando para reiniciar os serviços de áudio
RESTART_CMD="systemctl --user restart pipewire{,-pulse,} wireplumber"
# --- FIM DA CONFIGURAÇÃO ---

# Verifica se os pacotes necessários estão instalados
if ! pacman -Q bluez bluez-utils &> /dev/null; then
    echo "Instalando pacotes bluez e bluez-utils..."
    sudo pacman -S --needed bluez bluez-utils
fi

# Verifica e inicia o serviço do Bluetooth
if ! systemctl is-active --quiet bluetooth.service; then
    echo "Iniciando serviço Bluetooth..."
    sudo systemctl start bluetooth.service
fi

echo "Conectando à Echo Dot ($MAC_ECHO)..."

# Comando bluetoothctl para parear, confiar e conectar
echo -e "power on\nagent on\ndefault-agent\npair $MAC_ECHO\ntrust $MAC_ECHO\nconnect $MAC_ECHO\nquit" | bluetoothctl

# Aguarda um momento para a conexão se estabelecer
sleep 2

# Passo Crucial: Força o perfil correto (A2DP Sink) e reinicia o áudio [citation:1]
echo "Aplicando configuração e reiniciando serviços de áudio..."
$RESTART_CMD

echo "Pronto! A Echo Dot deve aparecer como uma opção de saída de áudio no seu sistema."
echo "Dica: Use o 'pavucontrol' para selecioná-la como saída padrão, se necessário."
