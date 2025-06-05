#!/data/data/com.termux/files/usr/bin/bash
# RK13 Installer - Oh My Zsh
echo "[*] Actualizando repositorios..."
pkg update -y && pkg upgrade -y
echo "[*] Instalando git..."
pkg install -y git
echo "[*] Clonando Oh My Zsh..."
git clone https://github.com/ohmyzsh/ohmyzsh $HOME/ohmyzsh
echo "[*] Instalación completada en $HOME/ohmyzsh"
