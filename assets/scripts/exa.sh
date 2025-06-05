#!/data/data/com.termux/files/usr/bin/bash
# RK13 Installer - Exa
echo "[*] Actualizando repositorios..."
pkg update -y && pkg upgrade -y
echo "[*] Instalando git..."
pkg install -y git
echo "[*] Clonando Exa..."
git clone https://github.com/ogham/exa $HOME/exa
echo "[*] Instalación completada en $HOME/exa"
