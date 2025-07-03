#!/bin/bash

# ----------
# Script de NiPeGun para instalar y configurar xxxxxxxxx en Debian
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL x | bash
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL x | sed 's-sudo--g' | bash
#
# Ejecución remota sin caché:
#   curl -sL -H 'Cache-Control: no-cache, no-store' x | bash
#
# Ejecución remota con parámetros:
#   curl -sL x | bash -s Parámetro1 Parámetro2
#
# Bajar y editar directamente el archivo en nano
#   curl -sL x | nano -
# ----------

# Comprobar si el paquete mbpoll está instalado. Si no lo está, instalarlo.
  if [[ $(dpkg-query -s mbpoll 2>/dev/null | grep installed) == "" ]]; then
    echo ""
    echo -e "${cColorRojo}  El paquete mbpoll no está instalado. Iniciando su instalación...${cFinColor}"
    echo ""
    sudo apt-get -y update
    sudo apt-get -y install mbpoll
    echo ""
  fi

trap 'echo -e "\n[!] Escaneo cancelado por el usuario.\n"; exit 1' SIGINT

for vSlaveID in $(seq 1 255); do
  echo -n "Probando Slave ID $vSlaveID... "
  mbpoll -m tcp -t 4 -a $vSlaveID -r 0 -c 1 -0 -1 -o 1 127.0.0.1 > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    echo "✅ Responde"
  else
    echo "❌ No responde"
  fi
done
