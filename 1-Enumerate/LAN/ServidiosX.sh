#!/bin/bash

# Definiciones
  vDirSubred='192.168.10.0/24'
  vDirSubredText=$(echo "$vDirSubred" | sed 's|/|-|g')

# Definir la carpeta donde guardar los escaneos
  vCarpetaDondeGuardar='/tmp/masscan'

# Crear la carpeta donde guardar los escaneos
  mkdir -p "$vCarpetaDondeGuardar" 2 > /dev/null

# Escanear servicios en puertos por defecto

  # SSH
    masscan -p22 "$vDirSubred" > "$vCarpetaDondeGuardar"/"$vDirSubredText"-ssh.lst

  # Samba
    masscan -p445 "$vDirSubred" > "$vCarpetaDondeGuardar"/"$vDirSubredText"-smb.lst

# Limpiar los archivos para sólo dejar IPs
  sed -i "s/.* on //" "$vCarpetaDondeGuardar"/"$vDirSubredText"-ssh.lst


nmap -Pn -oA results -p445 --script smb-vuln-ms2017-010 -iL xxx.xxx.xxx.0-smb.lst
# Escanear servicios que realmente sean vulnerables
  nmap -sV --script vuln --script-args vulns.narrow=1 192.168.10.109
  nmap -p- --script vuln --script-args vulns.showall -oN salida.txt 192.168.10.109

# Grepear sólo los vulnerables
grep -B 7 VULNERABLE: results-*.nmap > temp.txt 

If you happen to be running the latest version from Github or SVN, you can add --script-args vulns.short to get a single-line output containing target IP, vulnerability status, and CVE for easy grepping 
