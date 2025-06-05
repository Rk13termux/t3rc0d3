#!/data/data/com.termux/files/usr/bin/bash
# RK13 Installer - Drozer
echo "[*] Actualizando repositorios..."
pkg update -y && pkg upgrade -y
echo "[*] Instalando git..."
pkg install -y git
echo "[*] Clonando Drozer..."
git clone https://github.com/FSecureLABS/drozer $HOME/drozer
echo "[*] Instalación completada en $HOME/drozer"
