#!/usr/bin/env python3

# Ejecución remota
#  curl -sL https://raw.githubusercontent.com/nipegun/pt-scripts/refs/heads/main/_/RunCommandAndLog.py | python3 - "nmap localhost -p-"
#
# Visualización posterior:
#  find logs/ -type f -print | sort | while read vArchivo; do cat "$vArchivo" && echo -e "\n";  done

import subprocess
import sys
import argparse
import datetime
import os

cLogDir = "logs"

def fGenerarNombreArchivo(vPrefijo):
  """
  Genera un nombre de archivo con el formato: y2007m12d03h23m17s15-prefijo.txt
  """
  vAhora = datetime.datetime.now()
  vTimestamp = vAhora.strftime("y%Ym%md%dh%Hm%Ms%S")
  return f"{vTimestamp}-{vPrefijo}.txt"

def fAsegurarseDirectorioLogs():
  try:
    os.makedirs(cLogDir, exist_ok=True)
  except Exception as e:
    print(f"[!] No se pudo crear '{cLogDir}': {e}")
    sys.exit(1)

def fRutaLog(vNombre):
  return os.path.join(cLogDir, vNombre)

def fGuardarSinLineasVacias(vRuta, vContenido):
  """
  Guarda el contenido en la ruta especificada eliminando las líneas vacías
  o compuestas solo por espacios.
  """
  vLineasFiltradas = []
  for vLinea in vContenido.splitlines():
    if vLinea.strip():  # descarta vacías o con solo espacios
      vLineasFiltradas.append(vLinea)
  with open(vRuta, 'w') as f:
    f.write("\n".join(vLineasFiltradas))

def fEjecutarComandoYGuardar(vComando, vVerbose=False):
  """
  Ejecuta un comando usando /bin/bash y guarda automáticamente el comando y su salida
  en la carpeta definida en cLogDir. Las notificaciones de archivos guardados solo se muestran si vVerbose=True.
  """
  fAsegurarseDirectorioLogs()
  vArchivoEntrada = fGenerarNombreArchivo("in")
  vArchivoSalida = fGenerarNombreArchivo("out")
  vRutaEntrada = fRutaLog(vArchivoEntrada)
  vRutaSalida = fRutaLog(vArchivoSalida)
  vProceso = None
  vOutput = ""

  try:
    # Guardar el comando en el archivo de entrada
    fGuardarSinLineasVacias(vRutaEntrada, vComando)

    if vVerbose:
      print(f"[INFO] Comando guardado en: {vRutaEntrada}")

    print(f"[INFO] Ejecutando con bash: {vComando}\n")
    print("-" * 50)

    # Ejecutar el comando usando /bin/bash explícitamente
    vProceso = subprocess.Popen(
      vComando,
      shell=True,
      executable="/bin/bash",
      stdout=subprocess.PIPE,
      stderr=subprocess.STDOUT,
      text=True
    )

    # Leer y mostrar la salida en tiempo real
    for vLinea in vProceso.stdout:
      print(vLinea, end='')
      vOutput += vLinea

    # Esperar a que termine el proceso
    vProceso.wait()

    # Guardar la salida en el archivo de salida, sin líneas vacías
    fGuardarSinLineasVacias(vRutaSalida, vOutput)

    if vVerbose:
      print("\n" + "-" * 50)
      print(f"[INFO] Salida guardada en: {vRutaSalida}")
      print(f"[INFO] Comando finalizado con código: {vProceso.returncode}")
    else:
      print(f"\n[ERROR] Comando finalizado con código: {vProceso.returncode}")

  except KeyboardInterrupt:
    print("\n[!] Ejecución interrumpida por el usuario")
    try:
      if vProceso and vProceso.poll() is None:
        vProceso.terminate()
        try:
          vProceso.wait(timeout=2)
        except subprocess.TimeoutExpired:
          vProceso.kill()
          vProceso.wait()
    except Exception:
      pass
    # Guardar lo que se haya ejecutado hasta ahora
    try:
      fGuardarSinLineasVacias(vRutaSalida, vOutput)
      if vVerbose:
        print(f"[+] Salida parcial guardada en: {vRutaSalida}")
    except Exception as e:
      if vVerbose:
        print(f"[!] No se pudo guardar la salida parcial: {e}")

  except Exception as e:
    print(f"[!] Error al ejecutar el comando: {e}")
    # Intentar guardar lo que haya en vOutput
    try:
      fGuardarSinLineasVacias(vRutaSalida, vOutput)
      if vVerbose:
        print(f"[+] Salida parcial guardada en: {vRutaSalida}")
    except Exception:
      pass

def fMain():
  vParser = argparse.ArgumentParser(
    description="Ejecutor automatizado de comandos con /bin/bash y logging automático",
    formatter_class=argparse.RawDescriptionHelpFormatter,
    epilog="""
Ejemplos de uso:
  python3 pentest_logger.py "nmap -sV 192.168.1.1"
  python3 pentest_logger.py -v "ping -c 4 google.com"
  python3 pentest_logger.py --verbose "whois example.com"
        """
  )

  vParser.add_argument(
    'comando',
    help='Comando a ejecutar (entre comillas si tiene espacios)'
  )

  vParser.add_argument(
    '-v', '--verbose',
    action='store_true',
    help='Modo verbose (muestra rutas de archivos guardados)'
  )

  if len(sys.argv) == 1:
    vParser.print_help()
    sys.exit(1)

  vArgs = vParser.parse_args()

  if vArgs.verbose:
    print(f"[DEBUG] Comando recibido: {vArgs.comando}")

  fEjecutarComandoYGuardar(vArgs.comando, vVerbose=vArgs.verbose)

if __name__ == "__main__":
  fMain()
