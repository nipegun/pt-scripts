#!/usr/bin/env python3

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

#sudo apt-get -y install python3-scapy

# ----------
# Script de NiPeGun para instalar y configurar xxxxxxxxx en Debian
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Scan-Idle.py | python3
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Scan-Idle.py | sed 's-sudo--g' | bash
#
# Ejecución remota sin caché:
#   curl -sL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Scan-Idle.py | bash
#
# Ejecución remota con parámetros:
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Scan-Idle.py | bash -s Parámetro1 Parámetro2
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Scan-Idle.py | nano -
# ----------

# Uso: sudo ./idlescan.py 172.16.0.105 172.16.0.109 80

import argparse
from scapy.all import *

def idle_scan(zombie_ip, victim_ip, victim_port):
    # Paso 1: Sondear el IP ID inicial del zombie
    syn_ack = IP(dst=zombie_ip)/TCP(dport=80, flags="SA")
    response = sr1(syn_ack, timeout=2, verbose=0)
    initial_ipid = response.id if response else None

    if initial_ipid is None:
        print("[!] Fallo al obtener el IPID del zombie.")
        return

    print(f"[*] IPID inicial del zombie: {initial_ipid}")

    # Paso 2: Enviar paquete SYN suplantado al objetivo
    spoofed_syn = IP(src=zombie_ip, dst=victim_ip)/TCP(dport=victim_port, flags="S")
    send(spoofed_syn, verbose=0)

    # Paso 3: Sondear el IP ID final del zombie
    response = sr1(syn_ack, timeout=2, verbose=0)
    final_ipid = response.id if response else None

    if final_ipid is None:
        print("[!] Fallo al obtener el IPID final del zombie.")
        return

    print(f"[*] IPID final del zombie: {final_ipid}")

    # Paso 4: Analizar resultados
    ipid_difference = final_ipid - initial_ipid
    if ipid_difference == 1:
        print(f"[+] El puerto {victim_port} en {victim_ip} está CERRADO.")
    elif ipid_difference == 2:
        print(f"[+] El puerto {victim_port} en {victim_ip} está ABIERTO.")
    else:
        print("[!] Comportamiento inesperado o error en el host zombie.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Escaneo idle utilizando un host zombie.")
    parser.add_argument("zombie_ip", help="Dirección IP del host zombie")
    parser.add_argument("victim_ip", help="Dirección IP del objetivo")
    parser.add_argument("victim_port", type=int, help="Puerto a escanear en el objetivo")
    args = parser.parse_args()

    idle_scan(args.zombie_ip, args.victim_ip, args.victim_port)
