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

## Structure
<!-- TREE_START -->
```
Configs
├── cava
│   ├── config
│   ├── shaders
│   │   ├── bar_spectrum.frag
│   │   ├── eye_of_phi.frag
│   │   ├── northern_lights.frag
│   │   ├── pass_through.vert
│   │   ├── spectrogram.frag
│   │   └── winamp_line_style_spectrum.frag
│   └── themes
│       ├── colors
│       ├── solarized_dark
│       └── tricolor
├── copy_dotfiles.sh
├── dunst
│   └── dunstrc
├── fastfetch
│   ├── ascii.txt
│   └── config.jsonc
├── fuzzel
│   ├── colors-fuzzel.ini
│   └── fuzzel.ini
├── hypr
│   ├── config
│   │   ├── animations.lua
│   │   ├── appearance.lua
│   │   ├── autostart.lua
│   │   ├── binds.lua
│   │   ├── colors.lua
│   │   ├── env.lua
│   │   ├── input.lua
│   │   └── windowrules.lua
│   ├── emoji-list.txt
│   ├── hypridle.conf
│   ├── hyprland.lua
│   ├── hyprlock.conf
│   ├── monitors.lua
│   └── workspaces.lua
├── install_aur.sh
├── install_dotfiles.sh
├── install_flatpak.sh
├── install_pacman.sh
├── kitty
│   ├── colors-kitty.conf
│   └── kitty.conf
├── lista_aur.txt
├── lista_pacman.txt
├── mako
│   └── config
├── mango
│   ├── bind.conf
│   ├── config.conf
│   ├── emoji-list.txt
│   ├── env.conf
│   ├── rule.conf
│   └── theme.conf
├── music-tui
│   └── config.toml
├── niri
│   ├── animations.kdl
│   ├── binds.kdl
│   ├── config.kdl
│   ├── emoji-list.txt
│   └── layout.kdl
├── scripts
│   ├── album_art.sh
│   ├── auto_detect_terminal.sh
│   ├── battery-status.sh
│   ├── battery_tracker.sh
│   ├── brilho.sh
│   ├── calendar.sh
│   ├── clipboard.sh
│   ├── clipboard_toggle.sh
│   ├── cliphist-fuzzel-img.sh
│   ├── colors
│   │   ├── cava-colors.sh
│   │   ├── colors.wt-constants
│   │   ├── dunst-colors.sh
│   │   ├── fuzzel-colors.sh
│   │   ├── hypr-colors.sh
│   │   ├── kitty-colors.sh
│   │   ├── mako-colors.sh
│   │   ├── mango-colors.sh
│   │   ├── niri-colors.sh
│   │   ├── telegram-colors.sh
│   │   ├── update-hyprlock.sh
│   │   ├── walstart.sh
│   │   ├── waybar-colors.sh
│   │   └── zathura-colors.sh
│   ├── contador_pacotes.sh
│   ├── converter_imagens.sh
│   ├── dashboard.sh
│   ├── dashboard_toggle.sh
│   ├── enable_services.sh
│   ├── exit-menu.sh
│   ├── extract_frames.sh
│   ├── flatpak-install.sh
│   ├── gravar-region.sh
│   ├── hyprkeys.sh
│   ├── hyprpicker.sh
│   ├── hyprshot.sh
│   ├── keys.sh
│   ├── launch_first_available.sh
│   ├── media-notify.sh
│   ├── mediaplayer.py
│   ├── music-progress.sh
│   ├── mute-mic.sh
│   ├── mute.sh
│   ├── niri-keys.sh
│   ├── niri-mirror.sh
│   ├── powermenu.sh
│   ├── qr.sh
│   ├── random-wallpaper.sh
│   ├── refreshWaybar.sh
│   ├── screen_recorder.sh
│   ├── screenshot.sh
│   ├── scrolling-mpris.py
│   ├── sequencia.sh
│   ├── status.sh
│   ├── take-screenshot.sh
│   ├── volume-down.sh
│   ├── volume-up.sh
│   ├── walgen.sh
│   ├── weather.sh
│   ├── wlsunset.sh
│   └── year-progress.sh
├── swaylock
│   └── config
├── swaync
│   ├── config.json
│   └── style.css
├── wallpapers
│   └── thumbnail-RQyNlaV-Na4-maxresdefault.png
├── waybar
│   ├── colors-waybar.css
│   ├── config.jsonc
│   └── style.css
└── zathura
    └── zathurarc
```
<!-- TREE_END -->


## 📦 What is installed (and what isn't)

This repository reflects EXACTLY what I currently use:

### Compositor
- **MangoWM** (main)

### Hybrid Components
- **hyprlock** (replaces swaylock)
- **hypridle** (power management, replaces swayidle)

### Tools
- **mako** (notifications, replaces dunst/swaync)
- **fuzzel** (launcher, replaces rofi)
- **waybar** (bar)
- **kitty** (terminal)

> [!IMPORTANT]
> Regardless of whether you choose Hyprland, MangoWM, or Niri, the `random-wallpaper.sh` will generate `current_wallpaper.png` inside `~/.cache`. After that, use `SUPER + G` shortcut to execute `sequencia.sh`, which will adjust the colors.
