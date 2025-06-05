#!/data/data/com.termux/files/usr/bin/bash
# RK13 Installer - WeeChat
echo "[*] Actualizando repositorios..."
pkg update -y && pkg upgrade -y
echo "[*] Instalando git..."
pkg install -y git
echo "[*] Clonando WeeChat..."
git clone https://github.com/weechat/weechat $HOME/weechat
echo "[*] Instalación completada en $HOME/weechat"
