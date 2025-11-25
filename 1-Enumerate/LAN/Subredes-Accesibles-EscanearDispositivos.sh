#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para escanear las subredes accesibles en busca de dispositivos
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/pt-scripts/refs/heads/main/1-Enumerate/LAN/Subredes-Accesibles-EscanearDispositivos.sh | bash
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/pt-scripts/refs/heads/main/1-Enumerate/LAN/Subredes-Accesibles-EscanearDispositivos.sh | sed 's-sudo--g' | bash
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/pt-scripts/refs/heads/main/1-Enumerate/LAN/Subredes-Accesibles-EscanearDispositivos.sh | nano -
# ----------

# Notificar inicio de ejecución del script
  echo ""
  echo "  Iniciando el script de detección de dispositivos conectados a las subredes accesibles..."
  echo ""

# Comprobar si el paquete curl está instalado. Si no lo está, instalarlo.
  if [[ $(dpkg-query -s curl 2>/dev/null | grep installed) == "" ]]; then
    echo ""
    echo -e "${cColorRojo}  El paquete curl no está instalado. Iniciando su instalación...${cFinColor}"
    echo ""
    sudo apt-get -y update
    sudo apt-get -y install curl
    echo ""
  fi

# Guardar subredes acdcesibles en un archivo
  curl -sL https://raw.githubusercontent.com/nipegun/pt-scripts/refs/heads/main/1-Enumerate/LAN/Subredes-Accesibles-Listar.sh | sudo bash -s -- -depth 3 -quiet | sort -n | uniq | grep ^[0-9] > /tmp/SubredesAccesibles.txt

# Escanear subredes detectadas
  cat /tmp/SubredesAccesibles.txt | awk '{print $1}' | xargs -n1 rustscan -g --ulimit 5000 -a
