#!/data/data/com.termux/files/usr/bin/bash
# RK13 Installer - MITMf
echo "[*] Actualizando repositorios..."
pkg update -y && pkg upgrade -y
echo "[*] Instalando git..."
pkg install -y git
echo "[*] Clonando MITMf..."
git clone https://github.com/byt3bl33d3r/MITMf $HOME/mitmf
echo "[*] Instalación completada en $HOME/mitmf"
