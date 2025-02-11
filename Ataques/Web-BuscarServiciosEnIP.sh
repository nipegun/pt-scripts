#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para instalar y configurar xxxxxxxxx en Debian
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Web-BuscarServiciosEnIP.sh | bash
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Web-BuscarServiciosEnIP.sh | sed 's-sudo--g' | bash
#
# Ejecución remota sin caché:
#   curl -sL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Web-BuscarServiciosEnIP.sh | bash
#
# Ejecución remota con parámetros:
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Web-BuscarServiciosEnIP.sh | bash -s Parámetro1 Parámetro2
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Web-BuscarServiciosEnIP.sh | nano -
# ----------

# Definir la cantidad de argumentos esperados
  cCantParamEsperados=3
  
# Comprobar que se hayan pasado la cantidad de parámetros correctos y proceder
  if [ $# -ne $cCantParamEsperados ]
    then
      echo ""
      echo -e "${cColorRojo}  Mal uso del script. El uso correcto sería: ${cFinColor}"
      echo "    $0 [Host]"
      echo ""
      echo "  Ejemplo:"
      echo "    $0 '192.168.1.3'"
      echo ""
      echo "    $0 '192.168.1.0/24'"
      echo ""
      exit
  fi

# Definir el objetivo
  vHost="$1"

# Ejecutar Nmap y extraer los números de puerto
  mapfile -t vPuertosConRespuesta < <(nmap -p- "$vHost" | grep -oP '^\d+(?=/)')

# Array para puertos con respuesta HTML
  vPuertosConRespuestaHTML=()

# Iterar sobre los puertos y probar con curl en HTTP y HTTPS
  echo ""
  for puerto in "${vPuertosConRespuesta[@]}"; do
    echo "Probando HTTP en puerto $puerto..."
    if curl -s --max-time 3 "http://$vHost:$puerto" | grep -q "<html"; then
        vPuertosConRespuestaHTML+=("http://$vHost:$puerto")
    fi

    echo "Probando HTTPS en puerto $puerto..."
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

