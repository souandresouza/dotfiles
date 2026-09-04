<div align="center">

# Dotfiles

![Arch](https://img.shields.io/badge/OS-Arch_Linux-1793d1?style=flat-square&logo=archlinux&logoColor=white)
![Wayland](https://img.shields.io/badge/Protocol-Wayland-ffbc42?style=flat-square&logo=wayland&logoColor=white)

</div>

## Niri
> [Niri](https://github.com/YaLTeR/niri) is a scrollable-tiling Wayland compositor written in Rust. It offers a unique approach to window management compared to traditional tiling compositors.

## Hyprland
> [Hyprland](https://github.com/hyprwm/Hyprland) is an independent, highly customizable, dynamic tiling Wayland compositor without sacrificing its looks.

## MangoWM
> [MangoWM](https://github.com/mangowm/mango) is as lightweight as dwl and can be built completely within a few seconds. Despite this, Mango does not compromise on functionality.

### Prerequisites
- Clean Arch Linux (recommended) or an Arch-based distro (e.g. EndeavourOS, Manjaro)

```bash
sudo pacman -Syu --needed --noconfirm git
```
```bash
cd ~ && git clone https://github.com/souandresouza/dotfiles.git
```
```bash
bash ~/dotfiles/install_pacman.sh
```

### Install AUR helper
```bash
git clone https://aur.archlinux.org/yay.git
cd yay && makepkg -si
```

```bash
bash ~/dotfiles/install_aur.sh
```

## Use symlinks to configure.

```bash
bash install_dotfiles.sh
```

### If you do not want to use symlinks, you can copy the configurations using the command below.
```bash
bash ~/dotfiles/copy_dotfiles.sh
```
