#!/data/data/com.termux/files/usr/bin/bash
# RK13 Installer - Hexyl
echo "[*] Actualizando repositorios..."
pkg update -y && pkg upgrade -y
echo "[*] Instalando git..."
pkg install -y git
echo "[*] Clonando Hexyl..."
git clone https://github.com/sharkdp/hexyl $HOME/hexyl
echo "[*] Instalación completada en $HOME/hexyl"
