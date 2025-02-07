# Preguntar al servidor raíz a.root-servers.net
  vRespServRaiz=$(dig @a.root-servers.net openwrt.org NS +norecurse | grep -P "IN\tA\t" | sort | head -n1 | sed -e 's-\t- -g' | cut -d' ' -f5)

# Preguntar al servidor del TLD .org a0.org.afilias-nst.info
  vRespServTLD=$(dig @$vIPServRaiz openwrt.org NS +norecurse | grep -P "IN\tA\t" | sort | head -n1 | sed -e 's-\t- -g' | cut -d' ' -f5)

# Preguntar al servidor autoritativo de openwrt.org	ns1.openwrt.org
  vRespServAuth=$(dig @$vIPServTLD openwrt.org A +norecurse | grep -P "IN\tA\t" | sort | head -n1 | sed -e 's-\t- -g' | cut -d' ' -f5)

echo $vRespServAuth
