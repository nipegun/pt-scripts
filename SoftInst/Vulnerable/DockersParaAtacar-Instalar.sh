#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para instalar y configurar Dockers para atacar en Debian
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/SoftInst/Vulnerable/DockersParaAtacar-Instalar.sh | bash
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/SoftInst/Vulnerable/DockersParaAtacar-Instalar.sh | sed 's-sudo--g' | bash
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/SoftInst/Vulnerable/DockersParaAtacar-Instalar.sh | nano -
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
      1 "Descargar repo de Github de dockers vulnerables de vulhub" on
      2 "Comprobar disponibilidad de docker-compose"                off
      3 "  Construir la imagen de x"                                off
      4 "  Construir la imagen de x"                                off
      5 "  Construir la imagen de x"                                off
      6 "  Construir la imagen de x"                                off
      7 "  Construir la imagen de x"                                off
      8 "  Construir la imagen de x"                                off
      9 "  Construir la imagen de x"                                off
     10 "  Construir la imagen de x"                                off
     11 "  Construir la imagen de x"                                off
     12 "  Construir la imagen de x"                                off
    )
  choices=$("${menu[@]}" "${opciones[@]}" 2>&1 >/dev/tty)

  for choice in $choices
    do
      case $choice in

        1)

          echo ""
          echo "  Descargando repo de Github de dockers vulnerables de vulhub..."
          echo ""
          # Comprobar si el paquete curl está instalado. Si no lo está, instalarlo.
            if [[ $(dpkg-query -s curl 2>/dev/null | grep installed) == "" ]]; then
              echo ""
              echo -e "${cColorRojo}    El paquete curl no está instalado. Iniciando su instalación...${cFinColor}"
              echo ""
              sudo apt-get -y update
              sudo apt-get -y install curl
              echo ""
            fi
          curl -L https://github.com/vulhub/vulhub/archive/master.zip -o /tmp/vulhub-master.zip
          cd /tmp/
          # Comprobar si el paquete unzip está instalado. Si no lo está, instalarlo.
            if [[ $(dpkg-query -s unzip 2>/dev/null | grep installed) == "" ]]; then
              echo ""
              echo -e "${cColorRojo}    El paquete unzip no está instalado. Iniciando su instalación...${cFinColor}"
              echo ""
              sudo apt-get -y update
              sudo apt-get -y install unzip
              echo ""
            fi
          unzip vulhub-master.zip
          cd vulhub-master

        ;;

        2)

          echo ""
          echo "  Comprobando disponibilidad de docker-compose..."
          echo ""
          # Comprobar si el paquete docker-compose está instalado. Si no lo está, instalarlo.
            if [[ $(dpkg-query -s docker-compose 2>/dev/null | grep installed) == "" ]]; then
              echo ""
              echo -e "${cColorRojo}    El paquete docker-compose no está instalado. Iniciando su instalación...${cFinColor}"
              echo ""
              sudo apt-get -y update
              sudo apt-get -y install docker-compose
              echo ""
            fi

        ;;

        3)

          echo ""
          echo "  Construyendo la imagen de x..."
          echo ""
          cd /tmp/vulhub-master/x
          sudo docker compose build
          sudo docker compose up -d

        ;;

        4)

          echo ""
          echo "  Construyendo la imagen de x..."
          echo ""
          cd /tmp/vulhub-master/x
          sudo docker compose build
          sudo docker compose up -d

        ;;


        5)

          echo ""
          echo "  Construyendo la imagen de x..."
          echo ""
          cd /tmp/vulhub-master/x
          sudo docker compose build
          sudo docker compose up -d

        ;;

        6)

          echo ""
          echo "  Construyendo la imagen de x..."
          echo ""
          cd /tmp/vulhub-master/x
          sudo docker compose build
          sudo docker compose up -d

        ;;

        7)

          echo ""
          echo "  Construyendo la imagen de x..."
          echo ""
          cd /tmp/vulhub-master/x
          sudo docker compose build
          sudo docker compose up -d

        ;;

        8)

          echo ""
          echo "  Construyendo la imagen de x..."
          echo ""
          cd /tmp/vulhub-master/x
          sudo docker compose build
          sudo docker compose up -d

        ;;

        9)

          echo ""
          echo "  Construyendo la imagen de x..."
          echo ""
          cd /tmp/vulhub-master/x
          sudo docker compose build
          sudo docker compose up -d

        ;;

       10)

          echo ""
          echo "  Construyendo la imagen de x..."
          echo ""
          cd /tmp/vulhub-master/x
          sudo docker compose build
          sudo docker compose up -d

        ;;


       11)

          echo ""
          echo "  Construyendo la imagen de x..."
          echo ""
          cd /tmp/vulhub-master/x
          sudo docker compose build
          sudo docker compose up -d

        ;;

    esac

done
