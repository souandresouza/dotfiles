# 🎨 Hyprland Theme Engine

> *Modular wallpaper + color theme manager for Hyprland*

A powerful, modular theme manager for Hyprland that handles wallpapers, color schemes, and lock screen blur generation. Built with extensibility and safety in mind.

---

## ✨ Features

| | |
|---|---|
| 🖼️ | **Random wallpaper selection** with smart history tracking |
| 📜 | **Wallpaper history** – prevents repeats in recent selections |
| 📺 | **Automatic resolution detection** for perfect scaling |
| 🔐 | **Blur generation** for Hyprlock lockscreen |
| 🧩 | **Modular architecture** with pluggable modules |
| 🛡️ | **Safe dependency handling** – graceful fallbacks |
| 🎯 | **Light/Dark theme** support |
| 🖥️ | **Optional SDDM** background support |

---

## 🧩 Supported Engines

### 📦 Required
| Engine | Purpose |
|--------|---------|
| `imagemagick` | Image processing & blur generation |
| `jq` | JSON parsing for Hyprland |

### 🎨 Optional (Recommended)
| Engine | Purpose |
|--------|---------|
| `swww` | Wallpaper setting |
| `hellwal` | Dynamic color generation |
| `pywal` | Alternative color generation |
| `pywalfox` | Firefox theme integration |

### 🛠️ Optional (Requires Root)
| Engine | Purpose |
|--------|---------|
| `SDDM` | Login screen background |

---

## 📁 Project Structure

```
scripts/
├── theme.sh              # Main entry point
└── modules/              # Pluggable modules
    ├── swww.sh          # Wallpaper engine
    ├── hellwal.sh       # Color generator
    ├── pywal.sh         # Alternative color generator
    └── sddm.sh          # Login screen (root)
```

---

## 🚀 Quick Start

```bash
# Clone your dotfiles
git clone https://github.com/souandresouza/dotfiles.git
cd dotfiles

# Make it executable
chmod +x scripts/theme.sh

# Run it!
./scripts/theme.sh
```

---

## ⚙️ Usage

### Basic Commands

```bash
# Apply random wallpaper with auto theme
./scripts/theme.sh --random

# Reapply current wallpaper
./scripts/theme.sh --same

# Force light/dark theme
./scripts/theme.sh --light
./scripts/theme.sh --dark
```

### Module Control

```bash
# Disable specific engines
./scripts/theme.sh --no-swww
./scripts/theme.sh --no-hellwal
./scripts/theme.sh --no-pywal

# Update SDDM background (requires sudo)
sudo ./scripts/theme.sh --sddm
```

### Custom Wallpaper Directory

```bash
# Override default wallpaper path
WALLPAPER_DIR=~/Pictures/wallpapers ./scripts/theme.sh
```

---

## 🎮 Command Reference

| Flag | Description |
|------|-------------|
| `--random` | Force a new random wallpaper |
| `--same` | Reapply the current wallpaper |
| `--light` | Apply light theme |
| `--dark` | Apply dark theme |
| `--no-swww` | Disable swww wallpaper engine |
| `--no-hellwal` | Disable hellwal color generation |
| `--no-pywal` | Disable pywal color generation |
| `--sddm` | Update SDDM background (root) |
| `--help` | Show this help message |

---

## 🔧 Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `WALLPAPER_DIR` | `~/Pictures/wallpapers` | Custom wallpaper directory |

### Example Hyprland Integration

Add to your `hyprland.conf`:

```conf
# Random wallpaper on startup
exec-once = ~/.config/hypr/scripts/theme.sh --random

# Keybindings
bind = $mainMod SHIFT, w, exec, ~/.config/hypr/scripts/theme.sh --random
bind = $mainMod CTRL, w, exec, ~/.config/hypr/scripts/theme.sh --same
```

---

## 📸 Preview

> *Add your beautiful Hyprland screenshots here!*

| Light Theme | Dark Theme |
|-------------|------------|
| *screenshot* | *screenshot* |

---

## 🛠️ Requirements

### Essential
- Hyprland (obviously!)
- bash 4.0+
- imagemagick
- jq

### Optional but Recommended
- swww (wallpaper daemon)
- hellwal or pywal (color schemes)

---

## 🤝 Contributing

This theme engine is designed to be **modular and extensible**. Want to add support for another wallpaper engine or color tool?

1. Create a new module in `scripts/modules/`
2. Implement a `run_module_name()` function
3. That's it! The main script handles the rest

---

## 📝 License

MIT © [souandresouza](https://github.com/souandresouza)

---

<div align="center">
  
**Made with 🎨 for the Hyprland community**

</div>
