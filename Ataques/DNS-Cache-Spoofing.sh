# Preguntar al servidor raíz
  vRespServRaiz=$(dig @a.root-servers.net openwrt.org NS +norecurse | grep -P "IN\tA\t" | sort | head -n1 | sed -e 's-\t- -g' | cut -d' ' -f5)
  echo "  El servidor raíz ha mandando a consultar a $vRespServRaiz."

# Preguntar al servidor TLD obtenido de la consulta anterior
  vRespServTLD=$(dig @$vRespServRaiz openwrt.org NS +norecurse | grep -P "IN\tNS\t" | sort | sed -e 's-\t- -g' | head -n1 | cut -d' ' -f6 | sed 's/.$//')
  echo "  El servidor TLD ha mandado a consultar a $vRespServTLD."

# Preguntar al servidor autoritativo obtenido en la consulta anterior
  vRespServAuth=$(dig @$vRespServTLD openwrt.org A +norecurse | grep -P "IN\tA\t" | sort | head -n1 | sed -e 's-\t- -g' | cut -d' ' -f6)
  echo "  El servidor autoritativo ha repondido que la IP de dominio es $vRespServAuth"
