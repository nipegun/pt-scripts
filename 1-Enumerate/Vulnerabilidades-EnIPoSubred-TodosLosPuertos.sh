#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para escanear vulnerabilidades con nmap en Debian
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/1-Enumerate/Vulnerabilidades-EnIPoSubred-TodosLosPuertos.sh | bash -s "192.168.1.0/24"
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/1-Enumerate/Vulnerabilidades-EnIPoSubred-TodosLosPuertos.sh | sed 's-sudo--g' | bash -s "192.168.1.3"
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/1-Enumerate/Vulnerabilidades-EnIPoSubred-TodosLosPuertos.sh | nano -
# ----------

vIPoSubred="$1"

# Comprobar si el paquete nmap está instalado. Si no lo está, instalarlo.
  if [[ $(dpkg-query -s nmap 2>/dev/null | grep installed) == "" ]]; then
    echo ""
    echo -e "${cColorRojo}  El paquete nmap no está instalado. Iniciando su instalación...${cFinColor}"
    echo ""
    sudo apt-get -y update
    sudo apt-get -y install nmap
    echo ""
  fi

# Actualizar la base de datos
  echo ""
  echo "  Ejecutando script updatedb..."
  echo ""
  sudo nmap --script-updatedb

# Ejecutar script vuln
  echo ""
  echo "  Ejecutando metascript vuln..."
  echo ""
  sudo nmap -v -Pn -sV --script=vuln -oN ~/ResultadoNmap-"$(echo "$vIPoSubred" | cut -d'/' -f1)"-vuln.txt "$vIPoSubred" -p-
  sudo chown $USER:$USER ~/ResultadoNmap-"$(echo "$vIPoSubred" | cut -d'/' -f1)"-vuln.txt
  cat ~/ResultadoNmap-"$(echo "$vIPoSubred" | cut -d'/' -f1)"-vuln.txt | grep -E 'vulners:|cpe:|EXPLOIT' | column -t

# Ejecutar script vulscan
  echo ""
  echo "  Ejecutando script vulscan..."
  echo ""
  # Comprobar si el paquete git está instalado. Si no lo está, instalarlo.
    if [[ $(dpkg-query -s git 2>/dev/null | grep installed) == "" ]]; then
      echo ""
      echo -e "${cColorRojo}  El paquete git no está instalado. Iniciando su instalación...${cFinColor}"
      echo ""
      sudo apt-get -y update
      sudo apt-get -y install git
      echo ""
    fi
  cd /usr/share/nmap/scripts/
  sudo rm -rf vulscan
  sudo git clone https://github.com/scipag/vulscan.git
  sudo nmap -v -Pn -sV --script=vulscan/vulscan.nse --script-args vulscandb=scipvuldb.csv,cve.csv,exploitdb.csv,openvas.csv,osvdb.csv,securityfocus.csv,securitytracker.csv,xforce.csv -oN ~/ResultadoNmap-"$(echo "$vIPoSubred" | cut -d'/' -f1)"-vulscan.txt "$vIPoSubred" -p-
  sudo chown $USER:$USER ~/ResultadoNmap-"$(echo "$vIPoSubred" | cut -d'/' -f1)"-vulscan.txt
  cat ~/ResultadoNmap-"$(echo "$vIPoSubred" | cut -d'/' -f1)"-vulscan.txt | grep -E 'vulners:|cpe:|EXPLOIT' | column -t

# Ejecutar script exploit
  echo ""
  echo "  Ejecutando script exploit..."
  echo ""
  sudo nmap -v -Pn -sV -p- --script=exploit "$vIPoSubred" -oN ~/ResultadoNmap-"$(echo "$vIPoSubred" | cut -d'/' -f1)"-exploit.txt
  sudo chown $USER:$USER ~/ResultadoNmap-"$(echo "$vIPoSubred" | cut -d'/' -f1)"-exploit.txt
  cat ~/ResultadoNmap-"$(echo "$vIPoSubred" | cut -d'/' -f1)"-exploit.txt | grep -E 'vulners:|cpe:|EXPLOIT' | column -t

# Notificar fin de ejecución del script
  echo ""
  echo "  Script finalizado. Se han creado los siguientes archivos:"
  echo ""
  ls -l ~/ResultadoNmap-"$(echo "$vIPoSubred" | cut -d'/' -f1)"--* | awk '{print $9}'
  echo ""
