#!/data/data/com.termux/files/usr/bin/bash
# RK13 Installer - Masscan
echo "[*] Actualizando repositorios..."
pkg update -y && pkg upgrade -y
echo "[*] Instalando git..."
pkg install -y git
echo "[*] Clonando Masscan..."
git clone https://github.com/robertdavidgraham/masscan $HOME/masscan
echo "[*] Instalación completada en $HOME/masscan"
