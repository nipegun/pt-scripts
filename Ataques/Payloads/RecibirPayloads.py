#!/usr/bin/env python3

import socket
import subprocess
import os
import time

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

def fIniciarEscucha():
  fLiberarPuerto(PORT)

  with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind((HOST, PORT))
    s.listen(5)
    print(f"[+] Escuchando en {HOST}:{PORT}...")

    while True:
      try:
        conn, addr = s.accept()
        with conn:
          print(f"[+] Conexión desde {addr[0]}:{addr[1]}")
          datos = []
          while True:
            data = conn.recv(4096)
            if not data:
              break
            datos.append(data)
          print(b"".join(datos).decode(errors="ignore"))
          print("[*] Conexión cerrada. Esperando nueva conexión...\n")
      except Exception as e:
        print(f"[!] Error durante la conexión: {e}")
        continue

if __name__ == "__main__":
  fIniciarEscucha()
