# Preguntar al servidor raíz a.root-servers.net
  dig @a.root-servers.net openwrt.org NS +norecurse
# Preguntar al servidor del TLD .org a0.org.afilias-nst.info
  dig @a0.org.afilias-nst.info openwrt.org NS +norecurse
# Preguntar al servidor autoritativo de openwrt.org	ns1.openwrt.org
  dig @ns1.openwrt.org openwrt.org A +norecurse
