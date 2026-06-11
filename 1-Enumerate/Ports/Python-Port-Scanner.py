import socket
import sys
import time
from concurrent.futures import ThreadPoolExecutor
from threading import Lock

ip      = "192.168.30.5"
timeout = 0.5
lock    = Lock()

# ── Contadores compartidos ──────────────────────────────────────────────────
contador = {"tcp": 0, "udp": 0}
total    = 65535

# ── Barra de progreso ───────────────────────────────────────────────────────
def barra(actual, total, encontrados, proto, ancho=30):
    pct   = actual / total
    lleno = int(ancho * pct)
    bar   = "█" * lleno + "░" * (ancho - lleno)
    sys.stdout.write(
        f"\r  [{bar}] {pct*100:5.1f}%  puerto {actual:5d}/{total}"
        f"  encontrados: {encontrados}"
        f"  proto: {proto.upper()}   "
    )
    sys.stdout.flush()

# ── TCP ─────────────────────────────────────────────────────────────────────
def scan_tcp(p):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(timeout)
    resultado = None
    try:
        if s.connect_ex((ip, p)) == 0:
            try:
                s.send(b"HEAD / HTTP/1.0\r\n\r\n")
                banner = s.recv(1024).decode(errors="ignore").strip().splitlines()[0]
            except:
                banner = ""
            resultado = ("TCP", p, banner)
    finally:
        s.close()

    with lock:
        contador["tcp"] += 1
        if contador["tcp"] % 100 == 0 or resultado:
            barra(contador["tcp"], total, len(tcp_abiertos), "tcp")
        if resultado:
            tcp_abiertos.append(resultado)
            sys.stdout.write(
                f"\n  \033[92m[+] TCP {p:5d}  {resultado[2] or '(sin banner)'}\033[0m\n"
            )
            sys.stdout.flush()

    return resultado

# ── UDP ─────────────────────────────────────────────────────────────────────
def scan_udp(p):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.settimeout(timeout)
    resultado = None
    try:
        s.sendto(b"\x00", (ip, p))
        s.recv(1024)
        resultado = ("UDP", p, "open")
    except socket.timeout:
        resultado = ("UDP?", p, "open|filtered")
    except socket.error:
        pass
    finally:
        s.close()

    with lock:
        contador["udp"] += 1
        if contador["udp"] % 100 == 0 or (resultado and "open" in resultado[2]):
            barra(contador["udp"], total, len(udp_abiertos), "udp")
        if resultado and resultado[2] == "open":
            udp_abiertos.append(resultado)
            sys.stdout.write(
                f"\n  \033[93m[?] UDP {p:5d}  {resultado[2]}\033[0m\n"
            )
            sys.stdout.flush()

    return resultado

# ── MAIN ────────────────────────────────────────────────────────────────────
tcp_abiertos = []
udp_abiertos = []

print(f"\n\033[1m[*] Objetivo: {ip}\033[0m")

# TCP
print(f"\n\033[94m[*] Fase 1/2 — Escaneo TCP (65535 puertos)\033[0m")
t0 = time.time()
with ThreadPoolExecutor(max_workers=300) as ex:
    list(ex.map(scan_tcp, range(1, 65536)))
barra(total, total, len(tcp_abiertos), "tcp")
print(f"\n  Tiempo: {time.time()-t0:.1f}s")

# UDP
print(f"\n\033[94m[*] Fase 2/2 — Escaneo UDP (65535 puertos)\033[0m")
t0 = time.time()
with ThreadPoolExecutor(max_workers=200) as ex:
    list(ex.map(scan_udp, range(1, 65536)))
barra(total, total, len(udp_abiertos), "udp")
print(f"\n  Tiempo: {time.time()-t0:.1f}s")

# Resumen
print(f"\n\033[1m{'═'*50}")
print(f"  RESULTADOS FINALES — {ip}")
print(f"{'═'*50}\033[0m")

print(f"\n\033[92m[TCP] {len(tcp_abiertos)} puertos abiertos:\033[0m")
for _, p, banner in sorted(tcp_abiertos, key=lambda x: x[1]):
    print(f"  {p:5d}/tcp  {banner or '(sin banner)'}")

print(f"\n\033[93m[UDP] {len(udp_abiertos)} puertos abiertos:\033[0m")
for proto, p, estado in sorted(udp_abiertos, key=lambda x: x[1]):
    print(f"  {p:5d}/udp  {estado}")

print()
