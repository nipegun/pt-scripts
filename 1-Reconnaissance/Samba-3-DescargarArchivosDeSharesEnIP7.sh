#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para descargar los archivos de los shares encontrados con el script de listar shares
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/1-Reconnaissance/Samba-3-DescargarArchivosDeSharesEnIP.sh | bash -s 'IPServSamba' 'Usuario'
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/1-Reconnaissance/Samba-3-DescargarArchivosDeSharesEnIP.sh | sed 's-sudo--g' | bash -s 'IPServSamba' 'Usuario'
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/1-Reconnaissance/Samba-3-DescargarArchivosDeSharesEnIP.sh | nano -
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
  cCantParamEsperados=2

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
      echo "    $vNombreDelScript [IPServSamba] [Usuario]"
      echo ""
      echo "  Ejemplo:"
      echo ""
      echo "    $vNombreDelScript '10.10.76.111' 'guest'"
      echo ""
      exit
  fi

vIPServSamba="$1"
vUsuario="$2"

# Guardar los shares obtenidos con el otro script
  aSharesEncontrados=($(curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/1-Reconnaissance/Samba-1-ListarSharesEnIP.sh | bash -s "$vIPServSamba" "$vUsuario" | cut -d':' -f2 | sed 's/^[ \t]*//'))

# Descargar contenido de cada share
  for vNombreDelShare in "${aSharesEncontrados[@]}"; do
    echo -e "\n===== Nombre del share: $vNombreDelShare =====\n"
    smbclient "//$vIPServSamba/$vNombreDelShare" -N -c 'lcd $vNombreDelShare; recurse; prompt; mget *.*'
  done

for vNombreDelShare in "${aSharesEncontrados[@]}"; do
  echo -e "\n===== Nombre del share: $vNombreDelShare =====\n"
  mkdir -p "$vNombreDelShare"
  smbclient "//$vIPServSamba/$vNombreDelShare" -N -c "lcd Share$vNombreDelShare; recurse; prompt; mget *.*"
done
