#!/data/data/com.termux/files/usr/bin/bash
# RK13 Installer - Feroxbuster
echo "[*] Actualizando repositorios..."
pkg update -y && pkg upgrade -y
echo "[*] Instalando git..."
pkg install -y git
echo "[*] Clonando Feroxbuster..."
git clone https://github.com/epi052/feroxbuster $HOME/feroxbuster
echo "[*] Instalación completada en $HOME/feroxbuster"
