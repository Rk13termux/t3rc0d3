#!/data/data/com.termux/files/usr/bin/bash
# RK13 Installer - Zsh Autosuggestions
echo "[*] Actualizando repositorios..."
pkg update -y && pkg upgrade -y
echo "[*] Instalando git..."
pkg install -y git
echo "[*] Clonando Zsh Autosuggestions..."
git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/zsh-autosuggestions
echo "[*] Instalación completada en $HOME/zsh-autosuggestions"
