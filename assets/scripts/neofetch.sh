#!/data/data/com.termux/files/usr/bin/bash
# RK13 Installer - Neofetch
echo "[*] Actualizando repositorios..."
pkg update -y && pkg upgrade -y
echo "[*] Instalando git..."
pkg install -y git
echo "[*] Clonando Neofetch..."
git clone https://github.com/dylanaraps/neofetch $HOME/neofetch
echo "[*] Instalación completada en $HOME/neofetch"
