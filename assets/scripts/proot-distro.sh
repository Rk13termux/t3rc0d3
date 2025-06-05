#!/data/data/com.termux/files/usr/bin/bash
# RK13 Installer - Proot Distro
echo "[*] Actualizando repositorios..."
pkg update -y && pkg upgrade -y
echo "[*] Instalando git..."
pkg install -y git
echo "[*] Clonando Proot Distro..."
git clone https://github.com/termux/proot-distro $HOME/proot-distro
echo "[*] Instalación completada en $HOME/proot-distro"
