#!/bin/bash

# ----------
# Script de NiPeGun para buscar servicios web en una subred o host
#
# Ejecución remota con parámetros:
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Descubrimientos/Servicios-EnIPoSubred.sh | bash -s "localhost"
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Descubrimientos/Servicios-EnIPoSubred.sh | nano -
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
  vIPoSubred="$1"

# Notificar inicio de ejecución del script
  echo ""
  echo -e "${cColorAzulClaro}  Buscando servicios en $vIPoSubred ... ${cFinColor}"
  echo ""

# Ejecutar Nmap y extraer los números de puerto
  mapfile -t vPuertosConRespuesta < <(nmap -p- "$vIPoSubred" | grep -oP '^\d+(?=/)')

# Verificar si se encontraron puertos
  if [ ${#vPuertosConRespuesta[@]} -eq 0 ]; then
    echo -e "${cColorRojo}    No se encontraron puertos abiertos en $vIPoSubred ${cFinColor}"
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
    echo ""
    echo "  Probando HTTP en puerto $puerto..."
    if curl -s --max-time 3 "http://$vIPoSubred:$puerto" | grep -q "<html"; then
      echo -e "${cColorVerde}    Respuesta HTML detectada en http://$vIPoSubred:$puerto ${cFinColor}"
      vPuertosConRespuestaHTML+=("http://$vIPoSubred:$puerto")
    else
      echo -e "${cColorRojo}    No se detectó HTML en http://$vIPoSubred:$puerto. ${cFinColor}"
    fi

    echo ""
    echo "  Probando HTTPS en puerto $puerto..."
    if curl -s --max-time 3 -k "https://$vIPoSubred:$puerto" | grep -q "<html"; then
      echo -e "${cColorVerde}    Respuesta HTML detectada en https://$vIPoSubred:$puerto ${cFinColor}"
      vPuertosConRespuestaHTML+=("https://$vIPoSubred:$puerto")
    else
      echo -e "${cColorRojo}    No se detectó respuesta HTML en https://$vIPoSubred:$puerto ${cFinColor}"
    fi
  done

# Mostrar los puertos que devolvieron HTML, línea por línea
  if [ ${#vPuertosConRespuestaHTML[@]} -gt 0 ]; then
    echo ""
    echo "  Resultado:"
    echo ""
    for vURL in "${vPuertosConRespuestaHTML[@]}"; do
      echo -e "${cColorVerde}    $vURL ${cFinColor}"
    done
  else
    echo ""
    echo "  Resultado:"
    echo ""
    echo -e "${cColorRojo}    No se encontraron puertos con respuesta HTML en $vIPoSubred ${cFinColor}"
  fi
  echo ""
