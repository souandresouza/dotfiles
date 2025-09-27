# 🎯 Dotfiles - Garuda Hyprland Setup

<div align="center">

![Hyprland](https://img.shields.io/badge/Hyprland-Wayland-blue?style=for-the-badge)
![Garuda Linux](https://img.shields.io/badge/Garuda-Linux-1793D1?style=for-the-badge)
![Arch](https://img.shields.io/badge/Arch_Linux-1793D1?logo=arch-linux&logoColor=fff&style=for-the-badge)

**Um ambiente Hyprland altamente customizado para produtividade e estética**

[![Instalação](#-instalação)](#-instalação) • [![Características](#-características)](#-características) • [![Capturas de Tela](#-capturas-de-tela)](#-capturas-de-tela)

</div>

## 🌟 Visão Geral

Setup pessoal do **Garuda Hyprland** focado em **performance, produtividade e design minimalista**. Configuração otimizada para desenvolvimento e uso diário com atenção especial à experiência do usuário.

## ✨ Características Principais

### 🚀 Performance
- **Hyprland** como compositor Wayland moderno
- **Waybar** leve e altamente customizável
- **Alacritty** terminal acelerado por GPU
- Startup rápido e consumo eficiente de recursos

### 🎨 Estética
- Tema **escuro moderno** com cores consistentes
- **Bordas arredondadas** e animações suaves
- **Fontes Nerdfonts** para ícones e símbolos
- Design **minimalista** e funcional

### ⚡ Produtividade
- **Atalhos intuitivos** e mnemônicos
- **Workspaces** organizados por tipo de tarefa
- **Integração perfeita** entre aplicações
- **Fluxo de trabalho** otimizado

## 🛠 Stack Tecnológica

### 🎯 Componentes Core
| Componente | Tecnologia | Finalidade |
|------------|------------|------------|
| **Window Manager** | Hyprland | Compositor Wayland |
| **Status Bar** | Waybar | Barra de status e system tray |
| **Terminal** | Alacritty | Terminal moderno e rápido |
| **File Manager** | Thunar | Gerenciador de arquivos gráfico |
| **Notifications** | Dunst | Sistema de notificações |
| **PDF Reader** | Zathura | Leitor PDF com vim keybinds |

### 📦 Aplicações Incluídas
| Categoria | Aplicações |
|-----------|------------|
| **Desenvolvimento** | Neovim, Git, Bash |
| **Navegação** | Firefox |
| **Comunicação** | Discord |
| **Multimídia** | Spotify, VLC |
| **Utilitários** | Thunar, Ranger, Btop |
| **Design** | GIMP |

## 🚀 Instalação

### 📋 Pré-requisitos
- **Garuda Linux** (ou outra distro Arch-based)
- **Hyprland** instalado e funcionando

### ⚡ Instalação Rápida
```bash
git clone https://github.com/souandresouza/dotfiles.git
cd dotfiles
chmod +x setup.sh dependencies-check.sh
./setup.sh
