#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para instalar la máxima cantidad posible de WordLists en texto plano en Debian
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/WordLists/PreCalculadas-Instalar.sh | bash
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/WordLists/PreCalculadas-Instalar.sh | sed 's-sudo--g' | bash
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/WordLists/PreCalculadas-Instalar.sh | nano -
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
  menu=(dialog --checklist "Marca las WordLists PreCalculadas que quieras instalar:" 22 96 16)
    opciones=(
      1 "  WeakPass RockYou MD5"            off
      2 "  WeakPass RockYou NTLM"           off
      3 "  WeakPass RockYou SHA1"           off
      4 "  WeakPass RockYou SHA256 NTLM"    off
      5 "  WeakPass RockYou SHA256"         off

      6 "  WeakPass 4 Latin MD5"            off
      7 "  WeakPass 4 Latin NTLM"           off
      8 "  WeakPass 4 Latin SHA1"           off
      9 "  WeakPass 4 Latin SHA256 NTLM"    off
     10 "  WeakPass 4 Latin SHA256"         off

     11 "  WeakPass 4 Merged MD5"           off
     12 "  WeakPass 4 Merged NTLM"          off
     13 "  WeakPass 4 Merged SHA1"          off
     14 "  WeakPass 4 Merged SHA256 NTLM"   off
     15 "  WeakPass 4 Merged SHA256"        off

     16 "  WeakPass 4 Policy MD5"           off
     17 "  WeakPass 4 Policy NTLM"          off
     18 "  WeakPass 4 Policy SHA1"          off
     19 "  WeakPass 4 Policy SHA256 NTLM"   off
     21 "  WeakPass 4 Policy SHA256"        off

     22 "  WeakPass 4a Latin MD5"           off
     23 "  WeakPass 4a Latin NTLM"          off
     24 "  WeakPass 4a Latin SHA1"          off
     25 "  WeakPass 4a Latin SHA256 NTLM"   off
     26 "  WeakPass 4a Latin SHA256"        off

     27 "  WeakPass 4a Policy MD5"          off
     28 "  WeakPass 4a Policy NTLM"         off
     29 "  WeakPass 4a Policy SHA1"         off
     30 "  WeakPass 4a Policy SHA256 NTLM"  off
     31 "  WeakPass 4a Policy SHA256"       off

     32 "  WeakPass All in One Policy MD5"  off
     33 "  WeakPass All in One Policy NTLM" off
     34 "  WeakPass All in One Policy SHA1" off
      
     35 "  WeakPass All in One Latin NTLM"  off
     36 "  WeakPass All in One Latin MD5"   off

      6 "  Reservado"                                          off
      7 "    Eliminar caracteres de tabulación"                on
      8 "      Preparar WordLists de caracteres incrementales" on
    )
    choices=$("${menu[@]}" "${opciones[@]}" 2>&1 >/dev/tty)

      for choice in $choices
        do
          case $choice in

            1)

              echo ""
              echo "  Instalando WordList WeakPass RockYou MD5..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/RockYou/ 2> /dev/null

            ;;

            2)

              echo ""
              echo "  Instalando WordList WeakPass RockYou NTLM..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/RockYou/ 2> /dev/null

            ;;

            3)

              echo ""
              echo "  Instalando WordList WeakPass RockYou SHA1..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/RockYou/ 2> /dev/null

            ;;

            4)

              echo ""
              echo "  Instalando WordList WeakPass RockYou SHA256 NTLM..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/RockYou/ 2> /dev/null

            ;;

            5)

              echo ""
              echo "  Instalando WordList WeakPass RockYou SHA256..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/RockYou/ 2> /dev/null

            ;;

            6)

              echo ""
              echo "  Instalando WordList WeakPass 4 Latin MD5..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4Latin/ 2> /dev/null

            ;;

            7)

              echo ""
              echo "  Instalando WordList WeakPass 4 Latin NTLM..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4Latin/ 2> /dev/null

            ;;

            8)

              echo ""
              echo "  Instalando WordList WeakPass 4 Latin SHA1..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4Latin/ 2> /dev/null

            ;;

            9)

              echo ""
              echo "  Instalando WordList WeakPass 4 Latin SHA256 NTLM..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4Latin/ 2> /dev/null

            ;;

           10)

              echo ""
              echo "  Instalando WordList WeakPass 4 Latin SHA256..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4Latin/ 2> /dev/null

            ;;

           11)

              echo ""
              echo "  Instalando WordList WeakPass 4 Merged MD5..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4Merged/ 2> /dev/null

            ;;

           12)

              echo ""
              echo "  Instalando WordList WeakPass 4 Merged NTLM..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4Merged/ 2> /dev/null

            ;;

           13)

              echo ""
              echo "  Instalando WordList WeakPass 4 Merged SHA1..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4Merged/ 2> /dev/null

            ;;

           14)

              echo ""
              echo "  Instalando WordList WeakPass 4 Merged SHA256 NTLM..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4Merged/ 2> /dev/null

            ;;

           15)

              echo ""
              echo "  Instalando WordList WeakPass 4 Merged SHA256..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4Merged/ 2> /dev/null

            ;;

           16)

              echo ""
              echo "  Instalando WordList WeakPass 4 Policy MD5..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4Policy/ 2> /dev/null

            ;;

           17)

              echo ""
              echo "  Instalando WordList WeakPass 4 Policy NTLM..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4Policy/ 2> /dev/null

            ;;

           18)

              echo ""
              echo "  Instalando WordList WeakPass 4 Policy SHA1..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4Policy/ 2> /dev/null

            ;;

           19)

              echo ""
              echo "  Instalando WordList WeakPass 4 Policy SHA256 NTLM..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4Policy/ 2> /dev/null

            ;;

           21)

              echo ""
              echo "  Instalando WordList WeakPass 4 Policy SHA256..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4Policy/ 2> /dev/null

            ;;

           22)

              echo ""
              echo "  Instalando WordList WeakPass 4a Latin MD5..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4aLatin/ 2> /dev/null

            ;;

           23)

              echo ""
              echo "  Instalando WordList WeakPass 4a Latin NTLM..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4aLatin/ 2> /dev/null

            ;;

           24)

              echo ""
              echo "  Instalando WordList WeakPass 4a Latin SHA1..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4aLatin/ 2> /dev/null

            ;;

           25)

              echo ""
              echo "  Instalando WordList WeakPass 4a Latin SHA256 NTLM..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4aLatin/ 2> /dev/null

            ;;

           26)

              echo ""
              echo "  Instalando WordList WeakPass 4a Latin SHA256..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4aLatin/ 2> /dev/null

            ;;

           27)

              echo ""
              echo "  Instalando WordList WeakPass 4a Policy MD5..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4aPolicy/ 2> /dev/null

            ;;

           28)

              echo ""
              echo "  Instalando WordList WeakPass 4a Policy NTLM..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4aPolicy/ 2> /dev/null

            ;;

           29)

              echo ""
              echo "  Instalando WordList WeakPass 4a Policy SHA1..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4aPolicy/ 2> /dev/null

            ;;

           30)

              echo ""
              echo "  Instalando WordList WeakPass 4a Policy SHA256 NTLM..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4aPolicy/ 2> /dev/null

            ;;

           31)

              echo ""
              echo "  Instalando WordList WeakPass 4a Policy SHA256..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4aPolicy/ 2> /dev/null

            ;;

           32)

              echo ""
              echo "  Instalando WordList WeakPass All in One Policy MD5..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/AiOPolicy/ 2> /dev/null

            ;;

           33)

              echo ""
              echo "  Instalando WordList WeakPass All in One Policy NTLM..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/AiOPolicy/ 2> /dev/null

            ;;

           34)

              echo ""
              echo "  Instalando WordList WeakPass All in One Policy SHA1..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/AiOPolicy/ 2> /dev/null

            ;;

           35)

              echo ""
              echo "  Instalando WordList WeakPass All in One Latin NTLM..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/AiOLatin/ 2> /dev/null

            ;;

           36)

              echo ""
              echo "  Instalando WordList WeakPass All in One Latin MD5..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/AiOLatin/ 2> /dev/null

            ;;














            1)

              echo ""
              echo "  Instalando WordList s de Debian..."
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
                rm -rf ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/ 2> /dev/null
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/ 2> /dev/null
              # Copiar WordLists a la carpeta Debian
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/scowl/
                cp -fv /usr/share/dict/scowl/*                 ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/scowl/
                cp -fv /usr/share/dict/american-english        ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/
                cp -fv /usr/share/dict/american-english-huge   ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/
                cp -fv /usr/share/dict/american-english-insane ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/
                cp -fv /usr/share/dict/american-english-large  ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/
                cp -fv /usr/share/dict/american-english-small  ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/
                cp -fv /usr/share/dict/bokmaal                 ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/
                cp -fv /usr/share/dict/brazilian               ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/
                cp -fv /usr/share/dict/british-english-huge    ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/
                cp -fv /usr/share/dict/british-english-insane  ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/
                cp -fv /usr/share/dict/british-english-large   ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/
                cp -fv /usr/share/dict/british-english-small   ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/
                cp -fv /usr/share/dict/bulgarian               ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/
                cp -fv /usr/share/dict/canadian-english        ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/
                cp -fv /usr/share/dict/canadian-english-huge   ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/
                cp -fv /usr/share/dict/canadian-english-insane ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/
                cp -fv /usr/share/dict/canadian-english-large  ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/
                cp -fv /usr/share/dict/canadian-english-small  ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/
                cp -fv /usr/share/dict/catalan                 ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/
                cp -fv /usr/share/dict/connectives             ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/
                cp -fv /usr/share/dict/cracklib-small          ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/
                cp -fv /usr/share/dict/danish                  ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/
                cp -fv /usr/share/dict/dutch                   ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/
                cp -fv /usr/share/dict/esperanto               ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/
                cp -fv /usr/share/dict/faroese                 ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/
                cp -fv /usr/share/dict/french                  ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/
                cp -fv /usr/share/dict/galician-minimos        ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/
                cp -fv /usr/share/dict/german-medical          ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/
                cp -fv /usr/share/dict/irish                   ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/
                cp -fv /usr/share/dict/italian                 ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/
                cp -fv /usr/share/dict/manx                    ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/
                cp -fv /usr/share/dict/ngerman                 ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/
                cp -fv /etc/dictionaries-common/norsk          ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/
                cp -fv /usr/share/dict/nynorsk                 ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/
                cp -fv /usr/share/dict/ogerman                 ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/
                cp -fv /usr/share/dict/polish                  ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/
                cp -fv /usr/share/dict/portuguese              ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/
                cp -fv /usr/share/dict/propernames             ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/
                cp -fv /usr/share/dict/spanish                 ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/
                cp -fv /usr/share/dict/swedish                 ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/
                cp -fv /usr/share/dict/swiss                   ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/
                cp -fv /usr/share/dict/ukrainian               ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/
                cp -fv /usr/share/dict/web2                    ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/
                cp -fv /usr/share/dict/web2a                   ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/
                cp -fv /etc/dictionaries-common/words          ~/HackingTools/WordLists/PreCalculadas/Packs/Debian/

            ;;

            2)

              echo ""
              echo "  Descargando WordLists de SecLists..."
              echo ""
              # Borrar la carpeta vieja
                rm -rf ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/ 2> /dev/null
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/ 2> /dev/null
              # Posicionarse en la carpeta
                cd ~/HackingTools/WordLists/PreCalculadas/Packs/
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
                  rm -f ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/SecLists.png
                  rm -f ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/LICENSE
                  rm -f ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/CONTRIBUTORS.md
                  rm -f ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/CONTRIBUTING.md
                # Archivos README.md
                  find ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/ -type f -name README.md -exec rm -f {} \;
                  rm -f ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/Discovery/Infrastructure/IPGenerator.sh
                # Archivos de inteligencia artificial
                  rm -rf ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/Ai 2> /dev/null
                  rm -rf ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/Ai 2> /dev/null

              # Descomprimir archivos comprimidos
                cd ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/Passwords/
                bzip2 -d "500-worst-passwords.txt.bz2"
                tar -xvzf "SCRABBLE-hackerhouse.tgz"
                rm "SCRABBLE-hackerhouse.tgz"
                rm -rf ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/Passwords/SCRABBLE/fetch.sh
                rm -rf ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/Passwords/SCRABBLE/mangle.py
                rm -rf ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/Passwords/Default-Credentials/scada-pass.csv
                rm -rf ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/Passwords/Default-Credentials/default-passwords.csv
                rm -rf ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/Pattern-Matching/grepstrings-auditing-php.md
                rm -rf ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/Payloads/
                rm -rf ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/Web-Shells/
                rm -rf ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/Fuzzing/
                # No convierten bien a UTF8
                  #rm -rf ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/Discovery/DNS/FUZZSUBS_CYFARE_2.txt
                  #rm -rf ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/Discovery/Web-Content/raft-large-files-lowercase.txt
                  #rm -rf ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/Discovery/Web-Content/trickest-robots-disallowed-WordLists/top-10000.txt
                  #rm -rf ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/Discovery/Web-Content/raft-large-files.txt
                  #rm -rf ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/Discovery/Web-Content/combined_words.txt
                  #rm -rf ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/Discovery/Web-Content/CMS/trickest-cms-WordList/dolibarr.txt
                  #rm -rf ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/Discovery/Web-Content/CMS/trickest-cms-WordList/dolibarr-all-levels.txt
                  #rm -rf ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/Discovery/Web-Content/CMS/Django.txt
                  #rm -rf ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/Discovery/Web-Content/raft-large-directories.txt
                  #rm -rf ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/Discovery/Web-Content/raft-small-directories.txt
                  #rm -rf ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/Discovery/Web-Content/raft-medium-directories.txt
                  #rm -rf ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/Passwords/dutch_passWordList.txt
                  #rm -rf ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/Passwords/Cracked-Hashes/milw0rm-dictionary.txt
                  #rm -rf ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/Passwords/Leaked-Databases/fortinet-2021.txt
                  #rm -rf ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/Passwords/Leaked-Databases/honeynet-withcount.txt
                  #rm -rf ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/Passwords/Leaked-Databases/honeynet2.txt
                  #rm -rf ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/Passwords/Leaked-Databases/honeynet.txt
                  #rm -rf ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/Passwords/Leaked-Databases/myspace-withcount.txt
                  #rm -rf ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/Passwords/Honeypot-Captures/python-heralding-sep2019.txt
                  #rm -rf ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/Passwords/Common-Credentials/10-million-password-list-top-100.txt
                  #rm -rf ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/Passwords/Common-Credentials/Language-Specific/Spanish_common-usernames-and-passwords.txt
                  #rm -rf ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/Passwords/Common-Credentials/10-million-password-list-top-100000.txt
                  #rm -rf ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/Usernames/Honeypot-Captures/multiplesources-users-fabian-fingerle.de.txt
                  #rm -rf ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/Miscellaneous/control-chars.txt
                  #rm -rf ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/Miscellaneous/Moby-Project/Moby-Language-II/german.txt
                  #rm -rf ~/HackingTools/WordLists/PreCalculadas/Packs/SecLists/Miscellaneous/Moby-Project/Moby-Language-II/japanese.txt
                  #rm -rf ~/HackingTools/WordLists/PreCalculadas/Packs/CSL-LABS/ROCKYOU-CSL.txt
                  #rm -rf ~/HackingTools/WordLists/PreCalculadas/Packs/CSL-LABS/misc/sports.txt
                  #rm -rf ~/HackingTools/WordLists/PreCalculadas/Packs/CSL-LABS/misc/top_songs.txt

            ;;

            3)

              echo ""
              echo "  Descargando WordLists de CSL-LABS..."
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
                rm -rf ~/HackingTools/WordLists/PreCalculadas/Packs/CSL-LABS/ 2> /dev/null
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/ 2> /dev/null
              # Mover carpeta
                mv /tmp/CrackingWordLists/dics/ ~/HackingTools/WordLists/PreCalculadas/Packs/CSL-LABS/
              #
                cd ~/HackingTools/WordLists/PreCalculadas/Packs/CSL-LABS/
                tar -xvzf ROCKYOU-CSL.tar.gz
                rm -f ROCKYOU-CSL.tar.gz
                find ~/HackingTools/WordLists/PreCalculadas/Packs/CSL-LABS/ -type f -name "*.dic" -exec bash -c 'mv "$0" "${0%.dic}.txt"' {} \;

            ;;

            4)

              echo ""
              echo "  Descargando WordLists de CrackStation..."
              echo ""
              curl -L https://crackstation.net/files/crackstation.txt.gz -o /tmp/crackstation.txt.gz
              cd /tmp/
              gunzip -v /tmp/crackstation.txt.gz
              mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/CrackStation/ 2> /dev/null
              mv /tmp/crackstation.txt ~/HackingTools/WordLists/PreCalculadas/Packs/CrackStation/

            ;;

            5)

              echo ""
              echo "  Descargando WordList WeakPass 4a..."
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
              mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4a/ 2> /dev/null
              7z x /tmp/weakpass_4a.txt.7z -o~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4a/ # No hay que dejar espacio entre -o y la ruta del directorio

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
              echo "  Preparando WordLists de caracteres incrementales..."
              echo "  Dependiendo de la capacidad de proceso del sistema, puede tardar más de 10 minutos."
              echo ""

              # Crear WordLists
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
                for vArchivo in ~/HackingTools/WordLists/PreCalculadas/PorCantCaracteres/*.txt; do
                  sed -e 's/^[[:space:]]*//' "$vArchivo" | grep -a -P '^[\x20-\x7E]+$' > "$vArchivo.tmp"
                  mv -f "$vArchivo.tmp" "$vArchivo"
                done

              # Ordenar y eliminar líneas duplicadas
                find "$vCarpetaDestino" -type f -name "*.txt" | while read -r vArchivo; do
                  sort "$vArchivo" | uniq > "$vArchivo.tmp" && mv "$vArchivo.tmp" "$vArchivo"
                done
                echo ""

              # Asegurarse de que cada arhivo tenga la cantidad correcta de caracteres por linea
                for vArchivo in ~/HackingTools/WordLists/PreCalculadas/PorCantCaracteres/All*Characters.txt; do
                  vCantidad=$(basename "$vArchivo" | sed -E 's/All([0-9]+)Characters\.txt/\1/')
                  grep -E "^.{$vCantidad}$" "$vArchivo" > "$vArchivo.tmp"
                  mv -f "$vArchivo.tmp" "$vArchivo"
                done

              # Corregir nombres de los archivos con un sólo número
                mv ~/HackingTools/WordLists/PreCalculadas/PorCantCaracteres/All1Characters.txt ~/HackingTools/WordLists/PreCalculadas/PorCantCaracteres/All01Characters.txt
                mv ~/HackingTools/WordLists/PreCalculadas/PorCantCaracteres/All2Characters.txt ~/HackingTools/WordLists/PreCalculadas/PorCantCaracteres/All02Characters.txt
                mv ~/HackingTools/WordLists/PreCalculadas/PorCantCaracteres/All3Characters.txt ~/HackingTools/WordLists/PreCalculadas/PorCantCaracteres/All03Characters.txt
                mv ~/HackingTools/WordLists/PreCalculadas/PorCantCaracteres/All4Characters.txt ~/HackingTools/WordLists/PreCalculadas/PorCantCaracteres/All04Characters.txt
                mv ~/HackingTools/WordLists/PreCalculadas/PorCantCaracteres/All5Characters.txt ~/HackingTools/WordLists/PreCalculadas/PorCantCaracteres/All05Characters.txt
                mv ~/HackingTools/WordLists/PreCalculadas/PorCantCaracteres/All6Characters.txt ~/HackingTools/WordLists/PreCalculadas/PorCantCaracteres/All06Characters.txt
                mv ~/HackingTools/WordLists/PreCalculadas/PorCantCaracteres/All7Characters.txt ~/HackingTools/WordLists/PreCalculadas/PorCantCaracteres/All07Characters.txt
                mv ~/HackingTools/WordLists/PreCalculadas/PorCantCaracteres/All8Characters.txt ~/HackingTools/WordLists/PreCalculadas/PorCantCaracteres/All08Characters.txt
                mv ~/HackingTools/WordLists/PreCalculadas/PorCantCaracteres/All9Characters.txt ~/HackingTools/WordLists/PreCalculadas/PorCantCaracteres/All09Characters.txt

              # Notificar fin de la ejecución
                echo ""
                echo "  Se han procesado todos los .txt de $vCarpetaInicio y se han creado nuevas WordLists con su contenido."
                echo "  Puedes encontrarlas en $vCarpetaDestino"
                echo ""

            ;;

        esac

    done

