#!/usr/bin/env python3

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para enviar una carga binaria por TCP
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Scan-Idle.py | python3
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Scan-Idle.py | sed 's-sudo--g' | bash
#
# Ejecución remota sin caché:
#   curl -sL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Scan-Idle.py | bash
#
# Ejecución remota con parámetros:
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Scan-Idle.py | bash -s Parámetro1 Parámetro2
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Scan-Idle.py | nano -
# ----------


import socket

vDestino = "example.com"
vPruerto = 80
vDatosEnBinario = b"\x50\x79\x74\x68\x6f\x6e\x00\x01\x02\x03"  # Datos binarios arbitrarios

vConex = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
try:
    vConex.connect((vDestino, vPuerto))
    vConex.sendall(vDatosEnBinario)
    vRespuesta = vConex.recv(4096)
    print(vRespuesta)
except socket.error as vDescError:
    print(f"Error en la creación del socket: {vDescError}")
finally:
    vConex.close()
