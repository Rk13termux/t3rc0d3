#!/data/data/com.termux/files/usr/bin/bash
# RK13 Installer - Termux API
echo "[*] Actualizando repositorios..."
pkg update -y && pkg upgrade -y
echo "[*] Instalando git..."
pkg install -y git
echo "[*] Clonando Termux API..."
git clone https://github.com/termux/termux-api $HOME/termux-api
echo "[*] Instalación completada en $HOME/termux-api"
