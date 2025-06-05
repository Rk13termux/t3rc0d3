#!/data/data/com.termux/files/usr/bin/bash
# RK13 Installer - Pwncat
echo "[*] Actualizando repositorios..."
pkg update -y && pkg upgrade -y
echo "[*] Instalando git..."
pkg install -y git
echo "[*] Clonando Pwncat..."
git clone https://github.com/pwncat/pwncat $HOME/pwncat
echo "[*] Instalación completada en $HOME/pwncat"
