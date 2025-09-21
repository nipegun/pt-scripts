#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para instalar la máxima cantidad posible de WordLists en texto plano en Debian
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/WordLists/EnHashes-Instalar.sh | bash
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/WordLists/EnHashes-Instalar.sh | sed 's-sudo--g' | bash
#
# Ejecución remota como root indicando diferentes carpetas (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/WordLists/EnHashes-Instalar.sh | sed 's-sudo--g' | bash -s "/WordLists/tmp" "/WordLists"
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/WordLists/EnHashes-Instalar.sh | nano -
# ----------

# Definir cual va a ser la carpeta temporal
  vCarpetaTemporal="${1:-/tmp}"                              # No hay que poner barra final
# Definbir la carpeta de WordLists
  vCarpetaDeWordLists="${2:-"$HOME"/HackingTools/WordLists}" # No hay que poner barra final

# Definir constantes de color
  cColorAzul='\033[0;34m'
  cColorAzulClaro='\033[1;34m'
  cColorVerde='\033[1;32m'
  cColorRojo='\033[1;31m'
  # Para el color rojo también:
    #echo "$(tput setaf 1)Mensaje en color rojo. $(tput sgr 0)"
  cFinColor='\033[0m'

# Instalar paquetes necesarios para ejecutar correctamente el script
  sudo apt-get -y update
  sudo apt-get -y install dialog
  sudo apt-get -y install curl
  sudo apt-get -y install p7zip-full

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
  menu=(dialog --checklist "Marca las WordLists EnHashes que quieras instalar:" 22 80 16)
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

    )
    choices=$("${menu[@]}" "${opciones[@]}" 2>&1 >/dev/tty)

      for choice in $choices
        do
          case $choice in

            1)

              echo ""
              echo "  Instalando la WordList WeakPass RockYou MD5..."
              echo ""
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 0.3; then
                  # Descargar archivo comprimido
                    sudo rm -f "$vCarpetaTemporal"/rockyou.txt.md5.txt.7z 2> /dev/null
                    curl -L https://weakpass.com/pre-computed/download/rockyou.txt.md5.txt.7z -o "$vCarpetaTemporal"/rockyou.txt.md5.txt.7z
                  # Descomprimir archivo hacia la ubicación final
                    # Borrar la carpeta existente
                      rm -rf "$vCarpetaDeWordLists"/EnHashes/MD5/WeakPass-RockYou/ 2> /dev/null
                    # Asegurarse de que la carpeta final exista
                      mkdir -p "$vCarpetaDeWordLists"/EnHashes/MD5/WeakPass-RockYou/ 2> /dev/null
                    # Descomprimir
                      7z x "$vCarpetaTemporal"/rockyou.txt.md5.txt.7z -o"$vCarpetaDeWordLists"/EnHashes/MD5/WeakPass-RockYou/ # No hay que dejar espacio entre -o y la ruta del directorio
                    # Renombar el archivo de wordlist a su nombre final
                      
                    # Borrar el archivo comprimido recién descomprimido
                      rm -vf "$vCarpetaTemporal"/rockyou.txt.md5.txt.7z
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
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 0.3; then
                  # Descargar archivo comprimido
                    sudo rm -f "$vCarpetaTemporal"/rockyou.txt.ntlm.txt.7z 2> /dev/null
                    curl -L https://weakpass.com/pre-computed/download/rockyou.txt.ntlm.txt.7z -o "$vCarpetaTemporal"/rockyou.txt.ntlm.txt.7z
                  # Descomprimir archivo hacia la ubicación final
                    # Borrar la carpeta existente
                      rm -rf "$vCarpetaDeWordLists"/EnHashes/NTLM/WeakPass-RockYou/ 2> /dev/null
                    # Asegurarse de que la carpeta final exista
                      mkdir -p "$vCarpetaDeWordLists"/EnHashes/NTLM/WeakPass-RockYou/ 2> /dev/null
                    # Descomprimir
                      7z x "$vCarpetaTemporal"/rockyou.txt.ntlm.txt.7z -o"$vCarpetaDeWordLists"/EnHashes/NTLM/WeakPass-RockYou/ # No hay que dejar espacio entre -o y la ruta del directorio
                    # Renombar el archivo de wordlist a su nombre final
                      
                    # Borrar el archivo comprimido recién descomprimido
                      rm -vf "$vCarpetaTemporal"/rockyou.txt.ntlm.txt.7z
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
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 0.4; then
                  # Descargar archivo comprimido
                    sudo rm -f "$vCarpetaTemporal"/rockyou.txt.sha1.txt.7z 2> /dev/null
                    curl -L https://weakpass.com/pre-computed/download/rockyou.txt.sha1.txt.7z -o "$vCarpetaTemporal"/rockyou.txt.sha1.txt.7z
                  # Descomprimir archivo hacia la ubicación final
                    # Borrar la carpeta existente
                      rm -rf "$vCarpetaDeWordLists"/EnHashes/SHA1/WeakPass-RockYou/ 2> /dev/null
                    # Asegurarse de que la carpeta final exista
                      mkdir -p "$vCarpetaDeWordLists"/EnHashes/SHA1/WeakPass-RockYou/ 2> /dev/null
                    # Descomprimir
                      7z x "$vCarpetaTemporal"/rockyou.txt.sha1.txt.7z -o"$vCarpetaDeWordLists"/EnHashes/SHA1/WeakPass-RockYou/ # No hay que dejar espacio entre -o y la ruta del directorio
                    # Renombar el archivo de wordlist a su nombre final
                      
                    # Borrar el archivo comprimido recién descomprimido
                      rm -vf "$vCarpetaTemporal"/rockyou.txt.sha1.txt.7z
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
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 0.6; then
                  # Descargar archivo comprimido
                    sudo rm -f "$vCarpetaTemporal"/rockyou.txt.sha256.ntlm.txt.7z 2> /dev/null
                    curl -L https://weakpass.com/pre-computed/download/rockyou.txt.sha256.ntlm.txt.7z -o "$vCarpetaTemporal"/rockyou.txt.sha256.ntlm.txt.7z
                  # Descomprimir archivo hacia la ubicación final
                    # Borrar la carpeta existente
                      rm -rf "$vCarpetaDeWordLists"/EnHashes/SHA256NTLM/WeakPass-RockYou/ 2> /dev/null
                    # Asegurarse de que la carpeta final exista
                      mkdir -p "$vCarpetaDeWordLists"/EnHashes/SHA256NTLM/WeakPass-RockYou/ 2> /dev/null
                    # Descomprimir
                      7z x "$vCarpetaTemporal"/rockyou.txt.sha256.ntlm.txt.7z -o"$vCarpetaDeWordLists"/EnHashes/SHA256NTLM/WeakPass-RockYou/ # No hay que dejar espacio entre -o y la ruta del directorio
                    # Renombar el archivo de wordlist a su nombre final
                      
                    # Borrar el archivo comprimido recién descomprimido
                      rm -vf "$vCarpetaTemporal"/rockyou.txt.sha256.ntlm.txt.7z
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
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 0.6; then
                  # Descargar archivo comprimido
                    sudo rm -f "$vCarpetaTemporal"/rockyou.txt.sha256.txt.7z 2> /dev/null
                    curl -L https://weakpass.com/pre-computed/download/rockyou.txt.sha256.txt.7z -o "$vCarpetaTemporal"/rockyou.txt.sha256.txt.7z
                  # Descomprimir archivo hacia la ubicación final
                    # Borrar la carpeta existente
                      rm -rf "$vCarpetaDeWordLists"/EnHashes/SHA256/WeakPass-RockYou/ 2> /dev/null
                    # Asegurarse de que la carpeta final exista
                      mkdir -p "$vCarpetaDeWordLists"/EnHashes/SHA256/WeakPass-RockYou/ 2> /dev/null
                    # Descomprimir
                      7z x "$vCarpetaTemporal"/rockyou.txt.sha256.txt.7z -o"$vCarpetaDeWordLists"/EnHashes/SHA256/WeakPass-RockYou/ # No hay que dejar espacio entre -o y la ruta del directorio
                    # Renombar el archivo de wordlist a su nombre final
                      
                    # Borrar el archivo comprimido recién descomprimido
                      rm -vf "$vCarpetaTemporal"/rockyou.txt.sha256.txt.7z
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
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 89; then
                  # Descargar archivo comprimido
                    sudo rm -f "$vCarpetaTemporal"/weakpass_4.latin.txt.md5.txt.7z 2> /dev/null
                    curl -L https://weakpass.com/pre-computed/download/weakpass_4.latin.txt.md5.txt.7z -o "$vCarpetaTemporal"/weakpass_4.latin.txt.md5.txt.7z
                  # Descomprimir archivo hacia la ubicación final
                    # Borrar la carpeta existente
                      rm -rf "$vCarpetaDeWordLists"/EnHashes/MD5/WeakPass-4Latin/ 2> /dev/null
                    # Asegurarse de que la carpeta final exista
                      mkdir -p "$vCarpetaDeWordLists"/EnHashes/MD5/WeakPass-4Latin/ 2> /dev/null
                    # Descomprimir
                      7z x "$vCarpetaTemporal"/weakpass_4.latin.txt.md5.txt.7z -o"$vCarpetaDeWordLists"/EnHashes/MD5/WeakPass-4Latin/ # No hay que dejar espacio entre -o y la ruta del directorio
                    # Renombar el archivo de wordlist a su nombre final
                      
                    # Borrar el archivo comprimido recién descomprimido
                      rm -vf "$vCarpetaTemporal"/weakpass_4.latin.txt.md5.txt.7z
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
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 89; then
                  # Descargar archivo comprimido
                    sudo rm -f "$vCarpetaTemporal"/weakpass_4.latin.txt.ntlm.txt.7z 2> /dev/null
                    curl -L https://weakpass.com/pre-computed/download/weakpass_4.latin.txt.ntlm.txt.7z -o "$vCarpetaTemporal"/weakpass_4.latin.txt.ntlm.txt.7z
                  # Descomprimir archivo hacia la ubicación final
                    # Borrar la carpeta existente
                      rm -rf "$vCarpetaDeWordLists"/EnHashes/NTLM/WeakPass-4Latin/ 2> /dev/null
                    # Asegurarse de que la carpeta final exista
                      mkdir -p "$vCarpetaDeWordLists"/EnHashes/NTLM/WeakPass-4Latin/ 2> /dev/null
                    # Descomprimir
                      7z x "$vCarpetaTemporal"/weakpass_4.latin.txt.ntlm.txt.7z -o"$vCarpetaDeWordLists"/EnHashes/NTLM/WeakPass-4Latin/ # No hay que dejar espacio entre -o y la ruta del directorio
                    # Renombar el archivo de wordlist a su nombre final
                      
                    # Borrar el archivo comprimido recién descomprimido
                      rm -vf "$vCarpetaTemporal"/weakpass_4.latin.txt.ntlm.txt.7z
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
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 105; then
                  # Descargar archivo comprimido
                    sudo rm -f "$vCarpetaTemporal"/weakpass_4.latin.txt.sha1.txt.7z 2> /dev/null
                    curl -L https://weakpass.com/pre-computed/download/weakpass_4.latin.txt.sha1.txt.7z -o "$vCarpetaTemporal"/weakpass_4.latin.txt.sha1.txt.7z
                  # Descomprimir archivo hacia la ubicación final
                    # Borrar la carpeta existente
                      rm -rf "$vCarpetaDeWordLists"/EnHashes/SHA1/WeakPass-4Latin/ 2> /dev/null
                    # Asegurarse de que la carpeta final exista
                      mkdir -p "$vCarpetaDeWordLists"/EnHashes/SHA1/WeakPass-4Latin/ 2> /dev/null
                    # Descomprimir
                      7z x "$vCarpetaTemporal"/weakpass_4.latin.txt.sha1.txt.7z -o"$vCarpetaDeWordLists"/EnHashes/SHA1/WeakPass-4Latin/ # No hay que dejar espacio entre -o y la ruta del directorio
                    # Renombar el archivo de wordlist a su nombre final
                      
                    # Borrar el archivo comprimido recién descomprimido
                      rm -vf "$vCarpetaTemporal"/weakpass_4.latin.txt.sha1.txt.7z
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
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 153; then
                  # Descargar archivo comprimido
                    sudo rm -f "$vCarpetaTemporal"/weakpass_4.latin.txt.sha256.ntlm.txt.7z 2> /dev/null
                    curl -L https://weakpass.com/pre-computed/download/weakpass_4.latin.txt.sha256.ntlm.txt.7z -o "$vCarpetaTemporal"/weakpass_4.latin.txt.sha256.ntlm.txt.7z
                  # Descomprimir archivo hacia la ubicación final
                    # Borrar la carpeta existente
                      rm -rf "$vCarpetaDeWordLists"/EnHashes/SHA256NTLM/WeakPass-4Latin/ 2> /dev/null
                    # Asegurarse de que la carpeta final exista
                      mkdir -p "$vCarpetaDeWordLists"/EnHashes/SHA256NTLM/WeakPass-4Latin/ 2> /dev/null
                    # Descomprimir
                      7z x "$vCarpetaTemporal"/weakpass_4.latin.txt.sha256.ntlm.txt.7z -o"$vCarpetaDeWordLists"/EnHashes/SHA256NTLM/WeakPass-4Latin/ # No hay que dejar espacio entre -o y la ruta del directorio
                    # Renombar el archivo de wordlist a su nombre final
                      
                    # Borrar el archivo comprimido recién descomprimido
                      rm -vf "$vCarpetaTemporal"/weakpass_4.latin.txt.sha256.ntlm.txt.7z
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
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 153; then
                  # Descargar archivo comprimido
                    sudo rm -f "$vCarpetaTemporal"/weakpass_4.latin.txt.sha256.txt.7z 2> /dev/null
                    curl -L https://weakpass.com/pre-computed/download/weakpass_4.latin.txt.sha256.txt.7z -o "$vCarpetaTemporal"/weakpass_4.latin.txt.sha256.txt.7z
                  # Descomprimir archivo hacia la ubicación final
                    # Borrar la carpeta existente
                      rm -rf "$vCarpetaDeWordLists"/EnHashes/SHA256/WeakPass-4Latin/ 2> /dev/null
                    # Asegurarse de que la carpeta final exista
                      mkdir -p "$vCarpetaDeWordLists"/EnHashes/SHA256/WeakPass-4Latin/ 2> /dev/null
                    # Descomprimir
                      7z x "$vCarpetaTemporal"/weakpass_4.latin.txt.sha256.txt.7z -o"$vCarpetaDeWordLists"/EnHashes/SHA256/WeakPass-4Latin/ # No hay que dejar espacio entre -o y la ruta del directorio
                    # Renombar el archivo de wordlist a su nombre final
                      
                    # Borrar el archivo comprimido recién descomprimido
                      rm -vf "$vCarpetaTemporal"/weakpass_4.latin.txt.sha256.txt.7z
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
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 148; then
                  # Descargar archivo comprimido
                    sudo rm -f "$vCarpetaTemporal"/weakpass_4.merged.txt.md5.txt.7z 2> /dev/null
                    curl -L https://weakpass.com/pre-computed/download/weakpass_4.merged.txt.md5.txt.7z -o "$vCarpetaTemporal"/weakpass_4.merged.txt.md5.txt.7z
                  # Descomprimir archivo hacia la ubicación final
                    # Borrar la carpeta existente
                      rm -rf "$vCarpetaDeWordLists"/EnHashes/MD5/WeakPass-4Merged/ 2> /dev/null
                    # Asegurarse de que la carpeta final exista
                      mkdir -p "$vCarpetaDeWordLists"/EnHashes/MD5/WeakPass-4Merged/ 2> /dev/null
                    # Descomprimir
                      7z x "$vCarpetaTemporal"/weakpass_4.merged.txt.md5.txt.7z -o"$vCarpetaDeWordLists"/EnHashes/MD5/WeakPass-4Merged/ # No hay que dejar espacio entre -o y la ruta del directorio
                    # Renombar el archivo de wordlist a su nombre final
                      
                    # Borrar el archivo comprimido recién descomprimido
                      rm -vf "$vCarpetaTemporal"/weakpass_4.merged.txt.md5.txt.7z
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
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 148; then
                  # Descargar archivo comprimido
                    sudo rm -f "$vCarpetaTemporal"/weakpass_4.merged.txt.ntlm.txt.7z 2> /dev/null
                    curl -L https://weakpass.com/pre-computed/download/weakpass_4.merged.txt.ntlm.txt.7z -o "$vCarpetaTemporal"/weakpass_4.merged.txt.ntlm.txt.7z
                  # Descomprimir archivo hacia la ubicación final
                    # Borrar la carpeta existente
                      rm -rf "$vCarpetaDeWordLists"/EnHashes/NTLM/WeakPass-4Merged/ 2> /dev/null
                    # Asegurarse de que la carpeta final exista
                      mkdir -p "$vCarpetaDeWordLists"/EnHashes/NTLM/WeakPass-4Merged/ 2> /dev/null
                    # Descomprimir
                      7z x "$vCarpetaTemporal"/weakpass_4.merged.txt.ntlm.txt.7z -o"$vCarpetaDeWordLists"/EnHashes/NTLM/WeakPass-4Merged/ # No hay que dejar espacio entre -o y la ruta del directorio
                    # Renombar el archivo de wordlist a su nombre final
                      
                    # Borrar el archivo comprimido recién descomprimido
                      rm -vf "$vCarpetaTemporal"/weakpass_4.merged.txt.ntlm.txt.7z
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
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 175; then
                  # Descargar archivo comprimido
                    sudo rm -f "$vCarpetaTemporal"/weakpass_4.merged.txt.sha1.txt.7z 2> /dev/null
                    curl -L https://weakpass.com/pre-computed/download/weakpass_4.merged.txt.sha1.txt.7z -o "$vCarpetaTemporal"/weakpass_4.merged.txt.sha1.txt.7z
                  # Descomprimir archivo hacia la ubicación final
                    # Borrar la carpeta existente
                      rm -rf "$vCarpetaDeWordLists"/EnHashes/SHA1/WeakPass-4Merged/ 2> /dev/null
                    # Asegurarse de que la carpeta final exista
                      mkdir -p "$vCarpetaDeWordLists"/EnHashes/SHA1/WeakPass-4Merged/ 2> /dev/null
                    # Descomprimir
                      7z x "$vCarpetaTemporal"/weakpass_4.merged.txt.sha1.txt.7z -o"$vCarpetaDeWordLists"/EnHashes/SHA1/WeakPass-4Merged/ # No hay que dejar espacio entre -o y la ruta del directorio
                    # Renombar el archivo de wordlist a su nombre final
                      
                    # Borrar el archivo comprimido recién descomprimido
                      rm -vf "$vCarpetaTemporal"/weakpass_4.merged.txt.sha1.txt.7z
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
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 255; then
                  # Descargar archivo comprimido
                    sudo rm -f "$vCarpetaTemporal"/weakpass_4.merged.txt.sha256.ntlm.txt.7z 2> /dev/null
                    curl -L https://weakpass.com/pre-computed/download/weakpass_4.merged.txt.sha256.ntlm.txt.7z -o "$vCarpetaTemporal"/weakpass_4.merged.txt.sha256.ntlm.txt.7z
                  # Descomprimir archivo hacia la ubicación final
                    # Borrar la carpeta existente
                      rm -rf "$vCarpetaDeWordLists"/EnHashes/SHA256NTLM/WeakPass-4Merged/ 2> /dev/null
                    # Asegurarse de que la carpeta final exista
                      mkdir -p "$vCarpetaDeWordLists"/EnHashes/SHA256NTLM/WeakPass-4Merged/ 2> /dev/null
                    # Descomprimir
                      7z x "$vCarpetaTemporal"/weakpass_4.merged.txt.sha256.ntlm.txt.7z -o"$vCarpetaDeWordLists"/EnHashes/SHA256NTLM/WeakPass-4Merged/ # No hay que dejar espacio entre -o y la ruta del directorio
                    # Renombar el archivo de wordlist a su nombre final
                      
                    # Borrar el archivo comprimido recién descomprimido
                      rm -vf "$vCarpetaTemporal"/weakpass_4.merged.txt.sha256.ntlm.txt.7z
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
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 255; then
                  # Descargar archivo comprimido
                    sudo rm -f "$vCarpetaTemporal"/weakpass_4.merged.txt.sha256.txt.7z 2> /dev/null
                    curl -L https://weakpass.com/pre-computed/download/weakpass_4.merged.txt.sha256.txt.7z -o "$vCarpetaTemporal"/weakpass_4.merged.txt.sha256.txt.7z
                  # Descomprimir archivo hacia la ubicación final
                    # Borrar la carpeta existente
                      rm -rf "$vCarpetaDeWordLists"/EnHashes/SHA256/WeakPass-4Merged/ 2> /dev/null
                    # Asegurarse de que la carpeta final exista
                      mkdir -p "$vCarpetaDeWordLists"/EnHashes/SHA256/WeakPass-4Merged/ 2> /dev/null
                    # Descomprimir
                      7z x "$vCarpetaTemporal"/weakpass_4.merged.txt.sha256.txt.7z -o"$vCarpetaDeWordLists"/EnHashes/SHA256/WeakPass-4Merged/ # No hay que dejar espacio entre -o y la ruta del directorio
                    # Renombar el archivo de wordlist a su nombre final
                      
                    # Borrar el archivo comprimido recién descomprimido
                      rm -vf "$vCarpetaTemporal"/weakpass_4.merged.txt.sha256.txt.7z
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
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 14; then
                  # Descargar archivo comprimido
                    sudo rm -f "$vCarpetaTemporal"/weakpass_4.policy.txt.md5.txt.7z 2> /dev/null
                    curl -L https://weakpass.com/pre-computed/download/weakpass_4.policy.txt.md5.txt.7z -o "$vCarpetaTemporal"/weakpass_4.policy.txt.md5.txt.7z
                  # Descomprimir archivo hacia la ubicación final
                    # Borrar la carpeta existente
                      rm -rf "$vCarpetaDeWordLists"/EnHashes/MD5/WeakPass-4Policy/ 2> /dev/null
                    # Asegurarse de que la carpeta final exista
                      mkdir -p "$vCarpetaDeWordLists"/EnHashes/MD5/WeakPass-4Policy/ 2> /dev/null
                    # Descomprimir
                      7z x "$vCarpetaTemporal"/weakpass_4.policy.txt.md5.txt.7z -o"$vCarpetaDeWordLists"/EnHashes/MD5/WeakPass-4Policy/ # No hay que dejar espacio entre -o y la ruta del directorio
                    # Renombar el archivo de wordlist a su nombre final
                      
                    # Borrar el archivo comprimido recién descomprimido
                      rm -vf "$vCarpetaTemporal"/weakpass_4.policy.txt.md5.txt.7z
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
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 14; then
                  # Descargar archivo comprimido
                    sudo rm -f "$vCarpetaTemporal"/weakpass_4.policy.txt.ntlm.txt.7z 2> /dev/null
                    curl -L https://weakpass.com/pre-computed/download/weakpass_4.policy.txt.ntlm.txt.7z -o "$vCarpetaTemporal"/weakpass_4.policy.txt.ntlm.txt.7z
                  # Descomprimir archivo hacia la ubicación final
                    # Borrar la carpeta existente
                      rm -rf "$vCarpetaDeWordLists"/EnHashes/NTLM/WeakPass-4Policy/ 2> /dev/null
                    # Asegurarse de que la carpeta final exista
                      mkdir -p "$vCarpetaDeWordLists"/EnHashes/NTLM/WeakPass-4Policy/ 2> /dev/null
                    # Descomprimir
                      7z x "$vCarpetaTemporal"/weakpass_4.policy.txt.ntlm.txt.7z -o"$vCarpetaDeWordLists"/EnHashes/NTLM/WeakPass-4Policy/ # No hay que dejar espacio entre -o y la ruta del directorio
                    # Renombar el archivo de wordlist a su nombre final
                      
                    # Borrar el archivo comprimido recién descomprimido
                      rm -vf "$vCarpetaTemporal"/weakpass_4.policy.txt.ntlm.txt.7z
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
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 16; then
                  # Descargar archivo comprimido
                    sudo rm -f "$vCarpetaTemporal"/weakpass_4.policy.txt.sha1.txt.7z 2> /dev/null
                    curl -L https://weakpass.com/pre-computed/download/weakpass_4.policy.txt.sha1.txt.7z -o "$vCarpetaTemporal"/weakpass_4.policy.txt.sha1.txt.7z
                  # Descomprimir archivo hacia la ubicación final
                    # Borrar la carpeta existente
                      rm -rf "$vCarpetaDeWordLists"/EnHashes/SHA1/WeakPass-4Policy/ 2> /dev/null
                    # Asegurarse de que la carpeta final exista
                      mkdir -p "$vCarpetaDeWordLists"/EnHashes/SHA1/WeakPass-4Policy/ 2> /dev/null
                    # Descomprimir
                      7z x "$vCarpetaTemporal"/weakpass_4.policy.txt.sha1.txt.7z -o"$vCarpetaDeWordLists"/EnHashes/SHA1/WeakPass-4Policy/ # No hay que dejar espacio entre -o y la ruta del directorio
                    # Renombar el archivo de wordlist a su nombre final
                      
                    # Borrar el archivo comprimido recién descomprimido
                      rm -vf "$vCarpetaTemporal"/weakpass_4.policy.txt.sha1.txt.7z
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
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 23; then
                  # Descargar archivo comprimido
                    sudo rm -f "$vCarpetaTemporal"/weakpass_4.policy.txt.sha256.ntlm.txt.7z 2> /dev/null
                    curl -L https://weakpass.com/pre-computed/download/weakpass_4.policy.txt.sha256.ntlm.txt.7z -o "$vCarpetaTemporal"/weakpass_4.policy.txt.sha256.ntlm.txt.7z
                  # Descomprimir archivo hacia la ubicación final
                    # Borrar la carpeta existente
                      rm -rf "$vCarpetaDeWordLists"/EnHashes/SHA256NTLM/WeakPass-4Policy/ 2> /dev/null
                    # Asegurarse de que la carpeta final exista
                      mkdir -p "$vCarpetaDeWordLists"/EnHashes/SHA256NTLM/WeakPass-4Policy/ 2> /dev/null
                    # Descomprimir
                      7z x "$vCarpetaTemporal"/weakpass_4.policy.txt.sha256.ntlm.txt.7z -o"$vCarpetaDeWordLists"/EnHashes/SHA256NTLM/WeakPass-4Policy/ # No hay que dejar espacio entre -o y la ruta del directorio
                    # Renombar el archivo de wordlist a su nombre final
                      
                    # Borrar el archivo comprimido recién descomprimido
                      rm -vf "$vCarpetaTemporal"/weakpass_4.policy.txt.sha256.ntlm.txt.7z
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
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 23; then
                  # Descargar archivo comprimido
                    sudo rm -f "$vCarpetaTemporal"/weakpass_4.policy.txt.sha256.txt.7z 2> /dev/null
                    curl -L https://weakpass.com/pre-computed/download/weakpass_4.policy.txt.sha256.txt.7z -o "$vCarpetaTemporal"/weakpass_4.policy.txt.sha256.txt.7z
                  # Descomprimir archivo hacia la ubicación final
                    # Borrar la carpeta existente
                      rm -rf "$vCarpetaDeWordLists"/EnHashes/SHA256/WeakPass-4Policy/ 2> /dev/null
                    # Asegurarse de que la carpeta final exista
                      mkdir -p "$vCarpetaDeWordLists"/EnHashes/SHA256/WeakPass-4Policy/ 2> /dev/null
                    # Descomprimir
                      7z x "$vCarpetaTemporal"/weakpass_4.policy.txt.sha256.txt.7z -o"$vCarpetaDeWordLists"/EnHashes/SHA256/WeakPass-4Policy/ # No hay que dejar espacio entre -o y la ruta del directorio
                    # Renombar el archivo de wordlist a su nombre final
                      
                    # Borrar el archivo comprimido recién descomprimido
                      rm -vf "$vCarpetaTemporal"/weakpass_4.policy.txt.sha256.txt.7z
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
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 335; then
                  # Descargar archivo comprimido
                    sudo rm -f "$vCarpetaTemporal"/weakpass_4a.latin.txt.md5.txt.7z 2> /dev/null
                    curl -L https://weakpass.com/pre-computed/download/weakpass_4a.latin.txt.md5.txt.7z -o "$vCarpetaTemporal"/weakpass_4a.latin.txt.md5.txt.7z
                  # Descomprimir archivo hacia la ubicación final
                    # Borrar la carpeta existente
                      rm -rf "$vCarpetaDeWordLists"/EnHashes/MD5/WeakPass-4aLatin/ 2> /dev/null
                    # Asegurarse de que la carpeta final exista
                      mkdir -p "$vCarpetaDeWordLists"/EnHashes/MD5/WeakPass-4aLatin/ 2> /dev/null
                    # Descomprimir
                      7z x "$vCarpetaTemporal"/weakpass_4a.latin.txt.md5.txt.7z -o"$vCarpetaDeWordLists"/EnHashes/MD5/WeakPass-4aLatin/ # No hay que dejar espacio entre -o y la ruta del directorio
                    # Renombar el archivo de wordlist a su nombre final
                      
                    # Borrar el archivo comprimido recién descomprimido
                      rm -vf "$vCarpetaTemporal"/weakpass_4a.latin.txt.md5.txt.7z
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
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 335; then
                  # Descargar archivo comprimido
                    sudo rm -f "$vCarpetaTemporal"/weakpass_4a.latin.txt.ntlm.txt.7z 2> /dev/null
                    curl -L https://weakpass.com/pre-computed/download/weakpass_4a.latin.txt.ntlm.txt.7z -o "$vCarpetaTemporal"/weakpass_4a.latin.txt.ntlm.txt.7z
                  # Descomprimir archivo hacia la ubicación final
                    # Borrar la carpeta existente
                      rm -rf "$vCarpetaDeWordLists"/EnHashes/NTLM/WeakPass-4aLatin/ 2> /dev/null
                    # Asegurarse de que la carpeta final exista
                      mkdir -p "$vCarpetaDeWordLists"/EnHashes/NTLM/WeakPass-4aLatin/ 2> /dev/null
                    # Descomprimir
                      7z x "$vCarpetaTemporal"/weakpass_4a.latin.txt.ntlm.txt.7z -o"$vCarpetaDeWordLists"/EnHashes/NTLM/WeakPass-4aLatin/ # No hay que dejar espacio entre -o y la ruta del directorio
                    # Renombar el archivo de wordlist a su nombre final
                      
                    # Borrar el archivo comprimido recién descomprimido
                      rm -vf "$vCarpetaTemporal"/weakpass_4a.latin.txt.ntlm.txt.7z
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
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 396; then
                  # Descargar archivo comprimido
                    sudo rm -f "$vCarpetaTemporal"/weakpass_4a.latin.txt.sha1.txt.7z 2> /dev/null
                    curl -L https://weakpass.com/pre-computed/download/weakpass_4a.latin.txt.sha1.txt.7z -o "$vCarpetaTemporal"/weakpass_4a.latin.txt.sha1.txt.7z
                  # Descomprimir archivo hacia la ubicación final
                    # Borrar la carpeta existente
                      rm -rf "$vCarpetaDeWordLists"/EnHashes/SHA1/WeakPass-4aLatin/ 2> /dev/null
                    # Asegurarse de que la carpeta final exista
                      mkdir -p "$vCarpetaDeWordLists"/EnHashes/SHA1/WeakPass-4aLatin/ 2> /dev/null
                    # Descomprimir
                      7z x "$vCarpetaTemporal"/weakpass_4a.latin.txt.sha1.txt.7z -o"$vCarpetaDeWordLists"/EnHashes/SHA1/WeakPass-4aLatin/ # No hay que dejar espacio entre -o y la ruta del directorio
                    # Renombar el archivo de wordlist a su nombre final
                      
                    # Borrar el archivo comprimido recién descomprimido
                      rm -vf "$vCarpetaTemporal"/weakpass_4a.latin.txt.sha1.txt.7z
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
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 590; then
                  # Descargar archivo comprimido
                    sudo rm -f "$vCarpetaTemporal"/weakpass_4a.latin.txt.sha256.ntlm.txt.7z 2> /dev/null
                    curl -L https://weakpass.com/pre-computed/download/weakpass_4a.latin.txt.sha256.ntlm.txt.7z -o "$vCarpetaTemporal"/weakpass_4a.latin.txt.sha256.ntlm.txt.7z
                  # Descomprimir archivo hacia la ubicación final
                    # Borrar la carpeta existente
                      rm -rf "$vCarpetaDeWordLists"/EnHashes/SHA256NTLM/WeakPass-4aLatin/ 2> /dev/null
                    # Asegurarse de que la carpeta final exista
                      mkdir -p "$vCarpetaDeWordLists"/EnHashes/SHA256NTLM/WeakPass-4aLatin/ 2> /dev/null
                    # Descomprimir
                      7z x "$vCarpetaTemporal"/weakpass_4a.latin.txt.sha256.ntlm.txt.7z -o"$vCarpetaDeWordLists"/EnHashes/SHA256NTLM/WeakPass-4aLatin/ # No hay que dejar espacio entre -o y la ruta del directorio
                    # Renombar el archivo de wordlist a su nombre final
                      
                    # Borrar el archivo comprimido recién descomprimido
                      rm -vf "$vCarpetaTemporal"/weakpass_4a.latin.txt.sha256.ntlm.txt.7z
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
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 590; then
                  # Descargar archivo comprimido
                    sudo rm -f "$vCarpetaTemporal"/weakpass_4a.latin.txt.sha256.txt.7z 2> /dev/null
                    curl -L https://weakpass.com/pre-computed/download/weakpass_4a.latin.txt.sha256.txt.7z -o "$vCarpetaTemporal"/weakpass_4a.latin.txt.sha256.txt.7z
                  # Descomprimir archivo hacia la ubicación final
                    # Borrar la carpeta existente
                      rm -rf "$vCarpetaDeWordLists"/EnHashes/SHA256/WeakPass-4aLatin/ 2> /dev/null
                    # Asegurarse de que la carpeta final exista
                      mkdir -p "$vCarpetaDeWordLists"/EnHashes/SHA256/WeakPass-4aLatin/ 2> /dev/null
                    # Descomprimir
                      7z x "$vCarpetaTemporal"/weakpass_4a.latin.txt.sha256.txt.7z -o"$vCarpetaDeWordLists"/EnHashes/SHA256/WeakPass-4aLatin/ # No hay que dejar espacio entre -o y la ruta del directorio
                    # Renombar el archivo de wordlist a su nombre final
                      
                    # Borrar el archivo comprimido recién descomprimido
                      rm -vf "$vCarpetaTemporal"/weakpass_4a.latin.txt.sha256.txt.7z
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
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 73; then
                  # Descargar archivo comprimido
                    sudo rm -f "$vCarpetaTemporal"/weakpass_4a.policy.txt.md5.txt.7z 2> /dev/null
                    curl -L https://weakpass.com/pre-computed/download/weakpass_4a.policy.txt.md5.txt.7z -o "$vCarpetaTemporal"/weakpass_4a.policy.txt.md5.txt.7z
                  # Descomprimir archivo hacia la ubicación final
                    # Borrar la carpeta existente
                      rm -rf "$vCarpetaDeWordLists"/EnHashes/MD5/WeakPass-4aPolicy/ 2> /dev/null
                    # Asegurarse de que la carpeta final exista
                      mkdir -p "$vCarpetaDeWordLists"/EnHashes/MD5/WeakPass-4aPolicy/ 2> /dev/null
                    # Descomprimir
                      7z x "$vCarpetaTemporal"/weakpass_4a.policy.txt.md5.txt.7z -o"$vCarpetaDeWordLists"/EnHashes/MD5/WeakPass-4aPolicy/ # No hay que dejar espacio entre -o y la ruta del directorio
                    # Renombar el archivo de wordlist a su nombre final
                      
                    # Borrar el archivo comprimido recién descomprimido
                      rm -vf "$vCarpetaTemporal"/weakpass_4a.policy.txt.md5.txt.7z
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
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 73; then
                  # Descargar archivo comprimido
                    sudo rm -f "$vCarpetaTemporal"/weakpass_4a.policy.txt.ntlm.txt.7z 2> /dev/null
                    curl -L https://weakpass.com/pre-computed/download/weakpass_4a.policy.txt.ntlm.txt.7z -o "$vCarpetaTemporal"/weakpass_4a.policy.txt.ntlm.txt.7z
                  # Descomprimir archivo hacia la ubicación final
                    # Borrar la carpeta existente
                      rm -rf "$vCarpetaDeWordLists"/EnHashes/NTLM/WeakPass-4aPolicy/ 2> /dev/null
                    # Asegurarse de que la carpeta final exista
                      mkdir -p "$vCarpetaDeWordLists"/EnHashes/NTLM/WeakPass-4aPolicy/ 2> /dev/null
                    # Descomprimir
                      7z x "$vCarpetaTemporal"/weakpass_4a.policy.txt.ntlm.txt.7z -o"$vCarpetaDeWordLists"/EnHashes/NTLM/WeakPass-4aPolicy/ # No hay que dejar espacio entre -o y la ruta del directorio
                    # Renombar el archivo de wordlist a su nombre final
                      
                    # Borrar el archivo comprimido recién descomprimido
                      rm -vf "$vCarpetaTemporal"/weakpass_4a.policy.txt.ntlm.txt.7z
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
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 86; then
                  # Descargar archivo comprimido
                    sudo rm -f "$vCarpetaTemporal"/weakpass_4a.policy.txt.sha1.txt.7z 2> /dev/null
                    curl -L https://weakpass.com/pre-computed/download/weakpass_4a.policy.txt.sha1.txt.7z -o "$vCarpetaTemporal"/weakpass_4a.policy.txt.sha1.txt.7z
                  # Descomprimir archivo hacia la ubicación final
                    # Borrar la carpeta existente
                      rm -rf "$vCarpetaDeWordLists"/EnHashes/SHA1/WeakPass-4aPolicy/ 2> /dev/null
                    # Asegurarse de que la carpeta final exista
                      mkdir -p "$vCarpetaDeWordLists"/EnHashes/SHA1/WeakPass-4aPolicy/ 2> /dev/null
                    # Descomprimir
                      7z x "$vCarpetaTemporal"/weakpass_4a.policy.txt.sha1.txt.7z -o"$vCarpetaDeWordLists"/EnHashes/SHA1/WeakPass-4aPolicy/ # No hay que dejar espacio entre -o y la ruta del directorio
                    # Renombar el archivo de wordlist a su nombre final
                      
                    # Borrar el archivo comprimido recién descomprimido
                      rm -vf "$vCarpetaTemporal"/weakpass_4a.policy.txt.sha1.txt.7z
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
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 125; then
                  # Descargar archivo comprimido
                    sudo rm -f "$vCarpetaTemporal"/weakpass_4a.policy.txt.sha256.ntlm.txt.7z 2> /dev/null
                    curl -L https://weakpass.com/pre-computed/download/weakpass_4a.policy.txt.sha256.ntlm.txt.7z -o "$vCarpetaTemporal"/weakpass_4a.policy.txt.sha256.ntlm.txt.7z
                  # Descomprimir archivo hacia la ubicación final
                    # Borrar la carpeta existente
                      rm -rf "$vCarpetaDeWordLists"/EnHashes/SHA256NTLM/WeakPass-4aPolicy/ 2> /dev/null
                    # Asegurarse de que la carpeta final exista
                      mkdir -p "$vCarpetaDeWordLists"/EnHashes/SHA256NTLM/WeakPass-4aPolicy/ 2> /dev/null
                    # Descomprimir
                      7z x "$vCarpetaTemporal"/weakpass_4a.policy.txt.sha256.ntlm.txt.7z -o"$vCarpetaDeWordLists"/EnHashes/SHA256NTLM/WeakPass-4aPolicy/ # No hay que dejar espacio entre -o y la ruta del directorio
                    # Renombar el archivo de wordlist a su nombre final
                      
                    # Borrar el archivo comprimido recién descomprimido
                      rm -vf "$vCarpetaTemporal"/weakpass_4a.policy.txt.sha256.ntlm.txt.7z
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
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 125; then
                  # Descargar archivo comprimido
                    sudo rm -f "$vCarpetaTemporal"/weakpass_4a.policy.txt.sha256.txt.7z 2> /dev/null
                    curl -L https://weakpass.com/pre-computed/download/weakpass_4a.policy.txt.sha256.txt.7z -o "$vCarpetaTemporal"/weakpass_4a.policy.txt.sha256.txt.7z
                  # Descomprimir archivo hacia la ubicación final
                    # Borrar la carpeta existente
                      rm -rf "$vCarpetaDeWordLists"/EnHashes/SHA256/WeakPass-4aPolicy/ 2> /dev/null
                    # Asegurarse de que la carpeta final exista
                      mkdir -p "$vCarpetaDeWordLists"/EnHashes/SHA256/WeakPass-4aPolicy/ 2> /dev/null
                    # Descomprimir
                      7z x "$vCarpetaTemporal"/weakpass_4a.policy.txt.sha256.txt.7z -o"$vCarpetaDeWordLists"/EnHashes/SHA256/WeakPass-4aPolicy/ # No hay que dejar espacio entre -o y la ruta del directorio
                    # Renombar el archivo de wordlist a su nombre final
                      
                    # Borrar el archivo comprimido recién descomprimido
                      rm -vf "$vCarpetaTemporal"/weakpass_4a.policy.txt.sha256.txt.7z
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
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 153; then
                  # Descargar archivo comprimido
                    sudo rm -f "$vCarpetaTemporal"/all_in_one.policy.txt.md5.txt.7z 2> /dev/null
                    curl -L https://weakpass.com/pre-computed/download/all_in_one.policy.txt.md5.txt.7z -o "$vCarpetaTemporal"/all_in_one.policy.txt.md5.txt.7z
                  # Descomprimir archivo hacia la ubicación final
                    # Borrar la carpeta existente
                      rm -rf "$vCarpetaDeWordLists"/EnHashes/MD5/WeakPass-AiOPolicy/ 2> /dev/null
                    # Asegurarse de que la carpeta final exista
                      mkdir -p "$vCarpetaDeWordLists"/EnHashes/MD5/WeakPass-AiOPolicy/ 2> /dev/null
                    # Descomprimir
                      7z x "$vCarpetaTemporal"/all_in_one.policy.txt.md5.txt.7z -o"$vCarpetaDeWordLists"/EnHashes/MD5/WeakPass-AiOPolicy/ # No hay que dejar espacio entre -o y la ruta del directorio
                    # Renombar el archivo de wordlist a su nombre final
                      
                    # Borrar el archivo comprimido recién descomprimido
                      rm -vf "$vCarpetaTemporal"/all_in_one.policy.txt.md5.txt.7z
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
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 153; then
                  # Descargar archivo comprimido
                    sudo rm -f "$vCarpetaTemporal"/all_in_one.policy.txt.ntlm.txt.7z 2> /dev/null
                    curl -L https://weakpass.com/pre-computed/download/all_in_one.policy.txt.ntlm.txt.7z -o "$vCarpetaTemporal"/all_in_one.policy.txt.ntlm.txt.7z
                  # Descomprimir archivo hacia la ubicación final
                    # Borrar la carpeta existente
                      rm -rf "$vCarpetaDeWordLists"/EnHashes/NTLM/WeakPass-AiOPolicy/ 2> /dev/null
                    # Asegurarse de que la carpeta final exista
                      mkdir -p "$vCarpetaDeWordLists"/EnHashes/NTLM/WeakPass-AiOPolicy/ 2> /dev/null
                    # Descomprimir
                      7z x "$vCarpetaTemporal"/all_in_one.policy.txt.ntlm.txt.7z -o"$vCarpetaDeWordLists"/EnHashes/NTLM/WeakPass-AiOPolicy/ # No hay que dejar espacio entre -o y la ruta del directorio
                    # Renombar el archivo de wordlist a su nombre final
                      
                    # Borrar el archivo comprimido recién descomprimido
                      rm -vf "$vCarpetaTemporal"/all_in_one.policy.txt.ntlm.txt.7z
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
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 182; then
                  # Descargar archivo comprimido
                    sudo rm -f "$vCarpetaTemporal"/all_in_one.policy.txt.sha1.txt.7z 2> /dev/null
                    curl -L https://weakpass.com/pre-computed/download/all_in_one.policy.txt.sha1.txt.7z -o "$vCarpetaTemporal"/all_in_one.policy.txt.sha1.txt.7z
                  # Descomprimir archivo hacia la ubicación final
                    # Borrar la carpeta existente
                      rm -rf "$vCarpetaDeWordLists"/EnHashes/SHA1/WeakPass-AiOPolicy/ 2> /dev/null
                    # Asegurarse de que la carpeta final exista
                      mkdir -p "$vCarpetaDeWordLists"/EnHashes/SHA1/WeakPass-AiOPolicy/ 2> /dev/null
                    # Descomprimir
                      7z x "$vCarpetaTemporal"/all_in_one.policy.txt.sha1.txt.7z -o"$vCarpetaDeWordLists"/EnHashes/SHA1/WeakPass-AiOPolicy/ # No hay que dejar espacio entre -o y la ruta del directorio
                    # Renombar el archivo de wordlist a su nombre final
                      
                    # Borrar el archivo comprimido recién descomprimido
                      rm -vf "$vCarpetaTemporal"/all_in_one.policy.txt.sha1.txt.7z
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
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 563; then
                  # Descargar archivo comprimido
                    sudo rm -f "$vCarpetaTemporal"/all_in_one.latin.txt.ntlm.txt.7z 2> /dev/null
                    curl -L https://weakpass.com/pre-computed/download/all_in_one.latin.txt.ntlm.txt.7z -o "$vCarpetaTemporal"/all_in_one.latin.txt.ntlm.txt.7z
                  # Descomprimir archivo hacia la ubicación final
                    # Borrar la carpeta existente
                      rm -rf "$vCarpetaDeWordLists"/EnHashes/NTLM/WeakPass-AiOLatin/ 2> /dev/null
                    # Asegurarse de que la carpeta final exista
                      mkdir -p "$vCarpetaDeWordLists"/EnHashes/NTLM/WeakPass-AiOLatin/ 2> /dev/null
                    # Descomprimir
                      7z x "$vCarpetaTemporal"/all_in_one.latin.txt.ntlm.txt.7z -o"$vCarpetaDeWordLists"/EnHashes/NTLM/WeakPass-AiOLatin/ # No hay que dejar espacio entre -o y la ruta del directorio
                    # Renombar el archivo de wordlist a su nombre final
                      
                    # Borrar el archivo comprimido recién descomprimido
                      rm -vf "$vCarpetaTemporal"/all_in_one.latin.txt.ntlm.txt.7z
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
              # Calcular espacio libre disponible antes de instalar la WordList
                if fCalcularEspacioLibre 563; then
                  # Descargar archivo comprimido
                    sudo rm -f "$vCarpetaTemporal"/all_in_one.latin.txt.md5.txt.7z 2> /dev/null
                    curl -L https://weakpass.com/pre-computed/download/all_in_one.latin.txt.md5.txt.7z -o "$vCarpetaTemporal"/all_in_one.latin.txt.md5.txt.7z
                  # Descomprimir archivo hacia la ubicación final
                    # Borrar la carpeta existente
                      rm -rf "$vCarpetaDeWordLists"/EnHashes/MD5/WeakPass-AiOLatin/ 2> /dev/null
                    # Asegurarse de que la carpeta final exista
                      mkdir -p "$vCarpetaDeWordLists"/EnHashes/MD5/WeakPass-AiOLatin/ 2> /dev/null
                    # Descomprimir
                      7z x "$vCarpetaTemporal"/all_in_one.latin.txt.md5.txt.7z -o"$vCarpetaDeWordLists"/EnHashes/MD5/WeakPass-AiOLatin/ # No hay que dejar espacio entre -o y la ruta del directorio
                    # Renombar el archivo de wordlist a su nombre final
                      
                    # Borrar el archivo comprimido recién descomprimido
                      rm -vf "$vCarpetaTemporal"/all_in_one.latin.txt.md5.txt.7z
                else
                  echo ""
                  echo -e "${cColorRojo}    La carpeta $vCarpetaTemporal no tiene espacio disponible para descargar la WordList WeakPass All in One Latin MD5...${cFinColor}"
                  echo ""
                fi

            ;;

        esac

    done

