#!/usr/bin/env python3


# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para escanear un PLC usando python-snap7 v1
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/1-Reconnaissance/S7Comm/Snap7v1-ScanPLC.py | python3 - [IPDelPLC]
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/1-Reconnaissance/S7Comm/Snap7v1-ScanPLC.py | sed 's-sudo--g' | python3 - [IPDelPLC]
#
# Ejecución remota con parámetros:
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/1-Reconnaissance/S7Comm/Snap7v1-ScanPLC.py | python3 - [IPDelPLC]
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/1-Reconnaissance/S7Comm/Snap7v1-ScanPLC.py | nano -
# ----------


import sys
import subprocess

# ---- Variables de control de versión ----
vMinSnap7 = "1.4.1"
vExcSnap7 = "2.0.0"
# -----------------------------------------

# ---- Asegurar que 'packaging' está instalado ----
try:
  from packaging import version
except ImportError:
  print("\n[!] 'Paquete packaging' no encontrado. Instalando...\n")
  subprocess.check_call([sys.executable, "-m", "pip", "install", "packaging"])
  from packaging import version
# -----------------------------------------------

# ---- Asegurar que 'snap7' está instalado ----
try:
  import snap7
except ImportError:
  print(f"\n[!] 'Paquete python-snap7' no encontrado. Instalando versión mínima requerida ({vMinSnap7})...\n")
  subprocess.check_call([sys.executable, "-m", "pip", "install", f"python-snap7=={vMinSnap7}"])
  import snap7
# ---------------------------------------------

# ---- Verificar la versión instalada de snap7 ----
required_min = version.parse(vMinSnap7)
excluded_max = version.parse(vExcSnap7)
current_version = version.parse(snap7.__version__)

if not (required_min <= current_version < excluded_max):
  print(f"\n[-] Versión de snap7 no compatible: {snap7.__version__}")
  print(f"[!] Se requiere una versión >= {vMinSnap7} y < {vExcSnap7}")
  sys.exit(1)
# ------------------------------------------------

import argparse
import string
import re
from snap7.types import Areas

def extract_ascii_strings(data, min_len=4):
  pattern = f"[{re.escape(string.printable[:-5])}]{{{min_len},}}".encode()
  return re.findall(pattern, data)

def hexdump(data, width=16):
  for i in range(0, len(data), width):
    row = data[i:i+width]
    hex_part = " ".join(f"{b:02X}" for b in row)
    ascii_part = "".join(chr(b) if chr(b) in string.printable and b >= 32 else "." for b in row)
    print(f"  {i:04X}: {hex_part:<{width*3}} {ascii_part}")

def print_info(client):
  order_code = client.get_order_code()
  cpu_info = client.get_cpu_info()
  cp_info = client.get_cp_info()

  print(f"[+] Order Code: {order_code.OrderCode.decode()}")
  print(f"[+] CPU Type: {cpu_info.ModuleTypeName}")
  print(f"[+] Serial Number: {cpu_info.SerialNumber}")
  print(f"[+] AS Name: {cpu_info.ASName}")
  print(f"[+] Module Name: {cpu_info.ModuleName}")
  print(f"[+] Copyright: {cpu_info.Copyright}")

  try:
    protection = client.get_protection()
    print("[*] Protección:")
    for attr in dir(protection):
      if not attr.startswith('_'):
        print(f"    {attr}: {getattr(protection, attr)}")
  except Exception as e:
    print(f"[-] No se pudo obtener la protección: {e}")

  print(f"[+] Max PDU Length: {cp_info.MaxPduLength}")
  print(f"[+] Max Connections: {cp_info.MaxConnections}")

def try_read_area(client, area, area_name):
  try:
    data = client.read_area(area, 0, 0, 10)
    print(f"[+] Leído {area_name}: {data.hex()}")
  except Exception as e:
    print(f"[-] Error al leer {area_name}: {e}")

def scan_and_read_dbs(client, max_db=255, size=512):
  print(f"\n[*] Escaneando bloques de datos (DB0–DB{max_db}):")
  for db_num in range(max_db + 1):
    try:
      data = client.read_area(Areas.DB, db_num, 0, size)
      if any(b != 0x00 for b in data):
        print(f"[+] DB{db_num} encontrado. {size} bytes leídos:")
        hexdump(data)

        strings_found = extract_ascii_strings(data)
        if strings_found:
          print("[*] Cadenas encontradas:")
          for s in strings_found:
            print(f"    {s.decode(errors='ignore')}")
        else:
          print("[*] No se encontraron cadenas legibles.")
        print()
    except Exception as e:
      if b'Item not available' in str(e).encode():
        continue
      print(f"[-] DB{db_num}: {e}")

def main():
  parser = argparse.ArgumentParser(description="Escaneo de PLC Siemens usando python-snap7 v1.4.1 con extracción de cadenas")
  parser.add_argument("ip", help="IP del PLC")
  parser.add_argument("-r", "--rack", type=int, default=0, help="Rack del PLC (default=0)")
  parser.add_argument("-s", "--slot", type=int, default=2, help="Slot del PLC (default=2)")
  parser.add_argument("--max-db", type=int, default=255, help="Máximo número de DBs a escanear")
  parser.add_argument("--db-size", type=int, default=512, help="Tamaño en bytes a leer de cada DB")
  args = parser.parse_args()

  client = snap7.client.Client()
  try:
    print(f"[+] Conectando al PLC {args.ip} en rack {args.rack}, slot {args.slot}...")
    client.connect(args.ip, args.rack, args.slot)

    if not client.get_connected():
      print("[-] No se pudo conectar al PLC.")
      return

    print("[+] Conexión establecida.")
    print_info(client)

    print("\n[*] Leyendo áreas de memoria:")
    try_read_area(client, Areas.PE, "Entradas (PE)")
    try_read_area(client, Areas.PA, "Salidas (PA)")
    try_read_area(client, Areas.MK, "Merker (MK)")

    scan_and_read_dbs(client, args.max_db, args.db_size)

  except Exception as e:
    print(f"[-] Error de conexión: {e}")
  finally:
    client.disconnect()
    print("[*] Conexión cerrada.")

if __name__ == "__main__":
  main()
