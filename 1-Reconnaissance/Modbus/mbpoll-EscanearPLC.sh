#!/bin/bash

# ----------
# Script de NiPeGun para escanear un PLC con mbpoll
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/1-Reconnaissance/Modbus/mbpoll-EscanearPLC.sh | bash -s [IPDelPLC] [PuertoModbus]
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/1-Reconnaissance/Modbus/mbpoll-EscanearPLC.sh | sed 's-sudo--g' | bash -s [IPDelPLC] [PuertoModbus]
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/1-Reconnaissance/Modbus/mbpoll-EscanearPLC.sh | nano -
# ----------

vTimeOut="1"

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
      echo "    $vNombreDelScript [IPDelPLC] [PuertoModbus]"
      echo ""
      echo "  Ejemplo:"
      echo ""
      echo "    $vNombreDelScript 10.10.76.111 502"
      echo ""
      exit
  fi

# Comprobar si el paquete mbpoll está instalado. Si no lo está, instalarlo.
  if [[ $(dpkg-query -s mbpoll 2>/dev/null | grep installed) == "" ]]; then
    echo ""
    echo -e "${cColorRojo}  El paquete mbpoll no está instalado. Iniciando su instalación...${cFinColor}"
    echo ""
    sudo apt-get -y update
    sudo apt-get -y install mbpoll
    echo ""
  fi

vIP="$1"
vPuerto="$2"

trap 'echo -e "\n[!] Escaneo cancelado por el usuario.\n"; exit 1' SIGINT

aSlaveIDsValidos=()

# Escanear el PLC en búsqueda de Slave IDs válidos
  echo ""
  echo "  Escaneando el PLC en busca de Slave IDs válidos..."
  echo ""
  for vSlaveID in $(seq 1 3); do
    echo -n "    Probando Slave ID $vSlaveID... "
    mbpoll -m tcp -t 4 -a $vSlaveID -r 0 -c 1 -0 -1 -o 1 "$vIP" -p "$vPuerto" > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    echo "✅ Responde"
    aSlaveIDsValidos+=($vSlaveID)
  else
    echo "❌ No responde"
  fi
done

# Salir si no hay ningún Slave ID válido
  if [ ${#aSlaveIDsValidos[@]} -eq 0 ]; then
    echo ""
    echo "    [!] No se detectaron Slave IDs válidos. Saliendo..."
    echo ""
    exit 1
  fi

# Mostrar Slave IDs vñalidos
  echo ""
  echo "    Slaves IDs válidos: ${aSlaveIDsValidos[@]}"
  echo ""

# Escaneo de registros de cada Slave ID válido
  for vSlaveID in "${aSlaveIDsValidos[@]}"; do
    
    echo ""
    echo "  🔍 Escaneando Coils (0x01) del Slave ID $vSlaveID..."
    echo ""
    timeout "$vTimeOut" mbpoll -m tcp -t 0 -a $vSlaveID -r 0 -c 125 -0 -1 -q "$vIP" -p "$vPuerto" || echo "    ⚠️ Fallo al leer Coils del Slave ID $vSlaveID"

    echo ""
    echo "  🔍 Escaneando Discrete Inputs (0x02) del Slave ID $vSlaveID..."
    echo ""
    timeout "$vTimeOut" mbpoll -m tcp -t 1 -a $vSlaveID -r 0 -c 125 -0 -1 -q "$vIP" -p "$vPuerto" || echo "    ⚠️ Fallo al leer Inputs del Slave ID $vSlaveID"

    echo ""
    echo "  🔍 Escaneando Input Registers (0x04) del Slave ID $vSlaveID..."
    echo ""
    timeout "$vTimeOut" mbpoll -m tcp -t 3 -a $vSlaveID -r 0 -c 125 -0 -1 -q "$vIP" -p "$vPuerto" || echo "    ⚠️ Fallo al leer Input Registers del Slave ID $vSlaveID"

    echo ""
    echo "  🔍 Escaneando Holding Registers (0x03) del Slave ID $vSlaveID..."
    echo ""
    timeout "$vTimeOut" mbpoll -m tcp -t 4 -a $vSlaveID -r 0 -c 125 -0 -1 -q "$vIP" -p "$vPuerto" || echo "    ⚠️ Fallo al leer Holding Registers del Slave ID $vSlaveID"

  done
