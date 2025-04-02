#!/usr/bin/env python3

import socket
import subprocess
import os
import time
import sys

HOST = "0.0.0.0"
PORT = 4444

def fLiberarPuerto(port):
  try:
    resultado = subprocess.check_output(
      ["lsof", "-t", f"-i:{port}"]
    ).decode().split()
    for pid in resultado:
      print(f"[!] Cerrando proceso que usa el puerto {port}: PID {pid}")
      os.kill(int(pid), 9)
      time.sleep(0.2)
  except subprocess.CalledProcessError:
    pass
  except FileNotFoundError:
    print("[!] Error: 'lsof' no está instalado. No se pudo liberar el puerto.")

def fIniciarEscucha(logfile):
  fLiberarPuerto(PORT)

  with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind((HOST, PORT))
    s.listen(5)
    print(f"[+] Escuchando en {HOST}:{PORT}...\n")
    print(f"[+] Guardando logs en: {logfile}")

    while True:
      conn, addr = s.accept()
      print(f"[+] Conexión desde {addr[0]}:{addr[1]}")
      conn.settimeout(2)

      payload = b""
      try:
        while True:
          data = conn.recv(4096)
          if not data:
            break
          payload += data
      except socket.timeout:
        pass

      conn.close()

      if payload:
        texto = payload.decode(errors="ignore").replace("\n", "\\n").replace("\r", "")
        print(f"[>] Payload recibido: {texto}\n")
        with open(logfile, "a") as f:
          f.write(texto + "\n")
      else:
        print("[!] Conexión sin datos recibidos.\n")

if __name__ == "__main__":
  if len(sys.argv) != 2:
    print(f"Uso: {sys.argv[0]} archivo_de_log.txt")
    sys.exit(1)

  log_filename = sys.argv[1]
  fIniciarEscucha(log_filename)
