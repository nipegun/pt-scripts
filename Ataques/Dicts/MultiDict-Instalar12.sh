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
      1 "Preparar la carpeta ~/MultiDict"                  on
      2 "  Descargar diccionarios de SecLists"             off
      3 "  Descargar diccionarios de CSL-LABS"             off
      4 "    Convertir todos los archivos a UTF8"          off
      5 "      Preparar diccionarios de 1 a 16 caracteres" off
    )
    choices=$("${menu[@]}" "${opciones[@]}" 2>&1 >/dev/tty)

      for choice in $choices
        do
          case $choice in

            1)

              echo ""
              echo "  Preparando la carpeta ~/MultiDict..."
              echo ""
              # Crearla
                mkdir -p ~/MultiDict/Internet/ 2> /dev/null

            ;;

            2)

              echo ""
              echo "  Descargando diccionarios de SecLists..."
              echo ""
              # Borrar la carpeta vieja
                rm -rf ~/MultiDict/Internet/SecLists/
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
    
                rm -rf ~/MultiDict/Internet/SecLists/Ai 2> /dev/null
                rm -rf ~/MultiDict/Internet/SecLists/Ai 2> /dev/null

              # Descomprimir archivos comprimidos
                cd ~/MultiDict/Internet/SecLists/Passwords/
                bzip2 -d "500-worst-passwords.txt.bz2"
                tar -xvzf "SCRABBLE-hackerhouse.tgz"
                rm "SCRABBLE-hackerhouse.tgz"
                rm -rf  ~/MultiDict/Internet/SecLists/Passwords/SCRABBLE/fetch.sh
                rm -rf  ~/MultiDict/Internet/SecLists/Passwords/SCRABBLE/mangle.py
                rm -rf  ~/MultiDict/Internet/SecLists/Passwords/Default-Credentials/scada-pass.csv
                rm -rf  ~/MultiDict/Internet/SecLists/Passwords/Default-Credentials/default-passwords.csv
                rm -rf  ~/MultiDict/Internet/SecLists/Pattern-Matching/grepstrings-auditing-php.md
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
                rm -rf ~/MultiDict/Internet/CSL-LABS/ 2> /dev/null
                mv /tmp/CrackingWordLists/dics/ ~/MultiDict/Internet/CSL-LABS/
                cd ~/MultiDict/Internet/CSL-LABS/
                tar -xvzf ROCKYOU-CSL.tar.gz
                rm -f ROCKYOU-CSL.tar.gz
                find ~/MultiDict/Internet/CSL-LABS/ -type f -name "*.dic" -exec bash -c 'mv "$0" "${0%.dic}.txt"' {} \;

            ;;

            4)

              echo ""
              echo "  Convirtiendo todos los archivos a UTF8..."
              echo ""

              # Directorio de origen (se puede modificar o pasar como argumento)
              DIRECTORIO="$HOME/MultiDict/Internet/"

              # Detectar la codificación y convertir a UTF-8
              convertir_a_utf8() {
                local archivo="$1"
                local codificacion

                # Obtener la codificación del archivo
                codificacion=$(file -i "$archivo" | awk -F'charset=' '{print $2}')

                # Si la codificación ya es UTF-8, no hacer nada
                if [[ "$codificacion" == "utf-8" ]]; then
                  return
                fi

                # Intentar convertir a UTF-8
                iconv -f "$codificacion" -t UTF-8 "$archivo" -o "$archivo.converted"

                # Si la conversión fue exitosa, reemplazar el archivo original
                if [[ $? -eq 0 ]]; then
                  mv "$archivo.converted" "$archivo"
                else
                  echo "❌ Error en la conversión de $archivo"
                  rm -f "$archivo.converted"
                fi
              }

              export -f convertir_a_utf8

              # Buscar todos los archivos .txt en la carpeta y subcarpetas
              find "$DIRECTORIO" -type f -name "*.txt" -print0 | xargs -0 -I {} bash -c 'convertir_a_utf8 "$@"' _ {}

              echo "🎉 Conversión completada."

            ;;

            5)

              echo ""
              echo "  Preparando diccionarios con listas de 1 a 16 caracteres..."
              echo ""

              # Crear diccionarios
                export LC_ALL=C.UTF-8  # Forzar UTF-8 para evitar problemas de codificación

                vCarpetaInicio="$HOME/MultiDict/Internet/"
                vCarpetaDestino="$HOME/MultiDict/PorCantCaracteres/"
                rm "$vCarpetaDestino"/*

                mkdir -p "$vCarpetaDestino"
                cd "$vCarpetaDestino" || exit 1

                vCaracteresMin=1
                vCaracteresMax=16

                for ((i=vCaracteresMin; i<=vCaracteresMax; i++)); do
                  > "All${i}Characters.txt"
                done

                find "$vCarpetaInicio" -type f -name "*.txt" -print0 | xargs -0 awk -c -v min="$vCaracteresMin" -v max="$vCaracteresMax" '
                {
                  len = length($0);
                  if (len >= min && len <= max)
                    print $0 >> ("All" len "Characters.txt");
                }
                '

                echo "Procesamiento completado."

              # Buscar y procesar cada archivo .txt en la carpeta y subcarpetas
              find "$vCarpetaDestino" -type f -name "*.txt" | while read -r vArchivo; do
                sort "$vArchivo" | uniq > "$vArchivo.tmp" && mv "$vArchivo.tmp" "$vArchivo"
              done

            ;;

        esac

    done

