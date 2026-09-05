#!/bin/bash
# sequencia.sh -- executa scripts com verificação

# Função para verificar se um pacote está instalado
is_package_installed() {
    pacman -Q "$1" >/dev/null 2>&1
}

# Função para verificar se um binário existe
is_binary_installed() {
    command -v "$1" >/dev/null 2>&1
}

echo "=== Iniciando atualização de cores ==="
echo

# cava - precisa estar rodando para aplicar cores
if command -v cava >/dev/null 2>&1 && pgrep -x "cava" >/dev/null 2>&1; then
    echo "✓ Executando cava-colors.sh (cava ativo)"
    $HOME/.config/scripts/colors/cava-colors.sh
else
    echo "✗ cava não está instalado ou não está em execução. Pulando..."
fi

# fuzzel
if command -v fuzzel >/dev/null 2>&1 && pgrep -x "fuzzel" >/dev/null 2>&1; then
    echo "✓ Executando fuzzel-colors.sh (fuzzel ativo)"
    $HOME/.config/scripts/colors/fuzzel-colors.sh
else
    echo "✗ fuzzel não está instalado ou não está em execução. Pulando..."
fi

# kitty
if command -v kitty >/dev/null 2>&1 && pgrep -x "kitty" >/dev/null 2>&1; then
    echo "✓ Executando kitty-colors.sh (kitty ativo)"
    $HOME/.config/scripts/colors/kitty-colors.sh
else
    echo "✗ kitty não está instalado ou não está em execução. Pulando..."
fi

# niri
if command -v niri >/dev/null 2>&1 && pgrep -x "niri" >/dev/null 2>&1; then
    echo "✓ Executando niri-colors.sh (niri ativo)"
    $HOME/.config/scripts/colors/niri-colors.sh
else
    echo "✗ niri não está instalado ou não está em execução. Pulando..."
fi

# mako
if command -v mako >/dev/null 2>&1 && pgrep -x "mako" >/dev/null 2>&1; then
    echo "✓ Executando mako-colors.sh (mako ativo)"
    $HOME/.config/scripts/colors/mako-colors.sh
else
    echo "✗ mako não está instalado ou não está em execução. Pulando..."
fi

# hyprlock
if command -v hyprlock >/dev/null 2>&1; then
    echo "✓ Executando update-hyprlock.sh (hyprlock instalado)"
    $HOME/.config/scripts/colors/update-hyprlock.sh
else
    echo "✗ hyprlock não está instalado. Pulando..."
fi

# wal-telegram-git - só verifica se o pacote está instalado (não fica rodando)
if pacman -Q wal-telegram-git >/dev/null 2>&1; then
    echo "✓ Executando telegram-colors.sh (wal-telegram-git instalado)"
    $HOME/.config/scripts/colors/telegram-colors.sh
else
    echo "✗ wal-telegram-git não está instalado. Pulando..."
fi

# waybar
if command -v waybar >/dev/null 2>&1 && pgrep -x "waybar" >/dev/null 2>&1; then
    echo "✓ Executando waybar-colors.sh (waybar ativo)"
    $HOME/.config/scripts/colors/waybar-colors.sh
else
    echo "✗ waybar não está instalado ou não está em execução. Pulando..."
fi

# zathura
if command -v zathura >/dev/null 2>&1 && pgrep -x "zathura" >/dev/null 2>&1; then
    echo "✓ Executando zathura-colors.sh (zathura ativo)"
    $HOME/.config/scripts/colors/zathura-colors.sh
else
    echo "✗ zathura não está instalado ou não está em execução. Pulando..."
fi

echo
echo "=== Atualização de cores concluída ==="
