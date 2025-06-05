#!/data/data/com.termux/files/usr/bin/bash
# RK13 Installer - Antigen
echo "[*] Actualizando repositorios..."
pkg update -y && pkg upgrade -y
echo "[*] Instalando git..."
pkg install -y git
echo "[*] Clonando Antigen..."
git clone https://github.com/zsh-users/antigen $HOME/antigen
echo "[*] Instalación completada en $HOME/antigen"
