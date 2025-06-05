#!/data/data/com.termux/files/usr/bin/bash
# RK13 Installer - Ripgrep
echo "[*] Actualizando repositorios..."
pkg update -y && pkg upgrade -y
echo "[*] Instalando git..."
pkg install -y git
echo "[*] Clonando Ripgrep..."
git clone https://github.com/BurntSushi/ripgrep $HOME/ripgrep
echo "[*] Instalación completada en $HOME/ripgrep"
