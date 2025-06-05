#!/data/data/com.termux/files/usr/bin/bash
# RK13 Installer - Bat
echo "[*] Actualizando repositorios..."
pkg update -y && pkg upgrade -y
echo "[*] Instalando git..."
pkg install -y git
echo "[*] Clonando Bat..."
git clone https://github.com/sharkdp/bat $HOME/bat
echo "[*] Instalación completada en $HOME/bat"
