#!/data/data/com.termux/files/usr/bin/bash
# RK13 Installer - RouterSploit
echo "[*] Actualizando repositorios..."
pkg update -y && pkg upgrade -y
echo "[*] Instalando git..."
pkg install -y git
echo "[*] Clonando RouterSploit..."
git clone https://github.com/threat9/routersploit $HOME/routersploit
echo "[*] Instalación completada en $HOME/routersploit"
