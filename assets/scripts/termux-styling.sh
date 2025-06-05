#!/data/data/com.termux/files/usr/bin/bash
# RK13 Installer - Termux Styling
echo "[*] Actualizando repositorios..."
pkg update -y && pkg upgrade -y
echo "[*] Instalando git..."
pkg install -y git
echo "[*] Clonando Termux Styling..."
git clone https://github.com/termux/termux-styling $HOME/termux-styling
echo "[*] Instalación completada en $HOME/termux-styling"
