#!/data/data/com.termux/files/usr/bin/bash
# RK13 Installer - Sublist3r
echo "[*] Actualizando repositorios..."
pkg update -y && pkg upgrade -y
echo "[*] Instalando git..."
pkg install -y git
echo "[*] Clonando Sublist3r..."
git clone https://github.com/aboul3la/Sublist3r $HOME/sublist3r
echo "[*] Instalación completada en $HOME/sublist3r"
