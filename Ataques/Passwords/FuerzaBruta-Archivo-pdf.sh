#!/bin/bash

# ----------
# Script de NiPeGun para aplicar fuerza bruta de contraseñas a un archivo .zip
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Passwords/FuerzaBruta-Archivo-pdf.sh | bash -s Parámetro1 Parámetro2
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Passwords/FuerzaBruta-Archivo-pdf.sh | sed 's-sudo--g' | bash -s Parámetro1 Parámetro2
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Passwords/FuerzaBruta-Archivo-pdf.sh | nano -
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
      echo "    $0 '$HOME/Descargas/ArchivoProtegido.zip' '$HOME/HackingTools/MultiDict/Packs/CSL-LABS/ROCKYOU-CSL.txt'"
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

# Comprobar si pdf2john está disponible, si no lo está, compilarlo e instalarlo
  if [ ! -f "$HOME/HackingTools/john/pdf2john.pl" ]; then
    echo ""
    echo -e "${cColorRojo}  pdf2john no está instalado. Iniciando su instalación...${cFinColor}"
    echo ""
    sudo apt -y update
    sudo apt -y install curl
    curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/SoftInst/ParaCLI/pdf2john-Instalar-Compilando.sh | sudo bash
  fi

# Crackear contraseña
  ~/HackingTools/john/pdf2john.pl "$vRutaAlArchivo" > "$vRutaAlArchivo.hashes"
  echo ""
  ~/HackingTools/john/john -w="$vRutaAlDiccionario" "$vRutaAlArchivo.hashes"
  echo ""
  ~/HackingTools/john/john --show "$vRutaAlArchivo.hashes" | cut -d':' -f1,2 | sed 's-:- > El password es -g'
  echo ""
