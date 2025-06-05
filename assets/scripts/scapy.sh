#!/data/data/com.termux/files/usr/bin/bash
# RK13 Installer - Scapy
echo "[*] Actualizando repositorios..."
pkg update -y && pkg upgrade -y
echo "[*] Instalando git..."
pkg install -y git
echo "[*] Clonando Scapy..."
git clone https://github.com/secdev/scapy $HOME/scapy
echo "[*] Instalación completada en $HOME/scapy"
