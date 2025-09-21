#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para listar los servicios desde dentro de un docker y ver que comando los lanzó
#
# Ejecución remota con parámetros:
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/1-Enumerate/Docker-Servicios-ALaEscucha-Listar.sh | bash
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/1-Enumerate/Docker-Servicios-ALaEscucha-Listar.sh | nano -
# ----------

# Verificación de Docker
if grep -qE '/docker/|/lxc/' /proc/1/cgroup 2>/dev/null || [ -f /.dockerenv ]; then
  echo "[INFO] Ejecutándose dentro de un contenedor Docker"
fi

# Detección de distribución
distro="desconocida"
if [ -f /etc/os-release ]; then
  . /etc/os-release
  distro="$ID"
  echo "[INFO] Distribución detectada: $distro"
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
printf "PROTO\tPUERTO\tPID\tBINARIO\tUSUARIO\tCMDLINE\n"

# Procesar salida de ss
ss -tulpn | tail -n +2 | while read -r line; do
  proto=$(echo "$line" | awk '{print $1}')
  local_addr=$(echo "$line" | awk '{print $5}')
  port=$(echo "$local_addr" | sed -E 's/.*:([0-9]+)$/\1/')

  users_field=$(echo "$line" | grep -o 'users:(.*)')

  if [ -n "$users_field" ]; then
    echo "$users_field" | tr ',' '\n' | sed -n 's/.*pid=\([0-9]\+\).*/\1/p' | while read -r pid; do
      if [ -n "$pid" ] && [ -d "/proc/$pid" ]; then
        exe=$(readlink -f "/proc/$pid/exe" 2>/dev/null)
        cmdline=$(tr '\0' ' ' < "/proc/$pid/cmdline" 2>/dev/null)
        uid=$(awk '/^Uid:/ {print $2}' /proc/$pid/status 2>/dev/null)
        user=$(getent passwd "$uid" | cut -d: -f1)
        [ -z "$user" ] && user="$uid"
        printf "%s\t%s\t%s\t%s\t%s\t%s\n" "$proto" "$port" "$pid" "$exe" "$user" "$cmdline"
      fi
    done
  else
    # Entrada sin información de usuarios (sin PID)
    printf "%s\t%s\t-\t-\t-\t-\n" "$proto" "$port"
  fi
done

