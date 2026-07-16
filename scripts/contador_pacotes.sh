#!/usr/bin/env bash

# Conta pacotes oficiais
OFICIAIS=$(pacman -Qq | wc -l)

# Conta AUR (usa yay ou paru se existirem)
if command -v yay &> /dev/null; then
    AUR=$(yay -Qqm | wc -l)
elif command -v paru &> /dev/null; then
    AUR=$(paru -Qqm | wc -l)
else
    AUR=0
fi

# Conta Flatpaks (mesmo método do FastFetch)
if command -v flatpak &> /dev/null; then
    # O FastFetch conta todos os flatpaks (sistema + usuário)
    FLATPAK=$(flatpak list --columns=application | tail -n +1 | grep -v "Application ID" | wc -l)
else
    FLATPAK=0
fi

TOTAL=$((OFICIAIS + AUR + FLATPAK))

# Formata o tooltip com os detalhes
TOOLTIP="📦 Pacman: $OFICIAIS\n📦 AUR: $AUR\n📦 Flatpak: $FLATPAK"

# Retorna no formato que a Waybar espera para tooltip
echo "{\"text\": \"📦 $TOTAL\", \"tooltip\": \"$TOOLTIP\"}"
