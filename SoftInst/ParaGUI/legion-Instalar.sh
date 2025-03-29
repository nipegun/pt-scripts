#!/bin/bash

git clone https://github.com/Hackman238/legion.git ~/HackingTools/Legion
cd ~/HackingTools/Legion
sudo ~/HackingTools/Legion/deps/installDeps.sh
eyewitness
phantomjs
sudo ~/HackingTools/Legion/deps/installPythonLibs.sh
cat requirements.txt | xargs sudo pip3 install --break-system-packages 
cp ~/HackingTools/Legion/app/importers/NmapImporter.py ~/HackingTools/Legion/app/importers/NmapImporter.py.bak 

echo ""
echo "  Legion instalado. Ejecutalo con:"
echo ""
echo "    sudo python3 legion.py"
echo ""

