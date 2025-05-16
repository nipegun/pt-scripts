#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para instalar la máxima cantidad posible de WordLists en texto plano en Debian
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Diccionarios/MultiDict-WordLists-Instalar.sh | bash
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Diccionarios/MultiDict-WordLists-Instalar.sh | sed 's-sudo--g' | bash
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Diccionarios/MultiDict-WordLists-Instalar.sh | nano -
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
      1 "  Instalar Diccionarios de Debian"                       on
      2 "  Descargar diccionarios de SecLists"                    on
      3 "  Descargar diccionarios de CSL-LABS"                    on
      4 "  Descargar diccionarios de CrackStation"                on
      5 "  Descargar WeakPass 4a"                                 on
      6 "  Reservado"                                             off
      7 "    Eliminar caracteres de tabulación"                   on
      8 "      Preparar diccionarios de caracteres incrementales" on
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
              # 
              sudo apt-get -y --reinstall install cracklib-runtime
              sudo apt-get -y --reinstall install miscfiles
              sudo apt-get -y --reinstall install wamerican
              sudo apt-get -y --reinstall install wamerican-huge
              sudo apt-get -y --reinstall install wamerican-insane
              sudo apt-get -y --reinstall install wamerican-large
              sudo apt-get -y --reinstall install wamerican-small
              sudo apt-get -y --reinstall install wbrazilian
              sudo apt-get -y --reinstall install wbritish
              sudo apt-get -y --reinstall install wbritish-huge
              sudo apt-get -y --reinstall install wbritish-insane
              sudo apt-get -y --reinstall install wbritish-large
              sudo apt-get -y --reinstall install wbritish-small
              sudo apt-get -y --reinstall install wbulgarian
              sudo apt-get -y --reinstall install wcanadian
              sudo apt-get -y --reinstall install wcanadian-huge
              sudo apt-get -y --reinstall install wcanadian-insane
              sudo apt-get -y --reinstall install wcanadian-large
              sudo apt-get -y --reinstall install wcanadian-small
              sudo apt-get -y --reinstall install wcatalan
              sudo apt-get -y --reinstall install wdanish
              sudo apt-get -y --reinstall install wdutch
              sudo apt-get -y --reinstall install wesperanto
              sudo apt-get -y --reinstall install wfaroese
              sudo apt-get -y --reinstall install wfrench
              sudo apt-get -y --reinstall install wgalician-minimos
              sudo apt-get -y --reinstall install wgerman-medical
              sudo apt-get -y --reinstall install wirish
              sudo apt-get -y --reinstall install witalian
              sudo apt-get -y --reinstall install wmanx
              sudo apt-get -y --reinstall install wngerman
              sudo apt-get -y --reinstall install wnorwegian
              sudo apt-get -y --reinstall install wogerman
              sudo apt-get -y --reinstall install wpolish
              sudo apt-get -y --reinstall install wportuguese
              sudo apt-get -y --reinstall install wspanish
              sudo apt-get -y --reinstall install wswedish
              sudo apt-get -y --reinstall install wswiss
              sudo apt-get -y --reinstall install wukrainian
              sudo apt-get -y --reinstall install scowl
              cd /usr/share/dict/
              sudo gzip -v -f -d -k connectives.gz
              sudo gzip -v -f -d -k propernames.gz
              sudo gzip -v -f -d -k web2a.gz
              # Borrar la carpeta vieja
                rm -rf ~/HackingTools/MultiDict/WordLists/Packs/Debian/ 2> /dev/null
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/MultiDict/WordLists/Packs/Debian/ 2> /dev/null
              # Copiar diccionarios a la carpeta Debian
                mkdir -p ~/HackingTools/MultiDict/WordLists/Packs/Debian/scowl/
                cp -fv /usr/share/dict/scowl/*                 ~/HackingTools/MultiDict/WordLists/Packs/Debian/scowl/
                cp -fv /usr/share/dict/american-english        ~/HackingTools/MultiDict/WordLists/Packs/Debian/
                cp -fv /usr/share/dict/american-english-huge   ~/HackingTools/MultiDict/WordLists/Packs/Debian/
                cp -fv /usr/share/dict/american-english-insane ~/HackingTools/MultiDict/WordLists/Packs/Debian/
                cp -fv /usr/share/dict/american-english-large  ~/HackingTools/MultiDict/WordLists/Packs/Debian/
                cp -fv /usr/share/dict/american-english-small  ~/HackingTools/MultiDict/WordLists/Packs/Debian/
                cp -fv /usr/share/dict/bokmaal                 ~/HackingTools/MultiDict/WordLists/Packs/Debian/
                cp -fv /usr/share/dict/brazilian               ~/HackingTools/MultiDict/WordLists/Packs/Debian/
                cp -fv /usr/share/dict/british-english-huge    ~/HackingTools/MultiDict/WordLists/Packs/Debian/
                cp -fv /usr/share/dict/british-english-insane  ~/HackingTools/MultiDict/WordLists/Packs/Debian/
                cp -fv /usr/share/dict/british-english-large   ~/HackingTools/MultiDict/WordLists/Packs/Debian/
                cp -fv /usr/share/dict/british-english-small   ~/HackingTools/MultiDict/WordLists/Packs/Debian/
                cp -fv /usr/share/dict/bulgarian               ~/HackingTools/MultiDict/WordLists/Packs/Debian/
                cp -fv /usr/share/dict/canadian-english        ~/HackingTools/MultiDict/WordLists/Packs/Debian/
                cp -fv /usr/share/dict/canadian-english-huge   ~/HackingTools/MultiDict/WordLists/Packs/Debian/
                cp -fv /usr/share/dict/canadian-english-insane ~/HackingTools/MultiDict/WordLists/Packs/Debian/
                cp -fv /usr/share/dict/canadian-english-large  ~/HackingTools/MultiDict/WordLists/Packs/Debian/
                cp -fv /usr/share/dict/canadian-english-small  ~/HackingTools/MultiDict/WordLists/Packs/Debian/
                cp -fv /usr/share/dict/catalan                 ~/HackingTools/MultiDict/WordLists/Packs/Debian/
                cp -fv /usr/share/dict/connectives             ~/HackingTools/MultiDict/WordLists/Packs/Debian/
                cp -fv /usr/share/dict/cracklib-small          ~/HackingTools/MultiDict/WordLists/Packs/Debian/
                cp -fv /usr/share/dict/danish                  ~/HackingTools/MultiDict/WordLists/Packs/Debian/
                cp -fv /usr/share/dict/dutch                   ~/HackingTools/MultiDict/WordLists/Packs/Debian/
                cp -fv /usr/share/dict/esperanto               ~/HackingTools/MultiDict/WordLists/Packs/Debian/
                cp -fv /usr/share/dict/faroese                 ~/HackingTools/MultiDict/WordLists/Packs/Debian/
                cp -fv /usr/share/dict/french                  ~/HackingTools/MultiDict/WordLists/Packs/Debian/
                cp -fv /usr/share/dict/galician-minimos        ~/HackingTools/MultiDict/WordLists/Packs/Debian/
                cp -fv /usr/share/dict/german-medical          ~/HackingTools/MultiDict/WordLists/Packs/Debian/
                cp -fv /usr/share/dict/irish                   ~/HackingTools/MultiDict/WordLists/Packs/Debian/
                cp -fv /usr/share/dict/italian                 ~/HackingTools/MultiDict/WordLists/Packs/Debian/
                cp -fv /usr/share/dict/manx                    ~/HackingTools/MultiDict/WordLists/Packs/Debian/
                cp -fv /usr/share/dict/ngerman                 ~/HackingTools/MultiDict/WordLists/Packs/Debian/
                cp -fv /etc/dictionaries-common/norsk          ~/HackingTools/MultiDict/WordLists/Packs/Debian/
                cp -fv /usr/share/dict/nynorsk                 ~/HackingTools/MultiDict/WordLists/Packs/Debian/
                cp -fv /usr/share/dict/ogerman                 ~/HackingTools/MultiDict/WordLists/Packs/Debian/
                cp -fv /usr/share/dict/polish                  ~/HackingTools/MultiDict/WordLists/Packs/Debian/
                cp -fv /usr/share/dict/portuguese              ~/HackingTools/MultiDict/WordLists/Packs/Debian/
                cp -fv /usr/share/dict/propernames             ~/HackingTools/MultiDict/WordLists/Packs/Debian/
                cp -fv /usr/share/dict/spanish                 ~/HackingTools/MultiDict/WordLists/Packs/Debian/
                cp -fv /usr/share/dict/swedish                 ~/HackingTools/MultiDict/WordLists/Packs/Debian/
                cp -fv /usr/share/dict/swiss                   ~/HackingTools/MultiDict/WordLists/Packs/Debian/
                cp -fv /usr/share/dict/ukrainian               ~/HackingTools/MultiDict/WordLists/Packs/Debian/
                cp -fv /usr/share/dict/web2                    ~/HackingTools/MultiDict/WordLists/Packs/Debian/
                cp -fv /usr/share/dict/web2a                   ~/HackingTools/MultiDict/WordLists/Packs/Debian/
                cp -fv /etc/dictionaries-common/words          ~/HackingTools/MultiDict/WordLists/Packs/Debian/

            ;;

            2)

              echo ""
              echo "  Descargando diccionarios de SecLists..."
              echo ""
              # Borrar la carpeta vieja
                rm -rf ~/HackingTools/MultiDict/WordLists/Packs/SecLists/ 2> /dev/null
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/MultiDict/WordLists/Packs/ 2> /dev/null
              # Posicionarse en la carpeta
                cd ~/HackingTools/MultiDict/WordLists/Packs/
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
                  rm -f ~/HackingTools/MultiDict/WordLists/Packs/SecLists/SecLists.png
                  rm -f ~/HackingTools/MultiDict/WordLists/Packs/SecLists/LICENSE
                  rm -f ~/HackingTools/MultiDict/WordLists/Packs/SecLists/CONTRIBUTORS.md
                  rm -f ~/HackingTools/MultiDict/WordLists/Packs/SecLists/CONTRIBUTING.md
                # Archivos README.md
                  find ~/HackingTools/MultiDict/WordLists/Packs/SecLists/ -type f -name README.md -exec rm -f {} \;
                  rm -f ~/HackingTools/MultiDict/WordLists/Packs/SecLists/Discovery/Infrastructure/IPGenerator.sh
                # Archivos de inteligencia artificial
                  rm -rf ~/HackingTools/MultiDict/WordLists/Packs/SecLists/Ai 2> /dev/null
                  rm -rf ~/HackingTools/MultiDict/WordLists/Packs/SecLists/Ai 2> /dev/null

              # Descomprimir archivos comprimidos
                cd ~/HackingTools/MultiDict/WordLists/Packs/SecLists/Passwords/
                bzip2 -d "500-worst-passwords.txt.bz2"
                tar -xvzf "SCRABBLE-hackerhouse.tgz"
                rm "SCRABBLE-hackerhouse.tgz"
                rm -rf ~/HackingTools/MultiDict/WordLists/Packs/SecLists/Passwords/SCRABBLE/fetch.sh
                rm -rf ~/HackingTools/MultiDict/WordLists/Packs/SecLists/Passwords/SCRABBLE/mangle.py
                rm -rf ~/HackingTools/MultiDict/WordLists/Packs/SecLists/Passwords/Default-Credentials/scada-pass.csv
                rm -rf ~/HackingTools/MultiDict/WordLists/Packs/SecLists/Passwords/Default-Credentials/default-passwords.csv
                rm -rf ~/HackingTools/MultiDict/WordLists/Packs/SecLists/Pattern-Matching/grepstrings-auditing-php.md
                rm -rf ~/HackingTools/MultiDict/WordLists/Packs/SecLists/Payloads/
                rm -rf ~/HackingTools/MultiDict/WordLists/Packs/SecLists/Web-Shells/
                rm -rf ~/HackingTools/MultiDict/WordLists/Packs/SecLists/Fuzzing/
                # No convierten bien a UTF8
                  #rm -rf ~/HackingTools/MultiDict/WordLists/Packs/SecLists/Discovery/DNS/FUZZSUBS_CYFARE_2.txt
                  #rm -rf ~/HackingTools/MultiDict/WordLists/Packs/SecLists/Discovery/Web-Content/raft-large-files-lowercase.txt
                  #rm -rf ~/HackingTools/MultiDict/WordLists/Packs/SecLists/Discovery/Web-Content/trickest-robots-disallowed-wordlists/top-10000.txt
                  #rm -rf ~/HackingTools/MultiDict/WordLists/Packs/SecLists/Discovery/Web-Content/raft-large-files.txt
                  #rm -rf ~/HackingTools/MultiDict/WordLists/Packs/SecLists/Discovery/Web-Content/combined_words.txt
                  #rm -rf ~/HackingTools/MultiDict/WordLists/Packs/SecLists/Discovery/Web-Content/CMS/trickest-cms-wordlist/dolibarr.txt
                  #rm -rf ~/HackingTools/MultiDict/WordLists/Packs/SecLists/Discovery/Web-Content/CMS/trickest-cms-wordlist/dolibarr-all-levels.txt
                  #rm -rf ~/HackingTools/MultiDict/WordLists/Packs/SecLists/Discovery/Web-Content/CMS/Django.txt
                  #rm -rf ~/HackingTools/MultiDict/WordLists/Packs/SecLists/Discovery/Web-Content/raft-large-directories.txt
                  #rm -rf ~/HackingTools/MultiDict/WordLists/Packs/SecLists/Discovery/Web-Content/raft-small-directories.txt
                  #rm -rf ~/HackingTools/MultiDict/WordLists/Packs/SecLists/Discovery/Web-Content/raft-medium-directories.txt
                  #rm -rf ~/HackingTools/MultiDict/WordLists/Packs/SecLists/Passwords/dutch_passwordlist.txt
                  #rm -rf ~/HackingTools/MultiDict/WordLists/Packs/SecLists/Passwords/Cracked-Hashes/milw0rm-dictionary.txt
                  #rm -rf ~/HackingTools/MultiDict/WordLists/Packs/SecLists/Passwords/Leaked-Databases/fortinet-2021.txt
                  #rm -rf ~/HackingTools/MultiDict/WordLists/Packs/SecLists/Passwords/Leaked-Databases/honeynet-withcount.txt
                  #rm -rf ~/HackingTools/MultiDict/WordLists/Packs/SecLists/Passwords/Leaked-Databases/honeynet2.txt
                  #rm -rf ~/HackingTools/MultiDict/WordLists/Packs/SecLists/Passwords/Leaked-Databases/honeynet.txt
                  #rm -rf ~/HackingTools/MultiDict/WordLists/Packs/SecLists/Passwords/Leaked-Databases/myspace-withcount.txt
                  #rm -rf ~/HackingTools/MultiDict/WordLists/Packs/SecLists/Passwords/Honeypot-Captures/python-heralding-sep2019.txt
                  #rm -rf ~/HackingTools/MultiDict/WordLists/Packs/SecLists/Passwords/Common-Credentials/10-million-password-list-top-100.txt
                  #rm -rf ~/HackingTools/MultiDict/WordLists/Packs/SecLists/Passwords/Common-Credentials/Language-Specific/Spanish_common-usernames-and-passwords.txt
                  #rm -rf ~/HackingTools/MultiDict/WordLists/Packs/SecLists/Passwords/Common-Credentials/10-million-password-list-top-100000.txt
                  #rm -rf ~/HackingTools/MultiDict/WordLists/Packs/SecLists/Usernames/Honeypot-Captures/multiplesources-users-fabian-fingerle.de.txt
                  #rm -rf ~/HackingTools/MultiDict/WordLists/Packs/SecLists/Miscellaneous/control-chars.txt
                  #rm -rf ~/HackingTools/MultiDict/WordLists/Packs/SecLists/Miscellaneous/Moby-Project/Moby-Language-II/german.txt
                  #rm -rf ~/HackingTools/MultiDict/WordLists/Packs/SecLists/Miscellaneous/Moby-Project/Moby-Language-II/japanese.txt
                  #rm -rf ~/HackingTools/MultiDict/WordLists/Packs/CSL-LABS/ROCKYOU-CSL.txt
                  #rm -rf ~/HackingTools/MultiDict/WordLists/Packs/CSL-LABS/misc/sports.txt
                  #rm -rf ~/HackingTools/MultiDict/WordLists/Packs/CSL-LABS/misc/top_songs.txt

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
                rm -rf ~/HackingTools/MultiDict/WordLists/Packs/CSL-LABS/ 2> /dev/null
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/MultiDict/WordLists/Packs/ 2> /dev/null
              # Mover carpeta
                mv /tmp/CrackingWordLists/dics/ ~/HackingTools/MultiDict/WordLists/Packs/CSL-LABS/
              #
                cd ~/HackingTools/MultiDict/WordLists/Packs/CSL-LABS/
                tar -xvzf ROCKYOU-CSL.tar.gz
                rm -f ROCKYOU-CSL.tar.gz
                find ~/HackingTools/MultiDict/WordLists/Packs/CSL-LABS/ -type f -name "*.dic" -exec bash -c 'mv "$0" "${0%.dic}.txt"' {} \;

            ;;

            4)

              echo ""
              echo "  Descargando diccionarios de CrackStation..."
              echo ""
              curl -L https://crackstation.net/files/crackstation.txt.gz -o /tmp/crackstation.txt.gz
              cd /tmp/
              gunzip -v /tmp/crackstation.txt.gz
              mkdir -p ~/HackingTools/MultiDict/WordLists/Packs/CrackStation/ 2> /dev/null
              mv /tmp/crackstation.txt ~/HackingTools/MultiDict/WordLists/Packs/CrackStation/

            ;;

            5)

              echo ""
              echo "  Descargando diccionario WeakPass 4a..."
              echo ""
              # Comprobar si el paquete p7zip-full está instalado. Si no lo está, instalarlo.
                if [[ $(dpkg-query -s p7zip-full 2>/dev/null | grep installed) == "" ]]; then
                  echo ""
                  echo -e "${cColorRojo}  El paquete p7zip-full no está instalado. Iniciando su instalación...${cFinColor}"
                  echo ""
                  sudo apt-get -y update
                  sudo apt-get -y install p7zip-full
                  echo ""
                fi
              curl -L https://weakpass.com/download/2015/weakpass_4a.txt.7z -o /tmp/weakpass_4a.txt.7z
              mkdir -p ~/HackingTools/MultiDict/WordLists/Packs/WeakPass4a/ 2> /dev/null
              7z x /tmp/weakpass_4a.txt.7z -o~/HackingTools/MultiDict/WordLists/Packs/WeakPass4a/ # No hay que dejar espacio entre -o y la ruta del directorio

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

              vCarpetaInicio="$HOME/HackingTools/MultiDict/Packs/"
              find "$vCarpetaInicio" -type f -name "*.txt" -print0 | while IFS= read -r -d '' vArchivo; do
                sed -i 's/\t//g' "$vArchivo"
              done

            ;;

            8)

              echo ""
              echo "  Preparando diccionarios de caracteres incrementales..."
              echo "  Dependiendo de la capacidad de proceso del sistema, puede tardar más de 10 minutos."
              echo ""

              # Crear diccionarios
                export LC_ALL=C.UTF-8  # Forzar UTF-8 para evitar problemas de codificación

                vCarpetaInicio="$HOME/HackingTools/MultiDict/Packs/"
                vCarpetaDestino="$HOME/HackingTools/MultiDict/PorCantCaracteres/"
                rm "$vCarpetaDestino"* 2> /dev/null

                mkdir -p "$vCarpetaDestino"
                cd "$vCarpetaDestino" || exit 1

                vCaracteresMin=1
                vCaracteresMax=64

              # Crear los archivos
                for ((i=vCaracteresMin; i<=vCaracteresMax; i++)); do
                  > "All${i}Characters.txt"
                done

              # Popular los archivos
                find "$vCarpetaInicio" -type f -name "*.txt" -print0 | while IFS= read -r -d '' file; do
                  iconv -c -f UTF-8 -t UTF-8 "$file" | awk -v min="$vCaracteresMin" -v max="$vCaracteresMax" '
                  {
                    len = length($0);
                    if (len >= min && len <= max)
                      print $0 >> ("All" len "Characters.txt");
                  }'
                done

              # Eliminar caracteres no imprimibles de todos los archivos y sanitizar algunas líneas
                for vArchivo in ~/HackingTools/MultiDict/WordLists/PorCantCaracteres/*.txt; do
                  sed -e 's/^[[:space:]]*//' "$vArchivo" | grep -a -P '^[\x20-\x7E]+$' > "$vArchivo.tmp"
                  mv -f "$vArchivo.tmp" "$vArchivo"
                done

              # Ordenar y eliminar líneas duplicadas
                find "$vCarpetaDestino" -type f -name "*.txt" | while read -r vArchivo; do
                  sort "$vArchivo" | uniq > "$vArchivo.tmp" && mv "$vArchivo.tmp" "$vArchivo"
                done
                echo ""

              # Asegurarse de que cada arhivo tenga la cantidad correcta de caracteres por linea
                for vArchivo in ~/HackingTools/MultiDict/WordLists/PorCantCaracteres/All*Characters.txt; do
                  vCantidad=$(basename "$vArchivo" | sed -E 's/All([0-9]+)Characters\.txt/\1/')
                  grep -E "^.{$vCantidad}$" "$vArchivo" > "$vArchivo.tmp"
                  mv -f "$vArchivo.tmp" "$vArchivo"
                done

              # Corregir nombres de los archivos con un sólo número
                mv ~/HackingTools/MultiDict/WordLists/PorCantCaracteres/All1Characters.txt ~/HackingTools/MultiDict/WordLists/PorCantCaracteres/All01Characters.txt
                mv ~/HackingTools/MultiDict/WordLists/PorCantCaracteres/All2Characters.txt ~/HackingTools/MultiDict/WordLists/PorCantCaracteres/All02Characters.txt
                mv ~/HackingTools/MultiDict/WordLists/PorCantCaracteres/All3Characters.txt ~/HackingTools/MultiDict/WordLists/PorCantCaracteres/All03Characters.txt
                mv ~/HackingTools/MultiDict/WordLists/PorCantCaracteres/All4Characters.txt ~/HackingTools/MultiDict/WordLists/PorCantCaracteres/All04Characters.txt
                mv ~/HackingTools/MultiDict/WordLists/PorCantCaracteres/All5Characters.txt ~/HackingTools/MultiDict/WordLists/PorCantCaracteres/All05Characters.txt
                mv ~/HackingTools/MultiDict/WordLists/PorCantCaracteres/All6Characters.txt ~/HackingTools/MultiDict/WordLists/PorCantCaracteres/All06Characters.txt
                mv ~/HackingTools/MultiDict/WordLists/PorCantCaracteres/All7Characters.txt ~/HackingTools/MultiDict/WordLists/PorCantCaracteres/All07Characters.txt
                mv ~/HackingTools/MultiDict/WordLists/PorCantCaracteres/All8Characters.txt ~/HackingTools/MultiDict/WordLists/PorCantCaracteres/All08Characters.txt
                mv ~/HackingTools/MultiDict/WordLists/PorCantCaracteres/All9Characters.txt ~/HackingTools/MultiDict/WordLists/PorCantCaracteres/All09Characters.txt

              # Notificar fin de la ejecución
                echo ""
                echo "  Se han procesado todos los .txt de $vCarpetaInicio y se han creado nuevos diccionarios con su contenido."
                echo "  Puedes encontrar los nuevos diccionarios en $vCarpetaDestino"
                echo ""

            ;;

        esac

    done

