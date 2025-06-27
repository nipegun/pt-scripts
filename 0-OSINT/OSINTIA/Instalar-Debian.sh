#!/bin/bash

# curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/OSINT/OSINTIA/Instalar-Debian.sh | bash

# curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/OSINT/OSINTIA/Instalar-Debian.sh | sed 's-sudo--g' | bash

# Comprobar si el paquete curl está instalado. Si no lo está, instalarlo.
  if [[ $(dpkg-query -s curl 2>/dev/null | grep installed) == "" ]]; then
    echo ""
    echo -e "${cColorRojo}  El paquete curl no está instalado. Iniciando su instalación...${cFinColor}"
    echo ""
    sudo apt-get -y install curl
    echo ""
  fi

# CLonar el repositorio
  echo ""
  echo "  Creando carpetas y archivos..."
  echo ""
  sudo rm -rf $HOME/OSINTIA/
  sudo mkdir -p $HOME/OSINTIA/n8n/demo-data/workflows/
  cd $HOME/OSINTIA/
  sudo curl -sL -O https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/OSINT/OSINTIA/.env_euskal
  sudo curl -sL -O https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/OSINT/OSINTIA/Dockerfile.n8n
  sudo curl -sL -O https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/OSINT/OSINTIA/docker-compose.yaml
  sudo curl -sL -O https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/OSINT/OSINTIA/scraper.py
  sudo curl -sL -O https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/OSINT/OSINTIA/start.sh
  sudo curl -sL -O https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/OSINT/OSINTIA/test.sh
  cd $HOME/OSINTIA/n8n/
  sudo curl -sL -O https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/OSINT/OSINTIA/n8n/n8n.dockerfile
  sudo curl -sL -O https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/OSINT/OSINTIA/n8n/social-api.py
  cd $HOME/OSINTIA/n8n/demo-data/workflows/
  sudo curl -sL -O https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/OSINT/OSINTIA/n8n/demo-data/workflows/Agente_Smith.json
  sudo chown $USER:$USER $HOME/OSINTIA/ -Rv
  # Permisos
    find $HOME/OSINTIA/ -print -type f -name "*.py" -exec chmod +x {} \;
    find $HOME/OSINTIA/ -print -type f -name "*.sh" -exec chmod +x {} \;
  #ls -lha --group-directories-first
