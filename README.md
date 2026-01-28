# 🎨 Dotfiles - Hyprland Setup

<div align="center">

![Arch](https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)
![Hyprland](https://img.shields.io/badge/Hyprland-333333?style=for-the-badge&logo=hypr&logoColor=white)
![Wayland](https://img.shields.io/badge/Wayland-000000?style=for-the-badge&logo=wayland&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge)

*Um setup minimalista e produtivo para Hyprland no Arch Linux*

</div>

## 📸 Preview

*(Adicione screenshots aqui)*

## ✨ Features

- 🪟 **Hyprland** - Compositor Wayland dinâmico e eficiente
- 📊 **Waybar** - Barra de status altamente customizável
- 🚀 **Rofi** - Launcher rápido e bonito
- 🐱 **Kitty** - Terminal GPU-accelerated
- 📢 **Dunst/SwayNC** - Sistema de notificações
- 📁 **Thunar** - Gerenciador de arquivos leve
- 🎨 **Temas consistentes** - GTK, QT, icons e cursors
- 🔄 **Backup/restore automático** - Segurança total
- 🗑️ **Desinstalação limpa** - Sem deixar rastros

## 🗂️ Estrutura do Projeto

```
dotfiles/
├── dunst/           # Configurações do Dunst (notificações)
├── hypr/            # Configurações do Hyprland (WM)
├── kitty/           # Configurações do Kitty (terminal)
├── rofi/            # Configurações do Rofi (launcher)
├── scripts/         # Scripts utilitários
├── swaync/          # Configurações do SwayNC (notificações)
├── Thunar/          # Configurações do Thunar (gerenciador de arquivos)
├── waybar/          # Configurações da Waybar (barra de status)
├── zathura/         # Configurações do Zathura (visualizador PDF)
├── .bashrc          # Configurações do shell Bash
├── aur.txt          # Lista de pacotes AUR
├── black.qbtheme    # Tema dark para qBittorrent
├── install.sh       # Script de instalação automatizado
├── uninstall.sh     # Script de desinstalação segura
├── LICENSE          # Licença MIT
├── pacman.txt       # Lista de pacotes oficiais
└── README.md        # Este arquivo
```

## 🚀 Instalação Rápida

### Pré-requisitos
- Arch Linux (ou derivado)
- Git instalado
- Conexão com internet

### Passo a passo

```bash
# 1. Clonar o repositório
git clone https://github.com/souandresouza/dotfiles.git ~/dotfiles

# 2. Navegar para a pasta
cd ~/dotfiles

# 3. Tornar o script executável
chmod +x install.sh

# 4. Executar instalação completa
./install.sh
```

### Opções de Instalação

| Comando | Descrição |
|---------|-----------|
| `./install.sh` | Instalação completa (padrão) |
| `./install.sh update` | Atualiza sistema e pacotes |
| `./install.sh link` | Apenas linka configurações |
| `./install.sh backup` | Backup das configurações atuais |
| `./install.sh restore` | Restaura último backup |
| `./install.sh clean` | Limpa pacotes órfãos |
| `./install.sh list` | Lista configurações disponíveis |
| `./install.sh help` | Mostra ajuda |

## 🗑️ Desinstalação Segura

```bash
# Desinstalação completa (com backup)
./uninstall.sh

# Apenas mostrar status (não remove nada)
./uninstall.sh status

# Restaurar último backup
./uninstall.sh restore

# Remover links e restaurar backup
./uninstall.sh full
```

### Opções de Desinstalação

| Comando | Descrição |
|---------|-----------|
| `./uninstall.sh` | Remove links (mais seguro) |
| `./uninstall.sh restore` | Restaura último backup |
| `./uninstall.sh full` | Remove links E restaura backup |
| `./uninstall.sh clean` | Limpa cache e backups antigos |
| `./uninstall.sh status` | Mostra o que será afetado |
| `./uninstall.sh help` | Mostra ajuda |

**⚠️ Segurança:** O `uninstall.sh` sempre pergunta confirmação antes de remover!

## 🔧 Configuração de Monitores

Após a instalação, configure seus monitores:

```bash
# Instalar nwg-displays (se não veio nos pacotes)
yay -S nwg-displays

# Executar para configurar monitores
nwg-displays

# Isso criará automaticamente:
# ~/.config/hypr/monitors.conf
# ~/.config/hypr/workspaces.conf
```

**Importante:** Configure os monitores antes de reiniciar o Hyprland!

## 🎨 Gerenciamento de Temas

Este setup usa **Hellwal/Pywal** para gerenciamento dinâmico de temas:

```bash
# Aplicar tema de um wallpaper
hellwal --image ~/Imagens/wallpapers/seu-wallpaper.jpg

# Listar esquemas gerados
ls ~/.cache/wal/colorschemes/

# Recarregar Hyprland após mudar tema
hyprctl reload
```

Os esquemas de cores são aplicados automaticamente em:
- Hyprland (~/.cache/hellwal/hyprland-colors.conf)
- Waybar
- Rofi
- Kitty

## ⌨️ Atalhos Principais (Hyprland)

| Atalho | Ação |
|--------|------|
| `Super + Enter` | Terminal (Kitty) |
| `Super + E` | Gerenciador de Arquivos (Thunar) |
| `Super + Space` | Launcher (Rofi) |
| `Super + F` | Navegador (Firefox) |
| `Super + I` | Wallpaper aleatório |
| `Super + P` | Screenshot (tela inteira) |
| `Alt + S` | Screenshot (região) |
| `Super + L` | Bloquear tela (Hyprlock) |
| `Super + Q` | Fechar janela |
| `Super + M` | Menu de logout (Wlogout) |
| `Super + U` | Google Lens Upload |
| `Super + C` | Color Picker |

## ⚙️ Configurações Detalhadas

### 🪟 Hyprland (`hypr/`)
- Bindings de teclado customizados
- Regras de janelas inteligentes
- Autostart de aplicações essenciais
- Configurações de performance
- Scripts de utilidade

### 📊 Waybar (`waybar/`)
- Módulos essenciais:
  - Workspaces do Hyprland
  - Relógio e data
  - Rede e Wi-Fi
  - Áudio (volume)
  - CPU e Memória
  - Bateria
  - Systray
- CSS customizado para styling
- Configuração modular em JSONC

### 🚀 Rofi (`rofi/`)
- Launcher de aplicações
- Tema customizado
- Atalhos rápidos
- Modo window switcher
- Modo run dialog

### 🐱 Kitty (`kitty/`)
- Terminal com aceleração por GPU
- Suporte a fontes nerdfonts
- Tema color scheme
- Atalhos de teclado eficientes
- Multiplataforma

### 📢 Sistema de Notificações
**Escolha um:**
- **Dunst** (`dunst/`): Leve e minimalista
- **SwayNC** (`swaync/`): Centro de notificações estilo GNOME/KDE

### 🎨 Temas e Aparência
- **GTK Theme**: Orchis + Papirus Icons
- **QT Theme**: Kvantum
- **Cursor**: Hyprcursor
- **Fontes**: 
  - JetBrains Mono Nerd (terminal/código)
  - Noto Sans (interface)
  - Font Awesome (ícones)

## 📦 Pacotes Gerenciados

### Pacotes Oficiais (`pacman.txt`)
```bash
# Instalar manualmente (NÃO RECOMENDADO - use install.sh):
sudo pacman -S --needed $(cat pacman.txt)
```

### Pacotes AUR (`aur.txt`)
```bash
# Requer yay/paru instalado:
yay -S --needed $(cat aur.txt)
```

## 🔧 Scripts Utilitários (`scripts/`)

**Scripts que rodam automaticamente:**
- `wlsunset.sh` - Controle de temperatura de cor (modo noturno)
- `battery_tracker.sh` - Monitoramento de bateria
- `update-hyprlock-wallpaper.sh` - Atualiza wallpaper do Hyprlock

**Scripts acionados por atalhos:**
- `launch_first_available.sh` - Lança aplicativos (Terminal/File Manager/Browser)
- `random-hellwal2.sh` - Muda wallpaper aleatoriamente
- `google-lens-upload.sh` - Upload para Google Lens

## 🎨 Tema qBittorrent

O tema `black.qbtheme` é automaticamente aplicado ao qBittorrent durante a instalação.

## 🔄 Backup e Restauração

Ambos os scripts incluem sistema automático de backup:

```bash
# Backup manual
./install.sh backup

# Restaurar último backup
./install.sh restore
# ou
./uninstall.sh restore
```

Backups são salvos em: `~/dotfiles-backup-YYYYMMDD_HHMMSS/`

## 🐛 Solução de Problemas

### Problemas Comuns

1. **Hyprland não inicia**
   ```bash
   # Verificar logs
   cat ~/.hyprland.log
   
   # Verificar dependências
   ./install.sh update
   ```

2. **Waybar não aparece**
   ```bash
   # Verificar se o processo está rodando
   ps aux | grep waybar
   
   # Recarregar Hyprland
   hyprctl reload
   ```

3. **Scripts não executáveis**
   ```bash
   # Dar permissão de execução
   chmod +x ~/.config/scripts/*.sh ~/.config/scripts/*.py
   ```

4. **Problemas com AUR**
   ```bash
   # Atualizar yay
   yay -Syu
   
   # Instalar manualmente
   yay -S nome-do-pacote
   ```

### Logs
- Instalação: `~/dotfiles/install.log`
- Desinstalação: `~/dotfiles/uninstall.log`
- Hyprland: `~/.hyprland.log`
- Sistema: `journalctl -u hyprland`

## 🤝 Contribuindo

1. Fork o repositório
2. Crie uma branch (`git checkout -b feature/nova-feature`)
3. Commit suas mudanças (`git commit -am 'Add nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Crie um Pull Request

## 📄 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 🙏 Créditos

- [Hyprland](https://hyprland.org/) - Compositor Wayland
- [Arch Linux](https://archlinux.org/) - Distribuição base
- Comunidade Arch e Hyprland pelos dotfiles de inspiração

## 🌟 Star History

[![Star History Chart](https://api.star-history.com/svg?repos=souandresouza/dotfiles&type=Date)](https://star-history.com/#souandresouza/dotfiles&Date)

---

<div align="center">
  
**Enjoy your rice!** 🍚

*Se você gostou deste setup, considere dar uma ⭐ no repositório!*

</div>

## 📞 Contato

- **GitHub**: [@souandresouza](https://github.com/souandresouza)
- **Email**: contatosouzaandre@gmail.com

---

*Última atualização: 27/01/2024*
