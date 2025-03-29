#!/bin/bash

# Instalar en venv
  cd ~/
  sudo rm -rf ~/HackingTools/Legion/
  git clone https://github.com/Hackman238/legion.git ~/HackingTools/Legion
  sudo ~/HackingTools/Legion/deps/installDeps.sh
  eyewitness
  phantomjs
  cd ~/HackingTools/Legion/
  python3 -m venv venv
  source ~/HackingTools/Legion/venv/bin/activate
  ~/HackingTools/Legion/deps/installPythonLibs.sh

  
  chmod +x legion.py
  sudo ~/HackingTools/Legion/legion.py
  
# Instalar a nivel de sistema
  cat requirements.txt | xargs sudo pip3 install --break-system-packages 
  cp ~/HackingTools/Legion/app/importers/NmapImporter.py ~/HackingTools/Legion/app/importers/NmapImporter.py.bak 

echo ""
echo "  Legion instalado. Ejecutalo con:"
echo ""
echo "    sudo python3 legion.py"
echo ""

# Instalar en
