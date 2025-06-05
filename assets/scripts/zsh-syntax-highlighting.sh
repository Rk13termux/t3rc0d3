#!/data/data/com.termux/files/usr/bin/bash
# RK13 Installer - Zsh Syntax Highlighting
echo "[*] Actualizando repositorios..."
pkg update -y && pkg upgrade -y
echo "[*] Instalando git..."
pkg install -y git
echo "[*] Clonando Zsh Syntax Highlighting..."
git clone https://github.com/zsh-users/zsh-syntax-highlighting $HOME/zsh-syntax-highlighting
echo "[*] Instalación completada en $HOME/zsh-syntax-highlighting"
