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

# Conta Flatpaks
if command -v flatpak &> /dev/null; then
    FLATPAK=$(flatpak list --columns=application | tail -n +1 | grep -v "Application ID" | wc -l)
else
    FLATPAK=0
fi

# Conta AppImages
APPIMAGE=$(find ~ -type f -iname "*.appimage" 2>/dev/null | wc -l)

# Soma total de todas as fontes
TOTAL=$((OFICIAIS + AUR + FLATPAK + APPIMAGE))

# Saída de texto puro formatada para o Hyprlock
echo "📦 Total: $TOTAL"
echo "  ├─ Pacman: $OFICIAIS"
echo "  ├─ AUR: $AUR"
echo "  ├─ Flatpak: $FLATPAK"
echo "  └─ AppImage: $APPIMAGE"
