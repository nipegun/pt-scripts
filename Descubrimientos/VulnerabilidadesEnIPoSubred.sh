#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para escanear vulnerabilidades con nmap en Debian
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL x | bash
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL x | sed 's-sudo--g' | bash
#
# Ejecución remota sin caché:
#   curl -sL -H 'Cache-Control: no-cache, no-store' x | bash
#
# Ejecución remota con parámetros:
#   curl -sL x | bash -s Parámetro1 Parámetro2
#
# Bajar y editar directamente el archivo en nano
#   curl -sL x | nano -
# ----------

vIPoSubred="192.168.1.0/24"


# Escaneo de vulnerabilidades NSE (vuln y vulners)

  # Comprobar si el paquete nmap está instalado. Si no lo está, instalarlo.
    if [[ $(dpkg-query -s nmap 2>/dev/null | grep installed) == "" ]]; then
      echo ""
      echo -e "${cColorRojo}  El paquete nmap no está instalado. Iniciando su instalación...${cFinColor}"
      echo ""
      sudo apt-get -y update
      sudo apt-get -y install nmap
      echo ""
    fi
  sudo nmap -sV -p- --script=vuln,vulners "$vIPoSubred" -oN ~/ResultadoNmap1-nse.txt


# Escaneo de vulnerabilidades vulscan

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
  sudo git clone https://github.com/scipag/vulscan.git
  sudo nmap -sV -p- --script=vulscan/vulscan.nse "$vIPoSubred" -oN ~/ResultadoNmap2-vulscan.txt


# Escaneo de exploits conocidos (exploit)

  sudo nmap -sV --script=exploit "$vIPoSubred" -oN ~/ResultadoNmap3-exploits.txt

