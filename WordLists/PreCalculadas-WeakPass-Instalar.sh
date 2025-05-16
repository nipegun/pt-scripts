#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para instalar la máxima cantidad posible de WordLists en texto plano en Debian
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/WordLists/PreCalculadas-WeakPass-Instalar.sh | bash
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/WordLists/PreCalculadas-WeakPass-Instalar.sh | sed 's-sudo--g' | bash
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/WordLists/PreCalculadas-WeakPass-Instalar.sh | nano -
# ----------

# Definir cual va a ser la carpeta temporal
  vCarpetaTemporal="${1:-/tmp/}"

# Definir constantes de color
  cColorAzul='\033[0;34m'
  cColorAzulClaro='\033[1;34m'
  cColorVerde='\033[1;32m'
  cColorRojo='\033[1;31m'
  # Para el color rojo también:
    #echo "$(tput setaf 1)Mensaje en color rojo. $(tput sgr 0)"
  cFinColor='\033[0m'

  # Función para calcular el espacio libre disponible
    fCalcularEspacioLibre() {
    local vGBsNecesarios="$1"
    # Verificar que la variable global vCarpetaTemporal esté definida
      if [ -z "$vCarpetaTemporal" ] || [ -z "$vGBsNecesarios" ]; then
        false
        return
      fi
    # Convertir GB necesarios a KB (1 GiB = 1024 * 1024 KB)
      local vEspacioNecesarioEnKB
      vEspacioNecesarioEnKB=$(echo "$vGBsNecesarios * 1024 * 1024" | bc | cut -d'.' -f1)
    # Obtener espacio libre en KB de la partición correspondiente a la ruta
      local vEspacioLibreEnKB
      vEspacioLibreEnKB=$(df -k "$vCarpetaTemporal" | tail -1 | tr -s ' ' | cut -d ' ' -f 4)
    # Comparar y retornar true o false
      [ "$vEspacioLibreEnKB" -ge "$vEspacioNecesarioEnKB" ] && true || false
  }

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
  menu=(dialog --checklist "Marca las WordLists PreCalculadas que quieras instalar:" 22 80 16)
    opciones=(
      1 "  WeakPass RockYou MD5         (0,6 GB descomprimido)" off
      2 "  WeakPass RockYou NTLM        (0,6 GB descomprimido)" off
      3 "  WeakPass RockYou SHA1        (0,7 GB descomprimido)" off
      4 "  WeakPass RockYou SHA256 NTLM (1,1 GB descomprimido)" off
      5 "  WeakPass RockYou SHA256      (1,1 GB descomprimido)" off

      6 "  WeakPass 4 Latin MD5         ( 90 GB descomprimido)" off
      7 "  WeakPass 4 Latin NTLM        (105 GB descomprimido)" off
      8 "  WeakPass 4 Latin SHA1        (105 GB descomprimido)" off
      9 "  WeakPass 4 Latin SHA256 NTLM (155 GB descomprimido)" off
     10 "  WeakPass 4 Latin SHA256      (155 GB descomprimido)" off

     11 "  WeakPass 4 Merged MD5         (150 GB descomprimido)" off
     12 "  WeakPass 4 Merged NTLM        (150 GB descomprimido)" off
     13 "  WeakPass 4 Merged SHA1        (180 GB descomprimido)" off
     14 "  WeakPass 4 Merged SHA256 NTLM (260 GB descomprimido)" off
     15 "  WeakPass 4 Merged SHA256      (260 GB descomprimido)" off

     16 "  WeakPass 4 Policy MD5         (14 GB descomprimido)" off
     17 "  WeakPass 4 Policy NTLM        (14 GB descomprimido)" off
     18 "  WeakPass 4 Policy SHA1        (16 GB descomprimido)" off
     19 "  WeakPass 4 Policy SHA256 NTLM (23 GB descomprimido)" off
     21 "  WeakPass 4 Policy SHA256      (23 GB descomprimido)" off

     22 "  WeakPass 4a Latin MD5         (340 GB descomprimido)" off
     23 "  WeakPass 4a Latin NTLM        (340 GB descomprimido)" off
     24 "  WeakPass 4a Latin SHA1        (400 GB descomprimido)" off
     25 "  WeakPass 4a Latin SHA256 NTLM (590 GB descomprimido)" off
     26 "  WeakPass 4a Latin SHA256      (590 GB descomprimido)" off

     27 "  WeakPass 4a Policy MD5         ( 73 GB descomprimido)" off
     28 "  WeakPass 4a Policy NTLM        ( 73 GB descomprimido)" off
     29 "  WeakPass 4a Policy SHA1        ( 86 GB descomprimido)" off
     30 "  WeakPass 4a Policy SHA256 NTLM (125 GB descomprimido)" off
     31 "  WeakPass 4a Policy SHA256      (125 GB descomprimido)" off

     32 "  WeakPass All in One Policy MD5  (302 GB descomprimido)" off
     33 "  WeakPass All in One Policy NTLM (302 GB descomprimido)" off
     34 "  WeakPass All in One Policy SHA1 (355 GB descomprimido)" off

     35 "  WeakPass All in One Latin NTLM  (1,1 TB descomprimido)" off
     36 "  WeakPass All in One Latin MD5   (1,1 TB descomprimido)" off

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
              echo "  Instalando la WordList WeakPass RockYou MD5..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/RockYou/ 2> /dev/null
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 0.3; then
                  curl -L https://weakpass.com/pre-computed/download/rockyou.txt.md5.txt.7z -o ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/rockyou.txt.md5.txt.7z
                else
                  echo ""
                  echo -e "${cColorRojo}    La carpeta $vCarpetaTemporal no tiene espacio disponible para descargar la WordList WeakPass RockYou MD5...${cFinColor}"
                  echo ""
                fi

            ;;

            2)

              echo ""
              echo "  Instalando la WordList WeakPass RockYou NTLM..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/RockYou/ 2> /dev/null
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 0.3; then
                  curl -L https://weakpass.com/pre-computed/download/rockyou.txt.ntlm.txt.7z -o ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/rockyou.txt.ntlm.txt.7z
                else
                  echo ""
                  echo -e "${cColorRojo}    La carpeta $vCarpetaTemporal no tiene espacio disponible para descargar la WordList WeakPass RockYou NTLM...${cFinColor}"
                  echo ""
                fi

            ;;

            3)

              echo ""
              echo "  Instalando la WordList WeakPass RockYou SHA1..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/RockYou/ 2> /dev/null
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 0.4; then
                  curl -L https://weakpass.com/pre-computed/download/rockyou.txt.sha1.txt.7z -o ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/rockyou.txt.sha1.txt.7z
                else
                  echo ""
                  echo -e "${cColorRojo}    La carpeta $vCarpetaTemporal no tiene espacio disponible para descargar la WordList WeakPass RockYou SHA1...${cFinColor}"
                  echo ""
                fi

            ;;

            4)

              echo ""
              echo "  Instalando la WordList WeakPass RockYou SHA256 NTLM..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/RockYou/ 2> /dev/null
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 0.6; then
                  curl -L https://weakpass.com/pre-computed/download/rockyou.txt.sha256.ntlm.txt.7z -o ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/rockyou.txt.sha256.ntlm.txt.7z
                else
                  echo ""
                  echo -e "${cColorRojo}    La carpeta $vCarpetaTemporal no tiene espacio disponible para descargar la WordList WeakPass RockYou SHA256 NTLM...${cFinColor}"
                  echo ""
                fi

            ;;

            5)

              echo ""
              echo "  Instalando la WordList WeakPass RockYou SHA256..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/RockYou/ 2> /dev/null
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 0.6; then
                  curl -L https://weakpass.com/pre-computed/download/rockyou.txt.sha256.txt.7z -o ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/rockyou.txt.sha256.txt.7z
                else
                  echo ""
                  echo -e "${cColorRojo}    La carpeta $vCarpetaTemporal no tiene espacio disponible para descargar la WordList WeakPass RockYou SHA256...${cFinColor}"
                  echo ""
                fi

            ;;

            6)

              echo ""
              echo "  Instalando la WordList WeakPass 4 Latin MD5..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4Latin/ 2> /dev/null
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 89; then
                  curl -L https://weakpass.com/pre-computed/download/weakpass_4.latin.txt.md5.txt.7z -o ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/weakpass_4.latin.txt.md5.txt.7z
                else
                  echo ""
                  echo -e "${cColorRojo}    La carpeta $vCarpetaTemporal no tiene espacio disponible para descargar la WordList WeakPass 4 Latin MD5...${cFinColor}"
                  echo ""
                fi

            ;;

            7)

              echo ""
              echo "  Instalando la WordList WeakPass 4 Latin NTLM..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4Latin/ 2> /dev/null
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 89; then
                  curl -L https://weakpass.com/pre-computed/download/weakpass_4.latin.txt.ntlm.txt.7z -o ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/weakpass_4.latin.txt.ntlm.txt.7z
                else
                  echo ""
                  echo -e "${cColorRojo}    La carpeta $vCarpetaTemporal no tiene espacio disponible para descargar la WordList WeakPass 4 Latin NTLM...${cFinColor}"
                  echo ""
                fi

            ;;

            8)

              echo ""
              echo "  Instalando la WordList WeakPass 4 Latin SHA1..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4Latin/ 2> /dev/null
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 105; then
                  curl -L https://weakpass.com/pre-computed/download/weakpass_4.latin.txt.sha1.txt.7z -o ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/weakpass_4.latin.txt.sha1.txt.7z
                else
                  echo ""
                  echo -e "${cColorRojo}    La carpeta $vCarpetaTemporal no tiene espacio disponible para descargar la WordList WeakPass 4 Latin SHA1...${cFinColor}"
                  echo ""
                fi

            ;;

            9)

              echo ""
              echo "  Instalando la WordList WeakPass 4 Latin SHA256 NTLM..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4Latin/ 2> /dev/null
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 153; then
                  curl -L https://weakpass.com/pre-computed/download/weakpass_4.latin.txt.sha256.ntlm.txt.7z -o ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/weakpass_4.latin.txt.sha256.ntlm.txt.7z
                else
                  echo ""
                  echo -e "${cColorRojo}    La carpeta $vCarpetaTemporal no tiene espacio disponible para descargar la WordList WeakPass 4 Latin SHA256 NTLM...${cFinColor}"
                  echo ""
                fi

            ;;

           10)

              echo ""
              echo "  Instalando la WordList WeakPass 4 Latin SHA256..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4Latin/ 2> /dev/null
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 153; then
                  curl -L https://weakpass.com/pre-computed/download/weakpass_4.latin.txt.sha256.txt.7z -o ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/weakpass_4.latin.txt.sha256.txt.7z
                else
                  echo ""
                  echo -e "${cColorRojo}    La carpeta $vCarpetaTemporal no tiene espacio disponible para descargar la WordList WeakPass 4 Latin SHA256...${cFinColor}"
                  echo ""
                fi

            ;;

           11)

              echo ""
              echo "  Instalando la WordList WeakPass 4 Merged MD5..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4Merged/ 2> /dev/null
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 148; then
                  curl -L https://weakpass.com/pre-computed/download/weakpass_4.merged.txt.md5.txt.7z -o ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/weakpass_4.merged.txt.md5.txt.7z
                else
                  echo ""
                  echo -e "${cColorRojo}    La carpeta $vCarpetaTemporal no tiene espacio disponible para descargar la WordList WeakPass 4 Merged MD5...${cFinColor}"
                  echo ""
                fi

            ;;

           12)

              echo ""
              echo "  Instalando la WordList WeakPass 4 Merged NTLM..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4Merged/ 2> /dev/null
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 148; then
                  curl -L https://weakpass.com/pre-computed/download/weakpass_4.merged.txt.ntlm.txt.7z -o ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/weakpass_4.merged.txt.ntlm.txt.7z
                else
                  echo ""
                  echo -e "${cColorRojo}    La carpeta $vCarpetaTemporal no tiene espacio disponible para descargar la WordList WeakPass 4 Merged NTLM...${cFinColor}"
                  echo ""
                fi

            ;;

           13)

              echo ""
              echo "  Instalando la WordList WeakPass 4 Merged SHA1..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4Merged/ 2> /dev/null
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 175; then
                  curl -L https://weakpass.com/pre-computed/download/weakpass_4.merged.txt.sha1.txt.7z -o ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/weakpass_4.merged.txt.sha1.txt.7z
                else
                  echo ""
                  echo -e "${cColorRojo}    La carpeta $vCarpetaTemporal no tiene espacio disponible para descargar la WordList WeakPass 4 Merged SHA1...${cFinColor}"
                  echo ""
                fi

            ;;

           14)

              echo ""
              echo "  Instalando la WordList WeakPass 4 Merged SHA256 NTLM..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4Merged/ 2> /dev/null
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 255; then
                  curl -L https://weakpass.com/pre-computed/download/weakpass_4.merged.txt.sha256.ntlm.txt.7z -o ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/weakpass_4.merged.txt.sha256.ntlm.txt.7z
                else
                  echo ""
                  echo -e "${cColorRojo}    La carpeta $vCarpetaTemporal no tiene espacio disponible para descargar la WordList WeakPass 4 Merged SHA256 NTLM...${cFinColor}"
                  echo ""
                fi

            ;;

           15)

              echo ""
              echo "  Instalando la WordList WeakPass 4 Merged SHA256..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4Merged/ 2> /dev/null
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 255; then
                  curl -L https://weakpass.com/pre-computed/download/weakpass_4.merged.txt.sha256.txt.7z -o ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/weakpass_4.merged.txt.sha256.txt.7z
                else
                  echo ""
                  echo -e "${cColorRojo}    La carpeta $vCarpetaTemporal no tiene espacio disponible para descargar la WordList WeakPass 4 Merged SHA256...${cFinColor}"
                  echo ""
                fi

            ;;

           16)

              echo ""
              echo "  Instalando la WordList WeakPass 4 Policy MD5..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4Policy/ 2> /dev/null
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 14; then
                  curl -L https://weakpass.com/pre-computed/download/weakpass_4.policy.txt.md5.txt.7z -o ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/weakpass_4.policy.txt.md5.txt.7z
                else
                  echo ""
                  echo -e "${cColorRojo}    La carpeta $vCarpetaTemporal no tiene espacio disponible para descargar la WordList WeakPass 4 Policy MD5...${cFinColor}"
                  echo ""
                fi

            ;;

           17)

              echo ""
              echo "  Instalando la WordList WeakPass 4 Policy NTLM..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4Policy/ 2> /dev/null
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 14; then
                  curl -L https://weakpass.com/pre-computed/download/weakpass_4.policy.txt.ntlm.txt.7z -o ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/weakpass_4.policy.txt.ntlm.txt.7z
                else
                  echo ""
                  echo -e "${cColorRojo}    La carpeta $vCarpetaTemporal no tiene espacio disponible para descargar la WordList WeakPass 4 Policy NTLM...${cFinColor}"
                  echo ""
                fi

            ;;

           18)

              echo ""
              echo "  Instalando la WordList WeakPass 4 Policy SHA1..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4Policy/ 2> /dev/null
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 16; then
                  curl -L https://weakpass.com/pre-computed/download/weakpass_4.policy.txt.sha1.txt.7z -o ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/weakpass_4.policy.txt.sha1.txt.7z
                else
                  echo ""
                  echo -e "${cColorRojo}    La carpeta $vCarpetaTemporal no tiene espacio disponible para descargar la WordList WeakPass 4 Policy SHA1...${cFinColor}"
                  echo ""
                fi

            ;;

           19)

              echo ""
              echo "  Instalando la WordList WeakPass 4 Policy SHA256 NTLM..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4Policy/ 2> /dev/null
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 23; then
                  curl -L https://weakpass.com/pre-computed/download/weakpass_4.policy.txt.sha256.ntlm.txt.7z -o ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/weakpass_4.policy.txt.sha256.ntlm.txt.7z
                else
                  echo ""
                  echo -e "${cColorRojo}    La carpeta $vCarpetaTemporal no tiene espacio disponible para descargar la WordList WeakPass 4 Policy SHA256 NTLM...${cFinColor}"
                  echo ""
                fi

            ;;

           21)

              echo ""
              echo "  Instalando la WordList WeakPass 4 Policy SHA256..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4Policy/ 2> /dev/null
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 23; then
                  curl -L https://weakpass.com/pre-computed/download/weakpass_4.policy.txt.sha256.txt.7z -o ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/weakpass_4.policy.txt.sha256.txt.7z
                else
                  echo ""
                  echo -e "${cColorRojo}    La carpeta $vCarpetaTemporal no tiene espacio disponible para descargar la WordList WeakPass 4 Policy SHA256...${cFinColor}"
                  echo ""
                fi

            ;;

           22)

              echo ""
              echo "  Instalando la WordList WeakPass 4a Latin MD5..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4aLatin/ 2> /dev/null
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 335; then
                  curl -L https://weakpass.com/pre-computed/download/weakpass_4a.latin.txt.md5.txt.7z -o ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/weakpass_4a.latin.txt.md5.txt.7z
                else
                  echo ""
                  echo -e "${cColorRojo}    La carpeta $vCarpetaTemporal no tiene espacio disponible para descargar la WordList WeakPass 4a Latin MD5...${cFinColor}"
                  echo ""
                fi

            ;;

           23)

              echo ""
              echo "  Instalando la WordList WeakPass 4a Latin NTLM..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4aLatin/ 2> /dev/null
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 335; then
                  curl -L https://weakpass.com/pre-computed/download/weakpass_4a.latin.txt.ntlm.txt.7z -o ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/weakpass_4a.latin.txt.ntlm.txt.7z
                else
                  echo ""
                  echo -e "${cColorRojo}    La carpeta $vCarpetaTemporal no tiene espacio disponible para descargar la WordList WeakPass 4a Latin NTLM...${cFinColor}"
                  echo ""
                fi

            ;;

           24)

              echo ""
              echo "  Instalando la WordList WeakPass 4a Latin SHA1..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4aLatin/ 2> /dev/null
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 396; then
                  curl -L https://weakpass.com/pre-computed/download/weakpass_4a.latin.txt.sha1.txt.7z -o ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/weakpass_4a.latin.txt.sha1.txt.7z
                else
                  echo ""
                  echo -e "${cColorRojo}    La carpeta $vCarpetaTemporal no tiene espacio disponible para descargar la WordList WeakPass 4a Latin SHA1...${cFinColor}"
                  echo ""
                fi

            ;;

           25)

              echo ""
              echo "  Instalando la WordList WeakPass 4a Latin SHA256 NTLM..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4aLatin/ 2> /dev/null
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 590; then
                  curl -L https://weakpass.com/pre-computed/download/weakpass_4a.latin.txt.sha256.ntlm.txt.7z -o ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/weakpass_4a.latin.txt.sha256.ntlm.txt.7z
                else
                  echo ""
                  echo -e "${cColorRojo}    La carpeta $vCarpetaTemporal no tiene espacio disponible para descargar la WordList WeakPass 4a Latin SHA256 NTLM...${cFinColor}"
                  echo ""
                fi

            ;;

           26)

              echo ""
              echo "  Instalando la WordList WeakPass 4a Latin SHA256..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4aLatin/ 2> /dev/null
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 590; then
                  curl -L https://weakpass.com/pre-computed/download/weakpass_4a.latin.txt.sha256.txt.7z -o ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/weakpass_4a.latin.txt.sha256.txt.7z
                else
                  echo ""
                  echo -e "${cColorRojo}    La carpeta $vCarpetaTemporal no tiene espacio disponible para descargar la WordList WeakPass 4a Latin SHA256...${cFinColor}"
                  echo ""
                fi

            ;;

           27)

              echo ""
              echo "  Instalando la WordList WeakPass 4a Policy MD5..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4aPolicy/ 2> /dev/null
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 73; then
                  curl -L https://weakpass.com/pre-computed/download/weakpass_4a.policy.txt.md5.txt.7z -o ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/weakpass_4a.policy.txt.md5.txt.7z
                else
                  echo ""
                  echo -e "${cColorRojo}    La carpeta $vCarpetaTemporal no tiene espacio disponible para descargar la WordList WeakPass 4a Policy MD5...${cFinColor}"
                  echo ""
                fi

            ;;

           28)

              echo ""
              echo "  Instalando la WordList WeakPass 4a Policy NTLM..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4aPolicy/ 2> /dev/null
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 73; then
                  curl -L https://weakpass.com/pre-computed/download/weakpass_4a.policy.txt.ntlm.txt.7z -o ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/weakpass_4a.policy.txt.ntlm.txt.7z
                else
                  echo ""
                  echo -e "${cColorRojo}    La carpeta $vCarpetaTemporal no tiene espacio disponible para descargar la WordList WeakPass 4a Policy NTLM...${cFinColor}"
                  echo ""
                fi

            ;;

           29)

              echo ""
              echo "  Instalando la WordList WeakPass 4a Policy SHA1..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4aPolicy/ 2> /dev/null
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 86; then
                  curl -L https://weakpass.com/pre-computed/download/weakpass_4a.policy.txt.sha1.txt.7z -o ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/weakpass_4a.policy.txt.sha1.txt.7z
                else
                  echo ""
                  echo -e "${cColorRojo}    La carpeta $vCarpetaTemporal no tiene espacio disponible para descargar la WordList WeakPass 4a Policy SHA1...${cFinColor}"
                  echo ""
                fi

            ;;

           30)

              echo ""
              echo "  Instalando la WordList WeakPass 4a Policy SHA256 NTLM..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4aPolicy/ 2> /dev/null
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 125; then
                  curl -L https://weakpass.com/pre-computed/download/weakpass_4a.policy.txt.sha256.ntlm.txt.7z -o ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/weakpass_4a.policy.txt.sha256.ntlm.txt.7z
                else
                  echo ""
                  echo -e "${cColorRojo}    La carpeta $vCarpetaTemporal no tiene espacio disponible para descargar la WordList WeakPass 4a Policy SHA256 NTLM...${cFinColor}"
                  echo ""
                fi

            ;;

           31)

              echo ""
              echo "  Instalando la WordList WeakPass 4a Policy SHA256..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/4aPolicy/ 2> /dev/null
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 125; then
                  curl -L https://weakpass.com/pre-computed/download/weakpass_4a.policy.txt.sha256.txt.7z -o ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/weakpass_4a.policy.txt.sha256.txt.7z
                else
                  echo ""
                  echo -e "${cColorRojo}    La carpeta $vCarpetaTemporal no tiene espacio disponible para descargar la WordList WeakPass 4a Policy SHA256...${cFinColor}"
                  echo ""
                fi

            ;;

           32)

              echo ""
              echo "  Instalando la WordList WeakPass All in One Policy MD5..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/AiOPolicy/ 2> /dev/null
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 153; then
                  curl -L https://weakpass.com/pre-computed/download/all_in_one.policy.txt.md5.txt.7z -o ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/all_in_one.policy.txt.md5.txt.7z
                else
                  echo ""
                  echo -e "${cColorRojo}    La carpeta $vCarpetaTemporal no tiene espacio disponible para descargar la WordList WeakPass All in One Policy MD5...${cFinColor}"
                  echo ""
                fi

            ;;

           33)

              echo ""
              echo "  Instalando la WordList WeakPass All in One Policy NTLM..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/AiOPolicy/ 2> /dev/null
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 153; then
                  curl -L https://weakpass.com/pre-computed/download/all_in_one.policy.txt.ntlm.txt.7z -o ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/all_in_one.policy.txt.ntlm.txt.7z
                else
                  echo ""
                  echo -e "${cColorRojo}    La carpeta $vCarpetaTemporal no tiene espacio disponible para descargar la WordList WeakPass All in One Policy NTLM...${cFinColor}"
                  echo ""
                fi

            ;;

           34)

              echo ""
              echo "  Instalando la WordList WeakPass All in One Policy SHA1..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/AiOPolicy/ 2> /dev/null
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 182; then
                  curl -L https://weakpass.com/pre-computed/download/all_in_one.policy.txt.sha1.txt.7z -o ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/all_in_one.policy.txt.sha1.txt.7z
                else
                  echo ""
                  echo -e "${cColorRojo}    La carpeta $vCarpetaTemporal no tiene espacio disponible para descargar la WordList WeakPass All in One Policy SHA1...${cFinColor}"
                  echo ""
                fi

            ;;

           35)

              echo ""
              echo "  Instalando la WordList WeakPass All in One Latin NTLM..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/AiOLatin/ 2> /dev/null
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 563; then
                  curl -L https://weakpass.com/pre-computed/download/all_in_one.latin.txt.ntlm.txt.7z -o ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/all_in_one.latin.txt.ntlm.txt.7z
                else
                  echo ""
                  echo -e "${cColorRojo}    La carpeta $vCarpetaTemporal no tiene espacio disponible para descargar la WordList WeakPass All in One Latin NTLM...${cFinColor}"
                  echo ""
                fi

            ;;

           36)

              echo ""
              echo "  Instalando la WordList WeakPass All in One Latin MD5..."
              echo ""
              # Asegurarse de que la carpeta base exista
                mkdir -p ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/AiOLatin/ 2> /dev/null
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 563; then
                  curl -L https://weakpass.com/pre-computed/download/all_in_one.latin.txt.md5.txt.7z -o ~/HackingTools/WordLists/PreCalculadas/Packs/WeakPass/all_in_one.latin.txt.md5.txt.7z
                else
                  echo ""
                  echo -e "${cColorRojo}    La carpeta $vCarpetaTemporal no tiene espacio disponible para descargar la WordList WeakPass All in One Latin MD5...${cFinColor}"
                  echo ""
                fi

            ;;

        esac

    done

