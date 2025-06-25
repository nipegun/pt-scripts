#!/usr/bin/env python3
# Shebang que indica que el script debe ejecutarse con Python 3

import sys
import time
from pymodbus.client.sync import ModbusTcpClient as ModbusClient
from pymodbus.exceptions import ConnectionException

# Se obtiene la dirección IP del servidor Modbus desde el primer argumento de la línea de comandos
ip = sys.argv[1]

# Se crea un cliente Modbus TCP usando la IP proporcionada y el puerto estándar 502
client = ModbusClient(ip, port=502)

# Se intenta establecer la conexión con el servidor Modbus
client.connect()

# Bucle infinito para leer continuamente los registros Modbus
while True:
  # Se leen 16 registros 'holding' comenzando desde la dirección 1
  rr = client.read_holding_registers(1, 16)

  # Se imprime la lista de valores leídos desde los registros
  print(rr.registers)

  # Se espera 1 segundo antes de la siguiente lectura
  time.sleep(1)
