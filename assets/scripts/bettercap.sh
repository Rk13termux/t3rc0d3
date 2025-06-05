#!/data/data/com.termux/files/usr/bin/bash
# RK13 Installer - Bettercap
echo "[*] Actualizando repositorios..."
pkg update -y && pkg upgrade -y
echo "[*] Instalando git..."
pkg install -y git
echo "[*] Clonando Bettercap..."
git clone https://github.com/bettercap/bettercap $HOME/bettercap
echo "[*] Instalación completada en $HOME/bettercap"
