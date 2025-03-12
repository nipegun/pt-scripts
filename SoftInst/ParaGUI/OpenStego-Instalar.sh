#!/bin/bash

# Instalar Java

# Obtener el número de la última versión disponible
  vUltVers=$(curl -s https://api.github.com/repos/syvaidya/openstego/releases/latest | jq -r '.tag_name')

# Buscar el enlace 

# Descargar el .deb
  curl -sL https://github.com/syvaidya/openstego/releases/download/$vUltVers/openstego_0.8.6-1_all.deb -o /tmp/openstego.deb
openstego-0.8.6
