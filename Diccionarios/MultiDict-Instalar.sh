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
      1 "  Instalar Diccionarios de Debian"                    on
      2 "  Descargar diccionarios de SecLists"                 on
      3 "  Descargar diccionarios de CSL-LABS"                 off
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
              echo "  Instalando diccionarios de Debian..."
              echo ""
              sudo apt-get -y update
              sudo apt-get -y install wbulgarian
              sudo apt-get -y install wesperanto
              sudo apt-get -y install wirish
              sudo apt-get -y install wmanx
              sudo apt-get -y install wukrainian
              sudo apt-get -y install wgerman-medical
              sudo apt-get -y install wamerican-huge
              sudo apt-get -y install wamerican-insane
              sudo apt-get -y install wamerican-large
              sudo apt-get -y install wamerican-small
              sudo apt-get -y install wbritish-huge
              sudo apt-get -y install wbritish-insane
              sudo apt-get -y install wbritish-large
              sudo apt-get -y install wbritish-small
              sudo apt-get -y install wcanadian
              sudo apt-get -y install wcanadian-huge
              sudo apt-get -y install wcanadian-insane
              sudo apt-get -y install wcanadian-large
              sudo apt-get -y install wcanadian-small
              sudo apt-get -y install wcatalan
              sudo apt-get -y install wswedish
              sudo apt-get -y install wfrench
              sudo apt-get -y install witalian
              sudo apt-get -y install wspanish
              sudo apt-get -y install wordlist
              sudo apt-get -y install scowl
              # Borrar la carpeta vieja
                rm -rf ~/HackingTools/MultiDict/Debian/ 2> /dev/null
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/MultiDict/Debian/ 2> /dev/null
              # Copiar diccionarios a la carpeta Debian
                mkdir -p ~/HackingTools/MultiDict/Debian/scowl/
                cp -fv /usr/share/dict/scowl/*                 ~/HackingTools/MultiDict/Debian/scowl/
                cp -fv /usr/share/dict/american-english        ~/HackingTools/MultiDict/Debian/
                cp -fv /usr/share/dict/american-english-huge   ~/HackingTools/MultiDict/Debian/
                cp -fv /usr/share/dict/american-english-insane ~/HackingTools/MultiDict/Debian/
                cp -fv /usr/share/dict/american-english-large  ~/HackingTools/MultiDict/Debian/
                cp -fv /usr/share/dict/american-english-small  ~/HackingTools/MultiDict/Debian/
                cp -fv /usr/share/dict/bokmaal                 ~/HackingTools/MultiDict/Debian/
                cp -fv /usr/share/dict/brazilian               ~/HackingTools/MultiDict/Debian/
                cp -fv /usr/share/dict/british-english-huge    ~/HackingTools/MultiDict/Debian/
                cp -fv /usr/share/dict/british-english-insane  ~/HackingTools/MultiDict/Debian/
                cp -fv /usr/share/dict/british-english-large   ~/HackingTools/MultiDict/Debian/
                cp -fv /usr/share/dict/british-english-small   ~/HackingTools/MultiDict/Debian/
                cp -fv /usr/share/dict/canadian-english        ~/HackingTools/MultiDict/Debian/
                cp -fv /usr/share/dict/canadian-english-huge   ~/HackingTools/MultiDict/Debian/
                cp -fv /usr/share/dict/canadian-english-insane ~/HackingTools/MultiDict/Debian/
                cp -fv /usr/share/dict/canadian-english-large  ~/HackingTools/MultiDict/Debian/
                cp -fv /usr/share/dict/canadian-english-small  ~/HackingTools/MultiDict/Debian/
                cp -fv /usr/share/dict/catalan                 ~/HackingTools/MultiDict/Debian/
                cp -fv /usr/share/dict/cracklib-small          ~/HackingTools/MultiDict/Debian/
                cp -fv /usr/share/dict/danish                  ~/HackingTools/MultiDict/Debian/
                cp -fv /usr/share/dict/dutch                   ~/HackingTools/MultiDict/Debian/
                cp -fv /usr/share/dict/esperanto               ~/HackingTools/MultiDict/Debian/
                cp -fv /usr/share/dict/french                  ~/HackingTools/MultiDict/Debian/
                cp -fv /usr/share/dict/german-medical          ~/HackingTools/MultiDict/Debian/
                cp -fv /usr/share/dict/irish                   ~/HackingTools/MultiDict/Debian/
                cp -fv /usr/share/dict/italian                 ~/HackingTools/MultiDict/Debian/
                cp -fv /usr/share/dict/manx                    ~/HackingTools/MultiDict/Debian/
                cp -fv /usr/share/dict/ngerman                 ~/HackingTools/MultiDict/Debian/
                cp -fv /etc/dictionaries-common/norsk          ~/HackingTools/MultiDict/Debian/
                cp -fv /usr/share/dict/nynorsk                 ~/HackingTools/MultiDict/Debian/
                cp -fv /usr/share/dict/polish                  ~/HackingTools/MultiDict/Debian/
                cp -fv /usr/share/dict/portuguese              ~/HackingTools/MultiDict/Debian/
                cp -fv /usr/share/dict/spanish                 ~/HackingTools/MultiDict/Debian/
                cp -fv /usr/share/dict/swedish                 ~/HackingTools/MultiDict/Debian/
                cp -fv /usr/share/dict/ukranian                ~/HackingTools/MultiDict/Debian/
                cp -fv /etc/dictionaries-common/words          ~/HackingTools/MultiDict/Debian/

            ;;

            2)

              echo ""
              echo "  Descargando diccionarios de SecLists..."
              echo ""
              # Borrar la carpeta vieja
                rm -rf ~/HackingTools/MultiDict/Internet/SecLists/ 2> /dev/null
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/MultiDict/Internet/ 2> /dev/null
              # Posicionarse en la carpeta
                cd ~/HackingTools/MultiDict/Internet/
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
                  rm -f ~/HackingTools/MultiDict/Internet/SecLists/SecLists.png
                  rm -f ~/HackingTools/MultiDict/Internet/SecLists/LICENSE
                  rm -f ~/HackingTools/MultiDict/Internet/SecLists/CONTRIBUTORS.md
                  rm -f ~/HackingTools/MultiDict/Internet/SecLists/CONTRIBUTING.md
                # Archivos README.md
                  find ~/HackingTools/MultiDict/Internet/SecLists/ -type f -name README.md -exec rm -f {} \;
                  rm -f ~/HackingTools/MultiDict/Internet/SecLists/Discovery/Infrastructure/IPGenerator.sh
                # Archivos de inteligencia artificial
                  rm -rf ~/HackingTools/MultiDict/Internet/SecLists/Ai 2> /dev/null
                  rm -rf ~/HackingTools/MultiDict/Internet/SecLists/Ai 2> /dev/null

              # Descomprimir archivos comprimidos
                cd ~/HackingTools/MultiDict/Internet/SecLists/Passwords/
                bzip2 -d "500-worst-passwords.txt.bz2"
                tar -xvzf "SCRABBLE-hackerhouse.tgz"
                rm "SCRABBLE-hackerhouse.tgz"
                rm -rf ~/HackingTools/MultiDict/Internet/SecLists/Passwords/SCRABBLE/fetch.sh
                rm -rf ~/HackingTools/MultiDict/Internet/SecLists/Passwords/SCRABBLE/mangle.py
                rm -rf ~/HackingTools/MultiDict/Internet/SecLists/Passwords/Default-Credentials/scada-pass.csv
                rm -rf ~/HackingTools/MultiDict/Internet/SecLists/Passwords/Default-Credentials/default-passwords.csv
                rm -rf ~/HackingTools/MultiDict/Internet/SecLists/Pattern-Matching/grepstrings-auditing-php.md
                rm -rf ~/HackingTools/MultiDict/Internet/SecLists/Payloads/
                rm -rf ~/HackingTools/MultiDict/Internet/SecLists/Web-Shells/
                rm -rf ~/HackingTools/MultiDict/Internet/SecLists/Fuzzing/
                # No convierten bien a UTF8
                  #rm -rf ~/HackingTools/MultiDict/Internet/SecLists/Discovery/DNS/FUZZSUBS_CYFARE_2.txt
                  #rm -rf ~/HackingTools/MultiDict/Internet/SecLists/Discovery/Web-Content/raft-large-files-lowercase.txt
                  #rm -rf ~/HackingTools/MultiDict/Internet/SecLists/Discovery/Web-Content/trickest-robots-disallowed-wordlists/top-10000.txt
                  #rm -rf ~/HackingTools/MultiDict/Internet/SecLists/Discovery/Web-Content/raft-large-files.txt
                  #rm -rf ~/HackingTools/MultiDict/Internet/SecLists/Discovery/Web-Content/combined_words.txt
                  #rm -rf ~/HackingTools/MultiDict/Internet/SecLists/Discovery/Web-Content/CMS/trickest-cms-wordlist/dolibarr.txt
                  #rm -rf ~/HackingTools/MultiDict/Internet/SecLists/Discovery/Web-Content/CMS/trickest-cms-wordlist/dolibarr-all-levels.txt
                  #rm -rf ~/HackingTools/MultiDict/Internet/SecLists/Discovery/Web-Content/CMS/Django.txt
                  #rm -rf ~/HackingTools/MultiDict/Internet/SecLists/Discovery/Web-Content/raft-large-directories.txt
                  #rm -rf ~/HackingTools/MultiDict/Internet/SecLists/Discovery/Web-Content/raft-small-directories.txt
                  #rm -rf ~/HackingTools/MultiDict/Internet/SecLists/Discovery/Web-Content/raft-medium-directories.txt
                  #rm -rf ~/HackingTools/MultiDict/Internet/SecLists/Passwords/dutch_passwordlist.txt
                  #rm -rf ~/HackingTools/MultiDict/Internet/SecLists/Passwords/Cracked-Hashes/milw0rm-dictionary.txt
                  #rm -rf ~/HackingTools/MultiDict/Internet/SecLists/Passwords/Leaked-Databases/fortinet-2021.txt
                  #rm -rf ~/HackingTools/MultiDict/Internet/SecLists/Passwords/Leaked-Databases/honeynet-withcount.txt
                  #rm -rf ~/HackingTools/MultiDict/Internet/SecLists/Passwords/Leaked-Databases/honeynet2.txt
                  #rm -rf ~/HackingTools/MultiDict/Internet/SecLists/Passwords/Leaked-Databases/honeynet.txt
                  #rm -rf ~/HackingTools/MultiDict/Internet/SecLists/Passwords/Leaked-Databases/myspace-withcount.txt
                  #rm -rf ~/HackingTools/MultiDict/Internet/SecLists/Passwords/Honeypot-Captures/python-heralding-sep2019.txt
                  #rm -rf ~/HackingTools/MultiDict/Internet/SecLists/Passwords/Common-Credentials/10-million-password-list-top-100.txt
                  #rm -rf ~/HackingTools/MultiDict/Internet/SecLists/Passwords/Common-Credentials/Language-Specific/Spanish_common-usernames-and-passwords.txt
                  #rm -rf ~/HackingTools/MultiDict/Internet/SecLists/Passwords/Common-Credentials/10-million-password-list-top-100000.txt
                  #rm -rf ~/HackingTools/MultiDict/Internet/SecLists/Usernames/Honeypot-Captures/multiplesources-users-fabian-fingerle.de.txt
                  #rm -rf ~/HackingTools/MultiDict/Internet/SecLists/Miscellaneous/control-chars.txt
                  #rm -rf ~/HackingTools/MultiDict/Internet/SecLists/Miscellaneous/Moby-Project/Moby-Language-II/german.txt
                  #rm -rf ~/HackingTools/MultiDict/Internet/SecLists/Miscellaneous/Moby-Project/Moby-Language-II/japanese.txt
                  #rm -rf ~/HackingTools/MultiDict/Internet/CSL-LABS/ROCKYOU-CSL.txt
                  #rm -rf ~/HackingTools/MultiDict/Internet/CSL-LABS/misc/sports.txt
                  #rm -rf ~/HackingTools/MultiDict/Internet/CSL-LABS/misc/top_songs.txt

            ;;

            3)

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
                rm -rf ~/HackingTools/MultiDict/Internet/CSL-LABS/ 2> /dev/null
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/MultiDict/Internet/ 2> /dev/null
              # Mover carpeta
                mv /tmp/CrackingWordLists/dics/ ~/HackingTools/MultiDict/Internet/CSL-LABS/
              #
                cd ~/HackingTools/MultiDict/Internet/CSL-LABS/
                tar -xvzf ROCKYOU-CSL.tar.gz
                rm -f ROCKYOU-CSL.tar.gz
                find ~/HackingTools/MultiDict/Internet/CSL-LABS/ -type f -name "*.dic" -exec bash -c 'mv "$0" "${0%.dic}.txt"' {} \;

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

