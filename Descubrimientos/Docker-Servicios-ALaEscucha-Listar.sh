#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para listar los servicios desde dentro de un docker y ver que comando los lanzó
#
# Ejecución remota con parámetros:
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Descubrimientos/Servicios-Web-EnSubred.sh | bash -s "192.168.1.0/24"
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Descubrimientos/Servicios-Web-EnSubred.sh | nano -
# ----------

# Detección de distribución
distro="desconocida"
if [ -f /etc/os-release ]; then
  . /etc/os-release
  distro="$ID"
  echo "[INFO] Distribución detectada: $distro"
fi

# Verificación de Docker
if grep -qE '/docker/|/lxc/' /proc/1/cgroup 2>/dev/null || [ -f /.dockerenv ]; then
  echo "[INFO] Ejecutándose dentro de un contenedor Docker"
fi

# Instalar ss si no está
if ! command -v ss &>/dev/null; then
  echo "[INFO] Instalando 'iproute2'..."
  case "$distro" in
    debian|ubuntu)
      apt update && apt install -y iproute2
      ;;
    alpine)
      apk update && apk add iproute2
      ;;
    *)
      echo "[ERROR] Distribución no soportada para instalación automática."
      exit 1
      ;;
  esac
fi

# Escribir el encabezado
echo -e "PROTO\tPUERTO\tPID\tBINARIO\tCMDLINE"

# Procesar salida de ss
ss -tulpn | tail -n +2 | while read -r line; do
  proto=$(echo "$line" | awk '{print $1}')
  local_addr=$(echo "$line" | awk '{print $5}')
  port=$(echo "$local_addr" | sed -E 's/.*:([0-9]+)$/\1/')

  pids=$(echo "$line" | grep -oP 'pid=\K[0-9]+')

  for pid in $pids; do
    if [[ -d "/proc/$pid" ]]; then
      exe=$(readlink -f /proc/"$pid"/exe 2>/dev/null)
      cmdline=$(tr '\0' ' ' < /proc/"$pid"/cmdline 2>/dev/null)
      echo -e "$proto\t$port\t$pid\t$exe\t$cmdline"
    fi
  done
done
