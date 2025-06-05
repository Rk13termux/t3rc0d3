#!/data/data/com.termux/files/usr/bin/bash
# RK13 Installer - Havoc Framework
echo "[*] Actualizando repositorios..."
pkg update -y && pkg upgrade -y
echo "[*] Instalando git..."
pkg install -y git
echo "[*] Clonando Havoc Framework..."
git clone https://github.com/HavocFramework/Havoc-Framework $HOME/havoc-framework
echo "[*] Instalación completada en $HOME/havoc-framework"
