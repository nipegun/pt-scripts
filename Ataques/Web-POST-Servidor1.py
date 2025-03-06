#!/usr/bin/env python3

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para interactuar con un PLC Siemens S7-1200, versión 1214c
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Web-POST-Servidor.py | python3
#
# Bajar y editar directamente el archivo en nano:
#   curl -sL https://raw.githubusercontent.com/nipegun/dh-scripts/refs/heads/main/Ataques/Web-POST-Servidor.py | nano -
# ----------

import http.server
import json

html_correcta = """
<!DOCTYPE html>
<html>
<head>
  <title>Página Correcta</title>
</head>
<body>
  <h1>Bienvenido, admin!</h1>
  <p>Acceso concedido.</p>
</body>
</html>
"""

class SimpleHTTPRequestHandler(http.server.BaseHTTPRequestHandler):
  def do_POST(self):
    content_length = int(self.headers.get('Content-Length', 0))
    post_data = self.rfile.read(content_length)
    try:
      data = json.loads(post_data.decode('utf-8'))
    except json.JSONDecodeError:
      self.send_response(400)
      self.send_header('Content-Type', 'application/json')
      self.end_headers()
      response = {"error": "JSON inválido"}
      self.wfile.write(json.dumps(response).encode('utf-8'))
      return

    if data.get("name") == "admin" and data.get("pass:") == "P@ssw0rd":
      self.send_response(200)
      self.send_header('Content-Type', 'text/html')
      self.end_headers()
      self.wfile.write(html_correcta.encode('utf-8'))
    else:
      self.send_response(401)
      self.send_header('Content-Type', 'application/json')
      self.end_headers()
      response = {"error": "Credenciales inválidas"}
      self.wfile.write(json.dumps(response).encode('utf-8'))

  def do_GET(self):
    self.send_response(400)
    self.send_header('Content-Type', 'application/json')
    self.end_headers()
    response = {"mensaje": "Utiliza el método POST para enviar las credenciales."}
    self.wfile.write(json.dumps(response).encode('utf-8'))

if __name__ == "__main__":
  server_address = ('', 5000)
  httpd = http.server.HTTPServer(server_address, SimpleHTTPRequestHandler)
  print("Servidor corriendo en http://localhost:5000/")
  httpd.serve_forever()
