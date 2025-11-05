#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para listar los shares de un servidor samba sabiendo su IP y conociendo un usuario existente
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/pt-scripts/refs/heads/main/1-Enumerate/Samba/UsuarioExistente-1-ListarSharesEnIP.sh | bash -s 'IPServSamba' 'UsuarioExistente' 'Contraseña'
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/pt-scripts/refs/heads/main/1-Enumerate/Samba/UsuarioExistente-1-ListarSharesEnIP.sh | sed 's-sudo--g' | bash -s 'IPServSamba' 'UsuarioExistente' 'Contraseña'
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/pt-scripts/refs/heads/main/1-Enumerate/Samba/UsuarioExistente-1-ListarSharesEnIP.sh | nano -
# ----------

# Definir constantes de color
  cColorAzul="\033[0;34m"
  cColorAzulClaro="\033[1;34m"
  cColorVerde='\033[1;32m'
  cColorRojo='\033[1;31m'
  # Para el color rojo también:
    #echo "$(tput setaf 1)Mensaje en color rojo. $(tput sgr 0)"
  cFinColor='\033[0m'

# Definir la cantidad de argumentos esperados
  cCantParamEsperados=3

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
      echo "    $vNombreDelScript [IPServSamba] [UsuarioNoExistente] [Contraseña]"
      echo ""
      echo "  Ejemplo:"
      echo ""
      echo "    $vNombreDelScript '10.10.100.206' 'roberto' 'Default_2025!'"
      echo ""
      exit
  fi

vIPServSamba="$1"
vUsuarioNoExistente="$2"
vPassword="$3"

# Mostrar por pantalla
  #smbclient -L //"$vIPServSamba"/ -U "$vUsuario"% 2> /dev/null

# Guardar la salida en un array
  mapfile -t shares < <(smbclient -L //"$vIPServSamba"/ -U "$vUsuarioExistente"%"$vPassword" 2> /dev/null | grep -E 'Disk|IPC' | sed -E 's/^\s*([^\s]+).*/\1/' | cut -d' ' -f1)
  # MNostrar el array
    echo ""
    for s in "${shares[@]}"; do
      echo "Share encontrado: $s"
    done

