# Preguntar al servidor raíz a.root-servers.net
  vRespServRaiz=$(dig @a.root-servers.net openwrt.org NS +norecurse | grep -P "IN\tA\t" | sort | head -n1 | sed -e 's-\t- -g' | cut -d' ' -f5)

# Preguntar al servidor del TLD .org a0.org.afilias-nst.info
  vRespServTLD=$(dig @$vRespServRaiz openwrt.org NS +norecurse | grep -P "IN\tNS\t" | sort | sed -e 's-\t- -g' | head -n1 | cut -d' ' -f6 | sed 's/.$//')

# Preguntar al servidor autoritativo de openwrt.org	ns1.openwrt.org
  vRespServAuth=$(dig @$vRespServTLD openwrt.org A +norecurse | grep -P "IN\tA\t" | sort | head -n1 | sed -e 's-\t- -g' | cut -d' ' -f6)

echo $vRespServAuth
