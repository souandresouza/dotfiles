🎨 Hyprland Theme Engine

Modular wallpaper + color theme manager for Hyprland.
Supports multiple wallpaper engines and lockscreen blur generation, designed to be modular, safe, and easy to extend.


---

📦 Features

Random wallpaper selection

Wallpaper history (prevents repeats)

Automatic screen resolution detection

Blur generation for lockscreen (Hyprlock)

Modular architecture with pluggable modules

Safe dependency handling

Optional SDDM background support



---

🧩 Supported Engines

Required:

imagemagick

jq


Optional:

swww

hellwal

pywal

pywalfox


Optional (requires root):

SDDM (to update the SDDM background)



---

📁 Project Structure

scripts/
├── theme.sh
└── modules/
    ├── swww.sh
    ├── hellwal.sh
    ├── pywal.sh
    └── sddm.sh


---

🚀 Usage

To run the theme script, execute the following command:

./scripts/theme.sh


---

⚙️ Flags

Flag Description

--random Force a new random wallpaper
--same Reapply the current wallpaper
--light Apply light theme
--dark Apply dark theme
--no-swww Disable swww
--no-hellwal Disable hellwal
--no-pywal Disable pywal
--sddm Update SDDM background (requires root)
--help Show this help message



---

⚙️ Custom Wallpaper Directory

You can override the default wallpaper directory by setting the WALLPAPER_DIR variable:

WALLPAPER_DIR=~/Pictures ./scripts/theme.sh


---

📸 Preview

Add screenshots or GIFs of your Hyprland setup with the theme applied.


---

🛠 Installation

1. Clone your dotfiles:



git clone https://github.com/souandresouza/dotfiles.git
cd dotfiles

2. Make the theme script executable:



chmod +x scripts/theme.sh

3. Run the script:



./scripts/theme.sh


---

📜 License

MIT License
