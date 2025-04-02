#!/usr/bin/env python3

import socket

HOST = '0.0.0.0'
PORT = 4444

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
  s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
  s.bind((HOST, PORT))
  s.listen()
  print(f"[+] Escuchando en {HOST}:{PORT}...")

  while True:
    conn, addr = s.accept()
    with conn:
      print(f"[+] Conexión desde {addr[0]}:{addr[1]}")
      data = b''
      while True:
        chunk = conn.recv(4096)
        if not chunk:
          break
        data += chunk
      print(data.decode(errors='replace'))
      print("[*] Esperando próxima conexión...\n")

