#!/bin/bash

# Instalar dependencias
  sudo apt-get -y update
  sudo apt-get -y install vagrant
  sudo apt-get -y install ruby-full
  sudo gem install winrm winrm-fs winrm-elevated

# Obtener el archivo vagrant
  mkdir metasploitable3
  cd metasploitable3
  curl -O https://raw.githubusercontent.com/rapid7/metasploitable3/master/Vagrantfile
  vagrant up
