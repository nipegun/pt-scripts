#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para listar los usuarios de un servidor samba sabiendo el usuario y contraseña de un usuario válido
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/1-Reconnaissance/Samba-ListarUsuarios.sh | bash -s 'IPServSamba' 'UsuarioConocido' 'PassDelUsuario'
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/1-Reconnaissance/Samba-ListarUsuarios.sh | sed 's-sudo--g' | bash -s 'IPServSamba' 'UsuarioConocido' 'PassDelUsuario'
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/1-Reconnaissance/Samba-ListarUsuarios.sh | nano -
# ----------

vIPServSamba="$1"
vUsuarioConocido="$2"
vPassDelUsuario="$3"

# Comprobar si el paquete crackmapexec está instalado. Si no lo está, instalarlo.
  if [[ $(dpkg-query -s crackmapexec 2>/dev/null | grep installed) == "" ]]; then
    echo ""
    echo -e "${cColorRojo}  El paquete crackmapexec no está instalado. Iniciando su instalación...${cFinColor}"
    echo ""
    sudo apt-get -y update
    sudo apt-get -y install crackmapexec
    echo ""
  fi

crackmapexec smb "$vIPServSamba" -u "$vUsuarioConocido" -p "$vPassDelUsuario" --users


