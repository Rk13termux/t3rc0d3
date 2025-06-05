#!/data/data/com.termux/files/usr/bin/bash
# RK13 Installer - Termux App
echo "[*] Actualizando repositorios..."
pkg update -y && pkg upgrade -y
echo "[*] Instalando git..."
pkg install -y git
echo "[*] Clonando Termux App..."
git clone https://github.com/termux/termux-app $HOME/termux-app
echo "[*] Instalación completada en $HOME/termux-app"
