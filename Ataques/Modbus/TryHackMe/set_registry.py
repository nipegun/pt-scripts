#!/usr/bin/env python3
# Shebang que indica que el script debe ejecutarse con Python 3

import sys
import time
from pymodbus.client.sync import ModbusTcpClient as ModbusClient
from pymodbus.exceptions import ConnectionException

# Se obtiene la IP del servidor Modbus desde el primer argumento de la línea de comandos
ip = sys.argv[1]

# Se obtiene el número de registro al que se quiere escribir, desde el segundo argumento
registry = int(sys.argv[2])

# Se obtiene el valor entero que se quiere escribir en ese registro, desde el tercer argumento
value = int(sys.argv[3])

# Se crea un cliente Modbus TCP usando la IP proporcionada y el puerto estándar 502
client = ModbusClient(ip, port=502)

# Se intenta establecer la conexión con el servidor Modbus
client.connect()

# Se escribe el valor especificado en el registro holding indicado
client.write_register(registry, value)
