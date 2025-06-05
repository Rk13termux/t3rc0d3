#!/data/data/com.termux/files/usr/bin/bash
# RK13 Installer - Amass
echo "[*] Actualizando repositorios..."
pkg update -y && pkg upgrade -y
echo "[*] Instalando git..."
pkg install -y git
echo "[*] Clonando Amass..."
git clone https://github.com/OWASP/Amass $HOME/amass
echo "[*] Instalación completada en $HOME/amass"
