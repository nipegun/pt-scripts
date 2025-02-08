# 
  sudo apt -y install update
  sudo apt -y install python3-netfilterqueue
  sudo apt -y install libnetfilter-queue1
# 
  pip3 install nfqueue-bindings



# 
  sudo apt -y install python3-pip
  sudo apt -y install python3-dev
  sudo apt -y install build-essential
  sudo apt -y install libnetfilter-queue-dev
  sudo pip3 install --break-system-packages NetfilterQueue
  sudo pip3 install --break-system-packages scapy

# Comprobar
  python3 -c 'import netfilterqueue; print("¡Instalación exitosa!")'

# Crear el script
  echo '#!/usr/bin/env python3'                                                    > /root/modificar_ipid.py
  echo 'from netfilterqueue import NetfilterQueue'                                >> /root/modificar_ipid.py
  echo 'from scapy.all import IP'                                                 >> /root/modificar_ipid.py
  echo ''                                                                         >> /root/modificar_ipid.py
  echo 'def modify_packet(packet):'                                               >> /root/modificar_ipid.py
  echo '    scapy_packet = IP(packet.get_payload())'                              >> /root/modificar_ipid.py
  echo ''                                                                         >> /root/modificar_ipid.py
  echo '    if scapy_packet.haslayer(IP):'                                        >> /root/modificar_ipid.py
  echo '        scapy_packet.id += 1  # Incrementar el IP ID'                     >> /root/modificar_ipid.py
  echo '        del scapy_packet.chksum  # Recalcular el checksum IP'             >> /root/modificar_ipid.py
  echo ''                                                                         >> /root/modificar_ipid.py
  echo '        packet.set_payload(bytes(scapy_packet))  # Reemplazar el paquete' >> /root/modificar_ipid.py
  echo '    packet.accept()'                                                      >> /root/modificar_ipid.py
  echo ''                                                                         >> /root/modificar_ipid.py
  echo 'nfqueue = NetfilterQueue()'                                               >> /root/modificar_ipid.py
  echo 'nfqueue.bind(0, modify_packet)'                                           >> /root/modificar_ipid.py
  echo ''                                                                         >> /root/modificar_ipid.py
  echo 'try:'                                                                     >> /root/modificar_ipid.py
  echo '    print("[+] Modificando IP ID en los paquetes salientes...")'          >> /root/modificar_ipid.py
  echo '    nfqueue.run()'                                                        >> /root/modificar_ipid.py
  echo 'except KeyboardInterrupt:'                                                >> /root/modificar_ipid.py
  echo '    print("\n[-] Saliendo...")'                                           >> /root/modificar_ipid.py
  echo '    nfqueue.unbind()'                                                     >> /root/modificar_ipid.py
  chmod +x                                                                           /root/modificar_ipid.py

# Usarlo
  sudo nft add table inet myfilter
  sudo nft add chain inet myfilter output { type filter hook output priority 0 \; }
  sudo nft add rule inet myfilter output ip daddr 0.0.0.0/0 tcp dport 80 queue num 0



Para que nftables mantenga las reglas tras un reinicio:

sudo nft list ruleset > /etc/nftables.conf

Para eliminar la regla después de la prueba:

sudo nft delete table inet myfilter


🔴 Si tienes problemas...

    Error ModuleNotFoundError: No module named 'netfilterqueue'
        Verifica la instalación de NetfilterQueue con:

python3 -c "import netfilterqueue; print('Instalación correcta')"

Si falla, reinstala:

    pip3 install --break-system-packages NetfilterQueue

El script no cambia el IP ID

    Prueba en otro puerto, por ejemplo, el 443 (HTTPS):

    sudo nft add rule inet myfilter output ip daddr 0.0.0.0/0 tcp dport 443 queue num 0

Para capturar todo el tráfico TCP saliente:

    sudo nft add rule inet myfilter output ip daddr 0.0.0.0/0 tcp queue num 0



