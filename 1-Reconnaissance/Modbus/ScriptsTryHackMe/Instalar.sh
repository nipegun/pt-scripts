#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para instalar y configurar los scripts de Modbus de TryHackMe en Debian
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/1-Reconnaissance/Modbus/ScriptsTryHackMe/Instalar.sh | bash
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/1-Reconnaissance/Modbus/ScriptsTryHackMe/Instalar.sh | sed 's-sudo--g' | bash
#
# Ejecución remota sin caché:
#   curl -sL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/1-Reconnaissance/Modbus/ScriptsTryHackMe/Instalar.sh | bash
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/1-Reconnaissance/Modbus/ScriptsTryHackMe/Instalar.sh | nano -
# ----------

# Crear la carpeta HackingTools
  mkdir -p $HOME/HackingTools/ 2> /dev/null

# Borrar la carpeta anterior
  rm -rf $HOME/HackingTools/Descubrimiento/Modbus/ScriptsTryHackMe/  2> /dev/null

# Crear la carpeta para estos scripts
  mkdir -p $HOME/HackingTools/Descubrimiento/Modbus/ScriptsTryHackMe/ 2> /dev/null

# Crear el entorno virtual de Python
  echo ""
  echo "  Creando el entorno virtual de Python..."
  echo ""
  # Comprobar si el paquete python3-venv está instalado. Si no lo está, instalarlo.
    if [[ $(dpkg-query -s python3-venv 2>/dev/null | grep installed) == "" ]]; then
      echo ""
      echo -e "${cColorRojo}  El paquete python3-venv no está instalado. Iniciando su instalación...${cFinColor}"
      echo ""
      sudo apt-get -y update
      sudo apt-get -y install python3-venv
      echo ""
    fi
  cd $HOME/HackingTools/Descubrimiento/Modbus/ScriptsTryHackMe/
  python3 -m venv PythonVirtualEnvironment
  # Crear el mensaje para mostrar cuando se entra al entorno virtual
    echo 'echo -e "\n  Activando el entorno virtual de Python para los scripts Modbus de TryHackMe... \n"' >> $HOME/HackingTools/Modbus/ScriptsTryHackMe/PythonVirtualEnvironment/bin/activate

# Instalar los requisitos
  echo ""
  echo "  Instalando los requisitos..."
  echo ""
  source $HOME/HackingTools/Modbus/ScriptsTryHackMe/PythonVirtualEnvironment/bin/activate
    pip3 install pymodbus==1.5.2
    pip3 install six
  deactivate

# Descargar los scripts
  echo ""
  echo "  Descargando los scripts..."
  echo ""
  # Comprobar si el paquete curl está instalado. Si no lo está, instalarlo.
    if [[ $(dpkg-query -s curl 2>/dev/null | grep installed) == "" ]]; then
      echo ""
      echo -e "${cColorRojo}  El paquete curl no está instalado. Iniciando su instalación...${cFinColor}"
      echo ""
      sudo apt-get -y update
      sudo apt-get -y install curl
      echo ""
    fi
  cd $HOME/HackingTools/Modbus/ScriptsTryHackMe/
  curl -sL -O https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Modbus/ScriptsTryHackMe/discovery.py
  find $HOME/HackingTools/Modbus/ScriptsTryHackMe/ -type f -name '*.py' -exec chmod +x {} \;

# Notificar fin de ejecución del script
  echo ""
  echo "  Script de instalación de los scripts de Modbus de TryHackMe, finalizado."
  echo ""
  echo "    Para ejecutar los scripts, haz primero:"
  echo ""
  echo "      cd $HOME/HackingTools/Modbus/ScriptsTryHackMe/"
  echo "      source PythonVirtualEnvironment/bin/activate"
  echo ""
  echo "      ... y luego ejecuta cada script por separado."
  echo ""
  echo "    Por ejemplo:"
  echo ""
  echo "      ./discover.py '192.168.1.10'"
  echo ""
  echo "    o"
  echo ""
  echo "      ./set_registry.py '192.168.1.10' 11 1"
  echo ""

