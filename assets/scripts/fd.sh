#!/data/data/com.termux/files/usr/bin/bash
# RK13 Installer - Fd
echo "[*] Actualizando repositorios..."
pkg update -y && pkg upgrade -y
echo "[*] Instalando git..."
pkg install -y git
echo "[*] Clonando Fd..."
git clone https://github.com/sharkdp/fd $HOME/fd
echo "[*] Instalación completada en $HOME/fd"
