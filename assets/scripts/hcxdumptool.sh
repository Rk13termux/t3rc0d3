#!/data/data/com.termux/files/usr/bin/bash
# RK13 Installer - HCX Dumptool
echo "[*] Actualizando repositorios..."
pkg update -y && pkg upgrade -y
echo "[*] Instalando git..."
pkg install -y git
echo "[*] Clonando HCX Dumptool..."
git clone https://github.com/Z3APA/hcxdumptool $HOME/hcxdumptool
echo "[*] Instalación completada en $HOME/hcxdumptool"
