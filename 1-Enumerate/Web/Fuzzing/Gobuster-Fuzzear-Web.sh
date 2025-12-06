#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para escanear posibles directorios en una wbe usando Debian
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/pt-scripts/refs/heads/main/1-Enumerate/Web/Fuzzing/Gobuster-Fuzzear-Web.sh | bash -s [Protocolo] [IP] [Puerto] [WordList] [ExcludeLenght]
#   Ejemplo: curl -sL https://raw.githubusercontent.com/nipegun/pt-scripts/refs/heads/main/1-Enumerate/Web/Fuzzing/Gobuster-Fuzzear-Web.sh | bash -s https 127.0.0.1 10000 ~/HackingTools/WordLists/EnTextoPlano/Packs/Debian/american-english-huge.txt 4563
#
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/pt-scripts/refs/heads/main/1-Enumerate/Web/Fuzzing/Gobuster-Fuzzear-Web.sh | sed 's-sudo--g' | bash -s [Protocolo] [IP] [Puerto] [WordList] [ExcludeLenght]
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/pt-scripts/refs/heads/main/1-Enumerate/Web/Fuzzing/Gobuster-Fuzzear-Web.sh | nano -
# ----------

vProtocolo="${1:-http}"
vIP="${2:-127.0.0.1}"
vPuerto="${3:-80}"
vWordList="${4:-~/HackingTools/WordLists/EnTextoPlano/Packs/Debian/american-english-insane.txt}"
vExcLenght="${5:-0}"

# Comprobar si el paquete gobuster está instalado. Si no lo está, instalarlo.
  if [[ $(dpkg-query -s gobuster 2>/dev/null | grep installed) == "" ]]; then
    echo ""
    echo -e "${cColorRojo}  El paquete gobuster no está instalado. Iniciando su instalación...${cFinColor}"
    echo ""
    sudo apt-get -y update
    sudo apt-get -y install gobuster
    echo ""
  fi

gobuster dir -u "$vProtocolo"://"$vIP":"$vPuerto" -w "$vWordList" -k  --exclude-length "$vExcLenght"
