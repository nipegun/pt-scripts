#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para crear un laboratorio de ciberseguridad en Proxmox
#
# Ejecución remota:
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/SoftInst/Vulnerable/MV/Metasploitable2-Ubuntu-Preparar-ConProxmox.sh | bash
#
# Ejecución remota con parámetros:
#   curl sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/SoftInst/Vulnerable/MV/Metasploitable2-Ubuntu-Preparar-ConProxmox.sh | bash -s Almacenamiento
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/SoftInst/Vulnerable/MV/Metasploitable2-Ubuntu-Preparar-ConProxmox.sh | nano -
# ----------

vLinkDeDescarga="https://sourceforge.net/projects/metasploitable/files/latest/download"
vAlmacenamiento="local-lvm"
vIDdeLaMV="2000"
vIDDelPuente="vmbr0"
vDirMac="00:00:00:00:00:01"

# Crear la máquina virtual
  echo ""
  echo "  Creando la máquina virtual de Metasploitable2..."
  echo ""
  qm create $vIDdeLaMV \
    --name Metasploitable2-Ubuntu \
    --machine q35 \
    --numa 0 \
    --sockets 1 \
    --cpu x86-64-v2-AES \
    --cores 4 \
    --memory 2048 \
    --balloon 0 \
    --vga memory=512 \
    --net0 virtio=$vDirMac,bridge=$vIDDelPuente,firewall=1 \
    --boot order=sata0 \
    --scsihw virtio-scsi-single \
    --sata0 none,media=cdrom \
    --ostype l26 \
    --agent 1

# Descargar el archivo
  # Comprobar si el paquete curl está instalado. Si no lo está, instalarlo.
    if [[ $(dpkg-query -s curl 2>/dev/null | grep installed) == "" ]]; then
      echo ""
      echo -e "${cColorRojo}  El paquete curl no está instalado. Iniciando su instalación...${cFinColor}"
      echo ""
      sudo apt-get -y update
      sudo apt-get -y install curl
      echo ""
    fi
  curl -L "$vLinkDeDescarga" -o /tmp/Metasploitable2.zip

# Descomprimir el archivo
  # Comprobar si el paquete zip está instalado. Si no lo está, instalarlo.
    if [[ $(dpkg-query -s zip 2>/dev/null | grep installed) == "" ]]; then
      echo ""
      echo -e "${cColorRojo}  El paquete zip no está instalado. Iniciando su instalación...${cFinColor}"
      echo ""
      sudo apt-get -y update
      sudo apt-get -y install zip
      echo ""
    fi
  cd /tmp/
  unzip /tmp/Metasploitable2.zip

# Importar el archivo .vmdk a la máquina virtual
  echo ""
  echo "    Importando el archivo de .vmdk a la máquina virtual..."
  echo ""
  mv /tmp/Metasploitable2-Linux/Metasploitable.vmdk /tmp/Metasploitable2-Ubuntu.vmdk
  qm importdisk $vIDdeLaMV /tmp/Metasploitable2-Ubuntu.vmdk "$vAlmacenamiento" && rm -vf /tmp/Metasploitable2-Ubuntu.vmdk && rm -rf /tmp/Metasploitable2-Linux/
  vRutaAlDisco=$(qm config $vIDdeLaMV | grep unused | cut -d' ' -f2)
  qm set $vIDdeLaMV --sata1 $vRutaAlDisco
  qm set $vIDdeLaMV --boot order='sata0;sata1'
