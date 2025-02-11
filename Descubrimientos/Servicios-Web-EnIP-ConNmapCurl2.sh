#!/bin/bash

# ----------
# Script de NiPeGun para buscar servicios web en una subred o host
#
# Ejecución remota con parámetros:
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Descubrimientos/Servicios-Web-EnIP-ConNmapCurl.sh | bash -s "localhost"
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Descubrimientos/Servicios-Web-EnIP-ConNmapCurl.sh | nano -
# ----------

# Definir constantes de color
  cColorAzul='\033[0;34m'
  cColorAzulClaro='\033[1;34m'
  cColorVerde='\033[1;32m'
  cColorRojo='\033[1;31m'
  # Para el color rojo también:
    #echo "$(tput setaf 1)Mensaje en color rojo. $(tput sgr 0)"
  cFinColor='\033[0m'

# Definir el objetivo
  vHost="$1"

# Notificar inicio de ejecución del script
  echo ""
  echo -e "${cColorAzulClaro}  Buscando servicios web en $vHost... ${cFinColor}"
  echo ""

# Ejecutar Nmap y extraer los números de puerto
  mapfile -t vPuertosConRespuesta < <(nmap -p- "$vHost" | grep -oP '^\d+(?=/)')

# Verificar si se encontraron puertos
  if [ ${#vPuertosConRespuesta[@]} -eq 0 ]; then
    echo -e "${cColorRojo}    No se encontraron puertos abiertos en $vHost. ${cFinColor}"
    echo ""
    exit 1
  fi

# Notificar todos los puertos abiertos que se encontraron
  echo -e "${cColorVerde}    Se encontraron ${#vPuertosConRespuesta[@]} puertos abiertos. ${cFinColor}"
  echo ""

# Array para puertos con respuesta HTML
  vPuertosConRespuestaHTML=()

# Iterar sobre los puertos y probar con curl en HTTP y HTTPS
  for puerto in "${vPuertosConRespuesta[@]}"; do
    echo "  Probando HTTP en puerto $puerto..."
    if curl -s --max-time 3 "http://$vHost:$puerto" | grep -q "<html"; then
      echo -e "${cColorVerde}    Respuesta HTML detectada en http://$vHost:$puerto ${cFinColor}"
      vPuertosConRespuestaHTML+=("http://$vHost:$puerto")
    else
      echo -e "${cColorRojo}    No se detectó HTML en http://$vHost:$puerto. ${cFinColor}"
    fi

    echo "  Probando HTTPS en puerto $puerto..."
    if curl -s --max-time 3 -k "https://$vHost:$puerto" | grep -q "<html"; then
      echo ""
      echo -e "${cColorVerde}    Respuesta HTML detectada en https://$vHost:$puerto ${cFinColor}"
      echo ""
      vPuertosConRespuestaHTML+=("https://$vHost:$puerto")
    else
      echo ""
      echo -e "${cColorRojo}    No se detectó HTML en https://$vHost:$puerto ${cFinColor}"
      echo ""
    fi
  done

# Mostrar los puertos que devolvieron HTML, línea por línea
  if [ ${#vPuertosConRespuestaHTML[@]} -gt 0 ]; then
    echo -e "\n  IPs y puertos respectivos con respuesta HTML detectada:\n"
    for vURL in "${vPuertosConRespuestaHTML[@]}"; do
        echo "    $vURL"
    done
  else
    echo -e "\n  No se encontraron puertos con respuesta HTML en $vHost."
  fi
  echo ""
