#!/usr/bin/env python3

import subprocess
import sys

target = "192.168.10.109"
port = "554"

# Rutas comunes para streams RTSP en dispositivos de videovigilancia
common_paths = [
  "/live.sdp",
  "/stream1",
  "/main",
  "/video",
  "/cam",
  "/h264",
  "/11",
  "/1",
  "/media.amp",
  "/media/video1",
  "/img/video.sav",
  "/mpeg4",
  "/mp4",
  "/live"
]

print(f"[+] Probando acceso RTSP no autenticado en {target}:{port}")

for path in common_paths:
  url = f"rtsp://{target}:{port}{path}"
  print(f"\n[*] Probando: {url}")

  # ffprobe prueba handshake RTSP real
  cmd = [
    "timeout", "5",
    "ffprobe",
    "-v", "error",
    "-show_streams",
    "-i", url
  ]

  try:
    result = subprocess.run(cmd, capture_output=True, text=True)

    # Si ffprobe pudo abrir el stream, stdout tendrá info de video/audio
    if result.returncode == 0 and result.stdout.strip():
      print(f"[+] POSIBLE ÉXITO: {url}")
      print(f"Info del stream:\n{result.stdout}")

      with open("/tmp/workspace/rtsp_success.txt", "a") as f:
        f.write(f"{url}\n")
    else:
      # ffprobe imprime errores en stderr
      if result.stderr.strip():
        print(f"[-] Sin acceso: {result.stderr.strip()[:200]}")

  except Exception as e:
    print(f"[-] Error probando {url}: {e}")

print("\n[+] Prueba completada. Revisar /tmp/workspace/rtsp_success.txt para URLs exitosas.")
