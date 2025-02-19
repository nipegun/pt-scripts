#!/bin/bash

# Si el objetivo tiene sistemas de detección de intrusos (IDS) o firewalls activos, se pueden usar técnicas evasivas:
#    -sS → Escaneo sigiloso TCP SYN.
#    -T3 → Velocidad media (evita detección agresiva).
#    --dns-servers 8.8.8.8 → Usa DNS externo para consultas de nombres.
#    --spoof-mac → Cambia la MAC (simula otro dispositivo).

vIPoSubred="$1"
vServDNS="9.9.9.9"
vDirMAC="00:0a:1b:2c:3d:4e"

# Definir fecha de ejecución del script
  cFechaDeEjec=$(date +a%Ym%md%d@%T)

# Crear la carpeta
  mkdir -p ~/nmap/Escaneos/$cFechaDeEjec 2> /dev/null

# Ejecutar el escaneo
  sudo nmap -sS -sV -p- -T3 --script=vuln --dns-servers "$vServDNS" --spoof-mac "$vDirMAC" "$vIPoSubred" -oN ~/nmap/Escaneos/$cFechaDeEjec/ResultadoEvadiendoIDS.txt
