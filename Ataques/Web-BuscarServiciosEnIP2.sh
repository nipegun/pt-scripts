#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para instalar y configurar xxxxxxxxx en Debian
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Web-BuscarServiciosEnIP.sh | bash
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Web-BuscarServiciosEnIP.sh | sed 's-sudo--g' | bash
#
# Ejecución remota sin caché:
#   curl -sL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Web-BuscarServiciosEnIP.sh | bash
#
# Ejecución remota con parámetros:
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Web-BuscarServiciosEnIP.sh | bash -s Parámetro1 Parámetro2
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Web-BuscarServiciosEnIP.sh | nano -
# ----------
#!/bin/bash

# Definir el objetivo
vHost="localhost"

# Ejecutar Nmap y extraer los números de puerto
mapfile -t vPuertosConRespuesta < <(nmap -p- "$vHost" | grep -oP '^\d+(?=/)')

# Array para puertos con respuesta HTML
vPuertosConRespuestaHTML=()

# Iterar sobre los puertos y probar con curl en HTTP y HTTPS
  for puerto in "${vPuertosConRespuesta[@]}"; do
    echo "Probando HTTP en puerto $vPuertosConRespuesta..."
    if curl -s --max-time 3 "http://$vHost:$vPuertosConRespuesta" | grep -q "<html"; then
      vPuertosConRespuestaHTML+=("http://$vHost:$vPuertosConRespuesta")
    fi

    echo "Probando HTTPS en puerto $vPuertosConRespuesta..."
    if curl -s --max-time 3 -k "https://$vHost:$vPuertosConRespuesta" | grep -q "<html"; then
      vPuertosConRespuestaHTML+=("https://$vHost:$vPuertosConRespuesta")
    fi
  done

# Mostrar los puertos que devolvieron HTML, línea por línea
  echo "Puertos con respuesta HTML:"
  for vURL in "${vPuertosConRespuestaHTML[@]}"; do
    echo "$vURL"
  done

