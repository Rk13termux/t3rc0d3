#!/data/data/com.termux/files/usr/bin/bash
# RK13 Installer - FZF
echo "[*] Actualizando repositorios..."
pkg update -y && pkg upgrade -y
echo "[*] Instalando git..."
pkg install -y git
echo "[*] Clonando FZF..."
git clone https://github.com/junegunn/fzf $HOME/fzf
echo "[*] Instalación completada en $HOME/fzf"
