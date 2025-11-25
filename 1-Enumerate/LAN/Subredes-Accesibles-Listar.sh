#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para listar las posibles subredes accesibles desde la subred en la que se ejecuta el script
#
# Ejecución remota con parámetros:
#   curl -sL https://raw.githubusercontent.com/nipegun/pt-scripts/refs/heads/main/1-Enumerate/LAN/Subredes-Accesibles-Listar.sh | sudo bash -s -- -depth 1
#   curl -sL https://raw.githubusercontent.com/nipegun/pt-scripts/refs/heads/main/1-Enumerate/LAN/Subredes-Accesibles-Listar.sh | sudo bash -s -- -depth 3 -quiet
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/1-Enumerate/Docker-Servicios-ALaEscucha-Listar.sh | nano -
# ----------

set -euo pipefail

vSalidaPantalla=1
vArchivoSalida=""
vTmpDir="/tmp/netdisc_$$"
vModoAgresivo=0
vModoQuiet=0
vProfundidad=1  # 1=básico, 2=medio, 3=completo, 4=paranoid
vMaxJobs=1      # Número de procesos paralelos

declare -a aRangosPrivados=(
  "10.0.0.0/8"
  "172.16.0.0/12"
  "192.168.0.0/16"
)

# ============================================================================
# FUNCIONES GENERALES
# ============================================================================

function fDetectarCores() {
  local vCores=1

  if [ -f /proc/cpuinfo ]; then
    vCores=$(
      {
        grep -E "^physical id|^core id" /proc/cpuinfo | \
        sort -u | \
        grep "core id" | \
        wc -l
      } 2>/dev/null || echo 0
    )

    if [ "$vCores" -eq 0 ]; then
      if type lscpu &>/dev/null; then
        vCores=$(
          {
            lscpu -p | grep -v '^#' | sort -u -t, -k 2,4 | wc -l
          } 2>/dev/null || echo 0
        )
      fi
    fi

    if [ "$vCores" -eq 0 ]; then
      vCores=1
    fi
  fi

  vMaxJobs=$((vCores * 3 / 4))
  [ "$vMaxJobs" -lt 1 ] && vMaxJobs=1

  fLogInfo "Cores físicos detectados: $vCores (usando $vMaxJobs procesos paralelos)"
}

function fWaitJobs() {
  local vRunning
  while true; do
    vRunning=$( { jobs -r 2>/dev/null | wc -l; } 2>/dev/null || echo 0 )
    if [ "$vRunning" -lt "$vMaxJobs" ]; then
      break
    fi
    sleep 0.1
  done
}

function fLimpiar() {
  [ -d "$vTmpDir" ] && rm -rf "$vTmpDir"
}

trap fLimpiar EXIT

function fLogInfo() {
  [ "$vModoQuiet" -eq 0 ] && echo "$@" >&2
  return 0
}

function fMostrarAyuda() {
  cat << EOF
Uso: $0 [-file <archivo>] [-depth <1-4>] [-quiet] [-h]

Opciones:
  -file <archivo>  Guardar salida en archivo
  -depth <nivel>   Profundidad de escaneo (1=básico, 2=medio, 3=completo, 4=paranoid)
  -quiet           Modo silencioso (solo muestra SubRed1, SubRed2, etc.)
  -h, --help       Mostrar ayuda

Técnicas de descubrimiento por nivel:
  Nivel 1 (Básico):
    - Interfaces y rutas locales
    - Caché ARP
    - Conexiones establecidas
    - DNS/hosts
    
  Nivel 2 (Medio):
    + Traceroute
    + Escaneo de vecinos (±2 subredes)
    + Análisis de gateways
    
  Nivel 3 (Completo):
    + Escaneo exhaustivo de patrones comunes
    + SNMP discovery (community public)
    + Broadcast/multicast analysis
    
  Nivel 4 (Paranoid):
    + ARP-scan activo en todas las redes candidatas
    + Escaneo completo de terceros octetos (0-255)
    + Detección de múltiples CIDRs (/16, /20, /22, /24)
    + Port scanning de servicios de gestión
    + Fingerprinting de dispositivos de red
EOF
  exit 0
}

function fVerificarRoot() {
  if [ "$EUID" -ne 0 ]; then
    fLogInfo "[!] Advertencia: No eres root. Algunas técnicas serán limitadas."
    fLogInfo "    Ejecuta con sudo para mejor detección."
  fi
}

function fIpAEntero() {
  local vIp="$1"
  IFS=. read -r vA vB vC vD <<< "$vIp"
  echo $(( (vA<<24) + (vB<<16) + (vC<<8) + vD ))
}

function fIpARed24() {
  local vIp="$1"
  echo "$vIp" | awk -F. '{print $1"."$2"."$3".0/24"}'
}

function fIpARedVariable() {
  local vIp="$1"
  local vCidr="${2:-24}"

  IFS=. read -r vO1 vO2 vO3 vO4 <<< "$vIp"
  local vIpInt=$(( (vO1<<24) + (vO2<<16) + (vO3<<8) + vO4 ))
  local vMascara=$(( 0xFFFFFFFF << (32 - vCidr) ))
  local vRedInt=$(( vIpInt & vMascara ))

  local vR1=$(( (vRedInt >> 24) & 0xFF ))
  local vR2=$(( (vRedInt >> 16) & 0xFF ))
  local vR3=$(( (vRedInt >> 8) & 0xFF ))
  local vR4=$(( vRedInt & 0xFF ))

  echo "${vR1}.${vR2}.${vR3}.${vR4}/${vCidr}"
}

function fEsPrivada() {
  local vIp="$1"
  [[ "$vIp" =~ ^10\. ]] && return 0
  [[ "$vIp" =~ ^172\.(1[6-9]|2[0-9]|3[0-1])\. ]] && return 0
  [[ "$vIp" =~ ^192\.168\. ]] && return 0
  return 1
}

# ============================================================================
# NIVEL 1: TÉCNICAS BÁSICAS (SIEMPRE ACTIVAS)
# ============================================================================

function fObtenerRedesLocales() {
  fLogInfo "  [1] Obteniendo redes configuradas localmente..."

  > "$vTmpDir/locales.txt"

  {
    ip -4 -o addr show 2>/dev/null | awk '{print $4}' | grep -v '^127\.' | while read -r vRed; do
      if fEsPrivada "${vRed%%/*}"; then
        echo "IFACE|$vRed"
      fi
    done
  } >> "$vTmpDir/locales.txt" 2>/dev/null || true

  {
    ip -4 route show 2>/dev/null | awk '{print $1}' | grep -v '^default' | grep -v '^127\.' | while read -r vRed; do
      if fEsPrivada "${vRed%%/*}"; then
        echo "ROUTE|$vRed"
      fi
    done
  } >> "$vTmpDir/locales.txt" 2>/dev/null || true

  local vCount
  vCount=$(wc -l < "$vTmpDir/locales.txt")
  fLogInfo "      → Encontradas: $vCount redes"
}

function fAnalizarArpCache() {
  fLogInfo "  [2] Analizando caché ARP..."

  > "$vTmpDir/arp_redes.txt"

  if type ip &>/dev/null; then
    {
      ip neigh show 2>/dev/null | awk '{print $1}' | while read -r vIp; do
        if fEsPrivada "$vIp"; then
          local vRed
          vRed=$(fIpARed24 "$vIp")
          echo "ARP|$vRed"
        fi
      done
    } >> "$vTmpDir/arp_redes.txt" 2>/dev/null || true
  fi

  if type arp &>/dev/null; then
    {
      arp -a 2>/dev/null | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | while read -r vIp; do
        if fEsPrivada "$vIp"; then
          local vRed
          vRed=$(fIpARed24 "$vIp")
          echo "ARP|$vRed"
        fi
      done
    } >> "$vTmpDir/arp_redes.txt" 2>/dev/null || true
  fi

  local vCount
  vCount=$(cut -d'|' -f2 "$vTmpDir/arp_redes.txt" 2>/dev/null | sort -u | wc -l)
  fLogInfo "      → Encontradas: $vCount redes desde ARP"
}

function fAnalizarConexionesActivas() {
  fLogInfo "  [3] Analizando conexiones establecidas..."

  > "$vTmpDir/conexiones_redes.txt"

  if type ss &>/dev/null; then
    {
      ss -tunap 2>/dev/null | grep ESTAB | awk '{print $5}' | cut -d: -f1 | while read -r vIp; do
        if fEsPrivada "$vIp"; then
          local vRed
          vRed=$(fIpARed24 "$vIp")
          echo "CONN|$vRed"
        fi
      done
    } >> "$vTmpDir/conexiones_redes.txt" 2>/dev/null || true
  fi

  if type netstat &>/dev/null; then
    {
      netstat -tunap 2>/dev/null | grep ESTABLISHED | awk '{print $5}' | cut -d: -f1 | while read -r vIp; do
        if fEsPrivada "$vIp"; then
          local vRed
          vRed=$(fIpARed24 "$vIp")
          echo "CONN|$vRed"
        fi
      done
    } >> "$vTmpDir/conexiones_redes.txt" 2>/dev/null || true
  fi

  local vCount
  vCount=$(cut -d'|' -f2 "$vTmpDir/conexiones_redes.txt" 2>/dev/null | sort -u | wc -l)
  fLogInfo "      → Encontradas: $vCount redes desde conexiones"
}

function fAnalizarDns() {
  fLogInfo "  [4] Analizando configuración DNS/hosts..."

  > "$vTmpDir/dns_redes.txt"

  if [ -f /etc/hosts ]; then
    {
      grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' /etc/hosts 2>/dev/null | while read -r vIp; do
        if fEsPrivada "$vIp"; then
          local vRed
          vRed=$(fIpARed24 "$vIp")
          echo "HOSTS|$vRed"
        fi
      done
    } >> "$vTmpDir/dns_redes.txt" 2>/dev/null || true
  fi

  if [ -f /etc/resolv.conf ]; then
    {
      grep nameserver /etc/resolv.conf 2>/dev/null | awk '{print $2}' | while read -r vIp; do
        if fEsPrivada "$vIp"; then
          local vRed
          vRed=$(fIpARed24 "$vIp")
          echo "DNS|$vRed"
        fi
      done
    } >> "$vTmpDir/dns_redes.txt" 2>/dev/null || true
  fi

  local vCount
  vCount=$(cut -d'|' -f2 "$vTmpDir/dns_redes.txt" 2>/dev/null | sort -u | wc -l)
  fLogInfo "      → Encontradas: $vCount redes desde DNS/hosts"
}

# ============================================================================
# NIVEL 2: TÉCNICAS MEDIAS
# ============================================================================

function fAnalizarTraceroute() {
  fLogInfo "  [5] Analizando rutas con traceroute..."

  > "$vTmpDir/trace_redes.txt"

  if ! type traceroute &>/dev/null; then
    fLogInfo "      → traceroute no disponible, omitiendo"
    return
  fi

  local -a aDestinos=("8.8.8.8" "1.1.1.1")

  for vDest in "${aDestinos[@]}"; do
    fLogInfo "      Trazando ruta a $vDest..."
    {
      traceroute -n -m 10 -w 1 "$vDest" 2>/dev/null | \
        grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | while read -r vIp; do
          if fEsPrivada "$vIp"; then
            local vRed
            vRed=$(fIpARed24 "$vIp")
            echo "TRACE|$vRed"
          fi
        done
    } >> "$vTmpDir/trace_redes.txt" 2>/dev/null || true
  done

  local vCount
  vCount=$(cut -d'|' -f2 "$vTmpDir/trace_redes.txt" 2>/dev/null | sort -u | wc -l)
  fLogInfo "      → Encontradas: $vCount redes desde traceroute"
}

function fEscanearGateways() {
  fLogInfo "  [6] Detectando gateways y routers..."

  > "$vTmpDir/gateways_redes.txt"

  local vDefaultGw
  vDefaultGw=$(ip route 2>/dev/null | awk '/default/ {print $3}' | head -1)

  if [ -n "$vDefaultGw" ]; then
    fLogInfo "      Gateway predeterminado: $vDefaultGw"

    if fEsPrivada "$vDefaultGw"; then
      local vRed
      vRed=$(fIpARed24 "$vDefaultGw")
      echo "GATEWAY|$vRed" >> "$vTmpDir/gateways_redes.txt"
    fi

    IFS=. read -r vO1 vO2 vO3 vO4 <<< "$vDefaultGw"

    for vGwCandidate in 1 254 100 200; do
      if [ "$vGwCandidate" != "$vO4" ]; then
        local vTestGw="${vO1}.${vO2}.${vO3}.${vGwCandidate}"
        if timeout 0.5 ping -c 1 -W 1 "$vTestGw" &>/dev/null; then
          fLogInfo "      Encontrado router adicional: $vTestGw"
          local vRed2
          vRed2=$(fIpARed24 "$vTestGw")
          echo "GATEWAY|$vRed2" >> "$vTmpDir/gateways_redes.txt"
        fi
      fi
    done
  fi

  local vCount
  vCount=$(cut -d'|' -f2 "$vTmpDir/gateways_redes.txt" 2>/dev/null | sort -u | wc -l)
  fLogInfo "      → Encontradas: $vCount redes desde gateways"
}

function fEscaneoVecinos() {
  fLogInfo "  [7] Escaneando vecinos de redes conocidas (paralelo)..."

  > "$vTmpDir/vecinos_redes.txt"

  {
    cat "$vTmpDir"/*.txt 2>/dev/null | \
      cut -d'|' -f2 | \
      grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | \
      sort -u
  } > "$vTmpDir/ips_conocidas.txt" 2>/dev/null || true

  while read -r vIp; do
    [ -z "$vIp" ] && continue
    if ! fEsPrivada "$vIp"; then
      continue
    fi

    IFS=. read -r vO1 vO2 vO3 vO4 <<< "$vIp"

    for vOffset in -2 -1 0 1 2; do
      fWaitJobs
      (
        local vNuevoO3=$((vO3 + vOffset))
        if [ "$vNuevoO3" -ge 0 ] && [ "$vNuevoO3" -le 255 ]; then
          local vTestIp="${vO1}.${vO2}.${vNuevoO3}.1"
          if timeout 0.3 ping -c 1 -W 1 "$vTestIp" &>/dev/null; then
            echo "PING|${vO1}.${vO2}.${vNuevoO3}.0/24" >> "$vTmpDir/vecinos_redes.txt"
          fi
        fi
      ) &
    done
  done < "$vTmpDir/ips_conocidas.txt"

  wait

  local vCount
  vCount=$(cut -d'|' -f2 "$vTmpDir/vecinos_redes.txt" 2>/dev/null | sort -u | wc -l)
  fLogInfo "      → Encontradas: $vCount redes vecinas accesibles"
}

# ============================================================================
# NIVEL 3: TÉCNICAS COMPLETAS
# ============================================================================

function fEscaneoPatronesExhaustivo() {
  fLogInfo "  [8] Escaneo exhaustivo basado en patrones (paralelo)..."

  > "$vTmpDir/patrones_redes.txt"

  {
    cat "$vTmpDir"/*.txt 2>/dev/null | \
      cut -d'|' -f2 | \
      grep -oE '^([0-9]{1,3}\.){2}' | \
      sort -u
  } > "$vTmpDir/patrones.txt" 2>/dev/null || true

  local vCount=0

  while read -r vPatron; do
    [ -z "$vPatron" ] && continue
    for vZ in 0 1 5 10 20 50 100 200; do
      fWaitJobs
      (
        local vTestIp="${vPatron}${vZ}.1"
        if timeout 0.3 ping -c 1 -W 1 "$vTestIp" &>/dev/null; then
          echo "SCAN|${vPatron}${vZ}.0/24" >> "$vTmpDir/patrones_redes.txt"
          fLogInfo "      Encontrada: ${vPatron}${vZ}.0/24"
        fi
      ) &
    done
  done < "$vTmpDir/patrones.txt"

  wait

  vCount=$(cut -d'|' -f2 "$vTmpDir/patrones_redes.txt" 2>/dev/null | sort -u | wc -l)
  fLogInfo "      → Encontradas: $vCount redes por patrones"
}

function fDeteccionSnmp() {
  fLogInfo "  [9] Intentando descubrimiento SNMP..."

  > "$vTmpDir/snmp_redes.txt"

  if ! type snmpwalk &>/dev/null; then
    fLogInfo "      → snmpwalk no disponible, omitiendo"
    return
  fi

  {
    cat "$vTmpDir"/*.txt 2>/dev/null | \
      cut -d'|' -f2 | \
      grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | \
      grep -E '\.(1|254)$' | \
      sort -u
  } > "$vTmpDir/posibles_routers.txt" 2>/dev/null || true

  local -a aCommunities=("public" "private" "community")

  while read -r vRouterIp; do
    [ -z "$vRouterIp" ] && continue
    for vCommunity in "${aCommunities[@]}"; do
      local vResultado
      vResultado=$(timeout 2 snmpwalk -v2c -c "$vCommunity" "$vRouterIp" ipRouteTable 2>/dev/null || true)
      if [ -n "$vResultado" ]; then
        fLogInfo "      SNMP exitoso en $vRouterIp (community: $vCommunity)"
        {
          echo "$vResultado" | \
            grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | \
            while read -r vIp; do
              if fEsPrivada "$vIp"; then
                local vRed
                vRed=$(fIpARed24 "$vIp")
                echo "SNMP|$vRed" >> "$vTmpDir/snmp_redes.txt"
              fi
            done
        } 2>/dev/null || true
        break
      fi
    done
  done < "$vTmpDir/posibles_routers.txt"

  local vCount
  vCount=$(cut -d'|' -f2 "$vTmpDir/snmp_redes.txt" 2>/dev/null | sort -u | wc -l)
  fLogInfo "      → Encontradas: $vCount redes via SNMP"
}

function fAnalisisBroadcast() {
  fLogInfo "  [10] Analizando broadcast/multicast..."

  > "$vTmpDir/broadcast_redes.txt"

  if [ "$EUID" -ne 0 ]; then
    fLogInfo "      → Requiere root, omitiendo"
    return
  fi

  {
    ip -o link show 2>/dev/null | \
      awk -F': ' '{print $2}' | \
      grep -v '^lo$'
  } > "$vTmpDir/interfaces.txt" 2>/dev/null || true

  while read -r vIface; do
    [ -z "$vIface" ] && continue
    if type tcpdump &>/dev/null; then
      fLogInfo "      Analizando tráfico en $vIface..."
      {
        timeout 2 tcpdump -i "$vIface" -n broadcast 2>/dev/null | \
          grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | \
          while read -r vIp; do
            if fEsPrivada "$vIp"; then
              local vRed
              vRed=$(fIpARed24 "$vIp")
              echo "BCAST|$vRed" >> "$vTmpDir/broadcast_redes.txt"
            fi
          done
      } 2>/dev/null || true
    fi
  done < "$vTmpDir/interfaces.txt"

  local vCount
  vCount=$(cut -d'|' -f2 "$vTmpDir/broadcast_redes.txt" 2>/dev/null | sort -u | wc -l)
  fLogInfo "      → Encontradas: $vCount redes via broadcast"
}

# ============================================================================
# NIVEL 4: TÉCNICAS PARANOID (EXHAUSTIVAS)
# ============================================================================

function fArpscanActivo() {
  fLogInfo "  [11] ARP-scan activo en redes candidatas..."

  > "$vTmpDir/arpscan_redes.txt"

  if ! type arp-scan &>/dev/null; then
    fLogInfo "      → arp-scan no disponible, omitiendo"
    return
  fi

  if [ "$EUID" -ne 0 ]; then
    fLogInfo "      → Requiere root, omitiendo"
    return
  fi

  {
    cat "$vTmpDir"/*.txt 2>/dev/null | \
      cut -d'|' -f2 | \
      grep -E '/24$' | \
      sort -u
  } > "$vTmpDir/candidatas_arpscan.txt" 2>/dev/null || true

  {
    ip -o link show 2>/dev/null | \
      awk -F': ' '{print $2}' | \
      grep -v '^lo$'
  } > "$vTmpDir/ifaces_arpscan.txt" 2>/dev/null || true

  local vCount=0

  while read -r vRed; do
    [ -z "$vRed" ] && continue
    while read -r vIface; do
      [ -z "$vIface" ] && continue
      fLogInfo "      Escaneando $vRed en $vIface..."
      if timeout 5 arp-scan --interface="$vIface" "$vRed" 2>/dev/null | grep -q ':'; then
        echo "ARPSCAN|$vRed" >> "$vTmpDir/arpscan_redes.txt"
        vCount=$((vCount + 1))
        break
      fi
    done < "$vTmpDir/ifaces_arpscan.txt"
  done < "$vTmpDir/candidatas_arpscan.txt"

  fLogInfo "      → Confirmadas: $vCount redes via ARP-scan"
}

function fEscaneoCompletoOctetos() {
  fLogInfo "  [12] Escaneo completo de terceros octetos (paralelo)..."

  > "$vTmpDir/octetos_redes.txt"

  {
    cat "$vTmpDir"/*.txt 2>/dev/null | \
      cut -d'|' -f2 | \
      grep -oE '^([0-9]{1,3}\.){2}' | \
      sort -u
  } > "$vTmpDir/patrones_completos.txt" 2>/dev/null || true

  local vTotalPatrones
  vTotalPatrones=$(wc -l < "$vTmpDir/patrones_completos.txt" 2>/dev/null || echo 0)
  fLogInfo "      Analizando $vTotalPatrones patrones..."

  while read -r vPatron; do
    [ -z "$vPatron" ] && continue
    fLogInfo "      Escaneando rango ${vPatron}0-255.0/24..."
    for vZ in {0..255}; do
      fWaitJobs
      (
        local vTestIp="${vPatron}${vZ}.1"
        if timeout 0.2 ping -c 1 -W 1 "$vTestIp" &>/dev/null; then
          echo "OCTFULL|${vPatron}${vZ}.0/24" >> "$vTmpDir/octetos_redes.txt"
          fLogInfo "        → Encontrada: ${vPatron}${vZ}.0/24"
        fi
      ) &
    done
    wait
  done < "$vTmpDir/patrones_completos.txt"

  local vCount
  vCount=$(cut -d'|' -f2 "$vTmpDir/octetos_redes.txt" 2>/dev/null | sort -u | wc -l)
  fLogInfo "      → Encontradas: $vCount redes por escaneo completo"
}

function fDeteccionMulticidr() {
  fLogInfo "  [13] Detectando redes con CIDRs variables (/16, /20, /22)..."

  > "$vTmpDir/multicidr_redes.txt"

  {
    cat "$vTmpDir"/*.txt 2>/dev/null | \
      cut -d'|' -f2 | \
      grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' | \
      sort -u
  } > "$vTmpDir/ips_multicidr.txt" 2>/dev/null || true

  local vCount=0
  while read -r vIp; do
    [ -z "$vIp" ] && continue
    if ! fEsPrivada "$vIp"; then
      continue
    fi

    for vCidr in 22 20 16; do
      local vRed
      vRed=$(fIpARedVariable "$vIp" "$vCidr")
      local vRedBase
      vRedBase=$(echo "$vRed" | cut -d/ -f1)

      IFS=. read -r vO1 vO2 vO3 vO4 <<< "$vRedBase"

      local -a aTestHosts=(
        "$vO1.$vO2.0.1"
        "$vO1.$vO2.1.1"
        "$vO1.$vO2.10.1"
      )

      local vHostsAlcanzables=0
      for vTestHost in "${aTestHosts[@]}"; do
        if timeout 0.3 ping -c 1 -W 1 "$vTestHost" &>/dev/null; then
          vHostsAlcanzables=$((vHostsAlcanzables + 1))
        fi
      done

      if [ "$vHostsAlcanzables" -ge 2 ]; then
        echo "CIDR|$vRed" >> "$vTmpDir/multicidr_redes.txt"
        vCount=$((vCount + 1))
        fLogInfo "      → Detectada red más amplia: $vRed"
      fi
    done
  done < "$vTmpDir/ips_multicidr.txt"

  fLogInfo "      → Encontradas: $vCount redes con CIDR variable"
}

function fPortScanGateways() {
  fLogInfo "  [14] Escaneando puertos de gestión en gateways (paralelo)..."

  > "$vTmpDir/portscan_redes.txt"

  if ! type nc &>/dev/null && ! type nmap &>/dev/null; then
    fLogInfo "      → nc/nmap no disponibles, omitiendo"
    return
  fi

  {
    cat "$vTmpDir"/*.txt 2>/dev/null | \
      cut -d'|' -f2 | \
      grep -oE '([0-9]{1,3}\.){3}' | \
      sort -u
  } > "$vTmpDir/redes_base.txt" 2>/dev/null || true


  local -a aPuertosGestion=(22 23 80 443 8080 8443)

  # Sufijos típicos de equipos de gestión de los diferentes routers del mercado
  local -a aGwSuffixes=(1 2 20 99 100 138 227 254)

  while read -r vRedBase; do
    [ -z "$vRedBase" ] && continue
    for vGwSuffix in "${aGwSuffixes[@]}"; do
      fWaitJobs
      (
        local vGw="${vRedBase}${vGwSuffix}"

        if ! fEsPrivada "$vGw"; then
          exit 0
        fi

        local vPuertosAbiertos=0

        for vPuerto in "${aPuertosGestion[@]}"; do
          if type nc &>/dev/null; then
            if timeout 1 nc -z -w 1 "$vGw" "$vPuerto" 2>/dev/null; then
              vPuertosAbiertos=$((vPuertosAbiertos + 1))
            fi
          fi
        done

        if [ "$vPuertosAbiertos" -gt 0 ]; then
          local vRed
          vRed=$(fIpARed24 "$vGw")
          echo "PORTSCAN|$vRed" >> "$vTmpDir/portscan_redes.txt"
          fLogInfo "      → Dispositivo de red en $vGw (${vPuertosAbiertos} puertos abiertos)"
        fi
      ) &
    done
  done < "$vTmpDir/redes_base.txt"

  wait

  local vCount
  vCount=$(cut -d'|' -f2 "$vTmpDir/portscan_redes.txt" 2>/dev/null | sort -u | wc -l)
  fLogInfo "      → Encontradas: $vCount redes via port scan"
}

function fFingerprintDispositivos() {
  fLogInfo "  [15] Fingerprinting de dispositivos de red..."

  > "$vTmpDir/fingerprint_redes.txt"

  {
    cat "$vTmpDir"/*.txt 2>/dev/null | \
      cut -d'|' -f2 | \
      grep -oE '([0-9]{1,3}\.){3}' | \
      sort -u
  } > "$vTmpDir/dispositivos_base.txt" 2>/dev/null || true

  local vCount=0
  while read -r vRedBase; do
    [ -z "$vRedBase" ] && continue
    for vDevSuffix in 1 254; do
      local vDevice="${vRedBase}${vDevSuffix}"

      if ! fEsPrivada "$vDevice"; then
        continue
      fi

      local vTtl
      vTtl=$(ping -c 1 -W 1 "$vDevice" 2>/dev/null | grep -oP 'ttl=\K\d+' || true)

      if [ -n "$vTtl" ]; then
        if [ "$vTtl" -ge 250 ]; then
          fLogInfo "      → Posible dispositivo Cisco en $vDevice (TTL=$vTtl)"
          local vRed
          vRed=$(fIpARed24 "$vDevice")
          echo "FINGERPRINT|$vRed" >> "$vTmpDir/fingerprint_redes.txt"
          vCount=$((vCount + 1))
        elif [ "$vTtl" -ge 60 ] && [ "$vTtl" -le 65 ]; then
          fLogInfo "      → Posible dispositivo Linux/Unix en $vDevice (TTL=$vTtl)"
          local vRed2
          vRed2=$(fIpARed24 "$vDevice")
          echo "FINGERPRINT|$vRed2" >> "$vTmpDir/fingerprint_redes.txt"
          vCount=$((vCount + 1))
        fi
      fi
    done
  done < "$vTmpDir/dispositivos_base.txt"

  fLogInfo "      → Identificados: $vCount dispositivos de red"
}

# ============================================================================
# CONSOLIDACIÓN Y SALIDA
# ============================================================================

function fConsolidarResultados() {
  fLogInfo ""
  fLogInfo "  [*] Consolidando resultados..."

  {
    cat "$vTmpDir"/*.txt 2>/dev/null | grep '|' 2>/dev/null
  } > "$vTmpDir/raw.txt" || true

  > "$vTmpDir/procesado.txt"
  while IFS='|' read -r vFuente vRed; do
    [ -z "$vRed" ] && continue
    if [[ "$vRed" =~ / ]]; then
      local vIpParte
      local vCidr
      vIpParte=$(echo "$vRed" | cut -d/ -f1)
      vCidr=$(echo "$vRed" | cut -d/ -f2)

      if [[ "$vIpParte" =~ \.0$ ]]; then
        echo "$vFuente|${vIpParte}/${vCidr}"
      fi
    else
      if [[ "$vRed" =~ \.0$ ]]; then
        echo "$vFuente|${vRed}/24"
      else
        IFS=. read -r vO1 vO2 vO3 vO4 <<< "$vRed"
        echo "$vFuente|${vO1}.${vO2}.${vO3}.0/24"
      fi
    fi
  done < "$vTmpDir/raw.txt" > "$vTmpDir/procesado.txt"

  > "$vTmpDir/agrupado.txt"
  {
    cut -d'|' -f2 "$vTmpDir/procesado.txt" 2>/dev/null | sort -u
  } | while read -r vRed; do
    [ -z "$vRed" ] && continue
    local vFuentes
    vFuentes=$(
      grep "|$vRed" "$vTmpDir/procesado.txt" 2>/dev/null | \
        cut -d'|' -f1 | sort -u | tr '\n' ',' | sed 's/,$//' || true
    )
    echo "$vRed|$vFuentes"
  done > "$vTmpDir/agrupado.txt"

  if [ ! -s "$vTmpDir/agrupado.txt" ]; then
    fLogInfo "No se encontraron redes privadas accesibles."
    return 1
  fi

  if [ "$vSalidaPantalla" -eq 1 ] && [ "$vModoQuiet" -eq 0 ]; then
    echo
    echo "Redes privadas accesibles detectadas:"
    echo "====================================="
    echo
  fi

  while IFS='|' read -r vRed vFuentes; do
    local vFuentesLegibles
    vFuentesLegibles=$(echo "$vFuentes" | sed \
      -e 's/IFACE/Interfaz local/g' \
      -e 's/ROUTE/Tabla de rutas/g' \
      -e 's/ARP/Caché ARP/g' \
      -e 's/CONN/Conexión activa/g' \
      -e 's/TRACE/Traceroute/g' \
      -e 's/HOSTS/\/etc\/hosts/g' \
      -e 's/DNS/Servidor DNS/g' \
      -e 's/PING/Escaneo ping/g' \
      -e 's/GATEWAY/Gateway detectado/g' \
      -e 's/SCAN/Escaneo de patrones/g' \
      -e 's/SNMP/SNMP discovery/g' \
      -e 's/BCAST/Broadcast analysis/g' \
      -e 's/ARPSCAN/ARP-scan activo/g' \
      -e 's/OCTFULL/Escaneo completo octetos/g' \
      -e 's/CIDR/Red CIDR variable/g' \
      -e 's/PORTSCAN/Port scan gestión/g' \
      -e 's/FINGERPRINT/Device fingerprinting/g')

    if [ "$vSalidaPantalla" -eq 1 ] && [ "$vModoQuiet" -eq 0 ]; then
      echo "  $vRed"
      echo "    └─ Fuente(s): $vFuentesLegibles"
      echo
    elif [ "$vSalidaPantalla" -eq 0 ]; then
      echo "$vRed" >> "$vArchivoSalida"
    fi
  done < "$vTmpDir/agrupado.txt"

  local vTotal
  vTotal=$(wc -l < "$vTmpDir/agrupado.txt")
  if [ "$vModoQuiet" -eq 1 ]; then
    echo "Total: $vTotal redes únicas detectadas"
  else
    fLogInfo "Total: $vTotal redes únicas detectadas"
  fi

  [ "$vModoQuiet" -eq 0 ] && echo
  local vContador=1
  while IFS='|' read -r vRed vFuentes; do
    #echo "SubRed${vContador}: $vRed"
    echo "$vRed"
    vContador=$((vContador + 1))
  done < "$vTmpDir/agrupado.txt"
}

# ============================================================================
# MAIN
# ============================================================================

while [ "$#" -gt 0 ]; do
  case "$1" in
    -file)
      [ -z "${2:-}" ] && { echo "Error: -file requiere argumento" >&2; exit 1; }
      vSalidaPantalla=0
      vArchivoSalida="$2"
      : > "$vArchivoSalida"
      shift 2
      ;;
    -depth)
      [ -z "${2:-}" ] && { echo "Error: -depth requiere argumento" >&2; exit 1; }
      vProfundidad="$2"
      if ! [[ "$vProfundidad" =~ ^[1-4]$ ]]; then
        echo "Error: -depth debe ser 1, 2, 3 o 4" >&2
        exit 1
      fi
      shift 2
      ;;
    -quiet)
      vModoQuiet=1
      shift
      ;;
    -h|--help)
      fMostrarAyuda
      ;;
    *)
      echo "Error: Argumento desconocido: $1" >&2
      exit 1
      ;;
  esac
done

fVerificarRoot
mkdir -p "$vTmpDir"

fDetectarCores

fLogInfo "Iniciando descubrimiento de redes (Nivel $vProfundidad)..."
fLogInfo ""

# Nivel 1: Básico (siempre)
fObtenerRedesLocales
fAnalizarArpCache
fAnalizarConexionesActivas
fAnalizarDns

# Nivel 2: Medio
if [ "$vProfundidad" -ge 2 ]; then
  fAnalizarTraceroute
  fEscanearGateways
  fEscaneoVecinos
fi

# Nivel 3: Completo
if [ "$vProfundidad" -ge 3 ]; then
  fEscaneoPatronesExhaustivo
  fDeteccionSnmp
  fAnalisisBroadcast
fi

# Nivel 4: Paranoid
if [ "$vProfundidad" -ge 4 ]; then
  fArpscanActivo
  fEscaneoCompletoOctetos
  fDeteccionMulticidr
  fPortScanGateways
  fFingerprintDispositivos
fi

fConsolidarResultados
