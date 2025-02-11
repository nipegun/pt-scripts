#!/bin/bash

#vSubred="172.16.0.0/24"

# Buscar una IP encendida
  
  # Comprobar si la IP es predecible (Incremental)
    echo ""
    echo "  Buscando candidatos a zombie..."
    echo ""
    #sudo nmap --script ipidseq --script-args probeport=80 "$vSubred"

# Ejecuta el escaneo y filtra las IPs con secuencia incremental
#mapfile -t ip_list < <(sudo nmap --script ipidseq --script-args probeport=80 "$vSubred" | awk '/Nmap scan report/{ip=$NF} /IP ID Sequence Generation: Incremental/{print ip}')

# Muestra las IPs almacenadas en el array
echo "IPs con secuencia incremental:"
#for ip in "${ip_list[@]}"; do
#    echo "$ip"
#done

vIPZombie="192.168.1.218"

  # Notificar selección del zombie
    echo ""
    echo "  Se ha seleccionado el zombie $vIPZombie "
    echo ""

  # Realizar el escaneo
    echo ""
    echo "  Realizando el escaneo..."
    echo ""
    sudo nmap -PN -P0 -p22,80,443 -sI "$vIPZombie" 172.16.0.109
