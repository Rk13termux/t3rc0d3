#!/data/data/com.termux/files/usr/bin/bash
# RK13 Installer - Powerlevel10k
echo "[*] Actualizando repositorios..."
pkg update -y && pkg upgrade -y
echo "[*] Instalando git..."
pkg install -y git
echo "[*] Clonando Powerlevel10k..."
git clone https://github.com/romkatv/powerlevel10k $HOME/powerlevel10k
echo "[*] Instalación completada en $HOME/powerlevel10k"
