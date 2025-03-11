#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para instalar la máxima cantidad posible de diccionarios de palabras en Debian
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Dicts/MultiDict-Instalar.sh | bash
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Dicts/MultiDict-Instalar.sh | sed 's-sudo--g' | bash
#
# Ejecución remota sin caché:
#   curl -sL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Dicts/MultiDict-Instalar.sh | bash
#
# Ejecución remota con parámetros:
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Dicts/MultiDict-Instalar.sh | bash -s Parámetro1 Parámetro2
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Dicts/MultiDict-Instalar.sh | nano -
# ----------

# Definir constantes de color
  cColorAzul='\033[0;34m'
  cColorAzulClaro='\033[1;34m'
  cColorVerde='\033[1;32m'
  cColorRojo='\033[1;31m'
  # Para el color rojo también:
    #echo "$(tput setaf 1)Mensaje en color rojo. $(tput sgr 0)"
  cFinColor='\033[0m'

# Crear el menú
  # Comprobar si el paquete dialog está instalado. Si no lo está, instalarlo.
    if [[ $(dpkg-query -s dialog 2>/dev/null | grep installed) == "" ]]; then
      echo ""
      echo -e "${cColorRojo}  El paquete dialog no está instalado. Iniciando su instalación...${cFinColor}"
      echo ""
      sudo apt-get -y update
      sudo apt-get -y install dialog
      echo ""
    fi
  menu=(dialog --checklist "Marca las opciones que quieras instalar:" 22 96 16)
    opciones=(
      1 "Preparar la carpeta ~/MultiDict"      on
      2 "  Descargar diccionarios de SecLists" off
      3 "  Descargar diccionarios de CSL-LABS" off
      4 "Opción 4" off
      5 "  Preparar diccionarios de 1 a 16 caracteres" off
    )
    choices=$("${menu[@]}" "${opciones[@]}" 2>&1 >/dev/tty)

      for choice in $choices
        do
          case $choice in

            1)

              echo ""
              echo "  Preparando la carpeta ~/MultiDict..."
              echo ""
              # Posicionarse en la carpeta
                mkdir ~/MultiDict/

            ;;

            2)

              echo ""
              echo "  Descargando SecLists..."
              echo ""
              # Posicionarse en la carpeta
                cd ~/MultiDict/
              # Clonar el repo de SecLists
                # Comprobar si el paquete git está instalado. Si no lo está, instalarlo.
                  if [[ $(dpkg-query -s git 2>/dev/null | grep installed) == "" ]]; then
                    echo ""
                    echo -e "${cColorRojo}  El paquete git no está instalado. Iniciando su instalación...${cFinColor}"
                    echo ""
                    sudo apt-get -y update
                    sudo apt-get -y install git
                    echo ""
                  fi
                git clone --depth 1 https://github.com/danielmiessler/SecLists.git

              # Borrar carpetas sobrantes
                # Archivos de la raiz
                  rm -f ~/MultiDict/SecLists/SecLists.png
                  rm -f ~/MultiDict/SecLists/LICENSE
                  rm -f ~/MultiDict/SecLists/CONTRIBUTORS.md
                  rm -f ~/MultiDict/SecLists/CONTRIBUTING.md
                # Archivos README.md
                  find ~/MultiDict/SecLists/ -type f -name README.md -exec rm -f {} \;
                  rm -f ~/MultiDict/SecLists/Discovery/Infrastructure/IPGenerator.sh
    
                rm -rf ~/MultiDict/SecLists/Ai 2> /dev/null
                rm -rf ~/MultiDict/SecLists/Ai 2> /dev/null

              # Descomprimir archivos comprimidos
                cd ~/MultiDict/SecLists/Passwords/
                bzip2 -d "500-worst-passwords.txt.bz2"
                tar -xvzf "SCRABBLE-hackerhouse.tgz"
                rm "SCRABBLE-hackerhouse.tgz"
                rm -f ~/MultiDict/SecLists/Passwords/SCRABBLE/fetch.sh
                rm -f ~/MultiDict/SecLists/Passwords/SCRABBLE/mangle.py
                rm -f ~/MultiDict/SecLists/Passwords/Default-Credentials/scada-pass.csv
                rm -f ~/MultiDict/SecLists/Passwords/Default-Credentials/default-passwords.csv
                rm -f ~/MultiDict/SecLists/Pattern-Matching/grepstrings-auditing-php.md
                rm -rf ~/MultiDict/SecLists/Payloads/
                rm -rf ~/MultiDict/SecLists/Web-Shells/

            ;;

            3)

              echo ""
              echo "  Descargando diccionarios de CSL-LABS..."
              echo ""
              # Posicionarse en la carpeta /tmp
                cd /tmp/
              # Clonar el repo de SecLists
                # Comprobar si el paquete git está instalado. Si no lo está, instalarlo.
                  if [[ $(dpkg-query -s git 2>/dev/null | grep installed) == "" ]]; then
                    echo ""
                    echo -e "${cColorRojo}  El paquete git no está instalado. Iniciando su instalación...${cFinColor}"
                    echo ""
                    sudo apt-get -y update
                    sudo apt-get -y install git
                    echo ""
                  fi
                git clone --depth 1 https://github.com/CSL-LABS/CrackingWordLists.git
                mv /tmp/CrackingWordLists/dics/ ~/MultiDict/CSL-LABS/
                cd ~/MultiDict/CSL-LABS/
                tar -xvzf ROCKYOU-CSL.tar.gz
                rm -f ROCKYOU-CSL.tar.gz
                find ~/MultiDict/CSL-LABS/ -type f -name "*.dic" -exec bash -c 'mv "$0" "${0%.dic}.txt"' {} \;

            ;;

            4)

              echo ""
              echo "  Opción 4..."
              echo ""

            ;;

            5)

              echo ""
              echo "  Preparando diccionarios con listas de 1 a 16 caracteres..."
              echo ""

              vCarpetaInicio="$HOME/MultiDict/SecLists/"  # Carpeta de origen
              mkdir -p ~/MultiDict/PorCantCaracteres/  # Asegura que la carpeta existe
              cd ~/MultiDict/PorCantCaracteres/ || exit 1  # Si falla, salir del script

              vCaracteresMin=1
              vCaracteresMax=16

              # Limpiar archivos de salida si ya existen
              for ((i=vCaracteresMin; i<=vCaracteresMax; i++)); do
                > "All${i}Characters.txt"  # Vacía los archivos antes de escribir
              done

              # Recorrer todos los archivos en la carpeta de origen
              find "$vCarpetaInicio" -type f -name "*.txt" | while read -r vArchivo; do
                while IFS= read -r vLinea; do
                  vCantCaracteres=$(echo -n "$vLinea" | wc -m)
                  if (( vCantCaracteres >= vCaracteresMin && vCantCaracteres <= vCaracteresMax )); then
                    echo "$vLinea" >> "All${vCantCaracteres}Characters.txt"
                  fi
                done < "$vArchivo"
              done

            ;;

        esac

    done

