# 🎨 Hyprland Theme Engine

Modular wallpaper + color theme manager for Hyprland.

Supports:

- swww
- hellwal
- pywal
- SDDM (optional)
- Hyprlock blur generation

---

## 📦 Features

- Random wallpaper selection
- Wallpaper history (no repeats)
- Automatic resolution detection
- Blur generation for lockscreen
- Modular architecture
- Safe dependency handling
- Optional SDDM support

---

## 🧩 Dependencies

Required:

- `imagemagick`
- `jq`

Optional:

- `swww`
- `hellwal`
- `pywal`
- `pywalfox`

---

## 📁 Structure

```

scripts/
theme.sh
modules/
swww.sh
hellwal.sh
pywal.sh
sddm.sh

````

---

## 🚀 Usage

```bash
./theme.sh
````

### Flags

```bash
--random        Force random wallpaper
--same          Reapply current wallpaper
--no-swww       Disable swww
--no-hellwal    Disable hellwal
--no-pywal      Disable pywal
--sddm          Update SDDM background (requires root)
--help          Show help
```

---

## ⚙️ Custom Wallpaper Directory

You can override the default directory:

```bash
WALLPAPER_DIR=~/Pictures ./theme.sh
```

---

## 📸 Preview

(Add screenshots here)

---

## 🛠 Installation

Clone your dotfiles and symlink configs:

```bash
git clone https://github.com/souandresouza/dotfiles.git
cd dotfiles
chmod +x scripts/theme.sh
```

---

## 📜 License

MIT

```
