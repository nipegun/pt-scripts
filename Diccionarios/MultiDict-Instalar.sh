#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para instalar la máxima cantidad posible de diccionarios de palabras en Debian
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Diccionarios/MultiDict-Instalar.sh | bash
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Diccionarios/MultiDict-Instalar.sh | sed 's-sudo--g' | bash
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Diccionarios/MultiDict-Instalar.sh | nano -
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
      1 "  Descargar diccionarios de SecLists"                 on
      2 "  Descargar diccionarios de CSL-LABS"                 on
      3 "  Reservado"                                          off
      4 "  Reservado"                                          off
      5 "  Reservado"                                          off
      6 "  Reservado"                                          off
      7 "    Eliminar caracteres de tabulación"                on
      8 "      Preparar diccionarios de 1 hasta 16 caracteres" on
    )
    choices=$("${menu[@]}" "${opciones[@]}" 2>&1 >/dev/tty)

      for choice in $choices
        do
          case $choice in

            1)

              echo ""
              echo "  Descargando diccionarios de SecLists..."
              echo ""
              # Borrar la carpeta vieja
                rm -rf ~/MultiDict/Internet/SecLists/ 2> /dev/null
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/MultiDict/Internet/ 2> /dev/null
              # Posicionarse en la carpeta
                cd ~/MultiDict/Internet/
              # Clonar el repo de SecLists
                export LC_ALL=C.UTF-8  # Forzar UTF-8 para evitar problemas de codificación
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
                  rm -f ~/MultiDict/Internet/SecLists/SecLists.png
                  rm -f ~/MultiDict/Internet/SecLists/LICENSE
                  rm -f ~/MultiDict/Internet/SecLists/CONTRIBUTORS.md
                  rm -f ~/MultiDict/Internet/SecLists/CONTRIBUTING.md
                # Archivos README.md
                  find ~/MultiDict/Internet/SecLists/ -type f -name README.md -exec rm -f {} \;
                  rm -f ~/MultiDict/Internet/SecLists/Discovery/Infrastructure/IPGenerator.sh
                # Archivos de inteligencia artificial
                  rm -rf ~/MultiDict/Internet/SecLists/Ai 2> /dev/null
                  rm -rf ~/MultiDict/Internet/SecLists/Ai 2> /dev/null

              # Descomprimir archivos comprimidos
                cd ~/MultiDict/Internet/SecLists/Passwords/
                bzip2 -d "500-worst-passwords.txt.bz2"
                tar -xvzf "SCRABBLE-hackerhouse.tgz"
                rm "SCRABBLE-hackerhouse.tgz"
                rm -rf ~/MultiDict/Internet/SecLists/Passwords/SCRABBLE/fetch.sh
                rm -rf ~/MultiDict/Internet/SecLists/Passwords/SCRABBLE/mangle.py
                rm -rf ~/MultiDict/Internet/SecLists/Passwords/Default-Credentials/scada-pass.csv
                rm -rf ~/MultiDict/Internet/SecLists/Passwords/Default-Credentials/default-passwords.csv
                rm -rf ~/MultiDict/Internet/SecLists/Pattern-Matching/grepstrings-auditing-php.md
                rm -rf ~/MultiDict/Internet/SecLists/Payloads/
                rm -rf ~/MultiDict/Internet/SecLists/Web-Shells/
                rm -rf ~/MultiDict/Internet/SecLists/Fuzzing/
                # No convierten bien a UTF8
                  #rm -rf ~/MultiDict/Internet/SecLists/Discovery/DNS/FUZZSUBS_CYFARE_2.txt
                  #rm -rf ~/MultiDict/Internet/SecLists/Discovery/Web-Content/raft-large-files-lowercase.txt
                  #rm -rf ~/MultiDict/Internet/SecLists/Discovery/Web-Content/trickest-robots-disallowed-wordlists/top-10000.txt
                  #rm -rf ~/MultiDict/Internet/SecLists/Discovery/Web-Content/raft-large-files.txt
                  #rm -rf ~/MultiDict/Internet/SecLists/Discovery/Web-Content/combined_words.txt
                  #rm -rf ~/MultiDict/Internet/SecLists/Discovery/Web-Content/CMS/trickest-cms-wordlist/dolibarr.txt
                  #rm -rf ~/MultiDict/Internet/SecLists/Discovery/Web-Content/CMS/trickest-cms-wordlist/dolibarr-all-levels.txt
                  #rm -rf ~/MultiDict/Internet/SecLists/Discovery/Web-Content/CMS/Django.txt
                  #rm -rf ~/MultiDict/Internet/SecLists/Discovery/Web-Content/raft-large-directories.txt
                  #rm -rf ~/MultiDict/Internet/SecLists/Discovery/Web-Content/raft-small-directories.txt
                  #rm -rf ~/MultiDict/Internet/SecLists/Discovery/Web-Content/raft-medium-directories.txt
                  #rm -rf ~/MultiDict/Internet/SecLists/Passwords/dutch_passwordlist.txt
                  #rm -rf ~/MultiDict/Internet/SecLists/Passwords/Cracked-Hashes/milw0rm-dictionary.txt
                  #rm -rf ~/MultiDict/Internet/SecLists/Passwords/Leaked-Databases/fortinet-2021.txt
                  #rm -rf ~/MultiDict/Internet/SecLists/Passwords/Leaked-Databases/honeynet-withcount.txt
                  #rm -rf ~/MultiDict/Internet/SecLists/Passwords/Leaked-Databases/honeynet2.txt
                  #rm -rf ~/MultiDict/Internet/SecLists/Passwords/Leaked-Databases/honeynet.txt
                  #rm -rf ~/MultiDict/Internet/SecLists/Passwords/Leaked-Databases/myspace-withcount.txt
                  #rm -rf ~/MultiDict/Internet/SecLists/Passwords/Honeypot-Captures/python-heralding-sep2019.txt
                  #rm -rf ~/MultiDict/Internet/SecLists/Passwords/Common-Credentials/10-million-password-list-top-100.txt
                  #rm -rf ~/MultiDict/Internet/SecLists/Passwords/Common-Credentials/Language-Specific/Spanish_common-usernames-and-passwords.txt
                  #rm -rf ~/MultiDict/Internet/SecLists/Passwords/Common-Credentials/10-million-password-list-top-100000.txt
                  #rm -rf ~/MultiDict/Internet/SecLists/Usernames/Honeypot-Captures/multiplesources-users-fabian-fingerle.de.txt
                  #rm -rf ~/MultiDict/Internet/SecLists/Miscellaneous/control-chars.txt
                  #rm -rf ~/MultiDict/Internet/SecLists/Miscellaneous/Moby-Project/Moby-Language-II/german.txt
                  #rm -rf ~/MultiDict/Internet/SecLists/Miscellaneous/Moby-Project/Moby-Language-II/japanese.txt
                  #rm -rf ~/MultiDict/Internet/CSL-LABS/ROCKYOU-CSL.txt
                  #rm -rf ~/MultiDict/Internet/CSL-LABS/misc/sports.txt
                  #rm -rf ~/MultiDict/Internet/CSL-LABS/misc/top_songs.txt

            ;;

            2)

              echo ""
              echo "  Descargando diccionarios de CSL-LABS..."
              echo ""
              # Borrar posible descarga anterior
                rm -rf /tmp/CrackingWordLists/ 2> /dev/null
              # Posicionarse en la carpeta /tmp
                cd /tmp/
              # Clonar el repo de CSL-LABS
                export LC_ALL=C.UTF-8  # Forzar UTF-8 para evitar problemas de codificación
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
              # Borrar la carpeta vieja
                rm -rf ~/MultiDict/Internet/CSL-LABS/ 2> /dev/null
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/MultiDict/Internet/ 2> /dev/null
              # Mover carpeta
                mv /tmp/CrackingWordLists/dics/ ~/MultiDict/Internet/CSL-LABS/
              #
                cd ~/MultiDict/Internet/CSL-LABS/
                tar -xvzf ROCKYOU-CSL.tar.gz
                rm -f ROCKYOU-CSL.tar.gz
                find ~/MultiDict/Internet/CSL-LABS/ -type f -name "*.dic" -exec bash -c 'mv "$0" "${0%.dic}.txt"' {} \;

            ;;

            3)

              echo ""
              echo "  Reservado..."
              echo ""



            ;;

            4)

              echo ""
              echo "  Reservado..."
              echo ""



            ;;

            5)

              echo ""
              echo "  Reservado..."
              echo ""



            ;;

            6)

              echo ""
              echo "  Reservado..."
              echo ""



            ;;

            7)

              echo ""
              echo "  Eliminando caracteres de tabulación..."
              echo ""

              vCarpetaInicio="$HOME/MultiDict/Internet/"
              find "$vCarpetaInicio" -type f -name "*.txt" -print0 | while IFS= read -r -d '' vArchivo; do
                sed -i 's/\t//g' "$vArchivo"
              done

            ;;

            8)

              echo ""
              echo "  Preparando diccionarios de 1 hasta 16 caracteres..."
              echo ""

              # Crear diccionarios
                export LC_ALL=C.UTF-8  # Forzar UTF-8 para evitar problemas de codificación

                vCarpetaInicio="$HOME/MultiDict/Internet/"
                vCarpetaDestino="$HOME/MultiDict/PorCantCaracteres/"
                rm "$vCarpetaDestino"* 2> /dev/null

                mkdir -p "$vCarpetaDestino"
                cd "$vCarpetaDestino" || exit 1

                vCaracteresMin=1
                vCaracteresMax=16

                for ((i=vCaracteresMin; i<=vCaracteresMax; i++)); do
                  > "All${i}Characters.txt"
                done

                find "$vCarpetaInicio" -type f -name "*.txt" -print0 | while IFS= read -r -d '' file; do
                  iconv -c -f UTF-8 -t UTF-8 "$file" | awk -v min="$vCaracteresMin" -v max="$vCaracteresMax" '
                  {
                    len = length($0);
                    if (len >= min && len <= max)
                      print $0 >> ("All" len "Characters.txt");
                  }'
                done

              # Eliminar líneas duplicadas
                find "$vCarpetaDestino" -type f -name "*.txt" | while read -r vArchivo; do
                  sort "$vArchivo" | uniq > "$vArchivo.tmp" && mv "$vArchivo.tmp" "$vArchivo"
                done
                echo ""

              # Notificar fin de la ejecución
                echo ""
                echo "  Se han procesado todos los .txt de $vCarpetaInicio y se han creado nuevos diccionarios con su contenido."
                echo "  Puedes encontrar los nuevos diccionarios en $vCarpetaDestino"
                echo ""

            ;;

        esac

    done

