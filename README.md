<div align="center">

# Dotfiles

![Arch](https://img.shields.io/badge/OS-Arch_Linux-1793d1?style=flat-square&logo=archlinux&logoColor=white)
![Wayland](https://img.shields.io/badge/Protocol-Wayland-ffbc42?style=flat-square&logo=wayland&logoColor=white)

</div>

## Niri
> O [Niri](https://github.com/YaLTeR/niri) é um compositor Wayland de organização em mosaico (tiling) com rolagem, escrito em Rust. Ele oferece uma abordagem única para o gerenciamento de janelas em comparação com os compositores de mosaico tradicionais.

## Hyprland
> O [Hyprland](https://github.com/hyprwm/Hyprland) é um compositor Wayland independente, altamente personalizável e de organização dinâmica em mosaico, sem sacrificar a estética.

## MangoWM
> O [MangoWM](https://github.com/mangowm/mango) é tão leve quanto o dwl e pode ser compilado inteiramente em poucos segundos. Apesar disso, o Mango não abre mão da funcionalidade.

### Pré-requisitos
- Arch Linux limpo (recomendado) ou uma distribuição baseada no Arch (por exemplo, EndeavourOS, Manjaro)
```bash
sudo pacman -Syu --needed --noconfirm git
```
```bash
cd ~ && git clone https://github.com/souandresouza/dotfiles.git
```
```bash
bash ~/dotfiles/install_pacman.sh
```

### Instale AUR
```bash
git clone https://aur.archlinux.org/yay.git
cd yay && makepkg -si
```

```bash
bash ~/dotfiles/install_aur.sh
```

## Use links simbólicos para configurar.

```bash
bash install_dotfiles.sh
```

### Se você não quiser usar links simbólicos, pode copiar as configurações usando o comando abaixo.
```bash
bash ~/dotfiles/copy_dotfiles.sh
```

## Estrutura
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


## 📦 O que está instalado (e o que não está)

Este repositório reflete EXATAMENTE o que utilizo atualmente:

### Compositor
- **MangoWM** (principal)

### Componentes Híbridos
- **hyprlock** (substitui o swaylock)
- **hypridle** (gerenciamento de energia, substitui o swayidle)

### Ferramentas
- **mako** (notificações, substitui o dunst/swaync)
- **fuzzel** (lançador, substitui o rofi)
- **waybar** (barra)
- **kitty** (terminal)

> [!IMPORTANT]
> Independentemente de você escolher Hyprland, MangoWM ou Niri, o script `random-wallpaper.sh` gerará o arquivo `current_wallpaper.png` em `~/.cache`. Em seguida, use `SUPER + G` para executar o `sequencia.sh`, que ajustará as cores.

## 🔔 Serviços de Notificação

Todos os compositores suportados (MangoWM, Hyprland, Niri) utilizam o **mako** como o único daemon de notificação.

- **Em uso:** `mako` (configuração ativa em `mako/config`)
- **Configurações inativas (apenas para referência):** `dunst/`, `swaync/`

> ⚠️ **Importante:** Apenas um daemon de notificação pode estar ativo por vez.
> Os diretórios `dunst/` e `swaync/` estão sob controle de versão apenas para fins históricos, mas **não são utilizados** na minha configuração atual.
