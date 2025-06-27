#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para buscar servicios web en una subred o host
#
# Ejecución remota con parámetros:
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/1-Reconnaissance/Servicios-Web-EnSubred.sh | bash -s "192.168.1.0/24"
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/1-Reconnaissance/Servicios-Web-EnSubred.sh | nano -
# ----------

# Verificar si se pasó un argumento
if [ -z "$1" ]; then
  echo "Uso: $0 <subred en formato CIDR>"
  echo "Ejemplo: $0 192.168.1.0/24"
  exit 1
fi

# Guardar el parámetro pasado en una variable
  SUBNET="$1"

# Declarar un array para almacenar las IPs
  declare -a IPS_ARRAY

# Función para calcular todas las IPs de una subred excluyendo la dirección de subred y broadcast
  fCalcularIPs() {
    local NETWORK=$(echo "$SUBNET" | cut -d'/' -f1)
    local PREFIX=$(echo "$SUBNET" | cut -d'/' -f2)
    
    # Convertir IP a entero
    IFS=. read -r i1 i2 i3 i4 <<< "$NETWORK"
    local BASE_IP=$(( (i1 << 24) + (i2 << 16) + (i3 << 8) + i4 ))

    # Calcular máscara de red en base al prefijo
    local MASK=$(( 0xFFFFFFFF << (32 - PREFIX) & 0xFFFFFFFF ))

    # Calcular la primera y última IP en el rango
    local NET_IP=$(( BASE_IP & MASK ))  # Dirección de red
    local BROADCAST_IP=$(( NET_IP | ~MASK & 0xFFFFFFFF ))  # Dirección de broadcast

    # Generar todas las IPs dentro del rango, excluyendo red y broadcast
    for (( IP_INT = NET_IP + 1; IP_INT < BROADCAST_IP; IP_INT++ )); do
        IPS_ARRAY+=( "$(( (IP_INT >> 24) & 255 )).$(( (IP_INT >> 16) & 255 )).$(( (IP_INT >> 8) & 255 )).$(( IP_INT & 255 ))" )
    done
  }

# Llamar a la función para calcular IPs
  fCalcularIPs

# Mandar a escanear cada una de las IPs
  for IP in "${IPS_ARRAY[@]}"; do
    curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/1-Reconnaissance/Servicios-Web-EnIP-ConNmapCurl.sh | bash -s "$IP"
  done
