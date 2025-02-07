#!/bin/bash

# La idea es fisgonear el cahché de DNS de un servidor DNS para ver que consultas han hecho los usuarios que usan ese servidor.
# determinando si el dominio está cacheado o no.

# Constantes manuales
  cCantParamEsperados=2
  cDominioDelServidorRaiz="a.root-servers.net"

# Constantes automáticas
  cFQDN="$1"
  cIPDelServidorDNS="$2"

# Comprobar que se hayan pasado la cantidad de parámetros correctos y proceder
  if [ $# -ne $cCantParamEsperados ]
    then
      echo ""
      echo -e "${cColorRojo}  No le has pasado la cantidad de parámetros correctos al script: ${cFinColor}"
      echo ""
      echo "    Debes pasarle $cCantParamEsperados parámetros: [FQDN] [IPDelServidorDNS]"
      echo ""
      echo "  Ejemplo:"
      echo ""
      echo "    $0 'hacks4geeks.com' '172.16.1.1'"
      echo ""
      exit 1
  fi

# Comprobar si el paquete dnsutils está instalado. Si no lo está, instalarlo.
  if [[ $(dpkg-query -s dnsutils 2>/dev/null | grep installed) == "" ]]; then
    echo ""
    echo -e "${cColorRojo}  El paquete curl no está instalado. Iniciando su instalación...${cFinColor}"
    echo ""
    sudo apt-get -y dnsutils
    sudo apt-get -y install dnsutils
    echo ""
  fi

# Medir el tiempo de respuesta del ping
  echo ""
  echo "  Midiendo el tiempo de respuesta del ping..."
  echo ""
  vTiempoPing=$(ping -c 1 "$cFQDN" | grep -oP 'time=\K[0-9.]+')
  echo "    $vTiempoPing"

# Medir el tiempo de respuesta de la consulta recursiva
  echo ""
  echo "  Midiendo el tiempo de respuesta de la consulta recursiva..."
  echo ""
  vTiempoConsRecurs=$(dig "$cFQDN" "$cIPDelServidorDNS" +noall +stats | grep "Query time" | sed -nE 's/.*Query time: ([0-9]+) msec/\1/p' | sort -n | head -n1)
  echo "    $vTiempoConsRecurs"
  #time dig "$cFQDN" "$cIPDelServidorDNS" | grep time


# Extra para medir el tiempo total:  { time dig "$cFQDN" > /dev/null; } 2>&1 | grep real | cut -f2


# Replicar una consulta recursiva con consultas iterativas
  echo ""
  echo "  Replicando consulta recursiva con consultas iterativas..."
  echo ""

  # Preguntar al servidor raíz
    cIPDelServidorRaiz=$(dig +short "$cDominioDelServidorRaiz")
    dig "$cFQDN" @"$cIPDelServidorRaiz"
    vRespServRaiz=$(dig @"$cIPDelServidorRaiz" "$cFQDN" NS +norecurse | grep -P "IN\tA\t" | sort | head -n1 | sed -e 's-\t- -g' | cut -d' ' -f5)
    echo "  El servidor raíz ha mandando a consultar a $vRespServRaiz."

  # Preguntar al servidor TLD obtenido de la consulta anterior
    vRespServTLD=$(dig @$vRespServRaiz "$cFQDN" NS +norecurse | grep -P "IN\tNS\t" | sort | sed -e 's-\t- -g' | head -n1 | cut -d' ' -f6 | sed 's/.$//')
    echo "  El servidor TLD ha mandado a consultar a $vRespServTLD."

  # Preguntar al servidor autoritativo obtenido en la consulta anterior
    vRespServAuth=$(dig @$vRespServTLD "$cFQDN" A +norecurse | grep -P "IN\tA\t" | sort | head -n1 | sed -e 's-\t- -g' | cut -d' ' -f6)
    echo "  El servidor autoritativo ha repondido que la IP de dominio es $vRespServAuth"
