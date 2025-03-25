#!/bin/bash

# ----------
# Script de NiPeGun para aplicar fuerza bruta de contraseñas a un archivo .zip
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Passwords/FuerzaBruta-SHA512.sh | bash -s [ArchivoConHashes] [ArchivoDeDiccionario]
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Passwords/FuerzaBruta-SHA512.sh | sed 's-sudo--g' | bash -s [ArchivoConHashes] [ArchivoDeDiccionario]
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Passwords/FuerzaBruta-SHA512.sh | nano -
# ----------

# Definir la cantidad de argumentos esperados
  cCantParamEsperados=2

# Comprobar que se hayan pasado la cantidad de parámetros correctos. Abortar el script si no.
  if [ $# -ne $cCantParamEsperados ]
    then
      echo ""
      echo -e "${cColorRojo}  Mal uso del script. El uso correcto sería: ${cFinColor}"
      echo "    $0 [RutaAlArchivoZIP] [DiccionarioAUtilizar]"
      echo ""
      echo "  Ejemplo:"
      echo "    $0 '$HOME/Descargas/ArchivoProtegido.zip' '$HOME/HackingTools/MultiDict/Internet/CSL-LABS/ROCKYOU-CSL.txt'"
      echo ""
      exit
  fi

vRutaAlArchivo="$1"
vRutaAlDiccionario="$2"

# Definir constantes de color
  cColorAzul='\033[0;34m'
  cColorAzulClaro='\033[1;34m'
  cColorVerde='\033[1;32m'
  cColorRojo='\033[1;31m'
  # Para el color rojo también:
    #echo "$(tput setaf 1)Mensaje en color rojo. $(tput sgr 0)"
  cFinColor='\033[0m'

  ~/HackingTools/john/john -w="$vRutaAlDiccionario" "$vRutaAlArchivo.hashes"
  echo ""
  ~/HackingTools/john/john --show "$vRutaAlArchivo.hashes" | cut -d':' -f1,2 | sed 's-:- > El password es -g'
  echo ""
