#!/usr/bin/env bash

# == Script of installation for flatpak repository     ==
echo -e "The Flatpak installation has started..." && sleep 2 && sudo pacman -S flatpak --noconfirm && sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo && echo -e "Flatpak installation is complete"
