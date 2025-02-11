#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para buscar servicios web en una subred o host
#
# Ejecución remota con parámetros:
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Web-BuscarServiciosEnIP.sh | bash -s "localhost"
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Web-BuscarServiciosEnIP.sh | nano -
# ----------

# Definir constantes de color
  cColorAzul='\033[0;34m'
  cColorAzulClaro='\033[1;34m'
  cColorVerde='\033[1;32m'
  cColorRojo='\033[1;31m'
  # Para el color rojo también:
    #echo "$(tput setaf 1)Mensaje en color rojo. $(tput sgr 0)"
  cFinColor='\033[0m'

# Definir la cantidad de argumentos esperados
  cCantParamEsperados=1
  
# Comprobar que se hayan pasado la cantidad de parámetros correctos y proceder
  if [ $# -ne $cCantParamEsperados ]
    then
      echo ""
      echo -e "${cColorRojo}  Mal uso del script. El uso correcto sería: ${cFinColor}"
      echo ""
      echo "    $0 [Host]"
      echo ""
      echo "  Ejemplo:"
      echo ""
      echo "    $0 '192.168.1.3'"
      echo ""
      echo "    $0 '192.168.1.0/24'"
      echo ""
      exit
  fi

# Definir el objetivo
  vHost="$1"

# Ejecutar Nmap y extraer los números de puerto
  # Comprobar si el paquete nmap está instalado. Si no lo está, instalarlo.
    if [[ $(dpkg-query -s nmap 2>/dev/null | grep installed) == "" ]]; then
      echo ""
      echo -e "${cColorRojo}  El paquete nmap no está instalado. Iniciando su instalación...${cFinColor}"
      echo ""
      sudo apt-get -y update
      sudo apt-get -y install nmap
      echo ""
    fi
  mapfile -t vPuertosConRespuesta < <(nmap -p- "$vHost" | grep -oP '^\d+(?=/)')

# Array para puertos con respuesta HTML
  vPuertosConRespuestaHTML=()

# Iterar sobre los puertos y probar con curl en HTTP y HTTPS
  # Comprobar si el paquete curl está instalado. Si no lo está, instalarlo.
    if [[ $(dpkg-query -s curl 2>/dev/null | grep installed) == "" ]]; then
      echo ""
      echo -e "${cColorRojo}  El paquete curl no está instalado. Iniciando su instalación...${cFinColor}"
      echo ""
      sudo apt-get -y update
      sudo apt-get -y install curl
      echo ""
    fi
  echo ""
  for puerto in "${vPuertosConRespuesta[@]}"; do
    echo "Probando http://$vHost:$puerto..."
    if curl -s --max-time 3 "http://$vHost:$puerto" | grep -q "<html"; then
        vPuertosConRespuestaHTML+=("http://$vHost:$puerto")
    fi

    echo "Probando https://$vHost:$puerto..."
    if curl -s --max-time 3 -k "https://$vHost:$puerto" | grep -q "<html"; then
        vPuertosConRespuestaHTML+=("https://$vHost:$puerto")
    fi
  done

# Mostrar los puertos que devolvieron HTML, línea por línea
  echo ""
  echo "  Puertos con respuesta HTML:"
  echo ""
  for vURL in "${vPuertosConRespuestaHTML[@]}"; do
    echo "$vURL"
  done
  echo ""

